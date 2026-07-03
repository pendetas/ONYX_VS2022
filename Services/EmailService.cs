using System;
using System.Configuration;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;
using System.Web;
using System.Web.Hosting;

namespace ONYX_DDAC.Services
{
    public class EmailService
    {
        public async Task SendRegistrationOtpAsync(string recipientEmail, string otp, int expiryMinutes)
        {
            await SendAsync(
                recipientEmail,
                "Your ONYX verification code",
                "Your ONYX verification code is: " + otp + Environment.NewLine +
                "This code expires in " + expiryMinutes + " minutes." + Environment.NewLine +
                "If you did not request this code, you can ignore this email.");
        }

        public async Task SendAccountCreatedAsync(
            string recipientEmail,
            string displayName,
            string signInMethod)
        {
            await SendAsync(
                recipientEmail,
                "Welcome to ONYX Gaming",
                BuildAccountCreatedHtmlBody(displayName, signInMethod),
                true,
                BuildAccountCreatedBody(displayName, signInMethod));
        }

        public static string BuildAccountCreatedBody(string displayName, string signInMethod)
        {
            string name = string.IsNullOrWhiteSpace(displayName)
                ? "there"
                : displayName.Trim();

            return
                "Hi " + name + "," + Environment.NewLine +
                Environment.NewLine +
                "Welcome to ONYX Gaming - your registration is complete." + Environment.NewLine +
                Environment.NewLine +
                "We're excited to have you join our community of gamers, creators, and performance-driven players. " +
                "ONYX Gaming is built for those who value precision, speed, comfort, and style in every gaming setup." +
                Environment.NewLine +
                Environment.NewLine +
                "With your account, you can now explore our latest gaming gear, manage your profile, track your orders, " +
                "and stay updated with new product drops, exclusive offers, and member-only updates." +
                Environment.NewLine +
                Environment.NewLine +
                "Thank you for becoming part of ONYX Gaming. Your next level starts here." + Environment.NewLine +
                Environment.NewLine +
                "Best regards," + Environment.NewLine +
                "The ONYX Gaming Team" + Environment.NewLine +
                Environment.NewLine +
                "Need help? Contact us anytime." + Environment.NewLine +
                Environment.NewLine +
                "Email: support.onyxgaming@gmail.com" + Environment.NewLine +
                "Phone: +60 XX-XXX XXXX" + Environment.NewLine +
                "Website: www.onyxgaming.com" + Environment.NewLine +
                Environment.NewLine +
                "Follow us for new drops, gaming gear updates, and exclusive offers." + Environment.NewLine +
                Environment.NewLine +
                "You received this email because you registered an account with ONYX Gaming. " +
                "If this was not you, please contact our support team immediately." + Environment.NewLine +
                Environment.NewLine +
                "ONYX Gaming" + Environment.NewLine +
                "Performance Gear for Serious Players";
        }

        public static string BuildAccountCreatedHtmlBody(string displayName, string signInMethod)
        {
            string name = string.IsNullOrWhiteSpace(displayName)
                ? "there"
                : displayName.Trim();
            string encodedName = WebUtility.HtmlEncode(name);

            return
                "<!doctype html>" +
                "<html><body style=\"margin:0;padding:0;background:#050505;color:#f5f5f5;font-family:Arial,Helvetica,sans-serif;\">" +
                "<div style=\"max-width:640px;margin:0 auto;padding:36px 24px;\">" +
                "<div style=\"border:1px solid #242424;background:#0b0b0b;padding:32px;\">" +
                "<div style=\"font-size:22px;font-weight:700;letter-spacing:1px;margin-bottom:28px;\">ONYX Gaming</div>" +
                "<p style=\"font-size:16px;line-height:1.7;margin:0 0 18px;\">Hi " + encodedName + ",</p>" +
                "<p style=\"font-size:16px;line-height:1.7;margin:0 0 18px;\">Welcome to <strong>ONYX Gaming</strong> - your registration is complete.</p>" +
                "<p style=\"font-size:15px;line-height:1.7;color:#d7d7d7;margin:0 0 18px;\">We're excited to have you join our community of gamers, creators, and performance-driven players. ONYX Gaming is built for those who value precision, speed, comfort, and style in every gaming setup.</p>" +
                "<p style=\"font-size:15px;line-height:1.7;color:#d7d7d7;margin:0 0 18px;\">With your account, you can now explore our latest gaming gear, manage your profile, track your orders, and stay updated with new product drops, exclusive offers, and member-only updates.</p>" +
                "<p style=\"font-size:15px;line-height:1.7;color:#d7d7d7;margin:0 0 26px;\">Thank you for becoming part of ONYX Gaming. Your next level starts here.</p>" +
                "<p style=\"font-size:15px;line-height:1.7;margin:0 0 28px;\">Best regards,<br><strong>The ONYX Gaming Team</strong></p>" +
                "<hr style=\"border:0;border-top:1px solid #2b2b2b;margin:0 0 24px;\">" +
                "<p style=\"font-size:14px;line-height:1.7;color:#cfcfcf;margin:0 0 12px;\">Need help? Contact us anytime.</p>" +
                "<p style=\"font-size:14px;line-height:1.8;color:#cfcfcf;margin:0 0 24px;\">" +
                "Email: <a href=\"mailto:support.onyxgaming@gmail.com\" style=\"color:#ffffff;\">support.onyxgaming@gmail.com</a><br>" +
                "Phone: +60 XX-XXX XXXX<br>" +
                "Website: <a href=\"http://www.onyxgaming.com/\" style=\"color:#ffffff;\">www.onyxgaming.com</a>" +
                "</p>" +
                "<p style=\"font-size:14px;line-height:1.7;color:#cfcfcf;margin:0 0 24px;\">Follow us for new drops, gaming gear updates, and exclusive offers.</p>" +
                "<p style=\"font-size:12px;line-height:1.7;color:#8f8f8f;margin:0 0 22px;\">You received this email because you registered an account with ONYX Gaming. If this was not you, please contact our support team immediately.</p>" +
                "<p style=\"font-size:13px;line-height:1.7;color:#ffffff;margin:0;\"><strong>ONYX Gaming</strong><br>Performance Gear for Serious Players</p>" +
                "</div></div></body></html>";
        }

