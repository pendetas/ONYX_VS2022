using System;
using System.Linq;
using System.Web;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_checkout : Page
    {
        private readonly CartService _cartService = new CartService();
        private readonly OrderService _orderService = new OrderService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?checkout=true", true);
                return;
            }

            if (!IsPostBack)
            {
                if (ShowOrderSuccess())
                {
                    return;
                }

                BindCheckout();
            }
        }

        private bool ShowOrderSuccess()
        {
            string orderId = Request.QueryString["orderId"];
            if (string.IsNullOrWhiteSpace(orderId))
            {
                return false;
            }

            pnlOrderSuccess.Visible = true;
            pnlEmptyCheckout.Visible = false;
            pnlCheckout.Visible = false;
            litOrderSuccess.Text = $"<p>Your dummy payment was accepted. Order #{Server.HtmlEncode(orderId)} has been created.</p>";
            return true;
        }

        private void BindCheckout()
        {
            var cartItems = _cartService.GetCartItems();

            pnlEmptyCheckout.Visible = cartItems.Count == 0;
            pnlCheckout.Visible = cartItems.Count > 0;

            if (cartItems.Count == 0)
            {
                return;
            }

            rptCheckoutItems.DataSource = cartItems;
            rptCheckoutItems.DataBind();
            litCheckoutTotal.Text = CurrencyHelper.FormatMyr(cartItems.Sum(item => item.Price * item.Quantity));
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            long? createdOrderId = null;

            try
            {
                var cartItems = _cartService.GetCartItems();
                long userId = Convert.ToInt64(Session["UserId"]);
                string shippingAddress = BuildShippingAddress();

                createdOrderId = _orderService.CreateOrderFromCart(userId, shippingAddress, cartItems);
                _cartService.ClearCart();
            }
            catch (Exception ex)
            {
                lblCheckoutMessage.Text = Server.HtmlEncode(ex.Message);
                lblCheckoutMessage.ForeColor = System.Drawing.ColorTranslator.FromHtml("#ff4444");
                lblCheckoutMessage.Visible = true;
                return;
            }

            string invoiceUrl = ResolveUrl($"~/customer_page/onyx_invoice.aspx?orderId={createdOrderId.Value}");
            string redirectScript = $"window.location.replace('{HttpUtility.JavaScriptStringEncode(invoiceUrl)}');";
            ClientScript.RegisterStartupScript(GetType(), "redirectToInvoice", redirectScript, true);
        }

        private string BuildShippingAddress()
        {
            string address = txtShippingAddress.Text.Trim();
            if (string.IsNullOrWhiteSpace(address))
            {
                throw new InvalidOperationException("Shipping address is required.");
            }

            return $"{address}\nDelivery Method: {ddlDeliveryMethod.SelectedValue}\nPayment Method: {ddlPaymentMethod.SelectedValue}";
        }

        protected string GetImageUrl(object imageUrl)
        {
            string url = (imageUrl ?? string.Empty).ToString();
            return string.IsNullOrWhiteSpace(url)
                ? "/Content/home/products/onyx-mouse.png"
                : url;
        }
    }
}
