using System;
using System.Linq;
using System.Web;
using System.Web.UI;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_profile : Page
    {
        private readonly UserRepository userRepository = new UserRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!TryGetCurrentUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?profile=true");
                return;
            }

            if (!IsPostBack)
            {
                BindProfile(userId);
            }
        }

        private void BindProfile(long userId)
        {
            BindSettingsFields(TryLoadUser(userId));
        }

        private User TryLoadUser(long userId)
        {
            try
            {
                return userRepository.GetUserById(userId) ?? GetSessionFallbackUser();
            }
            catch
            {
                return GetSessionFallbackUser();
            }
        }

        private static User GetSessionFallbackUser()
        {
            HttpContext context = HttpContext.Current;
            object username = context == null ? null : context.Session["Username"];

            return new User
            {
                Username = username == null ? "onyx-user" : username.ToString(),
                CreatedAt = DateTime.MinValue
            };
        }

        protected void btnSaveSettings_Click(object sender, EventArgs e)
        {
            if (!TryGetCurrentUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?profile=true");
                return;
            }

            lblSettingsFeedback.Visible = true;

            string firstName = NormalizeOptionalValue(txtSettingsFirstName.Text);
            string lastName = NormalizeOptionalValue(txtSettingsLastName.Text);
            string fullName = NormalizeOptionalValue(string.Join(" ", new[] { firstName, lastName }.Where(value => !string.IsNullOrWhiteSpace(value))));
            string email = (txtSettingsEmail.Text ?? string.Empty).Trim();
            string phoneNumber = NormalizeOptionalValue(txtSettingsPhone.Text);
            string address = NormalizeOptionalValue(txtSettingsAddress.Text);

            if (string.IsNullOrWhiteSpace(fullName))
            {
                lblSettingsFeedback.Text = "Full name is required.";
                return;
            }

            if (string.IsNullOrWhiteSpace(email) || !LooksLikeEmail(email))
            {
                lblSettingsFeedback.Text = "Enter a valid email address.";
                return;
            }

            if (address != null && address.Length > 500)
            {
                lblSettingsFeedback.Text = "Keep the address under 500 characters.";
                return;
            }

            try
            {
                if (!userRepository.UpdateUserSettings(userId, fullName, email, phoneNumber, address))
                {
                    lblSettingsFeedback.Text = "Settings could not be saved.";
                    return;
                }

                User updatedUser = userRepository.GetUserById(userId);
                BindSettingsFields(updatedUser);
                lblSettingsFeedback.Text = "Settings saved.";
            }
            catch (Npgsql.PostgresException ex) when (ex.SqlState == "23505")
            {
                lblSettingsFeedback.Text = "That email is already used by another account.";
            }
        }

        private void BindSettingsFields(User user)
        {
            string fullName = user == null ? string.Empty : GetValueOrFallback(user.FullName, string.Empty);
            string firstName;
            string lastName;
            SplitDisplayName(fullName, out firstName, out lastName);

            txtSettingsFirstName.Text = firstName;
            txtSettingsLastName.Text = lastName;
            txtSettingsFullName.Text = fullName;
            txtSettingsEmail.Text = user == null ? string.Empty : GetValueOrFallback(user.Email, string.Empty);
            txtSettingsPhone.Text = user == null ? string.Empty : GetValueOrFallback(user.PhoneNumber, string.Empty);
            txtSettingsAddress.Text = user == null ? string.Empty : GetValueOrFallback(user.Address, string.Empty);
        }

        private static string GetValueOrFallback(string value, string fallback)
        {
            return string.IsNullOrWhiteSpace(value) ? fallback : value;
        }

        private static string NormalizeOptionalValue(string value)
        {
            string normalized = (value ?? string.Empty).Trim();
            return normalized.Length == 0 ? null : normalized;
        }

        private static void SplitDisplayName(string fullName, out string firstName, out string lastName)
        {
            string normalized = (fullName ?? string.Empty).Trim();
            int splitIndex = normalized.IndexOf(' ');

            if (splitIndex < 0)
            {
                firstName = normalized;
                lastName = string.Empty;
                return;
            }

            firstName = normalized.Substring(0, splitIndex).Trim();
            lastName = normalized.Substring(splitIndex + 1).Trim();
        }

        private static bool LooksLikeEmail(string email)
        {
            int atIndex = email.IndexOf('@');
            return atIndex > 0 && atIndex < email.Length - 1 && email.IndexOf('.', atIndex) > atIndex + 1;
        }

        private static bool TryGetCurrentUserId(out long userId)
        {
            userId = 0;
            object value = HttpContext.Current.Session["UserId"];

            if (value == null)
            {
                return false;
            }

            if (value is long longValue)
            {
                userId = longValue;
                return true;
            }

            return long.TryParse(value.ToString(), out userId);
        }
    }
}
