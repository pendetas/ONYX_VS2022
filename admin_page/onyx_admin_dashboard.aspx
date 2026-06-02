<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/admin_page/admin.Master" AutoEventWireup="true" CodeBehind="onyx_admin_dashboard.aspx.cs" Inherits="ONYX_DDAC.admin_page.onyx_admin_dashboard" %>

<%-- Chart.js loaded in <head> via the HeadContent placeholder --%>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        /* =====================================================================
           TOP BAR
        ===================================================================== */
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 32px;
        }

        .greeting-block h1 {
            font-size: 22px;
            font-weight: 700;
            color: var(--text-main);
            margin-bottom: 4px;
        }

        .greeting-block p {
            font-size: 13px;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 14px;
            background: var(--card-dark);
            padding: 8px 16px;
            border-radius: 30px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        .user-avatar {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            background: var(--accent-green);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #000;
            font-weight: 700;
            font-size: 13px;
        }

        .notif-btn {
            background: none;
            border: none;
            cursor: pointer;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            transition: color 0.2s;
        }

        .notif-btn:hover { color: var(--text-main); }

        /* =====================================================================
           ROW 1 — PASTEL KPI CARDS
        ===================================================================== */
        .metric-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-bottom: 18px;
        }

        .pastel-card {
            border-radius: 20px;
            padding: 24px 20px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            color: #111;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            cursor: default;
        }

        .pastel-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .bg-yellow { background-color: var(--pastel-yellow); }
        .bg-purple { background-color: var(--pastel-purple); }
        .bg-pink   { background-color: var(--pastel-pink);   }
        .bg-blue   { background-color: var(--pastel-blue);   }

        .pastel-card-icon {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            background: rgba(0, 0, 0, 0.08);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 4px;
        }

        .pastel-card-icon i { width: 18px; height: 18px; }

        .card-label {
            font-size: 12px;
            font-weight: 500;
            color: rgba(0, 0, 0, 0.5);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .card-value {
            font-size: 24px;
            font-weight: 700;
            color: #111;
            line-height: 1.2;
        }

        .trend-tag {
            font-size: 11px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 3px;
        }

        .trend-tag.trend-up   { color: #1a7a45; }
        .trend-tag.trend-down { color: #c62828; }

        /* =====================================================================
           ROW 2 — DARK SECONDARY CARDS
        ===================================================================== */
        .secondary-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px;
            margin-bottom: 18px;
        }

        .dark-card {
            background-color: var(--card-dark);
            border-radius: 20px;
            padding: 22px 24px;
            display: flex;
            align-items: center;
            gap: 18px;
            border: 1px solid rgba(255, 255, 255, 0.04);
            transition: transform 0.2s ease, border-color 0.2s ease;
        }

        .dark-card:hover {
            transform: translateY(-2px);
            border-color: rgba(255, 255, 255, 0.09);
        }

        .dark-icon-wrap {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .dark-icon-wrap i { width: 22px; height: 22px; }

        .icon-green { background: rgba(0, 255, 135, 0.12); color: var(--accent-green); }
        .icon-blue  { background: rgba(96, 165, 250, 0.12); color: #60a5fa; }
        .icon-red   { background: rgba(255, 68, 68, 0.12);  color: #ff4444; }
        .icon-amber { background: rgba(251, 191, 36, 0.12); color: #fbbf24; }

        .dark-card-body { flex: 1; min-width: 0; }

        .dark-label {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 6px;
        }

        .dark-value {
            font-size: 22px;
            font-weight: 700;
            color: var(--text-main);
            margin-bottom: 5px;
        }

        .dark-sub {
            font-size: 11px;
            color: var(--text-muted);
        }

        .view-link {
            font-size: 12px;
            color: var(--accent-green);
            text-decoration: none;
            font-weight: 500;
        }

        .view-link:hover { text-decoration: underline; }

        .dark-trend-up   { color: var(--accent-green); font-size: 11px; font-weight: 500; }
        .dark-trend-down { color: #ff4444; font-size: 11px; font-weight: 500; }

        /* =====================================================================
           ROW 3 — CHART + TOP PRODUCTS
        ===================================================================== */
        .content-grid {
            display: grid;
            grid-template-columns: 1.7fr 1fr;
            gap: 18px;
            margin-bottom: 18px;
        }

        .chart-card,
        .top-products-card {
            background-color: var(--card-dark);
            border-radius: 20px;
            padding: 24px;
            border: 1px solid rgba(255, 255, 255, 0.04);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .card-header h3 {
            font-size: 15px;
            font-weight: 600;
            color: var(--text-main);
        }

        .card-subtitle {
            font-size: 12px;
            color: var(--text-muted);
            background: rgba(255, 255, 255, 0.05);
            padding: 3px 10px;
            border-radius: 20px;
        }

        .chart-wrapper {
            height: 220px;
            position: relative;
        }

        /* Top products list */
        .product-list { display: flex; flex-direction: column; gap: 14px; }

        .product-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.04);
        }

        .product-item:last-child { border-bottom: none; padding-bottom: 0; }

        .product-rank {
            width: 26px;
            height: 26px;
            border-radius: 8px;
            background: rgba(0, 255, 135, 0.1);
            color: var(--accent-green);
            font-size: 12px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .product-rank.rank-1 { background: rgba(0, 255, 135, 0.18); }
        .product-rank.rank-2 { background: rgba(0, 255, 135, 0.11); }
        .product-rank.rank-3 { background: rgba(0, 255, 135, 0.07); }
        .product-rank.rank-4, .product-rank.rank-5 { background: rgba(255,255,255,0.05); color: var(--text-muted); }

        .product-info { flex: 1; min-width: 0; }

        .product-name {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-main);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .category-dot {
            display: inline-block;
            width: 6px;
            height: 6px;
            border-radius: 50%;
            margin-right: 5px;
        }

        .product-category { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

        .product-stats { text-align: right; flex-shrink: 0; }

        .product-revenue { font-size: 13px; font-weight: 600; color: var(--text-main); }

        .product-units { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

        .product-growth-up   { font-size: 11px; color: var(--accent-green); font-weight: 500; }
        .product-growth-down { font-size: 11px; color: #ff4444; font-weight: 500; }

        /* =====================================================================
           ROW 4 — RECENT ORDERS TABLE
        ===================================================================== */
        .orders-card {
            background-color: var(--card-dark);
            border-radius: 20px;
            padding: 24px;
            border: 1px solid rgba(255, 255, 255, 0.04);
        }

        .orders-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .orders-header h3 {
            font-size: 15px;
            font-weight: 600;
            color: var(--text-main);
        }

        .view-all-link {
            font-size: 13px;
            color: var(--accent-green);
            text-decoration: none;
            font-weight: 500;
        }

        .view-all-link:hover { text-decoration: underline; }

        .admin-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            color: var(--text-main);
        }

        .admin-table th {
            text-align: left;
            padding: 0 16px 12px 16px;
            color: var(--text-muted);
            font-weight: 500;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.06);
        }

        .admin-table td {
            padding: 14px 16px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.04);
            vertical-align: middle;
        }

        .admin-table tr:last-child td { border-bottom: none; }

        .admin-table tr:hover td { background: rgba(255, 255, 255, 0.02); }

        .order-id-cell { color: var(--text-muted); font-weight: 500; }

        .customer-name { font-weight: 500; }

        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            text-transform: capitalize;
            letter-spacing: 0.3px;
        }

        .status-pending   { background: rgba(251, 191, 36, 0.15);  color: #fbbf24; }
        .status-shipped   { background: rgba(96, 165, 250, 0.15);  color: #60a5fa; }
        .status-delivered { background: rgba(0, 255, 135, 0.15);   color: var(--accent-green); }
        .status-cancelled { background: rgba(255, 68, 68, 0.15);   color: #ff4444; }

        .amount-cell { font-weight: 600; }

        .date-cell { color: var(--text-muted); font-size: 12px; }

        /* =====================================================================
           RESPONSIVE
        ===================================================================== */
        @media (max-width: 1280px) {
            .metric-grid { grid-template-columns: repeat(2, 1fr); }
        }

        @media (max-width: 1024px) {
            .content-grid { grid-template-columns: 1fr; }
            .secondary-grid { grid-template-columns: 1fr 1fr; }
        }

        @media (max-width: 768px) {
            .metric-grid    { grid-template-columns: 1fr; }
            .secondary-grid { grid-template-columns: 1fr; }
            .admin-table th:nth-child(5),
            .admin-table td:nth-child(5) { display: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ================================================================
         TOP BAR
    ================================================================ --%>
    <div class="top-bar">
        <div class="greeting-block">
            <h1>Good morning, Admin 👋</h1>
            <p>
                <i data-lucide="map-pin" style="width:13px; height:13px;"></i>
                <asp:Label ID="lblCurrentDate" runat="server" />
                &nbsp;·&nbsp; Kuala Lumpur, Malaysia
            </p>
        </div>
        <div class="user-profile">
            <button class="notif-btn" title="Notifications">
                <i data-lucide="bell" style="width:18px; height:18px;"></i>
            </button>
            <div class="user-avatar">AD</div>
        </div>
    </div>

    <%-- ================================================================
         ROW 1 — 4 PASTEL KPI CARDS
    ================================================================ --%>
    <div class="metric-grid">

        <%-- Today's Sales --%>
        <div class="pastel-card bg-yellow">
            <div class="pastel-card-icon">
                <i data-lucide="trending-up"></i>
            </div>
            <div class="card-label">Today's Sales</div>
            <div class="card-value">
                <asp:Label ID="lblTodaySales" runat="server" Text="RM 0.00" />
            </div>
            <asp:Label ID="lblTodaySalesTrend" runat="server" CssClass="trend-tag trend-up" Text="" />
        </div>

        <%-- MTD Revenue --%>
        <div class="pastel-card bg-purple">
            <div class="pastel-card-icon">
                <i data-lucide="dollar-sign"></i>
            </div>
            <div class="card-label">Revenue (This Month)</div>
            <div class="card-value">
                <asp:Label ID="lblTotalRevenue" runat="server" Text="RM 0.00" />
            </div>
            <asp:Label ID="lblRevenueTrend" runat="server" CssClass="trend-tag trend-up" Text="" />
        </div>

        <%-- Orders MTD --%>
        <div class="pastel-card bg-pink">
            <div class="pastel-card-icon">
                <i data-lucide="shopping-bag"></i>
            </div>
            <div class="card-label">Orders (This Month)</div>
            <div class="card-value">
                <asp:Label ID="lblTotalOrders" runat="server" Text="0" />
            </div>
            <asp:Label ID="lblOrdersTrend" runat="server" CssClass="trend-tag trend-up" Text="" />
        </div>

        <%-- Average Order Value --%>
        <div class="pastel-card bg-blue">
            <div class="pastel-card-icon">
                <i data-lucide="receipt"></i>
            </div>
            <div class="card-label">Avg. Order Value</div>
            <div class="card-value">
                <asp:Label ID="lblAOV" runat="server" Text="RM 0.00" />
            </div>
            <asp:Label ID="lblAOVTrend" runat="server" CssClass="trend-tag trend-up" Text="" />
        </div>

    </div>

    <%-- ================================================================
         ROW 2 — 3 DARK SECONDARY METRIC CARDS
    ================================================================ --%>
    <div class="secondary-grid">

        <%-- Conversion Rate --%>
        <div class="dark-card">
            <div class="dark-icon-wrap icon-green">
                <i data-lucide="percent"></i>
            </div>
            <div class="dark-card-body">
                <div class="dark-label">Conversion Rate</div>
                <div class="dark-value">
                    <asp:Label ID="lblConversionRate" runat="server" Text="0.0%" />
                </div>
                <asp:Label ID="lblConversionTrend" runat="server" CssClass="dark-trend-up" Text="" />
            </div>
        </div>

        <%-- Returning Customer Rate --%>
        <div class="dark-card">
            <div class="dark-icon-wrap icon-blue">
                <i data-lucide="repeat-2"></i>
            </div>
            <div class="dark-card-body">
                <div class="dark-label">Returning Customers</div>
                <div class="dark-value">
                    <asp:Label ID="lblReturningRate" runat="server" Text="0.0%" />
                </div>
                <div class="dark-sub">of all purchases this month</div>
            </div>
        </div>

        <%-- Low Stock Alert --%>
        <div class="dark-card">
            <div class="dark-icon-wrap icon-amber">
                <i data-lucide="alert-triangle"></i>
            </div>
            <div class="dark-card-body">
                <div class="dark-label">Low Stock Alerts</div>
                <div class="dark-value">
                    <asp:Label ID="lblLowStock" runat="server" Text="0 items" />
                </div>
                <a href="onyx_admin_products.aspx" class="view-link">View inventory &rarr;</a>
            </div>
        </div>

    </div>

    <%-- ================================================================
         ROW 3 — REVENUE CHART + TOP PRODUCTS
    ================================================================ --%>
    <div class="content-grid">

        <%-- Revenue Trend Chart --%>
        <div class="chart-card">
            <div class="card-header">
                <h3>Revenue Trend</h3>
                <span class="card-subtitle">Last 7 days</span>
            </div>
            <div class="chart-wrapper">
                <canvas id="revenueChart"></canvas>
            </div>
        </div>

        <%-- Top Selling Products --%>
        <div class="top-products-card">
            <div class="card-header">
                <h3>Top Products</h3>
                <span class="card-subtitle">This month</span>
            </div>
            <div class="product-list">
                <asp:Repeater ID="TopProductsRepeater" runat="server">
                    <ItemTemplate>
                        <div class="product-item">
                            <div class="product-rank rank-<%# Container.ItemIndex + 1 %>">
                                <%# Container.ItemIndex + 1 %>
                            </div>
                            <div class="product-info">
                                <div class="product-name" title="<%# Eval("Name") %>"><%# Eval("Name") %></div>
                                <div class="product-category">
                                    <span class="category-dot" style="background-color: <%# GetCategoryColor(Eval("Category").ToString()) %>;"></span>
                                    <%# Eval("Category") %>
                                </div>
                            </div>
                            <div class="product-stats">
                                <div class="product-revenue">RM <%# string.Format("{0:N0}", Eval("Revenue")) %></div>
                                <div class="product-units"><%# Eval("UnitsSold") %> units</div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

    </div>

    <%-- ================================================================
         ROW 4 — RECENT ORDERS TABLE
    ================================================================ --%>
    <div class="orders-card">
        <div class="orders-header">
            <h3>Recent Orders</h3>
            <a href="onyx_admin_orders.aspx" class="view-all-link">View all orders &rarr;</a>
        </div>
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Order #</th>
                    <th>Customer</th>
                    <th>Status</th>
                    <th>Amount</th>
                    <th>Date &amp; Time</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="RecentOrdersRepeater" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td class="order-id-cell">#<%# Eval("OrderId") %></td>
                            <td class="customer-name"><%# Eval("CustomerName") %></td>
                            <td>
                                <span class="status-badge <%# Eval("StatusCssClass") %>">
                                    <%# Eval("Status") %>
                                </span>
                            </td>
                            <td class="amount-cell">RM <%# string.Format("{0:N2}", Eval("TotalAmount")) %></td>
                            <td class="date-cell"><%# ((DateTime)Eval("OrderedAt")).ToString("dd MMM, h:mm tt") %></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>

    <%-- ================================================================
         CHART.JS INITIALIZATION
         RevenueChartJson and DayLabelsJson are public properties set
         in the code-behind's Page_Load before the page renders.
    ================================================================ --%>
    <script>
        (function () {
            var revenueData = <%= RevenueChartJson %>;
            var dayLabels   = <%= DayLabelsJson %>;

            var ctx = document.getElementById('revenueChart');
            if (!ctx) return;

            new Chart(ctx.getContext('2d'), {
                type: 'line',
                data: {
                    labels: dayLabels,
                    datasets: [{
                        label: 'Revenue (RM)',
                        data: revenueData,
                        borderColor: '#00ff87',
                        backgroundColor: 'rgba(0, 255, 135, 0.07)',
                        borderWidth: 2.5,
                        fill: true,
                        tension: 0.45,
                        pointBackgroundColor: '#00ff87',
                        pointBorderColor: '#121215',
                        pointBorderWidth: 2,
                        pointRadius: 5,
                        pointHoverRadius: 7,
                        pointHoverBackgroundColor: '#00ff87',
                        pointHoverBorderColor: '#fff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: '#1c1c22',
                            borderColor: 'rgba(255,255,255,0.08)',
                            borderWidth: 1,
                            titleColor: '#888891',
                            bodyColor: '#ffffff',
                            padding: 12,
                            cornerRadius: 10,
                            callbacks: {
                                label: function (ctx) {
                                    return '  RM ' + ctx.parsed.y.toLocaleString('en-MY', {
                                        minimumFractionDigits: 2, maximumFractionDigits: 2
                                    });
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: { color: 'rgba(255,255,255,0.04)', drawBorder: false },
                            ticks: { color: '#888891', font: { family: 'Inter', size: 12 } }
                        },
                        y: {
                            grid: { color: 'rgba(255,255,255,0.04)', drawBorder: false },
                            ticks: {
                                color: '#888891',
                                font: { family: 'Inter', size: 12 },
                                callback: function (val) {
                                    return 'RM ' + val.toLocaleString('en-MY');
                                }
                            }
                        }
                    }
                }
            });
        })();
    </script>

</asp:Content>