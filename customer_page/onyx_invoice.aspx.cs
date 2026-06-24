using System;
using System.Linq;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_invoice : Page
    {
        private readonly OrderService _orderService = new OrderService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/auth_page/onyx_login.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                LoadInvoice();
            }
        }

        private void LoadInvoice()
        {
            if (!long.TryParse(Request.QueryString["orderId"], out long orderId))
            {
                ShowError("Missing or invalid order id.");
                return;
            }

            try
            {
                long userId = Convert.ToInt64(Session["UserId"]);
                Invoice invoice = _orderService.GetInvoice(orderId, userId);
                BindInvoice(invoice);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Invoice load failed: {0}", ex);
                ShowError("This paid invoice is unavailable or does not belong to your account.");
            }
        }

        private void BindInvoice(Invoice invoice)
        {
            pnlInvoice.Visible = true;
            pnlInvoiceError.Visible = false;

            litCustomerName.Text = Server.HtmlEncode(GetCustomerName(invoice.Customer));
            litCustomerContact.Text = FormatContact(invoice.Customer);
            litOrderId.Text = Server.HtmlEncode(invoice.OrderReference);
            litOrderDate.Text = Server.HtmlEncode(invoice.Order.OrderedAt.ToString("dd MMM yyyy, hh:mm tt"));
            litShippingAddress.Text = FormatAddress(invoice.Order.ShippingAddress);
            litDeliveryMethod.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(invoice.Order.DeliveryMethod) ? "Standard Delivery" : invoice.Order.DeliveryMethod);
            litPaymentMethod.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(invoice.Order.PaymentMethod) ? "Stripe" : invoice.Order.PaymentMethod);
            litGrandTotal.Text = CurrencyHelper.FormatMyr(invoice.Order.TotalAmount);

            rptInvoiceItems.DataSource = invoice.Order.Items;
            rptInvoiceItems.DataBind();
        }

        private void ShowError(string message)
        {
            pnlInvoice.Visible = false;
            pnlInvoiceError.Visible = true;
            litInvoiceError.Text = $"<p>{message}</p>";
        }

        private string GetCustomerName(User customer)
        {
            if (!string.IsNullOrWhiteSpace(customer.FullName))
            {
                return customer.FullName;
            }

            return string.IsNullOrWhiteSpace(customer.Username) ? customer.Email : customer.Username;
        }

        private string FormatContact(User customer)
        {
            string[] parts = new[]
            {
                customer.Email,
                customer.PhoneNumber
            }.Where(part => !string.IsNullOrWhiteSpace(part)).ToArray();

            return string.Join("<br />", parts.Select(part => Server.HtmlEncode(part)));
        }

        private string FormatAddress(string shippingAddress)
        {
            return Server.HtmlEncode(shippingAddress ?? string.Empty)
                .Replace("\r\n", "<br />")
                .Replace("\n", "<br />");
        }
    }
}
