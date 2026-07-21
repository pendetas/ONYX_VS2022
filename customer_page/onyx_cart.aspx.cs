using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.Services;
using ONYX_DDAC.Helpers;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_cart : Page
    {
        private readonly CartService _cartService = new CartService();

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthHelper.RequireLogin(this);

            // We only want to bind the data the first time the page loads.
            // If they click "Remove", the ItemCommand handles re-binding.
            if (!IsPostBack)
            {
                BindCart();
            }
        }

        private void BindCart()
        {
            var cartItems = _cartService.GetCartItems();

            if (cartItems.Count == 0)
            {
                // Show the empty state, hide the table
                pnlEmptyCart.Visible = true;
                pnlCart.Visible = false;
            }
            else
            {
                // Show the table, hide the empty state
                pnlEmptyCart.Visible = false;
                pnlCart.Visible = true;

                // Bind the items to the Repeater
                rptCartItems.DataSource = cartItems;
                rptCartItems.DataBind();

                // Calculate the grand total using the CartService
                decimal total = _cartService.CalculateTotal();
                litGrandTotal.Text = CurrencyHelper.FormatMyr(total);
            }
        }

        // Handles clicks from inside the Repeater (like the "Remove" button)
        protected void rptCartItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                // Split the argument to get ProductId and VariantId
                string[] args = e.CommandArgument.ToString().Split('|');
                long productId = long.Parse(args[0]);

                long? variantId = null;
                if (!string.IsNullOrEmpty(args[1]))
                {
                    variantId = long.Parse(args[1]);
                }

                // Remove from session
                _cartService.RemoveFromCart(productId, variantId);

                // Re-bind the UI to show the updated cart
                BindCart();
            }
        }

        // Handles redirecting to the checkout page
        protected void btnCheckout_Click(object sender, EventArgs e)
        {
            // Optional: Ensure the user is logged in before checking out!
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?checkout=true");
            }
            else
            {
                Response.Redirect("onyx_checkout.aspx");
            }
        }

        // ADD THIS NEW METHOD to handle empty database images
        protected string GetImageUrl(object imageUrl)
        {
            string url = (imageUrl ?? string.Empty).ToString();
            Uri absoluteUri;
            if (!string.IsNullOrWhiteSpace(url) &&
                Uri.TryCreate(url, UriKind.Absolute, out absoluteUri) &&
                (absoluteUri.Scheme == Uri.UriSchemeHttp || absoluteUri.Scheme == Uri.UriSchemeHttps))
            {
                return url;
            }

            return MediaUrlHelper.Resolve("site-photos/image-unavailable.svg");
        }
    }
}
