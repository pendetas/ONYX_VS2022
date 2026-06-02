using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_dashboard : Page
    {
        private readonly AdminRepository _adminRepo = new AdminRepository();

        // =====================================================================
        //  Public properties — consumed by <%= %> expressions in the ASPX
        //  for passing structured data to the Chart.js initialization script.
        // =====================================================================

        /// <summary>Daily revenue values for the past 7 days, as a JSON array literal (e.g. [2450,3100,...]).</summary>
        public string RevenueChartJson { get; private set; }

        /// <summary>Short day-name labels (Mon–Sun) for the chart x-axis, as a JSON array literal.</summary>
        public string DayLabelsJson { get; private set; }

        // =====================================================================
        //  PAGE LIFECYCLE
        // =====================================================================

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindDashboard();
            }
        }

        // =====================================================================
        //  DATA BINDING
        // =====================================================================

        private void BindDashboard()
        {
            BindTopBar();
            BindMetricCards();
            BindTopProducts();
            BindRecentOrders();
            BindChartData();
        }

        private void BindTopBar()
        {
            // Display current date in a friendly format for the greeting sub-line.
            lblCurrentDate.Text = DateTime.Now.ToString("dddd, d MMMM yyyy");
        }

        private void BindMetricCards()
        {
            DashboardMetrics metrics = _adminRepo.GetDashboardMetrics();

            // --- Row 1: Pastel KPI Cards ---
            lblTodaySales.Text = "RM " + metrics.TodaySales.ToString("N2");
            lblTotalRevenue.Text = "RM " + metrics.TotalRevenueMTD.ToString("N2");
            lblTotalOrders.Text = metrics.TotalOrdersMTD.ToString("N0");
            lblAOV.Text = "RM " + metrics.AverageOrderValue.ToString("N2");

            SetPastelTrend(lblTodaySalesTrend, metrics.TodaySalesTrend, "vs yesterday");
            SetPastelTrend(lblRevenueTrend, metrics.RevenueTrend, "vs last month");
            SetPastelTrend(lblOrdersTrend, metrics.OrdersTrend, "vs last month");
            SetPastelTrend(lblAOVTrend, metrics.AOVTrend, "vs last month");

            // --- Row 2: Dark Secondary Cards ---
            lblConversionRate.Text = metrics.ConversionRate.ToString("F1") + "%";
            lblReturningRate.Text = metrics.ReturningCustomerRate.ToString("F1") + "%";
            lblLowStock.Text = metrics.LowStockItems.ToString() + " item" + (metrics.LowStockItems == 1 ? "" : "s");

            SetDarkTrend(lblConversionTrend, metrics.ConversionTrend, "vs last week");
        }

        private void BindTopProducts()
        {
            List<TopProduct> products = _adminRepo.GetTopSellingProducts(5);
            TopProductsRepeater.DataSource = products;
            TopProductsRepeater.DataBind();
        }

        private void BindRecentOrders()
        {
            List<RecentOrder> orders = _adminRepo.GetRecentOrders(6);
            RecentOrdersRepeater.DataSource = orders;
            RecentOrdersRepeater.DataBind();
        }

        private void BindChartData()
        {
            // Weekly revenue → JSON number array for Chart.js
            List<decimal> weeklyRevenue = _adminRepo.GetWeeklyRevenueTrend();
            RevenueChartJson = "[" + string.Join(",", weeklyRevenue) + "]";

            // Day labels: short weekday names for the last 7 days (oldest first)
            var labels = new List<string>();
            for (int i = 6; i >= 0; i--)
                labels.Add("\"" + DateTime.Today.AddDays(-i).ToString("ddd") + "\"");
            DayLabelsJson = "[" + string.Join(",", labels) + "]";
        }

        // =====================================================================
        //  HELPER: trend label setters
        // =====================================================================

        /// <summary>
        /// Sets text + CSS class on a Label inside a pastel (light background) card.
        /// Uses dark-green/dark-red for legibility against the light pastel surface.
        /// </summary>
        private static void SetPastelTrend(Label lbl, double value, string suffix)
        {
            if (value >= 0)
            {
                lbl.CssClass = "trend-tag trend-up";
                lbl.Text = "↑ +" + value.ToString("F1") + "% " + suffix;
            }
            else
            {
                lbl.CssClass = "trend-tag trend-down";
                lbl.Text = "↓ " + value.ToString("F1") + "% " + suffix;
            }
        }

        /// <summary>
        /// Sets text + CSS class on a Label inside a dark card.
        /// Uses the standard accent-green / red-444 colours from the design system.
        /// </summary>
        private static void SetDarkTrend(Label lbl, double value, string suffix)
        {
            if (value >= 0)
            {
                lbl.CssClass = "dark-trend-up";
                lbl.Text = "↑ +" + value.ToString("F1") + "% " + suffix;
            }
            else
            {
                lbl.CssClass = "dark-trend-down";
                lbl.Text = "↓ " + value.ToString("F1") + "% " + suffix;
            }
        }

        // =====================================================================
        //  HELPER: called from within the Repeater ItemTemplate
        // =====================================================================

        /// <summary>
        /// Returns a hex colour for the category dot indicator in the top products list.
        /// Called inline via <%# GetCategoryColor(...) %> in the ASPX Repeater template.
        /// </summary>
        public static string GetCategoryColor(string category)
        {
            switch ((category ?? "").ToLowerInvariant())
            {
                case "mouse": return "#00ff87";
                case "keyboard": return "#a78bfa";
                case "headset": return "#f9a8d4";
                case "monitor": return "#7dd3fc";
                case "chair": return "#fcd34d";
                default: return "#888891";
            }
        }
    }
}