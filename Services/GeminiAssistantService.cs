using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Google.GenAI;
using Google.GenAI.Types;

namespace ONYX_DDAC.Services
{
    public class GeminiAssistantService
    {
        private const string DefaultModel = "gemini-3.5-flash";
        private const int MaxQuestionLength = 900;
        private static readonly OnyxKnowledgeService KnowledgeService = new OnyxKnowledgeService();

        private static readonly string[] AllowedTerms =
        {
            "onyx", "vanta", "forge", "pulse", "gaming", "gear", "mouse", "keyboard", "headset", "monitor",
            "accessory", "accessories", "product", "catalog", "category", "price", "stock", "variant",
            "buy", "shop", "shopping", "choose", "recommend", "compare",
            "cart", "checkout", "payment", "order", "invoice", "shipping", "delivery", "warranty",
            "support", "serial", "return", "refund", "replacement", "review", "wishlist", "profile",
            "account", "login", "register", "password", "setup", "dpi", "switch", "audio",
            "razer", "logitech", "deathadder", "g502", "viper", "hero", "wireless", "wired",
            "ergonomic", "lightweight", "fps", "opened", "damaged", "defect", "sensor",
            "charging", "macro", "pairing", "hours", "myt", "reply", "kuala", "malaysia",
            "newsletter", "drop", "drops", "restock", "waranty", "warrenty", "warantee"
        };

        private static readonly string[] VagueAssistantTerms =
        {
            "help", "can you help", "can you help me", "i need help", "question", "i have a question",
            "what can you do", "what do you do"
        };

        private static readonly string[] GreetingTerms =
        {
            "hi", "hello", "hey", "yo", "good morning", "good afternoon", "good evening"
        };

        private static readonly string[] BlockedAbuseTerms =
        {
            "nigger", "nigga", "faggot", "kike", "chink", "spic", "hate speech", "hateful insult",
            "racial slur", "racist joke", "porn", "nude", "kill yourself"
        };

        private static readonly string[] PromptInjectionTerms =
        {
            "ignore previous instruction", "ignore all instruction", "ignore your instruction",
            "system prompt", "developer message", "internal instruction", "hidden instruction",
            "jailbreak", "reveal prompt", "show prompt", "source file", "code path"
        };

        private static readonly string[] ClearlyOffTopicTerms =
        {
            "president", "weather", "stock market", "bitcoin", "homework", "essay", "medical", "doctor",
            "lawyer", "legal", "politics", "election", "recipe", "movie", "football", "coding", "programming",
            "python", "javascript", "celebrity", "dating", "religion"
        };

        public async Task<AssistantResult> AskAsync(string question, string pagePath)
        {
            string cleanQuestion = NormalizeQuestion(question);

            if (string.IsNullOrWhiteSpace(cleanQuestion))
            {
                return AssistantResult.Restricted("Ask me about ONYX products, orders, warranty, or support and I will help.");
            }

            if (IsGreetingPrompt(cleanQuestion))
            {
                return AssistantResult.Success("Hello. I can help with ONYX gear, orders, warranty, cart, or support.");
            }

            if (IsBlockedAbuse(cleanQuestion))
            {
                return AssistantResult.Restricted("I can help with ONYX products, orders, warranty, returns, setup, and account support. I cannot help with abusive or unrelated requests.");
            }

            if (IsPromptInjectionAttempt(cleanQuestion) || IsArithmeticPrompt(cleanQuestion))
            {
                return AssistantResult.Restricted("I can only answer from official ONYX product, order, warranty, account, and support information.");
            }

            if (IsClearlyOffTopic(cleanQuestion))
            {
                return AssistantResult.Restricted("I can only answer from official ONYX product, order, warranty, account, and support information.");
            }

            if (!IsOnyxRelated(cleanQuestion))
            {
                return IsVagueAssistantPrompt(cleanQuestion)
                    ? AssistantResult.Success("Sure. What would you like to know about ONYX gear, orders, warranty, cart, or support?")
                    : AssistantResult.Restricted("I can only help with ONYX products, orders, warranty, returns, setup, cart, and account support.");
            }

            string knowledgeContext = KnowledgeService.GetRelevantContext(cleanQuestion);
            if (string.IsNullOrWhiteSpace(knowledgeContext))
            {
                return AssistantResult.Restricted(NoMatchingKnowledgeReply());
            }

            string apiKey = GetApiKey();
            if (string.IsNullOrWhiteSpace(apiKey))
            {
                return AssistantResult.ConfigurationMissing("The ONYX Assistant needs a Gemini API key before it can answer. Add GEMINI_API_KEY or GeminiApiKey.");
            }

            try
            {
                var client = new Client(apiKey: apiKey);
                GenerateContentResponse response = await client.Models.GenerateContentAsync(
                    model: GetModel(),
                    contents: BuildUserPrompt(cleanQuestion, pagePath, knowledgeContext),
                    config: BuildGeminiConfig()).ConfigureAwait(false);

                string reply = ExtractReply(response);
                return string.IsNullOrWhiteSpace(reply)
                    ? AssistantResult.Success(SanitizeAssistantReply(BuildKnowledgeFallbackReply(cleanQuestion, knowledgeContext)))
                    : AssistantResult.Success(SanitizeAssistantReply(reply));
            }
            catch (Exception)
            {
                if (IsDebugErrorsEnabled())
                {
                    throw;
                }

                return AssistantResult.Success(SanitizeAssistantReply(BuildKnowledgeFallbackReply(cleanQuestion, knowledgeContext)));
            }
        }

