using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class OnyxKnowledgeService
    {
        private const int MaxFileBytes = 180000;
        private const int ChunkSize = 1200;
        private const int MaxChunks = 320;
        private const int MaxContextCharacters = 6000;
        private const int MaxProductContextCharacters = 2600;
        private const int MaxCatalogProducts = 24;
        private const string AssistantKnowledgeFileName = "onyx-assistant-knowledge.md";

        private static readonly HashSet<string> StopWords = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "a", "an", "and", "are", "as", "at", "be", "can", "do", "for", "from", "how", "i", "in",
            "is", "it", "me", "my", "of", "on", "or", "the", "to", "what", "when", "where", "with", "you",
            "detail", "details", "information", "know", "please", "question", "tell", "want"
        };

        private static readonly Dictionary<string, string[]> RelatedTerms = new Dictionary<string, string[]>(StringComparer.OrdinalIgnoreCase)
        {
            { "buy", new[] { "catalog", "product", "cart", "checkout", "price", "stock" } },
            { "shop", new[] { "catalog", "product", "cart", "checkout", "price", "stock" } },
            { "shopping", new[] { "catalog", "product", "cart", "checkout", "price", "stock" } },
            { "choose", new[] { "catalog", "product", "recommendation", "mouse", "gear" } },
            { "recommend", new[] { "catalog", "product", "recommendation", "mouse", "gear" } },
            { "compare", new[] { "catalog", "product", "recommendation", "mouse", "gear" } },
            { "purchase", new[] { "order", "checkout", "invoice", "receipt", "payment" } },
            { "track", new[] { "order", "history", "invoice", "shipping", "delivery" } },
            { "status", new[] { "order", "history", "support", "shipping" } },
            { "claim", new[] { "warranty", "support", "serial", "replacement", "issue" } },
            { "waranty", new[] { "warranty", "support", "claim", "serial", "replacement" } },
            { "warrenty", new[] { "warranty", "support", "claim", "serial", "replacement" } },
            { "warantee", new[] { "warranty", "support", "claim", "serial", "replacement" } },
            { "defect", new[] { "warranty", "support", "serial", "replacement", "photos" } },
            { "broken", new[] { "warranty", "support", "serial", "replacement", "issue" } },
            { "return", new[] { "returns", "support", "terms", "refund", "warranty" } },
            { "refund", new[] { "returns", "support", "terms", "order" } },
            { "saved", new[] { "wishlist", "cart", "product" } },
            { "favorite", new[] { "wishlist", "saved", "product" } },
            { "history", new[] { "order", "profile", "invoice", "receipt" } },
            { "receipt", new[] { "invoice", "order", "history" } },
            { "account", new[] { "profile", "login", "register", "order", "wishlist" } },
            { "signup", new[] { "register", "account", "login" } },
            { "sign", new[] { "login", "register", "account" } },
            { "audio", new[] { "headset", "sound", "comms", "catalog" } },
            { "mice", new[] { "mouse", "gaming", "catalog" } }
        };

        private readonly Lazy<IReadOnlyList<KnowledgeChunk>> cachedChunks;
        private readonly string rootPath;

        public OnyxKnowledgeService()
            : this(AppDomain.CurrentDomain.BaseDirectory)
        {
        }

        public OnyxKnowledgeService(string rootPath)
        {
            this.rootPath = string.IsNullOrWhiteSpace(rootPath)
                ? AppDomain.CurrentDomain.BaseDirectory
                : rootPath;
            cachedChunks = new Lazy<IReadOnlyList<KnowledgeChunk>>(LoadChunks, true);
        }

        public string GetRelevantContext(string question)
        {
            List<string> terms = ExtractTerms(question);
            if (terms.Count == 0)
            {
                return string.Empty;
            }

            var matches = cachedChunks.Value
                .Select(chunk => new
                {
                    Chunk = chunk,
                    Score = ScoreChunk(chunk, terms)
                })
                .Where(match => match.Score > 0)
                .OrderByDescending(match => match.Score)
                .ThenBy(match => match.Chunk.Source)
                .Take(5)
                .ToList();

            if (matches.Count == 0)
            {
                return string.Empty;
            }

            var context = new StringBuilder();
            foreach (var match in matches)
            {
                string block = match.Chunk.Text + "\n\n";
                if (context.Length + block.Length > MaxContextCharacters)
                {
                    break;
                }

                context.Append(block);
            }

            return context.ToString().Trim();
        }

        public string GetRelevantContext(string question, IEnumerable<Product> products)
        {
            string fileContext = GetRelevantContext(question);
            string productContext = BuildProductCatalogContext(question, products);

            if (string.IsNullOrWhiteSpace(productContext))
            {
                return fileContext;
            }

            if (string.IsNullOrWhiteSpace(fileContext))
            {
                return productContext;
            }

            return TruncateContext(productContext + "\n\n" + fileContext, MaxContextCharacters);
        }

        private static string BuildProductCatalogContext(string question, IEnumerable<Product> products)
        {
            if (products == null)
            {
                return string.Empty;
            }

            List<string> terms = ExtractTerms(question);
            string requestedProductCategory = GetRequestedProductCategory(question);
            bool broadProductQuestion = IsBroadProductQuestion(question) && requestedProductCategory == null;
            var matches = products
                .Where(product => product != null && !string.IsNullOrWhiteSpace(product.Name))
                .Where(product => requestedProductCategory == null || MatchesRequestedProductCategory(product, requestedProductCategory))
                .Where(product => !RequiresInStock(question) || product.StockQty > 0)
                .Select(product => new
                {
                    Product = product,
                    Score = ScoreProduct(product, terms, requestedProductCategory)
                })
                .Where(match => broadProductQuestion || match.Score > 0)
                .ToList();

            if (IsLowestPriceIntent(question))
            {
                matches = matches.OrderBy(match => match.Product.Price).ThenByDescending(match => match.Score).ToList();
            }
            else if (IsHighestPriceIntent(question))
            {
                matches = matches.OrderByDescending(match => match.Product.Price).ThenByDescending(match => match.Score).ToList();
            }
            else
            {
                matches = matches.OrderByDescending(match => match.Score).ThenBy(match => match.Product.Name).ToList();
            }

            matches = matches.Take(MaxCatalogProducts).ToList();

            if (matches.Count == 0)
            {
                return string.Empty;
            }

            var context = new StringBuilder();
            context.AppendLine("Live ONYX products from database:");
            foreach (var match in matches)
            {
                Product product = match.Product;
                string stock = product.StockQty > 0
                    ? product.StockQty.ToString(CultureInfo.InvariantCulture) + " in stock"
                    : "out of stock";

                context.Append("- Product: ");
                context.Append(product.Name.Trim());
                context.Append("; ID: ");
                context.Append(product.Id.ToString(CultureInfo.InvariantCulture));
                context.Append("; Brand: ");
                context.Append((product.Brand ?? "ONYX").Trim());
                context.Append("; Category: ");
                context.Append((product.Category ?? "Gear").Trim());
                context.Append("; Price: RM ");
                context.Append(product.Price.ToString("N2", CultureInfo.InvariantCulture));
                context.Append("; Stock: ");
                context.Append(stock);

                if (!string.IsNullOrWhiteSpace(product.Description))
                {
                    context.Append("; Description: ");
                    context.Append(TrimForKnowledge(product.Description, 180));
                }

                context.AppendLine();
            }

            return TruncateContext(context.ToString().Trim(), MaxProductContextCharacters);
        }

        private IReadOnlyList<KnowledgeChunk> LoadChunks()
        {
            string root = rootPath;
            string path = Path.Combine(root, "App_Data", AssistantKnowledgeFileName);
            if (!IsSafeKnowledgeFile(path))
            {
                return new List<KnowledgeChunk>();
            }

            string text = ReadSafeText(path);
            return string.IsNullOrWhiteSpace(text)
                ? new List<KnowledgeChunk>()
                : SplitIntoChunks(text)
                    .Take(MaxChunks)
                    .Select(chunk => new KnowledgeChunk(AssistantKnowledgeFileName, chunk))
                    .ToList();
        }

        private static bool IsSafeKnowledgeFile(string path)
        {
            try
            {
                return File.Exists(path) && new FileInfo(path).Length <= MaxFileBytes;
            }
            catch (IOException)
            {
                return false;
            }
            catch (UnauthorizedAccessException)
            {
                return false;
            }
        }

        private static string ReadSafeText(string path)
        {
            try
            {
                string text = File.ReadAllText(path);
                return NormalizeKnowledgeText(text);
            }
            catch (IOException)
            {
                return string.Empty;
            }
            catch (UnauthorizedAccessException)
            {
                return string.Empty;
            }
        }

        private static string NormalizeKnowledgeText(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
            {
                return string.Empty;
            }

            string normalized = text;
            normalized = Regex.Replace(normalized, @"(?i)\b(?:current\s+)?(?:ONYX\s+)?(?:catalog\s+)?knowledge base\b", "current ONYX information");
            normalized = Regex.Replace(normalized, @"[ \t]+", " ");
            normalized = Regex.Replace(normalized, @"\r?\n[ \t]*\r?\n", "\n\n").Trim();

            return normalized;
        }

        private static IEnumerable<string> SplitIntoChunks(string text)
        {
            foreach (string section in Regex.Split(text, @"(?m)(?=^#{1,2}\s)")
                .Where(value => !string.IsNullOrWhiteSpace(value)))
            {
                for (int index = 0; index < section.Length; index += ChunkSize)
                {
                    int length = Math.Min(ChunkSize, section.Length - index);
                    string chunk = section.Substring(index, length).Trim();
                    if (!string.IsNullOrWhiteSpace(chunk))
                    {
                        yield return chunk;
                    }
                }
            }
        }

        private static List<string> ExtractTerms(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
            {
                return new List<string>();
            }

            var terms = new List<string>();
            var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            string normalized = text.ToLowerInvariant();
            var baseTerms = Regex.Split(normalized, @"[^a-z0-9]+")
                .Where(term => term.Length >= 3 && !StopWords.Contains(term))
                .Distinct()
                .Take(14)
                .ToList();

            Action<string> addTerm = term =>
            {
                if (!string.IsNullOrWhiteSpace(term) && term.Length >= 3 && !StopWords.Contains(term) && seen.Add(term))
                {
                    terms.Add(term);
                }
            };

            foreach (string term in baseTerms)
            {
                addTerm(term);

                string[] related;
                if (RelatedTerms.TryGetValue(term, out related))
                {
                    foreach (string relatedTerm in related)
                    {
                        addTerm(relatedTerm);
                    }
                }
            }

            foreach (var pair in RelatedTerms)
            {
                if (normalized.Contains(pair.Key))
                {
                    foreach (string relatedTerm in pair.Value)
                    {
                        addTerm(relatedTerm);
                    }
                }
            }

            return terms.Take(22).ToList();
        }

        private static int ScoreChunk(KnowledgeChunk chunk, List<string> terms)
        {
            string haystack = (chunk.Source + " " + chunk.Text).ToLowerInvariant();
            int score = 0;

            foreach (string term in terms)
            {
                int count = CountTermMatches(haystack, term);
                if (count > 0)
                {
                    score += Math.Min(count, 8);
                }

                if (chunk.Source.IndexOf(term, StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    score += 4;
                }
            }

            if (score > 0 && chunk.Source.IndexOf(AssistantKnowledgeFileName, StringComparison.OrdinalIgnoreCase) >= 0)
            {
                score += 10;
            }

            return score;
        }

        private static int ScoreProduct(Product product, List<string> terms, string requestedProductCategory)
        {
            if (product == null || terms == null || terms.Count == 0)
            {
                return requestedProductCategory != null && MatchesRequestedProductCategory(product, requestedProductCategory) ? 6 : 0;
            }

            string haystack = string.Join(" ", new[]
            {
                product.Name,
                product.Brand,
                product.Category,
                product.Description
            }).ToLowerInvariant();

            int score = 0;
            foreach (string term in terms)
            {
                int count = CountTermMatches(haystack, term);
                if (count > 0)
                {
                    score += Math.Min(count, 8);
                }
            }

            if (requestedProductCategory != null && MatchesRequestedProductCategory(product, requestedProductCategory))
            {
                score += 6;
            }

            return score;
        }

        private static string GetRequestedProductCategory(string question)
        {
            string normalized = Regex.Replace((question ?? string.Empty).ToLowerInvariant(), @"[^a-z0-9\s]", " ");
            normalized = Regex.Replace(normalized, @"\s+", " ").Trim();

            if (Regex.IsMatch(normalized, @"\b(mousepad|mouse pad)\b")) return "mousepad";
            if (Regex.IsMatch(normalized, @"\b(monitor extension|monitor arm|monitor mount)\b")) return "monitor extension";
            if (Regex.IsMatch(normalized, @"\b(mice|mouse|gaming mice)\b")) return "mouse";
            if (Regex.IsMatch(normalized, @"\b(keyboard|keyboards)\b")) return "keyboard";
            if (Regex.IsMatch(normalized, @"\b(headset|headsets|headphone|headphones|earphone|earphones|earbud|earbuds|audio)\b")) return "headset";
            if (Regex.IsMatch(normalized, @"\b(mic|mics|microphone|microphones)\b")) return "mic";
            if (Regex.IsMatch(normalized, @"\b(monitor|monitors)\b")) return "monitor";
            if (Regex.IsMatch(normalized, @"\b(chair|chairs|gaming chair|gaming chairs)\b")) return "chair";
            if (Regex.IsMatch(normalized, @"\b(cable|cables)\b")) return "cable";
            if (Regex.IsMatch(normalized, @"\b(accessory|accessories)\b")) return "accessory";

            return null;
        }

        private static bool MatchesRequestedProductCategory(Product product, string requestedProductCategory)
        {
            string category = Regex.Replace((product.Category ?? string.Empty).ToLowerInvariant(), @"[^a-z0-9\s]", " ");
            category = Regex.Replace(category, @"\s+", " ").Trim();

            switch (requestedProductCategory)
            {
                case "mousepad":
                    return category == "mousepad" || category == "mouse pad";
                case "mouse":
                    return category == "mouse" || category == "mice" || category == "gaming mice";
                case "keyboard":
                    return category.Contains("keyboard");
                case "headset":
                    return category.Contains("headset") || category.Contains("audio");
                case "mic":
                    return category == "mic" || category.Contains("microphone");
                case "monitor":
                    return category == "monitor";
                case "monitor extension":
                    return category == "monitor extension";
                case "chair":
                    return category.Contains("chair");
                case "cable":
                    return category.Contains("cable");
                case "accessory":
                    return category.Contains("accessory") || category.Contains("accessories");
                default:
                    return true;
            }
        }

        private static bool IsBroadProductQuestion(string question)
        {
            if (string.IsNullOrWhiteSpace(question))
            {
                return false;
            }

            string normalized = question.ToLowerInvariant();
            return normalized.Contains("product")
                || normalized.Contains("catalog")
                || normalized.Contains("shop")
                || normalized.Contains("recommend")
                || normalized.Contains("compare")
                || normalized.Contains("mouse")
                || normalized.Contains("mice")
                || normalized.Contains("keyboard")
                || normalized.Contains("headset")
                || normalized.Contains("monitor")
                || normalized.Contains("accessory");
        }

        private static bool RequiresInStock(string question)
        {
            return Regex.IsMatch(question ?? string.Empty, @"\b(in stock|available now|currently available)\b", RegexOptions.IgnoreCase);
        }

        private static bool IsLowestPriceIntent(string question)
        {
            return Regex.IsMatch(question ?? string.Empty, @"\b(cheapest|lowest price|least expensive|budget|most affordable)\b", RegexOptions.IgnoreCase);
        }

        private static bool IsHighestPriceIntent(string question)
        {
            return Regex.IsMatch(question ?? string.Empty, @"\b(most expensive|highest price)\b", RegexOptions.IgnoreCase);
        }

        private static int CountTermMatches(string text, string term)
        {
            return Regex.Matches(text, @"\b" + Regex.Escape(term) + @"(?:s|es)?\b", RegexOptions.IgnoreCase).Count;
        }

        private static string TrimForKnowledge(string value, int maxLength)
        {
            string trimmed = Regex.Replace(value ?? string.Empty, @"\s+", " ").Trim();
            return trimmed.Length <= maxLength ? trimmed : trimmed.Substring(0, maxLength).Trim() + "...";
        }

        private static string TruncateContext(string value, int maxLength)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return string.Empty;
            }

            string trimmed = value.Trim();
            return trimmed.Length <= maxLength ? trimmed : trimmed.Substring(0, maxLength).Trim();
        }

        private class KnowledgeChunk
        {
            public KnowledgeChunk(string source, string text)
            {
                Source = source;
                Text = text;
            }

            public string Source { get; private set; }
            public string Text { get; private set; }
        }
    }
}
