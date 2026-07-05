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
        private readonly PersonalizationService personalizationService = new PersonalizationService();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthHelper.RequireLogin(this);

            if (!IsPostBack && TryGetUserId(out long userId) && personalizationService.HasCompletedProfile(userId))
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

            try
            {
                personalizationService.SaveProfile(new UserPersonalizationProfile
                {
                    UserId = userId,
                    GamingStyle = GamingStyleField.Value,
                    PreferredCategories = SplitValues(PreferredCategoriesField.Value),
                    Priorities = SplitValues(PrioritiesField.Value),
                    BudgetRange = BudgetRangeField.Value,
                    SetupGoal = SetupGoalField.Value
                });

                Response.Redirect("~/customer_page/onyx_home.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception exception)
            {
                FeedbackLabel.Text = Server.HtmlEncode(exception.Message);
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
    }
}
