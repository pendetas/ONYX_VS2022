using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_reviews : Page
    {
        private readonly ReviewService reviewService = new ReviewService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!TryGetCurrentUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?profile=true");
                return;
            }

            if (!IsPostBack)
            {
                BindReviewProducts(userId);
            }
        }

        private void BindReviewProducts(long userId)
        {
            IList<Product> products = reviewService.GetReviewableProducts(userId);

            pnlReviewForm.Visible = products.Count > 0;
            pnlNoReviewProducts.Visible = products.Count == 0;

            ddlReviewProduct.DataSource = products;
            ddlReviewProduct.DataTextField = "Name";
            ddlReviewProduct.DataValueField = "Id";
            ddlReviewProduct.DataBind();
        }

        protected void btnSubmitReview_Click(object sender, EventArgs e)
        {
            if (!TryGetCurrentUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?profile=true");
                return;
            }

            lblReviewFeedback.Visible = true;

            if (!long.TryParse(ddlReviewProduct.SelectedValue, out long productId))
            {
                lblReviewFeedback.Text = "Choose a purchased product first.";
                return;
            }

            if (!short.TryParse(ddlRating.SelectedValue, out short rating) || rating < 1 || rating > 5)
            {
                lblReviewFeedback.Text = "Choose a rating from 1 to 5.";
                return;
            }

            ReviewSubmissionResult result = reviewService.SaveReview(userId, productId, rating, txtReviewComment.Text);
            if (result.Success)
            {
                txtReviewComment.Text = string.Empty;
            }

            lblReviewFeedback.Text = result.Message;
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
