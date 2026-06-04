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
                ShowError(Server.HtmlEncode(ex.Message));
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
            litPaymentMethod.Text = Server.HtmlEncode(GetPaymentMethod(invoice.Order.ShippingAddress));
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
            return Server.HtmlEncode(CleanCheckoutLine(shippingAddress, "Payment Method:"))
                .Replace("\r\n", "<br />")
                .Replace("\n", "<br />");
        }

        private string GetPaymentMethod(string shippingAddress)
        {
            if (string.IsNullOrWhiteSpace(shippingAddress))
            {
                return "Dummy Payment";
            }

            string marker = "Payment Method:";
            int index = shippingAddress.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
            if (index < 0)
            {
                return "Dummy Payment";
            }

            return shippingAddress.Substring(index + marker.Length).Trim();
        }

        private string CleanCheckoutLine(string value, string marker)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return string.Empty;
            }

            int index = value.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
            return index < 0 ? value : value.Substring(0, index).Trim();
        }
    }
}
