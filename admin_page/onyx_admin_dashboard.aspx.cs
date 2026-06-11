using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_dashboard : Page
    {
        private readonly DashboardService _svc = new DashboardService();

        public string RevenueChartJson { get; private set; }
        public string DayLabelsJson    { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            BindChartData();

            if (!IsPostBack)
            {
                BindTopBar();
                BindMetricCards();
                BindTopProducts();
                BindLowStockAlerts();
                BindRecentOrders();
                BindNotifications();
            }
        }

        private void BindTopBar()
        {
            string username = Session["Username"]?.ToString() ?? "Admin";
            int    hour     = DateTime.Now.Hour;
            string greeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening";

            lblGreeting.Text    = greeting + ", " + Server.HtmlEncode(username);
            lblCurrentDate.Text = DateTime.Now.ToString("dddd, d MMMM yyyy");
            lblAvatar.Text      = username.Length >= 2
                                  ? username.Substring(0, 2).ToUpperInvariant()
                                  : username.ToUpperInvariant();
        }

        private void BindMetricCards()
        {
            var m = _svc.GetMetrics();

            lblTodaySales.Text   = "RM " + m.TodaySales.ToString("N2");
            lblTotalRevenue.Text = "RM " + m.TotalRevenueMTD.ToString("N2");
            lblTotalOrders.Text  = m.TotalOrdersMTD.ToString("N0");
            lblAOV.Text          = "RM " + m.AverageOrderValue.ToString("N2");

            SetPastelTrend(lblTodaySalesTrend, m.TodaySalesTrend,  "vs yesterday");
            SetPastelTrend(lblRevenueTrend,    m.RevenueTrend,     "vs last month");
            SetPastelTrend(lblOrdersTrend,     m.OrdersTrend,      "vs last month");
            SetPastelTrend(lblAOVTrend,        m.AOVTrend,         "vs last month");

            lblConversionRate.Text  = m.ConversionRate.ToString("F1") + "%";
            lblReturningRate.Text   = m.ReturningCustomerRate.ToString("F1") + "%";
            lblLowStock.Text        = m.LowStockItems + " item" + (m.LowStockItems == 1 ? "" : "s");

            SetDarkTrend(lblConversionTrend, m.ConversionTrend, "vs last week");
        }

        private void BindTopProducts()
        {
            TopProductsRepeater.DataSource = _svc.GetTopProducts(5);
            TopProductsRepeater.DataBind();
        }

        private void BindLowStockAlerts()
        {
            var items = _svc.GetLowStockProducts(5);
            pnlLowStock.Visible = items.Count > 0;
            if (items.Count > 0)
            {
                LowStockRepeater.DataSource = items;
                LowStockRepeater.DataBind();
            }
        }

        private void BindRecentOrders()
        {
            RecentOrdersRepeater.DataSource = _svc.GetRecentOrders(6);
            RecentOrdersRepeater.DataBind();
        }

        private void BindNotifications()
        {
            NotifRepeater.DataSource = _svc.GetRecentActivities(3);
            NotifRepeater.DataBind();
        }

        private void BindChartData()
        {
            var weekly = _svc.GetWeeklyRevenueTrend();
            RevenueChartJson = "[" + string.Join(",", weekly) + "]";

            var labels = new List<string>();
            for (int i = 6; i >= 0; i--)
                labels.Add("\"" + DateTime.Today.AddDays(-i).ToString("ddd") + "\"");
            DayLabelsJson = "[" + string.Join(",", labels) + "]";
        }

        public static string GetCategoryColor(string category)
        {
            switch ((category ?? "").ToLowerInvariant())
            {
                case "mouse":    return "#00ff87";
                case "keyboard": return "#a78bfa";
                case "headset":  return "#f9a8d4";
                case "monitor":  return "#7dd3fc";
                case "chair":    return "#fcd34d";
                default:         return "#888891";
            }
        }

        private static void SetPastelTrend(Label lbl, double value, string suffix)
        {
            const string iconStyle = "width:12px;height:12px;vertical-align:middle;margin-right:3px;";
            if (value >= 0)
            {
                lbl.CssClass = "trend-tag trend-up";
                lbl.Text = "<i data-lucide=\"trending-up\" style=\"" + iconStyle + "\"></i> +"
                           + value.ToString("F1") + "% " + suffix;
            }
            else
            {
                lbl.CssClass = "trend-tag trend-down";
                lbl.Text = "<i data-lucide=\"trending-down\" style=\"" + iconStyle + "\"></i> "
                           + value.ToString("F1") + "% " + suffix;
            }
        }

        private static void SetDarkTrend(Label lbl, double value, string suffix)
        {
            const string iconStyle = "width:12px;height:12px;vertical-align:middle;margin-right:3px;";
            if (value >= 0)
            {
                lbl.CssClass = "dark-trend-up";
                lbl.Text = "<i data-lucide=\"trending-up\" style=\"" + iconStyle + "\"></i> +"
                           + value.ToString("F1") + "% " + suffix;
            }
            else
            {
                lbl.CssClass = "dark-trend-down";
                lbl.Text = "<i data-lucide=\"trending-down\" style=\"" + iconStyle + "\"></i> "
                           + value.ToString("F1") + "% " + suffix;
            }
        }
    }
}
