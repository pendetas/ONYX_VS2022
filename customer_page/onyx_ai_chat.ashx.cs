using System;
using System.IO;
using System.Net;
using System.Threading.Tasks;
using System.Web;
using Newtonsoft.Json;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public class onyx_ai_chat : HttpTaskAsyncHandler
    {
        private readonly GeminiAssistantService assistantService = new GeminiAssistantService();

        public override bool IsReusable
        {
            get { return false; }
        }

        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            if (!string.Equals(context.Request.HttpMethod, "POST", StringComparison.OrdinalIgnoreCase))
            {
                WriteJson(context, (int)HttpStatusCode.MethodNotAllowed, new ChatResponse
                {
                    Reply = "Use POST to talk to the ONYX Assistant."
                });
                return;
            }

            ChatRequest request;

            try
            {
                request = ReadRequest(context);
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
                AssistantResult result = await assistantService
                    .AskAsync(request.Message, request.PagePath)
                    .ConfigureAwait(false);

                int statusCode = result.IsSuccess || result.IsRestricted
                    ? (int)HttpStatusCode.OK
                    : (int)result.StatusCode;

                WriteJson(context, statusCode, new ChatResponse
                {
                    Reply = result.Reply,
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
                        : "The ONYX Assistant had trouble answering. Please try again or contact support@onyxgaming.com."
                });
            }
        }

        private static ChatRequest ReadRequest(HttpContext context)
        {
            using (var reader = new StreamReader(context.Request.InputStream))
            {
                string body = reader.ReadToEnd();

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

            [JsonProperty("restricted")]
            public bool Restricted { get; set; }

            [JsonProperty("configurationMissing")]
            public bool ConfigurationMissing { get; set; }
        }
    }
}
