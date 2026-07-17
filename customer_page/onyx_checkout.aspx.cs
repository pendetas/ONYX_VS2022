using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_checkout : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?checkout=true", true);
                return;
            }

            if (!IsPostBack)
            {
                CheckoutAttemptToken = Guid.NewGuid().ToString("D");
                BindCheckout();
                if (string.Equals(Request.QueryString["payment"], "cancelled", StringComparison.OrdinalIgnoreCase))
                {
                    lblCheckoutMessage.Text = "Stripe payment was cancelled. Your cart remains unchanged and reserved stock was released.";
                    lblCheckoutMessage.Visible = true;
                }
            }
        }

        private void BindCheckout()
        {
            long userId = Convert.ToInt64(Session["UserId"]);
            var checkoutService = new CheckoutService();
            IList<CartItem> cartItems;

            lblCheckoutMessage.Text = string.Empty;
            lblCheckoutMessage.Visible = false;
            ResetVoucherPreview();

            try
            {
                cartItems = checkoutService.GetValidatedCheckoutCart(userId);
                Session["Cart"] = cartItems.ToList();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Checkout cart validation failed for user {0}: {1}", userId, ex);
                ShowCheckoutUnavailableState();
                return;
            }

            pnlEmptyCheckout.Visible = cartItems.Count == 0;
            pnlCheckout.Visible = cartItems.Count > 0;

            if (cartItems.Count == 0)
            {
                return;
            }

            rptCheckoutItems.DataSource = cartItems;
            rptCheckoutItems.DataBind();
            btnPayWithStripe.Enabled = true;
            btnApplyVoucher.Enabled = true;

            decimal subtotal = cartItems.Sum(item => item.Price * item.Quantity);
            litCheckoutSubtotal.Text = CurrencyHelper.FormatMyr(subtotal);
            litCheckoutTotal.Text = CurrencyHelper.FormatMyr(subtotal);

            if (!string.IsNullOrWhiteSpace(AppliedVoucherCode))
            {
                try
                {
                    VoucherQuote quote = new VoucherService().GetCheckoutQuote(userId, AppliedVoucherCode, cartItems);
                    AppliedVoucherCode = quote.Code;
                    txtVoucherCode.Text = quote.Code;
                    litCheckoutTotal.Text = CurrencyHelper.FormatMyr(quote.TotalAmount);
                    pnlVoucherDiscount.Visible = quote.DiscountAmount > 0m;
                    litVoucherDiscount.Text = CurrencyHelper.FormatMyr(quote.DiscountAmount);
                    pnlAppliedVoucher.Visible = true;
                    litVoucherName.Text = Server.HtmlEncode(quote.Name ?? string.Empty);
                    litVoucherCode.Text = Server.HtmlEncode(quote.Code ?? string.Empty);
                    litVoucherTerms.Text = Server.HtmlEncode(quote.TermsAndConditions ?? string.Empty)
                        .Replace("\r\n", "<br />")
                        .Replace("\n", "<br />");
                }
                catch (VoucherValidationException ex)
                {
                    AppliedVoucherCode = null;
                    txtVoucherCode.Text = string.Empty;
                    SetVoucherMessage(ex.Message, true);
                }
            }
        }

        protected void btnApplyVoucher_Click(object sender, EventArgs e)
        {
            string requestedCode = VoucherService.NormalizeCode(txtVoucherCode.Text);
            if (string.IsNullOrWhiteSpace(requestedCode))
            {
                AppliedVoucherCode = null;
                BindCheckout();
                txtVoucherCode.Text = string.Empty;
                SetVoucherMessage("Enter a voucher code.", true);
                return;
            }

            try
            {
                long userId = Convert.ToInt64(Session["UserId"]);
                IList<CartItem> cartItems = new CheckoutService().GetValidatedCheckoutCart(userId);
                Session["Cart"] = cartItems.ToList();
                VoucherQuote quote = new VoucherService().GetCheckoutQuote(userId, requestedCode, cartItems);
                AppliedVoucherCode = quote.Code;
                BindCheckout();
                SetVoucherMessage("Voucher applied to this checkout preview.", false);
            }
            catch (VoucherValidationException ex)
            {
                AppliedVoucherCode = null;
                BindCheckout();
                txtVoucherCode.Text = requestedCode;
                SetVoucherMessage(ex.Message, true);
            }
            catch (InvalidOperationException)
            {
                AppliedVoucherCode = null;
                txtVoucherCode.Text = requestedCode;
                ShowCheckoutUnavailableState();
            }
            catch (Exception ex)
            {
                long userId = Session["UserId"] == null ? 0 : Convert.ToInt64(Session["UserId"]);
                System.Diagnostics.Trace.TraceError("Voucher checkout preview apply failed for user {0}: {1}", userId, ex);
                AppliedVoucherCode = null;
                txtVoucherCode.Text = requestedCode;
                ShowCheckoutUnavailableState();
            }
        }

        protected void btnRemoveVoucher_Click(object sender, EventArgs e)
        {
            AppliedVoucherCode = null;
            BindCheckout();
            txtVoucherCode.Text = string.Empty;
            SetVoucherMessage("Voucher removed from this checkout preview.", false);
        }

        protected void btnPayWithStripe_Click(object sender, EventArgs e)
        {
            try
            {
                long userId = Convert.ToInt64(Session["UserId"]);
                string shippingAddress = txtShippingAddress.Text.Trim();
                string deliveryMethod = ddlDeliveryMethod.SelectedValue;
                string applicationBaseUrl = AppUrlHelper.GetBaseUrl(this);

                var checkoutService = new CheckoutService();
                var result = checkoutService.StartCheckout(
                    userId,
                    shippingAddress,
                    deliveryMethod,
                    CheckoutAttemptToken,
                    AppliedVoucherCode,
                    applicationBaseUrl);

                new CartService().RefreshCurrentUserCartFromDatabase();
                Response.Redirect(result.CheckoutUrl, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (ActiveCheckoutAttemptException ex)
            {
                lblCheckoutMessage.Text = Server.HtmlEncode(ex.Message);
                lblCheckoutMessage.ForeColor = System.Drawing.ColorTranslator.FromHtml("#ffb74d");
                lblCheckoutMessage.Visible = true;
                btnPayWithStripe.Enabled = true;
            }
            catch (Exception ex)
            {
                long userId = Session["UserId"] == null ? 0 : Convert.ToInt64(Session["UserId"]);
                System.Diagnostics.Trace.TraceError("Stripe Checkout start failed for user {0}: {1}", userId, ex);
                lblCheckoutMessage.Text = "Unable to start Stripe Checkout. Please try again. Any uncertain payment attempt remains pending for safe recovery.";
                lblCheckoutMessage.ForeColor = System.Drawing.ColorTranslator.FromHtml("#ff4444");
                lblCheckoutMessage.Visible = true;
                btnPayWithStripe.Enabled = true;
            }
        }

        protected string GetSafeImageUrl(object imageUrl)
        {
            const string fallback = "~/Content/home/products/onyx-mouse.png";
            string value = Convert.ToString(imageUrl)?.Trim();
            string resolved = ResolveUrl(fallback);

            if (!string.IsNullOrWhiteSpace(value) && !value.Contains("\\"))
            {
                if (Uri.TryCreate(value, UriKind.Absolute, out Uri absoluteUri))
                {
                    if (absoluteUri.Scheme == Uri.UriSchemeHttp ||
                        absoluteUri.Scheme == Uri.UriSchemeHttps)
                    {
                        resolved = absoluteUri.AbsoluteUri;
                    }
                }
                else if (!value.StartsWith("//", StringComparison.Ordinal) &&
                         !value.Contains(":"))
                {
                    string applicationPath = value.StartsWith("~/", StringComparison.Ordinal)
                        ? value
                        : "~/" + value.TrimStart('/');
                    resolved = ResolveUrl(applicationPath);
                }
            }

            return HttpUtility.HtmlAttributeEncode(resolved);
        }

        protected string EncodeProductName(object productName)
        {
            return Server.HtmlEncode(Convert.ToString(productName) ?? string.Empty);
        }

        private string CheckoutAttemptToken
        {
            get
            {
                string value = Convert.ToString(ViewState["CheckoutAttemptToken"]);
                if (string.IsNullOrWhiteSpace(value))
                {
                    value = Guid.NewGuid().ToString("D");
                    ViewState["CheckoutAttemptToken"] = value;
                }

                return value;
            }
            set { ViewState["CheckoutAttemptToken"] = value; }
        }

        private string AppliedVoucherCode
        {
            get { return Convert.ToString(ViewState["AppliedVoucherCode"]); }
            set { ViewState["AppliedVoucherCode"] = string.IsNullOrWhiteSpace(value) ? null : value; }
        }

        private void ResetVoucherPreview()
        {
            pnlAppliedVoucher.Visible = false;
            pnlVoucherDiscount.Visible = false;
            litVoucherName.Text = string.Empty;
            litVoucherCode.Text = string.Empty;
            litVoucherDiscount.Text = string.Empty;
            litVoucherTerms.Text = string.Empty;
            lblVoucherMessage.Text = string.Empty;
            lblVoucherMessage.Visible = false;
        }

        private void SetVoucherMessage(string message, bool isError)
        {
            lblVoucherMessage.Text = Server.HtmlEncode(message ?? string.Empty);
            lblVoucherMessage.ForeColor = isError
                ? System.Drawing.ColorTranslator.FromHtml("#ff8a8a")
                : System.Drawing.ColorTranslator.FromHtml("#d5f5dd");
            lblVoucherMessage.Visible = !string.IsNullOrWhiteSpace(message);
        }

        private void ShowCheckoutUnavailableState()
        {
            ResetVoucherPreview();
            pnlEmptyCheckout.Visible = false;
            pnlCheckout.Visible = true;
            btnPayWithStripe.Enabled = false;
            btnApplyVoucher.Enabled = false;
            lblCheckoutMessage.Text = "Checkout is currently unavailable. Return to your cart and verify item quantities.";
            lblCheckoutMessage.ForeColor = System.Drawing.ColorTranslator.FromHtml("#ff4444");
            lblCheckoutMessage.Visible = true;
        }
    }
}
