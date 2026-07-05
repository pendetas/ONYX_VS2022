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
                .Select(product => new PersonalizedProduct
                {
                    Product = product,
                    Score = CalculateScore(profile, product, wishlistCategories, purchasedCategories),
                    Reason = BuildReason(profile, product)
                })
                .OrderByDescending(item => item.Score)
                .ThenBy(item => item.Product.Price)
                .Take(count < 1 ? 4 : count)
                .ToList();
        }

        private static int CalculateScore(
            UserPersonalizationProfile profile,
            Product product,
            IList<string> wishlistCategories,
            IList<string> purchasedCategories)
        {
            int score = 0;
            string category = Normalize(product.Category);
            string searchable = Normalize(product.Name + " " + product.Description + " " + product.Brand);

            if (profile.PreferredCategories.Select(Normalize).Contains(category))
            {
                score += 50;
            }

            foreach (string priority in profile.Priorities.Select(Normalize))
            {
                if (MatchesPriority(priority, searchable))
                {
                    score += 25;
                }
            }

            if (PriceFitsBudget(product.Price, profile.BudgetRange))
            {
                score += 20;
            }

            if ((wishlistCategories ?? new List<string>()).Select(Normalize).Contains(category))
            {
                score += 15;
            }

            if ((purchasedCategories ?? new List<string>()).Select(Normalize).Contains(category))
            {
                score += 20;
            }

            if (SetupGoalMatches(profile.SetupGoal, category, searchable))
            {
                score += 10;
            }

            return score;
        }

        private static string BuildReason(UserPersonalizationProfile profile, Product product)
        {
            if (profile.PreferredCategories.Select(Normalize).Contains(Normalize(product.Category)))
            {
                return "Matched to your selected gear focus";
            }

            if (SetupGoalMatches(profile.SetupGoal, Normalize(product.Category), Normalize(product.Name + " " + product.Description)))
            {
                return "Aligned with your setup goal";
            }

            return "Recommended from your ONYX setup profile";
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
                .Distinct()
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
    }
}
