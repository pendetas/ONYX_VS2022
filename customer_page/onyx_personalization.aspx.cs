using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_personalization : Page
    {
        private const string GenericFailureMessage = "Personalization is temporarily unavailable. Please try again.";
        private const string PersonalizationCompletedSessionKey = "OnyxPersonalizationCompleted";
        private const string PersonalizationCompletedUserIdSessionKey = "OnyxPersonalizationCompletedUserId";
        private readonly PersonalizationService personalizationService = new PersonalizationService();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthHelper.RequireLogin(this);
            if (!EnsureCustomerAccess())
            {
                return;
            }

            if (!IsPostBack && TryGetUserId(out long userId) && HasCompletedProfileSafely(userId))
            {
                Response.Redirect("~/customer_page/onyx_home.aspx", true);
            }
        }

        protected void BuildSetupButton_Click(object sender, EventArgs e)
        {
            if (!TryGetUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx", true);
                return;
            }

            if (!EnsureCustomerAccess())
            {
                return;
            }

            try
            {
                personalizationService.SaveProfile(new UserPersonalizationProfile
                {
                    UserId = userId,
                    GamingStyle = GamingStyleField.Value,
                    PreferredCategories = SplitValues(PreferredCategoriesField.Value),
                    Priorities = SplitValues(PrioritiesField.Value),
                    BudgetRange = BudgetRangeField.Value,
                    SetupGoal = SetupGoalField.Value,
                    ComfortPreferences = SplitValues(ComfortPreferencesField.Value),
                    PerformancePreferences = SplitValues(PerformancePreferencesField.Value),
                    SetupConstraints = SplitValues(SetupConstraintsField.Value)
                });

                CachePersonalizationCompleted(userId);
                Response.Redirect("~/customer_page/onyx_home.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (ArgumentException exception)
            {
                string validationMessage = exception.GetBaseException().Message;
                if (IsKnownValidationMessage(validationMessage))
                {
                    FeedbackLabel.Text = Server.HtmlEncode(validationMessage);
                }
                else
                {
                    System.Diagnostics.Trace.TraceWarning("Unexpected personalization validation error for user '{0}': {1}", Session["UserId"], exception);
                    FeedbackLabel.Text = GenericFailureMessage;
                }

                FeedbackLabel.Visible = true;
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceError("Personalization save failed for user '{0}': {1}", Session["UserId"], exception);
                FeedbackLabel.Text = GenericFailureMessage;
                FeedbackLabel.Visible = true;
            }
        }

        private static IList<string> SplitValues(string value)
        {
            return (value ?? string.Empty)
                .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(item => item.Trim())
                .Where(item => item.Length > 0)
                .ToList();
        }

        private bool TryGetUserId(out long userId)
        {
            userId = 0;
            object value = Session["UserId"];

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

        private bool EnsureCustomerAccess()
        {
            string role = Convert.ToString(Session["Role"]);
            if (string.Equals(role, "customer", StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            bool isPrivilegedRole =
                string.Equals(role, "admin", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(role, "owner", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(role, "staff", StringComparison.OrdinalIgnoreCase);

            if (!isPrivilegedRole)
            {
                System.Diagnostics.Trace.TraceWarning("Non-customer role '{0}' attempted to access personalization page.", role ?? "(null)");
            }

            Response.Redirect("~/admin_page/onyx_admin_dashboard.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
            return false;
        }

        private static bool IsKnownValidationMessage(string message)
        {
            return string.Equals(message, "A signed-in customer is required.", StringComparison.Ordinal) ||
                   string.Equals(message, "Choose your main gaming style.", StringComparison.Ordinal) ||
                   string.Equals(message, "Choose at least one gear interest.", StringComparison.Ordinal) ||
                   string.Equals(message, "Choose at least one purchase priority.", StringComparison.Ordinal) ||
                   string.Equals(message, "Choose your budget range.", StringComparison.Ordinal) ||
                   string.Equals(message, "Choose your setup goal.", StringComparison.Ordinal) ||
                   string.Equals(message, "Choose at least one comfort preference.", StringComparison.Ordinal) ||
                   string.Equals(message, "Choose at least one performance preference.", StringComparison.Ordinal) ||
                   string.Equals(message, "Choose at least one setup constraint.", StringComparison.Ordinal);
        }

        private bool HasCompletedProfileSafely(long userId)
        {
            try
            {
                bool hasCompletedProfile = personalizationService.HasCompletedProfile(userId);
                if (hasCompletedProfile)
                {
                    CachePersonalizationCompleted(userId);
                }

                return hasCompletedProfile;
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceWarning(
                    "Personalization page completion lookup failed for user {0}: {1}",
                    userId,
                    exception);

                FeedbackLabel.Text = GenericFailureMessage;
                FeedbackLabel.Visible = true;
                BuildSetupButton.Enabled = false;
                return false;
            }
        }

        private void CachePersonalizationCompleted(long userId)
        {
            Session[PersonalizationCompletedSessionKey] = true;
            Session[PersonalizationCompletedUserIdSessionKey] = userId;
        }
    }
}
