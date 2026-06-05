using System;
using System.Collections.Generic;
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
        private readonly OrderRepository orderRepository = new OrderRepository();
        private readonly ReviewRepository reviewRepository = new ReviewRepository();
        private readonly WishlistRepository wishlistRepository = new WishlistRepository();

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
            User user = userRepository.GetUserById(userId);
            IList<Order> orders = orderRepository.GetOrdersForUser(userId, 5);
            IList<Product> reviewProducts = orderRepository.GetPurchasedProductsForUser(userId);
            int wishlistCount = wishlistRepository.GetWishlistProducts(userId).Count;

            BindAccountDetails(user);
            BindStats(orders.Count, reviewProducts.Count, wishlistCount);
            BindOrders(orders);
            BindReviewProducts(reviewProducts);
        }

        private void BindAccountDetails(User user)
        {
            string displayName = GetDisplayName(user);
            litInitials.Text = Server.HtmlEncode(GetInitials(displayName));
            litDisplayName.Text = Server.HtmlEncode(displayName);
            litUsername.Text = Server.HtmlEncode(GetValueOrFallback(user == null ? null : user.Username, "onyx-user"));
            litEmail.Text = Server.HtmlEncode(GetValueOrFallback(user == null ? null : user.Email, "Not provided"));
            litPhone.Text = Server.HtmlEncode(GetValueOrFallback(user == null ? null : user.PhoneNumber, "Not provided"));
            litAddress.Text = FormatAddress(user == null ? null : user.Address);
            litMemberSince.Text = user == null || user.CreatedAt == DateTime.MinValue
                ? "Recently joined"
                : Server.HtmlEncode(user.CreatedAt.ToString("dd MMM yyyy"));

            BindSettingsFields(user);
        }

        private void BindStats(int orderCount, int reviewableCount, int wishlistCount)
        {
            litOrderCount.Text = orderCount.ToString();
            litReviewableCount.Text = reviewableCount.ToString();
            litWishlistCount.Text = wishlistCount.ToString();
        }

        private void BindOrders(IList<Order> orders)
        {
            pnlEmptyOrders.Visible = orders.Count == 0;
            rptRecentOrders.Visible = orders.Count > 0;
            rptRecentOrders.DataSource = orders;
            rptRecentOrders.DataBind();
        }

        private void BindReviewProducts(IList<Product> products)
        {
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

            if (!orderRepository.HasPurchasedProduct(userId, productId))
            {
                lblReviewFeedback.Text = "Reviews are only available for purchased gear.";
                return;
            }

            string comment = (txtReviewComment.Text ?? string.Empty).Trim();
            if (comment.Length > 1200)
            {
                lblReviewFeedback.Text = "Keep the review under 1200 characters.";
                return;
            }

            reviewRepository.SaveReview(userId, productId, rating, comment);
            txtReviewComment.Text = string.Empty;
            lblReviewFeedback.Text = "Review saved. Thanks for testing the gear.";
        }

        protected void btnSaveSettings_Click(object sender, EventArgs e)
        {
            if (!TryGetCurrentUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?profile=true");
                return;
            }

            lblSettingsFeedback.Visible = true;

            string fullName = NormalizeOptionalValue(txtSettingsFullName.Text);
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
                BindAccountDetails(updatedUser);
                lblSettingsFeedback.Text = "Settings saved.";
            }
            catch (Npgsql.PostgresException ex) when (ex.SqlState == "23505")
            {
                lblSettingsFeedback.Text = "That email is already used by another account.";
            }
        }

        protected string FormatOrderDate(object value)
        {
            if (value is DateTime date)
            {
                return Server.HtmlEncode(date.ToString("dd MMM yyyy"));
            }

            return "Recent order";
        }

        protected string GetOrderSummary(object dataItem)
        {
            Order order = dataItem as Order;
            if (order == null || order.Items == null || order.Items.Count == 0)
            {
                return "Order details are being prepared.";
            }

            string[] names = order.Items
                .Take(3)
                .Select(item => string.Format("{0} x {1}", item.Quantity, item.ProductName))
                .ToArray();

            string summary = string.Join(", ", names);
            if (order.Items.Count > 3)
            {
                summary += string.Format(" and {0} more", order.Items.Count - 3);
            }

            return Server.HtmlEncode(summary);
        }

        private string FormatAddress(string address)
        {
            string value = GetValueOrFallback(address, "Not provided");
            return Server.HtmlEncode(value).Replace("\r\n", "<br />").Replace("\n", "<br />");
        }

        private void BindSettingsFields(User user)
        {
            txtSettingsFullName.Text = user == null ? string.Empty : GetValueOrFallback(user.FullName, string.Empty);
            txtSettingsEmail.Text = user == null ? string.Empty : GetValueOrFallback(user.Email, string.Empty);
            txtSettingsPhone.Text = user == null ? string.Empty : GetValueOrFallback(user.PhoneNumber, string.Empty);
            txtSettingsAddress.Text = user == null ? string.Empty : GetValueOrFallback(user.Address, string.Empty);
        }

        private static string GetDisplayName(User user)
        {
            if (user == null)
            {
                object sessionName = HttpContext.Current.Session["Username"];
                return sessionName == null ? "ONYX Member" : sessionName.ToString();
            }

            if (!string.IsNullOrWhiteSpace(user.FullName))
            {
                return user.FullName;
            }

            if (!string.IsNullOrWhiteSpace(user.Username))
            {
                return user.Username;
            }

            return string.IsNullOrWhiteSpace(user.Email) ? "ONYX Member" : user.Email;
        }

        private static string GetInitials(string displayName)
        {
            string[] parts = (displayName ?? string.Empty)
                .Split(new[] { ' ', '.', '_', '-' }, StringSplitOptions.RemoveEmptyEntries);

            if (parts.Length == 0)
            {
                return "O";
            }

            if (parts.Length == 1)
            {
                return parts[0].Substring(0, 1).ToUpperInvariant();
            }

            return (parts[0].Substring(0, 1) + parts[1].Substring(0, 1)).ToUpperInvariant();
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
