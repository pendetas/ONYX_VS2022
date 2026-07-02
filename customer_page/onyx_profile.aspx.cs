using System;
using System.Web;
using System.Web.UI;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_profile : Page
    {
        private readonly ProfileService profileService = new ProfileService();

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
            BindSettingsFields(profileService.GetUserProfile(userId));
        }

        protected void btnSaveSettings_Click(object sender, EventArgs e)
        {
            if (!TryGetCurrentUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?profile=true");
                return;
            }

            lblSettingsFeedback.Visible = true;

            ProfileUpdateResult result = profileService.UpdateUserSettings(
                userId,
                txtSettingsFirstName.Text,
                txtSettingsLastName.Text,
                txtSettingsEmail.Text,
                txtSettingsPhone.Text,
                txtSettingsAddress.Text);

            if (result.Success)
            {
                BindSettingsFields(result.User);
            }

            lblSettingsFeedback.Text = result.Message;
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
