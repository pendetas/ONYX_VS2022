using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public class onyx_ai_chat : HttpTaskAsyncHandler, IReadOnlySessionState
    {
        private const int MaxRequestBodyBytes = 16384;
        private readonly GeminiAssistantService assistantService = new GeminiAssistantService();

        public override bool IsReusable
        {
            get { return false; }
        }

        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();

            if (!string.Equals(context.Request.HttpMethod, "POST", StringComparison.OrdinalIgnoreCase))
            {
                WriteJson(context, (int)HttpStatusCode.MethodNotAllowed, new ChatResponse
                {
                    Reply = "Use POST to talk to the ONYX Assistant."
                });
                return;
            }

            if (string.IsNullOrWhiteSpace(context.Request.ContentType)
                || !context.Request.ContentType.StartsWith("application/json", StringComparison.OrdinalIgnoreCase))
            {
                WriteJson(context, (int)HttpStatusCode.UnsupportedMediaType, new ChatResponse
                {
                    Reply = "Send the ONYX Assistant message as JSON."
                });
                return;
            }

            if (context.Request.ContentLength > MaxRequestBodyBytes)
            {
                WriteJson(context, (int)HttpStatusCode.RequestEntityTooLarge, new ChatResponse
                {
                    Reply = "That message is too large. Please shorten it and try again."
                });
                return;
            }

            ChatRequest request;

            try
            {
                request = ReadRequest(context);
            }
            catch (InvalidDataException)
            {
                WriteJson(context, (int)HttpStatusCode.RequestEntityTooLarge, new ChatResponse
                {
                    Reply = "That message is too large. Please shorten it and try again."
                });
                return;
            }
            catch (JsonException)
            {
                WriteJson(context, (int)HttpStatusCode.BadRequest, new ChatResponse
                {
                    Reply = "The ONYX Assistant could not read that message. Please try again."
                });
                return;
            }

            try
            {
                long? currentUserId = TryGetCurrentUserId(context);
                AssistantResult result = await assistantService
                    .AskAsync(request.Message, request.PagePath, currentUserId)
                    .ConfigureAwait(false);

                int statusCode = result.IsSuccess || result.IsRestricted
                    ? (int)HttpStatusCode.OK
                    : (int)result.StatusCode;

                WriteJson(context, statusCode, new ChatResponse
                {
                    Reply = result.Reply,
                    Actions = MapActions(result.Actions),
                    Restricted = result.IsRestricted,
                    ConfigurationMissing = result.IsConfigurationMissing
                });
            }
            catch (Exception ex)
            {
                WriteJson(context, (int)HttpStatusCode.InternalServerError, new ChatResponse
                {
                    Reply = IsDebugErrorsEnabled()
                        ? ex.GetType().FullName + ": " + ex.Message
                        : "The ONYX Assistant had trouble answering. Please try again or contact support.onyxgaming@gmail.com."
                });
            }
        }

        private static ChatRequest ReadRequest(HttpContext context)
        {
            using (var reader = new StreamReader(context.Request.InputStream))
            {
                string body = reader.ReadToEnd();

                if (body.Length > MaxRequestBodyBytes)
                {
                    throw new InvalidDataException("Assistant request body is too large.");
                }

                if (string.IsNullOrWhiteSpace(body))
                {
                    return new ChatRequest();
                }

                return JsonConvert.DeserializeObject<ChatRequest>(body) ?? new ChatRequest();
            }
        }

        private static void WriteJson(HttpContext context, int statusCode, ChatResponse response)
        {
            context.Response.Clear();
            context.Response.ContentType = "application/json";
            context.Response.StatusCode = statusCode;
            context.Response.TrySkipIisCustomErrors = true;
            context.Response.Write(JsonConvert.SerializeObject(response));
        }

        private static bool IsDebugErrorsEnabled()
        {
            return string.Equals(Environment.GetEnvironmentVariable("ONYX_AI_DEBUG_ERRORS"), "1", StringComparison.Ordinal);
        }

        private static long? TryGetCurrentUserId(HttpContext context)
        {
            if (context == null || context.Session == null)
            {
                return null;
            }

            object value = context.Session["UserId"];
            if (value == null)
            {
                return null;
            }

            long userId;
            return long.TryParse(Convert.ToString(value), out userId) && userId > 0
                ? (long?)userId
                : null;
        }

        private static IList<ChatActionResponse> MapActions(IList<AssistantAction> actions)
        {
            if (actions == null || actions.Count == 0)
            {
                return new List<ChatActionResponse>();
            }

            return actions
                .Where(action => action != null && !string.IsNullOrWhiteSpace(action.Title))
                .Select(action => new ChatActionResponse
                {
                    Type = action.Type,
                    Title = action.Title,
                    Subtitle = action.Subtitle,
                    ImageUrl = action.ImageUrl,
                    Url = action.Url,
                    Status = action.Status,
                    Meta = action.Meta
                })
                .ToList();
        }

        private class ChatRequest
        {
            [JsonProperty("message")]
            public string Message { get; set; }

            [JsonProperty("pagePath")]
            public string PagePath { get; set; }
        }

        private class ChatResponse
        {
            [JsonProperty("reply")]
            public string Reply { get; set; }

            [JsonProperty("actions")]
            public IList<ChatActionResponse> Actions { get; set; }

            [JsonProperty("restricted")]
            public bool Restricted { get; set; }

            [JsonProperty("configurationMissing")]
            public bool ConfigurationMissing { get; set; }
        }

        private class ChatActionResponse
        {
            [JsonProperty("type")]
            public string Type { get; set; }

            [JsonProperty("title")]
            public string Title { get; set; }

            [JsonProperty("subtitle")]
            public string Subtitle { get; set; }

            [JsonProperty("imageUrl")]
            public string ImageUrl { get; set; }

            [JsonProperty("url")]
            public string Url { get; set; }

            [JsonProperty("status")]
            public string Status { get; set; }

            [JsonProperty("meta")]
            public string Meta { get; set; }
        }
    }
}
