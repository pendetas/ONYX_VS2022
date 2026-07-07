using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

namespace ONYX_DDAC.Services
{
    public class OnyxKnowledgeService
    {
        private const int MaxFileBytes = 180000;
        private const int ChunkSize = 1200;
        private const int MaxChunks = 320;
        private const int MaxContextCharacters = 6000;
        private const string AssistantKnowledgeFileName = "onyx-assistant-knowledge.md";

        private static readonly HashSet<string> AllowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".aspx", ".ascx", ".master", ".md", ".txt", ".sql"
        };

        private static readonly HashSet<string> ExcludedDirectoryNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".git", ".vs", "bin", "obj", "packages", "Video", "Videos"
        };

        private static readonly HashSet<string> ExcludedFileNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "Web.config", "Web.Debug.config", "Web.Release.config", "AppSettings.Local.config",
            "packages.config", "ONYX_DDAC.csproj", "ONYX_DDAC.sln"
        };

        private static readonly HashSet<string> StopWords = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "a", "an", "and", "are", "as", "at", "be", "can", "do", "for", "from", "how", "i", "in",
            "is", "it", "me", "my", "of", "on", "or", "the", "to", "what", "when", "where", "with", "you"
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

        private IReadOnlyList<KnowledgeChunk> LoadChunks()
        {
            string root = rootPath;
            var chunks = new List<KnowledgeChunk>();

            foreach (string path in EnumerateSafeFiles(root).OrderBy(GetKnowledgeFilePriority).ThenBy(path => path, StringComparer.OrdinalIgnoreCase))
            {
                if (chunks.Count >= MaxChunks)
                {
                    break;
                }

                string text = ReadSafeText(path);
                if (string.IsNullOrWhiteSpace(text))
                {
                    continue;
                }

                string source = GetRelativePath(root, path);
                foreach (string chunkText in SplitIntoChunks(text))
                {
                    if (chunks.Count >= MaxChunks)
                    {
                        break;
                    }

                    chunks.Add(new KnowledgeChunk(source, chunkText));
                }
            }

            return chunks;
        }

        private static IEnumerable<string> EnumerateSafeFiles(string root)
        {
            IEnumerable<string> files;

            try
            {
                files = Directory.EnumerateFiles(root, "*.*", SearchOption.AllDirectories);
            }
            catch (IOException)
            {
                return Enumerable.Empty<string>();
            }
            catch (UnauthorizedAccessException)
            {
                return Enumerable.Empty<string>();
            }

            return files.Where(IsSafeKnowledgeFile);
        }

        private static bool IsSafeKnowledgeFile(string path)
        {
            string extension = Path.GetExtension(path);
            if (!AllowedExtensions.Contains(extension))
            {
                return false;
            }

            string fileName = Path.GetFileName(path);
            if (ExcludedFileNames.Contains(fileName))
            {
                return false;
            }

            if (path.Split(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)
                .Any(part => ExcludedDirectoryNames.Contains(part)))
            {
                return false;
            }

            try
            {
                return new FileInfo(path).Length <= MaxFileBytes;
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

            string normalized = Regex.Replace(text, @"<script[\s\S]*?</script>", " ", RegexOptions.IgnoreCase);
            normalized = Regex.Replace(normalized, @"<style[\s\S]*?</style>", " ", RegexOptions.IgnoreCase);
            normalized = Regex.Replace(normalized, @"<%[\s\S]*?%>", " ");
            normalized = Regex.Replace(normalized, @"<[^>]+>", " ");
            normalized = HttpUtility.HtmlDecode(normalized);
            normalized = Regex.Replace(normalized, @"(?i)\b(?:current\s+)?(?:ONYX\s+)?(?:catalog\s+)?knowledge base\b", "current ONYX information");
            normalized = Regex.Replace(normalized, @"\s+", " ").Trim();

            return normalized;
        }

        private static IEnumerable<string> SplitIntoChunks(string text)
        {
            for (int index = 0; index < text.Length; index += ChunkSize)
            {
                int length = Math.Min(ChunkSize, text.Length - index);
                string chunk = text.Substring(index, length).Trim();
                if (!string.IsNullOrWhiteSpace(chunk))
                {
                    yield return chunk;
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

            if (chunk.Source.IndexOf(AssistantKnowledgeFileName, StringComparison.OrdinalIgnoreCase) >= 0)
            {
                score += 10;
            }

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

            return score;
        }

        private static int CountTermMatches(string text, string term)
        {
            return Regex.Matches(text, @"\b" + Regex.Escape(term) + @"(?:s|es)?\b", RegexOptions.IgnoreCase).Count;
        }

        private static int GetKnowledgeFilePriority(string path)
        {
            string fileName = Path.GetFileName(path);
            if (string.Equals(fileName, AssistantKnowledgeFileName, StringComparison.OrdinalIgnoreCase))
            {
                return 0;
            }

            string extension = Path.GetExtension(path);
            if (string.Equals(extension, ".md", StringComparison.OrdinalIgnoreCase))
            {
                return 1;
            }

            return 2;
        }

        private static string GetRelativePath(string root, string path)
        {
            Uri rootUri = new Uri(AppendDirectorySeparator(root));
            Uri pathUri = new Uri(path);
            return Uri.UnescapeDataString(rootUri.MakeRelativeUri(pathUri).ToString()).Replace('/', Path.DirectorySeparatorChar);
        }

        private static string AppendDirectorySeparator(string path)
        {
            if (path.EndsWith(Path.DirectorySeparatorChar.ToString(), StringComparison.Ordinal))
            {
                return path;
            }

            return path + Path.DirectorySeparatorChar;
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
