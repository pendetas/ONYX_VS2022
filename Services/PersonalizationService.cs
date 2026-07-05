using System;
using System.Collections.Generic;
using System.Linq;
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
            ValidateProfile(profile);
            _personalizationRepository.SaveProfile(NormalizeProfile(profile));
        }

        public IList<PersonalizedProduct> GetRecommendedProducts(long userId, int count)
        {
            UserPersonalizationProfile profile = _personalizationRepository.GetProfile(userId);
            if (profile == null || !profile.CompletedAt.HasValue)
            {
                return new List<PersonalizedProduct>();
            }

            IList<Product> products = _productRepository.GetAllProducts();
            IList<string> wishlistCategories = _personalizationRepository.GetWishlistCategories(userId);
            IList<string> purchasedCategories = _personalizationRepository.GetPurchasedCategories(userId);

            return RankProductsForProfile(
                profile,
                products,
                wishlistCategories,
                purchasedCategories,
                count);
        }

        public IList<PersonalizedProduct> RankProductsForProfile(
            UserPersonalizationProfile profile,
            IList<Product> products,
            IList<string> wishlistCategories,
            IList<string> purchasedCategories,
            int count)
        {
            if (profile == null || products == null)
            {
                return new List<PersonalizedProduct>();
            }

            return products
                .Select(product => BuildRecommendation(profile, product, wishlistCategories, purchasedCategories))
                .OrderByDescending(item => item.Score)
                .ThenBy(item => item.Product.Price)
                .ThenBy(item => item.Product.Name, StringComparer.Ordinal)
                .ThenBy(item => item.Product.Id)
                .Take(count < 1 ? 4 : count)
                .ToList();
        }

        private static PersonalizedProduct BuildRecommendation(
            UserPersonalizationProfile profile,
            Product product,
            IList<string> wishlistCategories,
            IList<string> purchasedCategories)
        {
            RecommendationSignals signals = GetRecommendationSignals(profile, product, wishlistCategories, purchasedCategories);

            return new PersonalizedProduct
            {
                Product = product,
                Score = CalculateScore(signals),
                Reason = BuildReason(signals)
            };
        }

        private static RecommendationSignals GetRecommendationSignals(
            UserPersonalizationProfile profile,
            Product product,
            IList<string> wishlistCategories,
            IList<string> purchasedCategories)
        {
            string category = Normalize(product.Category);
            string searchable = Normalize(product.Name + " " + product.Description + " " + product.Brand);
            IList<string> matchedPriorities = profile.Priorities
                .Select(Normalize)
                .Where(priority => MatchesPriority(priority, searchable))
                .ToList();

            return new RecommendationSignals
            {
                MatchesPreferredCategory = profile.PreferredCategories.Select(Normalize).Contains(category),
                MatchedPriorities = matchedPriorities,
                FitsBudget = PriceFitsBudget(product.Price, profile.BudgetRange),
                MatchesWishlistCategory = (wishlistCategories ?? new List<string>()).Select(Normalize).Contains(category),
                MatchesPurchasedCategory = (purchasedCategories ?? new List<string>()).Select(Normalize).Contains(category),
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

            if (signals.MatchedPriorities != null)
            {
                score += signals.MatchedPriorities.Count * 25;
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

            if (signals.MatchesSetupGoal)
            {
                score += 10;
            }

            return score;
        }

        private static string BuildReason(RecommendationSignals signals)
        {
            if (signals.MatchesPreferredCategory)
            {
                return "Matched to your selected gear focus";
            }

            if (signals.MatchedPriorities != null && signals.MatchedPriorities.Count > 0)
            {
                return "Supports your " + GetPriorityLabel(signals.MatchedPriorities[0]) + " priority";
            }

            if (signals.FitsBudget)
            {
                return "Fits the budget range in your ONYX profile";
            }

            if (signals.MatchesPurchasedCategory)
            {
                return "Complements categories already in your setup";
            }

            if (signals.MatchesWishlistCategory)
            {
                return "Lines up with the gear you save to your wishlist";
            }

            if (signals.MatchesSetupGoal)
            {
                return "Aligned with your setup goal";
            }

            return "Recommended from your ONYX setup profile";
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

        private static UserPersonalizationProfile NormalizeProfile(UserPersonalizationProfile profile)
        {
            profile.GamingStyle = NormalizeChoice(profile.GamingStyle);
            profile.PreferredCategories = NormalizeList(profile.PreferredCategories);
            profile.Priorities = NormalizeList(profile.Priorities);
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

        private static string Normalize(string value)
        {
            return (value ?? string.Empty).Trim().ToLowerInvariant();
        }

        private class RecommendationSignals
        {
            public bool MatchesPreferredCategory { get; set; }
            public IList<string> MatchedPriorities { get; set; }
            public bool FitsBudget { get; set; }
            public bool MatchesWishlistCategory { get; set; }
            public bool MatchesPurchasedCategory { get; set; }
            public bool MatchesSetupGoal { get; set; }
        }
    }
}