        private async Task SendAsync(string recipientEmail, string subject, string body)
        {
            await SendAsync(recipientEmail, subject, body, false, null);
        }

        private async Task SendAsync(
            string recipientEmail,
            string subject,
            string body,
            bool isHtml,
            string plainTextBody)
        {
            string host = GetRequiredSetting("SmtpHost");
            string fromAddress = GetRequiredSetting("EmailFromAddress", "SmtpFromAddress");
            string fromName = GetOptionalSetting("EmailFromName", "SmtpFromName") ?? "ONYX";
            string username = GetOptionalSetting("SmtpUsername");
            string password = GetOptionalSetting("SmtpPassword");

            int port;
            if (!int.TryParse(ConfigurationManager.AppSettings["SmtpPort"], out port))
                port = 587;

            bool enableSsl;
            if (!bool.TryParse(ConfigurationManager.AppSettings["SmtpEnableSsl"], out enableSsl))
                enableSsl = true;

            using (MailMessage message = new MailMessage())
            {
                message.From = new MailAddress(fromAddress, fromName);
                message.To.Add(new MailAddress(recipientEmail));
                message.Subject = subject;
                message.Body = body;
                message.IsBodyHtml = isHtml;
                if (isHtml && !string.IsNullOrWhiteSpace(plainTextBody))
                    message.AlternateViews.Add(
                        AlternateView.CreateAlternateViewFromString(
                            plainTextBody,
                            null,
                            "text/plain"));

                using (SmtpClient client = new SmtpClient(host, port))
                {
                    client.EnableSsl = enableSsl;
                    client.DeliveryMethod = SmtpDeliveryMethod.Network;
                    client.UseDefaultCredentials = false;

                    if (!string.IsNullOrWhiteSpace(username))
                        client.Credentials = new NetworkCredential(username, password ?? string.Empty);

                    try
                    {
                        await client.SendMailAsync(message);
                        WriteEmailDebugLog(
                            "sent",
                            recipientEmail,
                            subject,
                            null);
                    }
                    catch (Exception exception)
                    {
                        WriteEmailDebugLog(
                            "failed",
                            recipientEmail,
                            subject,
                            exception);
                        throw;
                    }
                }
            }
        }

        private static void WriteEmailDebugLog(
            string status,
            string recipientEmail,
            string subject,
            Exception exception)
        {
            try
            {
                string basePath = HttpContext.Current == null
                    ? HostingEnvironment.MapPath("~/App_Data") ?? AppDomain.CurrentDomain.BaseDirectory
                    : HttpContext.Current.Server.MapPath("~/App_Data");
                Directory.CreateDirectory(basePath);
                string path = Path.Combine(basePath, "email_debug.log");
                string line =
                    "[" + DateTime.UtcNow.ToString("u") + "] " +
                    status +
                    " to=" + recipientEmail +
                    " subject=\"" + subject + "\"";

                if (exception != null)
                    line += " error=" + exception.GetType().FullName + ": " + exception.Message;

                File.AppendAllText(path, line + Environment.NewLine);
            }
            catch
            {
                // Email diagnostics must never break registration or login.
            }
        }

        private static string GetRequiredSetting(params string[] keys)
        {
            string value = GetOptionalSetting(keys);
            if (string.IsNullOrWhiteSpace(value))
            {
                throw new ConfigurationErrorsException(
                    "Missing required SMTP setting: " + string.Join(" or ", keys));
            }

            return value;
        }

        private static string GetOptionalSetting(params string[] keys)
        {
            foreach (string key in keys)
            {
                string value = ConfigurationManager.AppSettings[key];
                if (!string.IsNullOrWhiteSpace(value) &&
                    value.IndexOf("REPLACE_", StringComparison.OrdinalIgnoreCase) < 0)
                {
                    return value;
                }

                value = Environment.GetEnvironmentVariable(key) ??
                        Environment.GetEnvironmentVariable(ToEnvironmentKey(key));

                if (string.IsNullOrWhiteSpace(value))
                {
                    value = Environment.GetEnvironmentVariable(key, EnvironmentVariableTarget.User) ??
                            Environment.GetEnvironmentVariable(ToEnvironmentKey(key), EnvironmentVariableTarget.User);
                }

                if (!string.IsNullOrWhiteSpace(value) &&
                    value.IndexOf("REPLACE_", StringComparison.OrdinalIgnoreCase) < 0)
                {
                    return value;
                }
            }

            return null;
        }

        private static string ToEnvironmentKey(string key)
        {
            if (string.IsNullOrWhiteSpace(key))
                return key;

            System.Text.StringBuilder builder = new System.Text.StringBuilder();
            for (int i = 0; i < key.Length; i++)
            {
                char c = key[i];
                if (i > 0 && char.IsUpper(c) && char.IsLower(key[i - 1]))
                    builder.Append('_');

                builder.Append(char.ToUpperInvariant(c));
            }

            return builder.ToString();
        }
    }
}