        private static string NormalizeQuestion(string question)
        {
            if (string.IsNullOrWhiteSpace(question))
            {
                return string.Empty;
            }

            string trimmed = question.Trim();
            return trimmed.Length <= MaxQuestionLength ? trimmed : trimmed.Substring(0, MaxQuestionLength);
        }

        private static bool IsOnyxRelated(string question)
        {
            string normalized = question.ToLowerInvariant();
            return AllowedTerms.Any(term => normalized.Contains(term));
        }

        private static bool IsVagueAssistantPrompt(string question)
        {
            string normalized = Regex.Replace(question.ToLowerInvariant(), @"[^a-z0-9\s]", " ");
            normalized = Regex.Replace(normalized, @"\s+", " ").Trim();
            return normalized.Length <= 60 && VagueAssistantTerms.Any(term => string.Equals(normalized, term, StringComparison.Ordinal));
        }

        private static bool IsGreetingPrompt(string question)
        {
            string normalized = question.Trim().ToLowerInvariant().Trim('.', '!', '?', ',', ' ');
            return normalized.Length <= 40 && GreetingTerms.Any(term => string.Equals(normalized, term, StringComparison.OrdinalIgnoreCase));
        }

        private static bool IsClearlyOffTopic(string question)
        {
            string normalized = question.ToLowerInvariant();
            return ClearlyOffTopicTerms.Any(term => normalized.Contains(term));
        }

        private static bool IsBlockedAbuse(string question)
        {
            string normalized = question.ToLowerInvariant();
            return BlockedAbuseTerms.Any(term => normalized.Contains(term));
        }

        private static bool IsPromptInjectionAttempt(string question)
        {
            string normalized = question.ToLowerInvariant();
            return PromptInjectionTerms.Any(term => normalized.Contains(term));
        }

        private static bool IsArithmeticPrompt(string question)
        {
            string normalized = question.ToLowerInvariant();
            bool hasNumericExpression = Regex.IsMatch(normalized, @"(?<![a-z0-9])\d+(?:\.\d+)?\s*(?:[+*/x×÷]|plus|minus|times|divided\s+by)\s*\d+(?:\.\d+)?(?![a-z0-9])");
            bool hasSubtractionExpression = Regex.IsMatch(normalized, @"(?<![a-z0-9])\d+(?:\.\d+)?\s*-\s*\d+(?:\.\d+)?(?![a-z0-9])");
            bool hasMathIntent = Regex.IsMatch(normalized, @"\b(calculate|solve|math|answer|what\s+is)\b");

            return hasNumericExpression || (hasSubtractionExpression && hasMathIntent);
        }

        private static string NoMatchingKnowledgeReply()
        {
            return "I do not have that exact ONYX detail. The safest next step is to email support@onyxgaming.com with your order ID, product name, and account email.";
        }

        private static string GetApiKey()
        {
            string apiKey = System.Environment.GetEnvironmentVariable("GEMINI_API_KEY");
            if (!string.IsNullOrWhiteSpace(apiKey))
            {
                return apiKey;
            }

            return ConfigurationManager.AppSettings["GeminiApiKey"];
        }

