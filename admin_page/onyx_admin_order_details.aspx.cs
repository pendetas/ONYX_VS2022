using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_order_details : System.Web.UI.Page
    {
        // Stores the current order's status key so btnUpdateStatus can update the badge
        private string _currentStatusKey = "delivered";

        // =====================================================================
        //  PAGE LIFECYCLE
        // =====================================================================

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Read order ID from query string; default to 1042 for direct preview
                string idParam = Request.QueryString["id"];
                long orderId = 1042;
                if (!string.IsNullOrWhiteSpace(idParam))
                    long.TryParse(idParam, out orderId);

                BindOrderDetails(orderId);
            }
        }

        // =====================================================================
        //  DATA BINDING  (replace with OrderService.GetDetails(id) when DB ready)
        // =====================================================================

        private void BindOrderDetails(long orderId)
        {
            // Simulate routing to different mock orders by ID
            // In production: var order = orderService.GetOrderById(orderId);
            string statusKey = GetMockStatusKey(orderId);
            string status = GetDisplayStatus(statusKey);

            _currentStatusKey = statusKey;

            // ---- Header ----
            litOrderId.Text = "#ORD-" + orderId;
            litOrderDate.Text = "2 Jun 2026, 4:15 PM";
            litCustomerNameHeader.Text = "Amir Rashid";
            lblStatusBadge.Text = BuildStatusBadge(statusKey, status);

            // ---- Customer info ----
            litCustName.Text = "Amir Rashid";
            litCustEmail.Text = "amir.rashid@gmail.com";
            litCustPhone.Text = "+60 12-345 6789";
            litCustSince.Text = "14 Jan 2025";

            // ---- Shipping address ----
            litShippingAddress.Text =
                "Unit 15-3, Menara Duta,<br>" +
                "Jalan Duta, Bukit Damansara,<br>" +
                "50480 Kuala Lumpur,<br>" +
                "Malaysia";

            // ---- Pre-select dropdown ----
            ddlStatus.SelectedValue = statusKey;

            // ---- Metadata ----
            litMetaOrderId.Text = "#ORD-" + orderId;
            litMetaDate.Text = "2 Jun 2026, 4:15 PM";
            litReceiptKey.Text = "receipts/" + orderId + ".json";

            // ---- Order items ----
            var mockItems = new List<object>
            {
                new { ProductName = "Viper V2 Pro",  Category = "Mouse",    Variant = "Wireless — Black",    Quantity = 1, UnitPrice = "RM 599.00", Subtotal = "RM 599.00" },
                new { ProductName = "BlackWidow V3", Category = "Keyboard", Variant = "US Layout — Black",   Quantity = 1, UnitPrice = "RM 449.00", Subtotal = "RM 449.00" },
                new { ProductName = "Kraken X",      Category = "Headset",  Variant = "Black",               Quantity = 1, UnitPrice = "RM 299.00", Subtotal = "RM 299.00" }
            };

            OrderItemsRepeater.DataSource = mockItems;
            OrderItemsRepeater.DataBind();

            // ---- Summary ----
            litSubtotal.Text = "RM 1,347.00";
            litTotal.Text = "RM 1,357.00";   // subtotal + RM10 shipping

            // ---- Timeline ----
            var timeline = new List<object>
            {
                new { Event = "Order Delivered",      Timestamp = "2 Jun 2026, 4:15 PM",  DotClass = "dot-green"  },
                new { Event = "Out for Delivery",     Timestamp = "2 Jun 2026, 9:00 AM",  DotClass = "dot-blue"   },
                new { Event = "Order Shipped",        Timestamp = "1 Jun 2026, 3:00 PM",  DotClass = "dot-blue"   },
                new { Event = "Payment Confirmed",    Timestamp = "31 May 2026, 11:30 PM", DotClass = "dot-yellow" },
                new { Event = "Order Placed",         Timestamp = "31 May 2026, 11:28 PM", DotClass = "dot-yellow" }
            };

            TimelineRepeater.DataSource = timeline;
            TimelineRepeater.DataBind();
        }

        // =====================================================================
        //  EVENT HANDLERS
        // =====================================================================

        protected void btnUpdateStatus_Click(object sender, EventArgs e)
        {
            string newKey = ddlStatus.SelectedValue;
            string newDisplay = ddlStatus.SelectedItem.Text;

            // TODO: Call OrderRepository.UpdateStatus(orderId, newKey) when DB is connected.
            lblStatusBadge.Text = BuildStatusBadge(newKey, newDisplay);
            litStatusMsg.Text = $"Status updated to \"{newDisplay}\" successfully.";
            pnlStatusMsg.Visible = true;
        }

        // =====================================================================
        //  HELPERS
        // =====================================================================

        /// <summary>
        /// Returns a simple status key for the given order ID.
        /// Simulates routing to different mock orders.
        /// </summary>
        private static string GetMockStatusKey(long orderId)
        {
            switch (orderId % 4)
            {
                case 0: return "delivered";
                case 1: return "shipped";
                case 2: return "pending";
                default: return "cancelled";
            }
        }

        private static string GetDisplayStatus(string key)
        {
            switch (key)
            {
                case "shipped": return "Shipped";
                case "pending": return "Pending";
                case "cancelled": return "Cancelled";
                default: return "Delivered";
            }
        }

        /// <summary>Builds the HTML for the status badge in the page header.</summary>
        private static string BuildStatusBadge(string key, string display)
        {
            return $"<span class=\"status-badge status-{key}\">{display}</span>";
        }
    }
}