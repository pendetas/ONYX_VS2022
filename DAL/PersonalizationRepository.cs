using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using Npgsql;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class PersonalizationRepository
    {
        public bool HasCompletedProfile(long userId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT COUNT(*)
                        FROM user_personalization_profiles
                        WHERE user_id = @UserId
                          AND completed_at IS NOT NULL";
                    AddParameter(cmd, "@UserId", userId);
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
        }

        public UserPersonalizationProfile GetProfile(long userId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT user_id, gaming_style, preferred_categories, priorities,
                               budget_range, setup_goal, completed_at, updated_at,
                               comfort_preferences, performance_preferences, setup_constraints
                        FROM user_personalization_profiles
                        WHERE user_id = @UserId";
                    AddParameter(cmd, "@UserId", userId);

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        return reader.Read() ? MapProfile(reader) : null;
                    }
                }
            }
        }

        public void SaveProfile(UserPersonalizationProfile profile)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        INSERT INTO user_personalization_profiles
                            (user_id, gaming_style, preferred_categories, priorities,
                             budget_range, setup_goal, comfort_preferences, performance_preferences,
                             setup_constraints, completed_at, updated_at)
                        VALUES
                            (@UserId, @GamingStyle, @PreferredCategories, @Priorities,
                             @BudgetRange, @SetupGoal, @ComfortPreferences, @PerformancePreferences,
                             @SetupConstraints, NOW(), NOW())
                        ON CONFLICT (user_id) DO UPDATE SET
                            gaming_style = EXCLUDED.gaming_style,
                            preferred_categories = EXCLUDED.preferred_categories,
                            priorities = EXCLUDED.priorities,
                            budget_range = EXCLUDED.budget_range,
                            setup_goal = EXCLUDED.setup_goal,
                            comfort_preferences = EXCLUDED.comfort_preferences,
                            performance_preferences = EXCLUDED.performance_preferences,
                            setup_constraints = EXCLUDED.setup_constraints,
                            completed_at = COALESCE(user_personalization_profiles.completed_at, NOW()),
                            updated_at = NOW()";
                    AddParameter(cmd, "@UserId", profile.UserId);
                    AddParameter(cmd, "@GamingStyle", profile.GamingStyle);
                    AddParameter(cmd, "@PreferredCategories", JoinValues(profile.PreferredCategories));
                    AddParameter(cmd, "@Priorities", JoinValues(profile.Priorities));
                    AddParameter(cmd, "@BudgetRange", profile.BudgetRange);
                    AddParameter(cmd, "@SetupGoal", profile.SetupGoal);
                    AddParameter(cmd, "@ComfortPreferences", JoinValues(profile.ComfortPreferences));
                    AddParameter(cmd, "@PerformancePreferences", JoinValues(profile.PerformancePreferences));
                    AddParameter(cmd, "@SetupConstraints", JoinValues(profile.SetupConstraints));
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public IList<string> GetWishlistCategories(long userId)
        {
            return GetCategorySignals(@"
                SELECT DISTINCT p.category
                FROM wishlists w
                INNER JOIN products p ON p.id = w.product_id
                WHERE w.user_id = @UserId", userId);
        }

        public IList<string> GetPurchasedCategories(long userId)
        {
            return GetCategorySignals(@"
                SELECT p.category
                FROM orders o
                INNER JOIN order_items oi ON oi.order_id = o.id
                INNER JOIN products p ON p.id = oi.product_id
                WHERE o.user_id = @UserId
                  AND COALESCE(o.status, '') <> 'cancelled'
                ORDER BY o.ordered_at DESC, oi.order_item_id DESC", userId);
        }

        public void RecordCatalogSearch(long userId, string searchTerm)
        {
            string normalizedTerm = (searchTerm ?? string.Empty).Trim();
            if (userId <= 0 || string.IsNullOrWhiteSpace(normalizedTerm))
            {
                return;
            }

            try
            {
                using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
                {
                    conn.Open();
                    IList<string> inferredCategories = InferSearchCategories(normalizedTerm);
                    if (inferredCategories.Count == 0)
                    {
                        inferredCategories.Add(null);
                    }

                    foreach (string inferredCategory in inferredCategories)
                    {
                        using (DbCommand cmd = conn.CreateCommand())
                        {
                            cmd.CommandText = @"
                            INSERT INTO catalog_search_events
                                (user_id, search_term, inferred_category, searched_at)
                            VALUES
                                (@UserId, @SearchTerm, @InferredCategory, NOW())";
                            AddParameter(cmd, "@UserId", userId);
                            AddParameter(cmd, "@SearchTerm", normalizedTerm);
                            AddParameter(cmd, "@InferredCategory", inferredCategory);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (PostgresException exception) when (exception.SqlState == PostgresErrorCodes.UndefinedTable)
            {
                System.Diagnostics.Trace.TraceWarning(
                    "Catalog search personalization event skipped because the table is missing for user {0}: {1}",
                    userId,
                    exception.MessageText);
            }
        }

        public IList<string> GetSearchedCategories(long userId)
        {
            return GetCategorySignals(@"
                SELECT inferred_category
                FROM catalog_search_events
                WHERE user_id = @UserId
                  AND inferred_category IS NOT NULL
                ORDER BY searched_at DESC
                LIMIT 50", userId);
        }

        private IList<string> GetCategorySignals(string sql, long userId)
        {
            var values = new List<string>();
            try
            {
                using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
                {
                    conn.Open();
                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = sql;
                        AddParameter(cmd, "@UserId", userId);
                        using (DbDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                if (!reader.IsDBNull(0))
                                {
                                    values.Add(reader.GetString(0));
                                }
                            }
                        }
                    }
                }
            }
            catch (PostgresException exception) when (exception.SqlState == PostgresErrorCodes.UndefinedTable)
            {
                System.Diagnostics.Trace.TraceWarning(
                    "Optional personalization signal lookup skipped because a related table is missing for user {0}: {1}",
                    userId,
                    exception.MessageText);
            }

            return values;
        }

        private static UserPersonalizationProfile MapProfile(DbDataReader reader)
        {
            return new UserPersonalizationProfile
            {
                UserId = reader.GetInt64(0),
                GamingStyle = reader.GetString(1),
                PreferredCategories = SplitValues(reader.GetString(2)),
                Priorities = SplitValues(reader.GetString(3)),
                BudgetRange = reader.GetString(4),
                SetupGoal = reader.GetString(5),
                CompletedAt = reader.IsDBNull(6) ? (DateTime?)null : reader.GetDateTime(6),
                UpdatedAt = reader.IsDBNull(7) ? (DateTime?)null : reader.GetDateTime(7),
                ComfortPreferences = reader.FieldCount > 8 && !reader.IsDBNull(8) ? SplitValues(reader.GetString(8)) : new List<string>(),
                PerformancePreferences = reader.FieldCount > 9 && !reader.IsDBNull(9) ? SplitValues(reader.GetString(9)) : new List<string>(),
                SetupConstraints = reader.FieldCount > 10 && !reader.IsDBNull(10) ? SplitValues(reader.GetString(10)) : new List<string>()
            };
        }

        private static void AddParameter(DbCommand cmd, string name, object value)
        {
            DbParameter parameter = cmd.CreateParameter();
            parameter.ParameterName = name;
            parameter.Value = value ?? DBNull.Value;
            cmd.Parameters.Add(parameter);
        }

        private static string JoinValues(IList<string> values)
        {
            return string.Join(",", (values ?? new List<string>())
                .Where(v => !string.IsNullOrWhiteSpace(v))
                .Select(v => v.Trim().ToLowerInvariant())
                .Distinct());
        }

        private static IList<string> SplitValues(string value)
        {
            return (value ?? string.Empty)
                .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(v => v.Trim())
                .Where(v => v.Length > 0)
                .ToList();
        }

        public IList<string> InferSearchCategories(string searchTerm)
        {
            string value = (searchTerm ?? string.Empty).Trim().ToLowerInvariant();
            var categories = new List<string>();

            AddIfMatches(categories, value, "Keyboard", "keyboard", "keycap", "switch", "mechanical");
            AddIfMatches(categories, value, "Mouse", "mouse", "mice", "dpi", "tracking", "sensor");
            AddIfMatches(categories, value, "Headset", "headset", "headphone", "audio", "ear cushion", "noise cancellation");
            AddIfMatches(categories, value, "Mic", "mic", "microphone", "voice");
            AddIfMatches(categories, value, "Monitor", "monitor", "display", "screen", "refresh", "hz");
            AddIfMatches(categories, value, "Mousepad", "mousepad", "mouse pad", "pad");
            AddIfMatches(categories, value, "Cable", "cable", "wire", "charging");
            AddIfMatches(categories, value, "Chair", "chair", "seat", "ergonomic");
            AddIfMatches(categories, value, "Monitor Extension", "monitor extension", "monitor arm", "arm", "mount");
            AddIfMatches(categories, value, "Accessory", "accessory", "accessories", "desk", "minimal");

            return categories.Distinct(StringComparer.OrdinalIgnoreCase).ToList();
        }

        private string InferSearchCategory(string searchTerm)
        {
            return InferSearchCategories(searchTerm).FirstOrDefault();
        }

        private static void AddIfMatches(IList<string> categories, string value, string category, params string[] terms)
        {
            if (terms.Any(term => value.Contains(term)))
            {
                categories.Add(category);
            }
        }
    }
}
