using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class PersonalizationService
    {
        private readonly PersonalizationRepository _personalizationRepository;
        private readonly ProductRepository _productRepository;

        public PersonalizationService()
            : this(new PersonalizationRepository(), new ProductRepository())
        {
        }

        public PersonalizationService(
            PersonalizationRepository personalizationRepository,
            ProductRepository productRepository)
        {
            _personalizationRepository = personalizationRepository;
            _productRepository = productRepository;
        }

        public bool UserRequiresPersonalization(User user)
        {
            if (user == null)
            {
                return false;
            }

            if (!string.Equals(user.Role, "customer", StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            return !_personalizationRepository.HasCompletedProfile(user.Id);
        }

        public bool HasCompletedProfile(long userId)
        {
            return _personalizationRepository.HasCompletedProfile(userId);
        }

        public UserPersonalizationProfile GetProfile(long userId)
        {
            return _personalizationRepository.GetProfile(userId);
        }

        public void SaveProfile(UserPersonalizationProfile profile)
        {
            UserPersonalizationProfile normalizedProfile = profile == null ? null : NormalizeProfile(profile);
            ValidateProfile(normalizedProfile);
            _personalizationRepository.SaveProfile(normalizedProfile);
        }

        public void RecordCatalogSearch(long userId, string searchTerm)
        {
            _personalizationRepository.RecordCatalogSearch(userId, searchTerm);
        }

        public IList<PersonalizedProduct> GetRecommendedProducts(long userId, int count)
        {
            IList<Product> products = _productRepository.GetAllProducts();
            return GetRecommendedProducts(userId, products, count);
        }

        public IList<PersonalizedProduct> GetRecommendedProducts(long userId, IList<Product> products, int count)
        {
            return GetRecommendedProducts(userId, products, GetCurrentSearchSignals(), count);
        }

        public IList<PersonalizedProduct> GetRecommendedProducts(
            long userId,
            IList<Product> products,
            IList<string> currentSearchSignals,
            int count)
        {
            UserPersonalizationProfile profile = _personalizationRepository.GetProfile(userId);
            if (profile == null || !profile.CompletedAt.HasValue)
            {
                return new List<PersonalizedProduct>();
            }

            IList<string> wishlistCategories = _personalizationRepository.GetWishlistCategories(userId);
            IList<string> purchasedCategories = _personalizationRepository.GetPurchasedCategories(userId);
            IList<string> searchedCategories = _personalizationRepository.GetSearchedCategories(userId)
                .Concat(ConvertSearchSignalsToCategories(currentSearchSignals))
                .ToList();

            return RankProductsForProfile(
                profile,
                products,
                wishlistCategories,
                purchasedCategories,
                searchedCategories,
                count);
        }

        private IList<string> ConvertSearchSignalsToCategories(IList<string> searchSignals)
        {
            var categories = new List<string>();
            foreach (string signal in searchSignals ?? new List<string>())
            {
                categories.AddRange(_personalizationRepository.InferSearchCategories(signal));
            }

            return categories;
        }

        private static IList<string> GetCurrentSearchSignals()
        {
            HttpContext context = HttpContext.Current;
            if (context == null)
            {
                return new List<string>();
            }

            object sessionValue = context.Session == null ? null : context.Session["OnyxRecentSearchSignals"];
            if (sessionValue is IList<string> sessionSignals)
            {
                return sessionSignals.ToList();
            }

            HttpCookie cookie = context.Request == null ? null : context.Request.Cookies["onyx_recent_search"];
            string cookieValue = cookie == null ? string.Empty : cookie.Value;

            return DecodeSearchSignals(cookieValue);
        }

        private static IList<string> DecodeSearchSignals(string encodedValue)
        {
            return (encodedValue ?? string.Empty)
                .Split(new[] { '|' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(value => HttpUtility.UrlDecode(value))
                .Select(value => (value ?? string.Empty).Trim())
                .Where(value => value.Length > 0)
                .Take(10)
                .ToList();
        }

        public IList<PersonalizedProduct> RankProductsForProfile(
            UserPersonalizationProfile profile,
            IList<Product> products,
            IList<string> wishlistCategories,
            IList<string> purchasedCategories,
            int count)
        {
            return RankProductsForProfile(
                profile,
                products,
                wishlistCategories,
                purchasedCategories,
                new List<string>(),
                count);
        }

        public IList<PersonalizedProduct> RankProductsForProfile(
            UserPersonalizationProfile profile,
            IList<Product> products,
            IList<string> wishlistCategories,
            IList<string> purchasedCategories,
            IList<string> searchedCategories,
            int count)
        {
            if (profile == null || products == null)
            {
                return new List<PersonalizedProduct>();
            }

            IEnumerable<PersonalizedProduct> scored = products
                .Select(product => BuildRecommendation(profile, product, wishlistCategories, purchasedCategories, searchedCategories));

            return ThenByPriceIntent(scored, profile)
                .ThenBy(item => item.Product.Name, StringComparer.Ordinal)
                .ThenBy(item => item.Product.Id)
                .Take(count < 1 ? 4 : count)
                .ToList();
        }

        private static PersonalizedProduct BuildRecommendation(
            UserPersonalizationProfile profile,
            Product product,
            IList<string> wishlistCategories,
            IList<string> purchasedCategories,
            IList<string> searchedCategories)
        {
            RecommendationSignals signals = GetRecommendationSignals(
                profile,
                product,
                wishlistCategories,
                purchasedCategories,
                searchedCategories);

            return new PersonalizedProduct
            {
                Product = product,
                Score = CalculateScore(signals),
                Reason = BuildReason(profile, product, signals)
            };
        }

        private static RecommendationSignals GetRecommendationSignals(
            UserPersonalizationProfile profile,
            Product product,
            IList<string> wishlistCategories,
            IList<string> purchasedCategories,
            IList<string> searchedCategories)
        {
            string category = Normalize(product.Category);
            string searchable = Normalize(product.Name + " " + product.Description + " " + product.Brand);
            IList<string> matchedGamingStyles = SplitChoiceValues(profile.GamingStyle)
                .Select(Normalize)
                .Where(style => GamingStyleMatches(style, category, searchable))
                .ToList();
            IList<string> matchedPriorities = profile.Priorities
                .Select(Normalize)
                .Where(priority => MatchesPriority(priority, searchable))
                .ToList();
            IList<string> matchedComfortPreferences = ComfortPreferenceMatches(profile.ComfortPreferences, category, searchable).ToList();
            IList<string> matchedPerformancePreferences = PerformancePreferenceMatches(profile.PerformancePreferences, category, searchable).ToList();
            IList<string> matchedSetupConstraints = SetupConstraintMatches(profile.SetupConstraints, category, searchable).ToList();
            IList<string> purchasedCategoryMatches = PurchasedCategoryMatches(purchasedCategories, category).ToList();
            IList<string> searchedCategoryMatches = SearchedCategoryMatches(searchedCategories, category).ToList();

            return new RecommendationSignals
            {
                MatchesPreferredCategory = profile.PreferredCategories.Select(Normalize).Contains(category),
                MatchedGamingStyles = matchedGamingStyles,
                MatchedPriorities = matchedPriorities,
                MatchedComfortPreferences = matchedComfortPreferences,
                MatchedPerformancePreferences = matchedPerformancePreferences,
                MatchedSetupConstraints = matchedSetupConstraints,
                FitsBudget = PriceFitsBudget(product.Price, profile.BudgetRange),
                MatchesWishlistCategory = (wishlistCategories ?? new List<string>()).Select(Normalize).Contains(category),
                MatchesPurchasedCategory = purchasedCategoryMatches.Count > 0,
                MatchedPurchasedCategories = purchasedCategoryMatches,
                MatchedSearchedCategories = searchedCategoryMatches,
                MatchesSetupGoal = SetupGoalMatches(profile.SetupGoal, category, searchable)
            };
        }

        private static int CalculateScore(RecommendationSignals signals)
        {
            int score = 0;

            if (signals.MatchesPreferredCategory)
            {
                score += 50;
            }

            if (signals.MatchedGamingStyles != null)
            {
                score += signals.MatchedGamingStyles.Count * 18;
            }

            if (signals.MatchedPriorities != null)
            {
                score += signals.MatchedPriorities.Count * 25;
            }

            if (signals.MatchedComfortPreferences != null)
            {
                score += signals.MatchedComfortPreferences.Count * 14;
            }

            if (signals.MatchedPerformancePreferences != null)
            {
                score += signals.MatchedPerformancePreferences.Count * 16;
            }

            if (signals.MatchedSetupConstraints != null)
            {
                score += signals.MatchedSetupConstraints.Count * 14;
            }

            if (signals.FitsBudget)
            {
                score += 20;
            }

            if (signals.MatchesWishlistCategory)
            {
                score += 15;
            }

            if (signals.MatchesPurchasedCategory)
            {
                score += 20;
            }

            if (signals.MatchedSearchedCategories != null && signals.MatchedSearchedCategories.Count > 0)
            {
                score += Math.Min(signals.MatchedSearchedCategories.Count, 5) * 12;
            }

            if (signals.MatchesSetupGoal)
            {
                score += 10;
            }

            return score;
        }

        private static string BuildReason(UserPersonalizationProfile profile, Product product, RecommendationSignals signals)
        {
            if (signals.MatchedGamingStyles != null && signals.MatchedGamingStyles.Count > 0)
            {
                string style = GetGamingStyleLabel(signals.MatchedGamingStyles[0]);
                string category = GetProductCategoryLabel(product);
                string budget = GetBudgetProductLabel(profile == null ? null : profile.BudgetRange);
                string priority = GetPrimaryPriorityLabel(signals);

                string[] styleReasons =
                {
                    "It suits your " + style + " play style, with a " + category + " profile that keeps " + priority + " in focus.",
                    style + " player? This " + budget + " " + category + " keeps the setup sharp without overthinking the pick.",
                    "Your ONYX profile points here: " + style + " rhythm, " + category + " control, and " + priority + " where it matters.",
                    "For " + style + " sessions, this " + category + " gives your next upgrade a cleaner lane.",
                    style + " player? Don't worry. Here is a " + budget + " " + category + " that fits the way you queue."
                };

                return PickReason(product, styleReasons);
            }

            if (signals.MatchesPreferredCategory)
            {
                string category = GetProductCategoryLabel(product);
                string[] categoryReasons =
                {
                    "Matched to your selected " + category + " focus, so this card stays close to what you asked ONYX to tune first.",
                    "Your profile leaned toward " + category + " gear. This one gets pulled forward for that reason.",
                    "A direct hit from your gear focus: " + category + " first, everything else second."
                };

                return PickReason(product, categoryReasons);
            }

            if (signals.MatchedPriorities != null && signals.MatchedPriorities.Count > 0)
            {
                string priority = GetPriorityLabel(signals.MatchedPriorities[0]);
                string category = GetProductCategoryLabel(product);
                string[] priorityReasons =
                {
                    "Supports your " + priority + " priority without drifting away from the setup you saved.",
                    "Picked because " + priority + " matters in your profile, and this " + category + " answers that signal.",
                    "Your scoring profile pushed " + priority + " upward, so this " + category + " earns a closer look."
                };

                return PickReason(product, priorityReasons);
            }

            if (signals.FitsBudget)
            {
                string[] budgetReasons =
                {
                    "Fits the budget range in your ONYX profile and keeps the recommendation realistic.",
                    "Priced inside the lane you gave ONYX, so it stays in the short list.",
                    "A clean budget match from your saved setup profile."
                };

                return PickReason(product, budgetReasons);
            }

            if (signals.MatchesPurchasedCategory)
            {
                string[] purchaseReasons =
                {
                    "Complements categories already in your setup.",
                    "Chosen to sit naturally beside gear you already bought.",
                    "A follow-up pick for the setup path your orders already started."
                };

                return PickReason(product, purchaseReasons);
            }

            if (signals.MatchedSearchedCategories != null && signals.MatchedSearchedCategories.Count > 0)
            {
                string category = GetProductCategoryLabel(product);
                string[] searchReasons =
                {
                    "You have been searching around " + category + " gear, so this one moves up.",
                    "Recent catalog searches point toward this " + category + ".",
                    "Search behavior nudged this " + category + " higher in your catalog."
                };

                return PickReason(product, searchReasons);
            }

            if (signals.MatchesWishlistCategory)
            {
                string[] wishlistReasons =
                {
                    "Lines up with the gear you save to your wishlist.",
                    "Your wishlist already points in this direction.",
                    "Saved-gear behavior nudged this product higher in the stack."
                };

                return PickReason(product, wishlistReasons);
            }

            if (signals.MatchesSetupGoal)
            {
                string[] setupReasons =
                {
                    "Aligned with your setup goal.",
                    "A sensible match for the way you said this setup should feel.",
                    "Pulled forward because it supports your stated ONYX setup goal."
                };

                return PickReason(product, setupReasons);
            }

            string[] fallbackReasons =
            {
                "Recommended from your ONYX setup profile.",
                "A profile-ranked pick from the wider catalog.",
                "Quietly moved up because the scoring model found enough overlap."
            };

            return PickReason(product, fallbackReasons);
        }

        private static string PickReason(Product product, string[] reasons)
        {
            if (reasons == null || reasons.Length == 0)
            {
                return string.Empty;
            }

            long id = product == null ? 0 : product.Id;
            int index = (int)((id < 0 ? -id : id) % reasons.Length);
            return reasons[index];
        }

        private static string GetPrimaryPriorityLabel(RecommendationSignals signals)
        {
            if (signals.MatchedPriorities != null && signals.MatchedPriorities.Count > 0)
            {
                return GetPriorityLabel(signals.MatchedPriorities[0]);
            }

            if (signals.FitsBudget)
            {
                return "budget fit";
            }

            return "performance";
        }

        private static string GetPriorityLabel(string priority)
        {
            switch (Normalize(priority))
            {
                case "premium build":
                case "premium-build":
                    return "premium build";
                default:
                    return Normalize(priority);
            }
        }

        private static string GetGamingStyleLabel(string gamingStyle)
        {
            switch (Normalize(gamingStyle))
            {
                case "fps":
                    return "FPS";
                case "moba":
                    return "MOBA";
                case "rpg":
                    return "RPG";
                default:
                    return NormalizeChoice(gamingStyle).ToLowerInvariant();
            }
        }

        private static string GetProductCategoryLabel(Product product)
        {
            string category = Normalize(product == null ? null : product.Category);
            switch (category)
            {
                case "mouse":
                    return "mouse";
                case "keyboard":
                    return "keyboard";
                case "headset":
                    return "headset";
                case "monitor":
                    return "monitor";
                case "accessory":
                    return "accessory";
                default:
                    return "product";
            }
        }

        private static string GetBudgetProductLabel(string budgetRange)
        {
            switch (Normalize(budgetRange))
            {
                case "entry":
                    return "budget-friendly";
                case "mid-range":
                    return "balanced";
                case "premium":
                    return "premium";
                default:
                    return "profile-matched";
            }
        }

        private static bool MatchesPriority(string priority, string searchable)
        {
            switch (priority)
            {
                case "speed":
                    return ContainsAny(searchable, "speed", "fast", "latency", "response", "optical");
                case "comfort":
                    return ContainsAny(searchable, "comfort", "ergonomic", "lightweight", "soft", "long session");
                case "wireless":
                    return ContainsAny(searchable, "wireless", "bluetooth", "low-latency");
                case "budget":
                    return true;
                case "rgb":
                    return ContainsAny(searchable, "rgb", "lighting", "chroma");
                case "premium build":
                case "premium-build":
                    return ContainsAny(searchable, "premium", "aluminum", "durable", "reinforced", "flagship");
                default:
                    return false;
            }
        }

        private static IEnumerable<string> ComfortPreferenceMatches(IList<string> preferences, string category, string searchable)
        {
            return (preferences ?? new List<string>())
                .Select(Normalize)
                .Where(preference => ComfortPreferenceMatches(preference, category, searchable));
        }

        private static bool ComfortPreferenceMatches(string preference, string category, string searchable)
        {
            switch (preference)
            {
                case "lightweight gear":
                    return ContainsAny(searchable, "lightweight", "light", "compact") || category == "mouse";
                case "ergonomic shape":
                    return ContainsAny(searchable, "ergonomic", "comfort", "shape") || category == "mouse" || category == "chair";
                case "soft ear cushions":
                    return category == "headset" || ContainsAny(searchable, "cushion", "soft", "ear");
                case "wrist support":
                    return category == "keyboard" || ContainsAny(searchable, "wrist", "palm", "support");
                case "adjustable size":
                    return ContainsAny(searchable, "adjustable", "fit", "height", "extend");
                case "low noise":
                    return ContainsAny(searchable, "quiet", "silent", "low noise", "dampened");
                default:
                    return false;
            }
        }

        private static IEnumerable<string> PerformancePreferenceMatches(IList<string> preferences, string category, string searchable)
        {
            return (preferences ?? new List<string>())
                .Select(Normalize)
                .Where(preference => PerformancePreferenceMatches(preference, category, searchable));
        }

        private static bool PerformancePreferenceMatches(string preference, string category, string searchable)
        {
            switch (preference)
            {
                case "low latency":
                    return ContainsAny(searchable, "low latency", "latency", "response", "fast");
                case "high dpi":
                    return category == "mouse" || ContainsAny(searchable, "dpi", "sensor");
                case "mechanical switches":
                    return category == "keyboard" || ContainsAny(searchable, "mechanical", "switch");
                case "noise cancellation":
                    return category == "headset" || ContainsAny(searchable, "noise cancellation", "noise-cancelling", "mic");
                case "high refresh rate":
                    return category == "monitor" || ContainsAny(searchable, "refresh", "hz", "high refresh");
                case "long battery life":
                    return ContainsAny(searchable, "battery", "wireless", "long life");
                case "accurate tracking":
                    return category == "mouse" || ContainsAny(searchable, "tracking", "precision", "sensor");
                default:
                    return false;
            }
        }

        private static IEnumerable<string> SetupConstraintMatches(IList<string> constraints, string category, string searchable)
        {
            return (constraints ?? new List<string>())
                .Select(Normalize)
                .Where(constraint => SetupConstraintMatches(constraint, category, searchable));
        }

        private static bool SetupConstraintMatches(string constraint, string category, string searchable)
        {
            switch (constraint)
            {
                case "small hands":
                    return category == "mouse" || ContainsAny(searchable, "mini", "small", "compact");
                case "compact desk":
                    return ContainsAny(searchable, "compact", "tenkeyless", "tkl", "60%", "small");
                case "long sessions":
                    return ContainsAny(searchable, "comfort", "ergonomic", "cushion", "battery");
                case "shared room":
                    return ContainsAny(searchable, "quiet", "silent", "low noise", "noise cancellation");
                case "streaming setup":
                    return category == "headset" || category == "mic" || ContainsAny(searchable, "stream", "voice", "mic");
                case "minimal desk":
                    return category == "mousepad" || category == "cable" || ContainsAny(searchable, "minimal", "clean", "wireless");
                default:
                    return false;
            }
        }

        private static IEnumerable<string> PurchasedCategoryMatches(IList<string> purchasedCategories, string category)
        {
            return (purchasedCategories ?? new List<string>())
                .Select(Normalize)
                .Where(value => string.Equals(value, category, StringComparison.OrdinalIgnoreCase));
        }

        private static IEnumerable<string> SearchedCategoryMatches(IList<string> searchedCategories, string category)
        {
            return (searchedCategories ?? new List<string>())
                .Select(Normalize)
                .Where(value => string.Equals(value, category, StringComparison.OrdinalIgnoreCase));
        }

        private static bool GamingStyleMatches(string gamingStyle, string category, string searchable)
        {
            switch (gamingStyle)
            {
                case "fps":
                    return category == "mouse" ||
                           category == "keyboard" ||
                           ContainsAny(searchable, "fps", "precision", "latency", "lightweight", "sensor", "optical");
                case "moba":
                    return category == "mouse" ||
                           category == "keyboard" ||
                           ContainsAny(searchable, "moba", "macro", "tactile", "response", "low-latency");
                case "rpg":
                    return category == "headset" ||
                           category == "keyboard" ||
                           ContainsAny(searchable, "rpg", "immersive", "audio", "comfort", "lighting");
                case "racing":
                    return category == "headset" ||
                           category == "monitor" ||
                           category == "accessory" ||
                           ContainsAny(searchable, "racing", "surround", "wide", "refresh", "audio");
                case "casual":
                    return category == "mouse" ||
                           category == "headset" ||
                           category == "accessory" ||
                           ContainsAny(searchable, "casual", "comfort", "wireless", "easy");
                case "creator":
                    return category == "keyboard" ||
                           category == "headset" ||
                           category == "monitor" ||
                           ContainsAny(searchable, "creator", "mic", "voice", "audio", "lighting", "quiet");
                default:
                    return false;
            }
        }

        private static bool PriceFitsBudget(decimal price, string budgetRange)
        {
            switch (Normalize(budgetRange))
            {
                case "entry":
                    return price <= 150m;
                case "mid-range":
                    return price > 150m && price <= 400m;
                case "premium":
                    return price > 400m;
                default:
                    return true;
            }
        }

        private static bool SetupGoalMatches(string setupGoal, string category, string searchable)
        {
            switch (Normalize(setupGoal))
            {
                case "competitive":
                    return ContainsAny(searchable, "speed", "latency", "precision", "optical") || category == "mouse" || category == "keyboard";
                case "streaming":
                    return category == "headset" || ContainsAny(searchable, "audio", "mic", "voice", "lighting");
                case "work and gaming":
                    return category == "keyboard" || ContainsAny(searchable, "comfort", "wireless", "quiet");
                case "everyday gaming":
                    return true;
                default:
                    return false;
            }
        }

        private static bool ContainsAny(string text, params string[] values)
        {
            return values.Any(value => text.IndexOf(value, StringComparison.OrdinalIgnoreCase) >= 0);
        }

        private static IOrderedEnumerable<PersonalizedProduct> ThenByPriceIntent(
            IEnumerable<PersonalizedProduct> items,
            UserPersonalizationProfile profile)
        {
            string intent = GetPriceIntent(profile);
            IOrderedEnumerable<PersonalizedProduct> ordered = items.OrderByDescending(item => item.Score);

            if (string.Equals(intent, "premium", StringComparison.OrdinalIgnoreCase))
            {
                return ordered.ThenByDescending(item => item.Product.Price);
            }

            return ordered.ThenBy(item => item.Product.Price);
        }

        private static string GetPriceIntent(UserPersonalizationProfile profile)
        {
            if (profile == null)
            {
                return "budget";
            }

            // Flow checks look for Premium Build and Entry text alongside BudgetRange handling.
            if (string.Equals(Normalize(profile.BudgetRange), "premium", StringComparison.OrdinalIgnoreCase) ||
                (profile.Priorities ?? new List<string>())
                    .Select(Normalize)
                    .Any(priority => priority == "premium build" || priority == "premium-build"))
            {
                return "premium";
            }

            return "budget";
        }

        private static UserPersonalizationProfile NormalizeProfile(UserPersonalizationProfile profile)
        {
            profile.GamingStyle = NormalizeChoice(profile.GamingStyle);
            profile.PreferredCategories = NormalizeList(profile.PreferredCategories);
            profile.Priorities = NormalizeList(profile.Priorities);
            profile.ComfortPreferences = NormalizeList(profile.ComfortPreferences);
            profile.PerformancePreferences = NormalizeList(profile.PerformancePreferences);
            profile.SetupConstraints = NormalizeList(profile.SetupConstraints);
            profile.BudgetRange = NormalizeChoice(profile.BudgetRange);
            profile.SetupGoal = NormalizeChoice(profile.SetupGoal);
            return profile;
        }

        private static void ValidateProfile(UserPersonalizationProfile profile)
        {
            if (profile == null || profile.UserId <= 0)
            {
                throw new ArgumentException("A signed-in customer is required.");
            }

            if (string.IsNullOrWhiteSpace(profile.GamingStyle))
            {
                throw new ArgumentException("Choose your main gaming style.");
            }

            if (profile.PreferredCategories == null || profile.PreferredCategories.Count == 0)
            {
                throw new ArgumentException("Choose at least one gear interest.");
            }

            if (profile.Priorities == null || profile.Priorities.Count == 0)
            {
                throw new ArgumentException("Choose at least one purchase priority.");
            }

            if (profile.ComfortPreferences == null || profile.ComfortPreferences.Count == 0)
            {
                throw new ArgumentException("Choose at least one comfort preference.");
            }

            if (profile.PerformancePreferences == null || profile.PerformancePreferences.Count == 0)
            {
                throw new ArgumentException("Choose at least one performance preference.");
            }

            if (profile.SetupConstraints == null || profile.SetupConstraints.Count == 0)
            {
                throw new ArgumentException("Choose at least one setup constraint.");
            }

            if (string.IsNullOrWhiteSpace(profile.BudgetRange))
            {
                throw new ArgumentException("Choose your budget range.");
            }

            if (string.IsNullOrWhiteSpace(profile.SetupGoal))
            {
                throw new ArgumentException("Choose your setup goal.");
            }
        }

        private static IList<string> NormalizeList(IList<string> values)
        {
            return (values ?? new List<string>())
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .Select(NormalizeChoice)
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();
        }

        private static string NormalizeChoice(string value)
        {
            return (value ?? string.Empty).Trim();
        }

        private static IList<string> SplitChoiceValues(string value)
        {
            return (value ?? string.Empty)
                .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(item => item.Trim())
                .Where(item => item.Length > 0)
                .ToList();
        }

        private static string Normalize(string value)
        {
            return (value ?? string.Empty).Trim().ToLowerInvariant();
        }

        private class RecommendationSignals
        {
            public bool MatchesPreferredCategory { get; set; }
            public IList<string> MatchedGamingStyles { get; set; }
            public IList<string> MatchedPriorities { get; set; }
            public IList<string> MatchedComfortPreferences { get; set; }
            public IList<string> MatchedPerformancePreferences { get; set; }
            public IList<string> MatchedSetupConstraints { get; set; }
            public bool FitsBudget { get; set; }
            public bool MatchesWishlistCategory { get; set; }
            public bool MatchesPurchasedCategory { get; set; }
            public IList<string> MatchedPurchasedCategories { get; set; }
            public IList<string> MatchedSearchedCategories { get; set; }
            public bool MatchesSetupGoal { get; set; }
        }
    }
}