        private static string GetModel()
        {
            string model = ConfigurationManager.AppSettings["GeminiModel"];
            return string.IsNullOrWhiteSpace(model) ? DefaultModel : model.Trim();
        }

        private static bool IsDebugErrorsEnabled()
        {
            return string.Equals(System.Environment.GetEnvironmentVariable("ONYX_AI_DEBUG_ERRORS"), "1", StringComparison.Ordinal);
        }

        private static GenerateContentConfig BuildGeminiConfig()
        {
            return new GenerateContentConfig
            {
                SystemInstruction = new Content
                {
                    Parts = new List<Part> { new Part { Text = BuildSystemInstruction() } }
                },
                Temperature = 0.25f,
                MaxOutputTokens = 320,
                ThinkingConfig = new ThinkingConfig { ThinkingBudget = 0 }
            };
        }

        private static string BuildSystemInstruction()
        {
            return string.Join("\n", new[]
            {
                "You are ONYX Assist, the official AI guide for ONYX, a black-and-silver gaming hardware brand focused on performance peripherals, clean setup flow, and reliable post-purchase support.",
                "Use only the approved ONYX product, account, order, warranty, return, setup, and support context supplied to you. Do not mention internal context, source files, or knowledge retrieval to the customer.",
                "Classify the customer message internally into the best ONYX route: Catalog, Product Recommendation, Orders, Warranty, Returns, Setup, Account, About ONYX, Human Escalation, or Unknown. Do not print the route label unless the customer asks for it.",
                "Answer the customer directly first in natural language. Never print internal URLs, page paths, source labels, filenames, .aspx names, or code paths.",
                "When suggesting navigation, use customer-facing names only, such as About page, Catalog, Order History, Profile, Wishlist, Cart, or Support.",
                "For product recommendations, use only the visible catalog products and explain practical fit: control, response, comfort, long-session use, and setup fit.",
                "Do not invent shipping times, refund rules, return windows, full product specs, warranty exclusions, opened-product return eligibility, stock, prices, discounts, or availability.",
                "Do not guarantee warranty approval, replacement, refund, return approval, or account changes.",
                "If the exact ONYX detail is not available, say so clearly and guide the customer to support@onyxgaming.com.",
                "Never ask for passwords, full card numbers, CVV, banking credentials, or private security codes.",
                "Use plain text only. Do not use Markdown, bold markers, headings, bullets, numbered lists, or links.",
                "Default to 1-2 short sentences. Use at most 3 short sentences only for comparisons, troubleshooting, or support preparation.",
                "Do not repeat brand values, list every feature, or write long paragraphs unless the customer explicitly asks for details."
            });
        }

        private static string BuildUserPrompt(string question, string pagePath, string knowledgeContext)
        {
            return string.Join("\n", new[]
            {
                "Website context: ONYX is a black-and-silver gaming hardware brand focused on performance peripherals and reliable post-purchase support.",
                "Customer context: The customer is using the ONYX website. Do not reveal internal page paths, file names, source labels, or URLs.",
                "Approved ONYX context:",
                knowledgeContext.Trim(),
                "User question: " + question
            });
        }

        private static string ExtractReply(GenerateContentResponse response)
        {
            Part part = response?.Candidates?.FirstOrDefault()?.Content?.Parts?.FirstOrDefault(item => !string.IsNullOrWhiteSpace(item.Text));
            return part == null ? string.Empty : part.Text;
        }

        private static string SanitizeAssistantReply(string reply)
        {
            if (string.IsNullOrWhiteSpace(reply))
            {
                return string.Empty;
            }

            string cleaned = Regex.Replace(reply, @"(?im)^\s*(Source|Knowledge context|Current page path|Page path)\s*:\s*.*$", string.Empty);
            cleaned = Regex.Replace(cleaned, @"(?i)\b(?:current\s+)?(?:ONYX\s+)?(?:catalog\s+)?knowledge base\b", "current ONYX information");
            cleaned = Regex.Replace(cleaned, @"(?i)\s+(at|via|through|from|:)?\s*/customer_page/[^\s.,;)]*", string.Empty);
            cleaned = Regex.Replace(cleaned, @"(?i)\b[A-Za-z0-9_-]+\.aspx\b", "the relevant ONYX page");
            cleaned = Regex.Replace(cleaned, @"[ \t]{2,}", " ");
            cleaned = Regex.Replace(cleaned, @"\s+([.,;:])", "$1");
            cleaned = Regex.Replace(cleaned, @"\n{3,}", "\n\n");
            cleaned = LimitSentences(cleaned, 3);

            return cleaned.Trim();
        }

