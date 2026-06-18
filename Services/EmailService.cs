using System;
using System.Configuration;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;

namespace ONYX_DDAC.Services
{
    public class EmailService
    {
        public async Task SendRegistrationOtpAsync(string recipientEmail, string otp, int expiryMinutes)
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
                message.Subject = "Your ONYX verification code";
                message.Body =
                    "Your ONYX verification code is: " + otp + Environment.NewLine +
                    "This code expires in " + expiryMinutes + " minutes." + Environment.NewLine +
                    "If you did not request this code, you can ignore this email.";
                message.IsBodyHtml = false;

                using (SmtpClient client = new SmtpClient(host, port))
                {
                    client.EnableSsl = enableSsl;
                    client.DeliveryMethod = SmtpDeliveryMethod.Network;
                    client.UseDefaultCredentials = false;

                    if (!string.IsNullOrWhiteSpace(username))
                        client.Credentials = new NetworkCredential(username, password ?? string.Empty);

                    await client.SendMailAsync(message);
                }
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
            }

            return null;
        }
    }
}
