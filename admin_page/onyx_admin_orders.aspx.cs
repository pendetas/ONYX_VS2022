using System;
using System.Collections.Generic;
using System.Web.UI;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_orders : System.Web.UI.Page
    {
        // =====================================================================
        //  PAGE LIFECYCLE
        // =====================================================================

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindOrders();
            }
        }

        // =====================================================================
        //  DATA BINDING  (replace with OrderRepository.GetAll() when DB ready)
        // =====================================================================

        private void BindOrders()
        {
            litLastUpdated.Text = DateTime.Now.ToString("d MMM yyyy, h:mm tt");

            // 10 mock orders — realistic Malaysian customer names, mix of statuses
            var mockOrders = new List<object>
            {
                new { RawId = 1042, OrderId = "#ORD-1042", CustomerName = "Amir Rashid",    Date = "2 Jun 2026, 4:15 PM",  ItemCount = 2, Total = "RM 1,148.00", Status = "Delivered", StatusKey = "delivered" },
                new { RawId = 1041, OrderId = "#ORD-1041", CustomerName = "Siti Nurhaliza", Date = "2 Jun 2026, 1:30 PM",  ItemCount = 1, Total = "RM 1,249.00", Status = "Shipped",   StatusKey = "shipped"   },
                new { RawId = 1040, OrderId = "#ORD-1040", CustomerName = "Lee Chong Wei",  Date = "2 Jun 2026, 11:00 AM", ItemCount = 1, Total = "RM 599.00",   Status = "Pending",   StatusKey = "pending"   },
                new { RawId = 1039, OrderId = "#ORD-1039", CustomerName = "Kumar Rajan",    Date = "1 Jun 2026, 9:45 PM",  ItemCount = 3, Total = "RM 2,947.00", Status = "Delivered", StatusKey = "delivered" },
                new { RawId = 1038, OrderId = "#ORD-1038", CustomerName = "Farah Liyana",   Date = "1 Jun 2026, 6:20 PM",  ItemCount = 1, Total = "RM 449.00",   Status = "Shipped",   StatusKey = "shipped"   },
                new { RawId = 1037, OrderId = "#ORD-1037", CustomerName = "Tan Wei Xiang",  Date = "1 Jun 2026, 3:00 PM",  ItemCount = 1, Total = "RM 349.00",   Status = "Cancelled", StatusKey = "cancelled" },
                new { RawId = 1036, OrderId = "#ORD-1036", CustomerName = "Nora Ariffin",   Date = "31 May 2026, 8:10 PM", ItemCount = 2, Total = "RM 748.00",   Status = "Delivered", StatusKey = "delivered" },
                new { RawId = 1035, OrderId = "#ORD-1035", CustomerName = "Jason Lim",      Date = "31 May 2026, 5:50 PM", ItemCount = 1, Total = "RM 2,199.00", Status = "Delivered", StatusKey = "delivered" },
                new { RawId = 1034, OrderId = "#ORD-1034", CustomerName = "Priya Sharma",   Date = "30 May 2026, 2:30 PM", ItemCount = 2, Total = "RM 798.00",   Status = "Shipped",   StatusKey = "shipped"   },
                new { RawId = 1033, OrderId = "#ORD-1033", CustomerName = "Ahmad Syafiq",   Date = "30 May 2026, 10:05 AM",ItemCount = 1, Total = "RM 499.00",   Status = "Pending",   StatusKey = "pending"   }
            };

            OrdersRepeater.DataSource = mockOrders;
            OrdersRepeater.DataBind();

            // Summary metrics
            litOrderCount.Text = mockOrders.Count.ToString();
            litTotalRevenue.Text = "RM 10,985.00";

            // Stat strip
            litStatTotal.Text = mockOrders.Count.ToString();
            litStatPending.Text = "2";
            litStatShipped.Text = "3";
            litStatDelivered.Text = "4";
        }
    }
}