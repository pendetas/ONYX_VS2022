using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using ONYX_DDAC.Helpers;

namespace ONYX_DDAC.Services
{
    public class S3Service
    {
        private static readonly HttpClient HttpClient = new HttpClient();

        // ponytail: product and campaign media use one upload path; split only if their storage requirements diverge.
        public string Upload(HttpPostedFile postedFile, string kind)
        {
            if (postedFile == null || postedFile.ContentLength <= 0)
                throw new ArgumentException("A media file is required.");

            if (!string.Equals(kind, "product", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(kind, "campaign", StringComparison.OrdinalIgnoreCase))
                throw new ArgumentException("Unsupported media kind.", nameof(kind));

            string apiUrl = ReadRequiredSetting("ONYX_MEDIA_API_URL");
            string apiToken = ReadRequiredSetting("ONYX_MEDIA_API_TOKEN");
            string extension = Path.GetExtension(postedFile.FileName ?? string.Empty).ToLowerInvariant();
            string contentType = (postedFile.ContentType ?? string.Empty).ToLowerInvariant();
            var serializer = new JavaScriptSerializer();
            string requestBody = serializer.Serialize(new
            {
                extension = extension,
                contentType = contentType,
                kind = kind.ToLowerInvariant()
            });

            string responseBody;
            using (var request = new HttpRequestMessage(HttpMethod.Post, apiUrl))
            {
                request.Headers.Add("x-onyx-media-token", apiToken);
                request.Content = new StringContent(requestBody, Encoding.UTF8, "application/json");

                using (HttpResponseMessage response = HttpClient.SendAsync(request).GetAwaiter().GetResult())
                {
                    if (!response.IsSuccessStatusCode)
                        throw new InvalidOperationException("Unable to create the media upload URL.");

                    responseBody = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
                }
            }

            var uploadResponse = serializer.Deserialize<Dictionary<string, object>>(responseBody);
            string uploadUrl = ReadResponseValue(uploadResponse, "uploadUrl");
            string objectKey = ReadResponseValue(uploadResponse, "objectKey");
            if (string.IsNullOrWhiteSpace(uploadUrl) || string.IsNullOrWhiteSpace(objectKey))
                throw new InvalidOperationException("The media upload service returned an invalid response.");

            if (postedFile.InputStream.CanSeek)
                postedFile.InputStream.Position = 0;

            using (var uploadRequest = new HttpRequestMessage(HttpMethod.Put, uploadUrl))
            using (var fileContent = new StreamContent(postedFile.InputStream))
            {
                fileContent.Headers.ContentType = new MediaTypeHeaderValue(contentType);
                fileContent.Headers.ContentLength = postedFile.ContentLength;
                uploadRequest.Content = fileContent;

                using (HttpResponseMessage uploadResult = HttpClient.SendAsync(uploadRequest).GetAwaiter().GetResult())
                {
                    if (!uploadResult.IsSuccessStatusCode)
                        throw new InvalidOperationException("Unable to upload media to cloud storage.");
                }
            }

            return MediaUrlHelper.Resolve(objectKey);
        }

        private static string ReadRequiredSetting(string key)
        {
            string value = Environment.GetEnvironmentVariable(key) ??
                           Environment.GetEnvironmentVariable(key, EnvironmentVariableTarget.User) ??
                           ConfigurationManager.AppSettings[key];

            if (string.IsNullOrWhiteSpace(value))
                throw new InvalidOperationException(key + " is not configured.");

            return value.Trim();
        }

        private static string ReadResponseValue(IDictionary<string, object> response, string key)
        {
            object value;
            return response != null && response.TryGetValue(key, out value) ? value as string : null;
        }
    }
}