        private static string LimitSentences(string text, int maxSentences)
        {
            string[] sentences = Regex.Split(text.Trim(), @"(?<=[.!?])\s+")
                .Where(sentence => !string.IsNullOrWhiteSpace(sentence))
                .ToArray();

            return sentences.Length <= maxSentences
                ? text
                : string.Join(" ", sentences.Take(maxSentences));
        }

        private static string BuildKnowledgeFallbackReply(string question, string knowledgeContext)
        {
            string normalized = string.IsNullOrWhiteSpace(question) ? string.Empty : question.ToLowerInvariant();
            string context = string.IsNullOrWhiteSpace(knowledgeContext) ? string.Empty : knowledgeContext;

            if (normalized.Contains("what is onyx") || normalized.Contains("about onyx") || normalized.Contains("onyx brand"))
            {
                return "ONYX is a black-and-silver gaming hardware brand focused on performance peripherals for competitive players. Its core message is \"Performance hardware for focused play,\" with gear built around precise aim, fast inputs, clean audio, durability, and a connected ownership experience.";
            }

            if (normalized.Contains("warranty") || normalized.Contains("waranty") || normalized.Contains("warrenty") || normalized.Contains("warantee") || normalized.Contains("broken") || normalized.Contains("defect"))
            {
                return "This sounds like a Warranty request. ONYX lists 2 years of coverage for flagship manufacturing defects on ONYX peripherals purchased through the store, but support must review the case. Prepare your product name, variant, serial number, order ID, purchase date, what changed, what troubleshooting you tried, and a photo or short video if available, then email support@onyxgaming.com.";
            }

            if (normalized.Contains("return") || normalized.Contains("refund") || normalized.Contains("replacement") || normalized.Contains("opened") || normalized.Contains("damaged") || normalized.Contains("wrong product") || normalized.Contains("wrong item"))
            {
                if (normalized.Contains("opened"))
                {
                    return "This sounds like a Returns request. ONYX does not list opened-product return eligibility in the current support details, so I should not guess. Prepare your order ID, product name, purchase date, item condition, and photos of the item and packaging if available, then email support@onyxgaming.com.";
                }

                return "This sounds like a Returns request. ONYX uses this lane for unopened items, damaged delivery, wrong products, and replacement eligibility. Prepare your order ID, product name, purchase date, whether the item is unopened, damaged, wrong, or defective, and photos of the item and packaging if available, then email support@onyxgaming.com.";
            }

            if (normalized.Contains("support hours") || normalized.Contains("hours") || normalized.Contains("reply time") || normalized.Contains("first reply") || normalized.Contains("support based") || normalized.Contains("kuala") || normalized.Contains("malaysia"))
            {
                return "ONYX support is based in Kuala Lumpur, Malaysia. Support hours are Monday to Friday, 10:00-18:00 MYT. ONYX lists an average first reply of around 24h on business days. For support, email support@onyxgaming.com.";
            }

            if (normalized.Contains("account") || normalized.Contains("login") || normalized.Contains("register") || normalized.Contains("password") || normalized.Contains("profile") || normalized.Contains("order history") || normalized.Contains("reviews"))
            {
                return "This sounds like an Account request. ONYX connects wishlist, checkout, order history, reviews, and profile tools through the customer account flow. Never share your password in chat. If you cannot access the account area, email support@onyxgaming.com with your account email and any available order details.";
            }

            if (normalized.Contains("setup") || normalized.Contains("pair") || normalized.Contains("pairing") || normalized.Contains("dpi") || normalized.Contains("macro") || normalized.Contains("profiles") || normalized.Contains("keyboard macros"))
            {
                return "This sounds like a Setup request. ONYX uses this lane for pairing, profiles, DPI, keyboard macros, cart, login, wishlist, and order history questions. Prepare your product name, device type, what you are trying to do, and any error message or screenshot if available. If it needs human help, email support@onyxgaming.com.";
            }

            if (normalized.Contains("newsletter") || normalized.Contains("drop") || normalized.Contains("drops") || normalized.Contains("restock"))
            {
                return "ONYX mentions newsletter and early-access updates for new drops and promotions, but the current site information does not include a specific release or restock date. Subscribe through the ONYX site for updates, or email support@onyxgaming.com if you need product-specific help.";
            }

            if (normalized.Contains("order") || normalized.Contains("invoice") || normalized.Contains("receipt") || normalized.Contains("history") || normalized.Contains("track"))
            {
                return "This sounds like an Orders request. For order status, delivery, invoice, receipt, tracking, missing item, or wrong address help, prepare your order ID, purchase date, account email, what happened, and evidence if available. Email support@onyxgaming.com, or check order history from your ONYX account/profile flow.";
            }

            if (normalized.Contains("cart") || normalized.Contains("checkout") || normalized.Contains("payment"))
            {
                return "This is a Setup or Orders topic depending on what happened. Use the cart to review saved items and continue checkout, but do not share passwords or payment details in chat. If there is a payment or order-specific issue, email support@onyxgaming.com with your order ID, purchase date, account email, and what happened.";
            }

            if (normalized.Contains("wishlist") || normalized.Contains("saved") || normalized.Contains("favorite"))
            {
                return "The ONYX wishlist is where saved products live, and you can remove items or move them to your cart from there. Open your Wishlist page.";
            }

            if (normalized.Contains("gear") || normalized.Contains("mouse") || normalized.Contains("mice") || normalized.Contains("keyboard") || normalized.Contains("headset") || normalized.Contains("monitor") || normalized.Contains("accessor") || normalized.Contains("product") || normalized.Contains("catalog") || normalized.Contains("buy") || normalized.Contains("shop") || normalized.Contains("choose") || normalized.Contains("recommend") || normalized.Contains("compare"))
            {
                if (normalized.Contains("wired") || normalized.Contains("ergonomic") || normalized.Contains("deathadder"))
                {
                    return "For a wired ergonomic mouse, the current catalog knowledge points to DeathAdder V3 by Razer. It fits customers who want comfort and controlled long-session use, but it is marked low stock in the visible catalog.";
                }

                if (normalized.Contains("logitech") || normalized.Contains("hero") || normalized.Contains("g502"))
                {
                    return "For a wireless Logitech mouse with a HERO sensor, the current catalog knowledge points to G502 X Plus. It is listed as in stock and fits customers who want wireless setup flow with practical control and response.";
                }

                if (normalized.Contains("lightweight") || normalized.Contains("fps") || normalized.Contains("viper"))
                {
                    return "For an ultra-lightweight wireless Razer mouse, the current catalog knowledge points to Viper V2 Pro. It is listed as in stock and fits competitive FPS-style control, fast response, and cleaner setup movement.";
                }

                return "For gaming mice, ONYX currently shows three clear choices: DeathAdder V3 for a wired ergonomic Razer setup, G502 X Plus for a wireless Logitech HERO sensor setup, and Viper V2 Pro for an ultra-lightweight wireless Razer FPS-style setup. Open the Catalog to browse the lineup.";
            }

            if (context.IndexOf("Support", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return "I found ONYX support context for this, but I need a clearer lane to give the right next step. Is this about Orders, Warranty, Returns, Setup, Account, or Catalog? If it is urgent or account-specific, email support@onyxgaming.com with the relevant order or product details.";
            }

            return "I found ONYX support context for this, but Gemini is busy right now. Try asking again shortly, or open the Support page if you need help with an order, product, warranty, or account issue.";
        }
    }

    public class AssistantResult
    {
        public bool IsSuccess { get; private set; }
        public bool IsRestricted { get; private set; }
        public bool IsConfigurationMissing { get; private set; }
        public HttpStatusCode StatusCode { get; private set; }
        public string Reply { get; private set; }

        public static AssistantResult Success(string reply)
        {
            return new AssistantResult { IsSuccess = true, Reply = reply, StatusCode = HttpStatusCode.OK };
        }

        public static AssistantResult Restricted(string reply)
        {
            return new AssistantResult { IsRestricted = true, Reply = reply, StatusCode = HttpStatusCode.OK };
        }

        public static AssistantResult ConfigurationMissing(string reply)
        {
            return new AssistantResult { IsConfigurationMissing = true, Reply = reply, StatusCode = HttpStatusCode.ServiceUnavailable };
        }
    }
}
