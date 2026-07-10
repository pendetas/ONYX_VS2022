<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/admin_page/admin.Master" AutoEventWireup="true" CodeBehind="onyx_admin_dashboard.aspx.cs" Inherits="ONYX_DDAC.admin_page.onyx_admin_dashboard" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        /* ── Top bar ─────────────────────────────────── */
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 36px;
        }

        .greeting-block h1 {
            font-size: 22px;
            font-weight: 700;
            color: #fff;
            letter-spacing: -0.02em;
            margin: 0 0 6px;
        }

        .greeting-meta {
            font-size: 12px;
            color: rgba(255,255,255,0.28);
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .greeting-meta i { width: 12px; height: 12px; }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            background: #111113;
            padding: 8px 14px;
            border-radius: 30px;
            border: 1px solid rgba(255,255,255,0.06);
            position: relative;
        }

        .notif-wrap { position: relative; }

        .notif-btn {
            background: none; border: none; cursor: pointer;
            color: rgba(255,255,255,0.30); display: flex;
            align-items: center; transition: color 0.2s; padding: 0;
        }

        .notif-btn:hover { color: rgba(255,255,255,0.75); }
        .notif-btn i { width: 16px; height: 16px; }

        .notif-dot {
            position: absolute; top: -2px; right: -2px;
            width: 7px; height: 7px; border-radius: 50%;
            background: rgba(255,255,255,0.60);
            border: 1.5px solid #0c0c0e;
        }

        /* Notification dropdown */
        .notif-panel {
            display: none;
            position: absolute;
            top: calc(100% + 10px);
            right: -14px;
            width: 290px;
            background: #111113;
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 10px;
            box-shadow: 0 12px 40px rgba(0,0,0,0.55);
            z-index: 999;
            overflow: hidden;
        }

        .notif-panel.open { display: block; }

        .notif-header {
            padding: 13px 16px 10px;
            font-size: 10px; font-weight: 600; letter-spacing: 0.14em;
            text-transform: uppercase; color: rgba(255,255,255,0.22);
            border-bottom: 1px solid rgba(255,255,255,0.05);
        }

        .notif-item {
            display: flex; align-items: flex-start; gap: 12px;
            padding: 13px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.04);
            transition: background 0.12s;
        }

        .notif-item:last-child { border-bottom: none; }
        .notif-item:hover { background: rgba(255,255,255,0.02); }

        .notif-icon {
            width: 30px; height: 30px; border-radius: 8px; flex-shrink: 0;
            background: rgba(255,255,255,0.05);
            display: flex; align-items: center; justify-content: center;
        }

        .notif-icon i { width: 14px; height: 14px; color: rgba(255,255,255,0.45); }

        .notif-title {
            font-size: 12px; font-weight: 500; color: #fff;
            line-height: 1.35; margin-bottom: 3px;
        }

        .notif-sub  { font-size: 11px; color: rgba(255,255,255,0.28); }
        .notif-time { font-size: 10px; color: rgba(255,255,255,0.20); margin-top: 4px; }

        .user-avatar {
            width: 30px; height: 30px; border-radius: 50%;
            background: rgba(255,255,255,0.07);
            display: flex; align-items: center; justify-content: center;
            color: rgba(255,255,255,0.60); font-weight: 700; font-size: 12px;
        }

        /* ── KPI grid ────────────────────────────────── */
        .metric-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
            margin-bottom: 14px;
        }

        .kpi-card {
            background: #111113;
            border: 1px solid rgba(255,255,255,0.05);
            border-radius: 10px;
            padding: 20px 22px;
            transition: border-color 0.18s;
        }

        .kpi-card:hover { border-color: rgba(255,255,255,0.10); }

        .kpi-icon {
            width: 32px; height: 32px; border-radius: 8px;
            background: rgba(255,255,255,0.05);
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 16px;
        }

        .kpi-icon i { width: 15px; height: 15px; color: rgba(255,255,255,0.45); }

        .kpi-label {
            font-size: 10px; font-weight: 600; letter-spacing: 0.12em;
            text-transform: uppercase; color: rgba(255,255,255,0.22);
            margin-bottom: 6px;
        }

        .kpi-value {
            font-size: 22px; font-weight: 700; color: #fff;
            letter-spacing: -0.02em; line-height: 1.1;
        }

        .kpi-trend {
            font-size: 11px; margin-top: 6px;
            display: flex; align-items: center; gap: 3px;
        }

        .trend-up   { color: rgba(255,255,255,0.50); }
        .trend-down { color: rgba(255,68,68,0.70); }

        /* ── Secondary row ───────────────────────────── */
        .secondary-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-bottom: 14px;
        }

        .sec-card {
            background: #111113;
            border: 1px solid rgba(255,255,255,0.05);
            border-radius: 10px;
            padding: 18px 20px;
            display: flex;
            align-items: center;
            gap: 16px;
            transition: border-color 0.18s;
        }

        .sec-card:hover { border-color: rgba(255,255,255,0.10); }

        .sec-icon {
            width: 40px; height: 40px; border-radius: 10px;
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        }

        .sec-icon i { width: 18px; height: 18px; }

        .icon-neutral { background: rgba(255,255,255,0.05); color: rgba(255,255,255,0.45); }
        .icon-blue    { background: rgba(96,165,250,0.10);  color: #60a5fa; }
        .icon-amber   { background: rgba(251,191,36,0.10);  color: #fbbf24; }

        .sec-label {
            font-size: 10px; font-weight: 600; letter-spacing: 0.12em;
            text-transform: uppercase; color: rgba(255,255,255,0.22); margin-bottom: 4px;
        }

        .sec-value { font-size: 20px; font-weight: 700; color: #fff; letter-spacing: -0.02em; }

        .sec-sub { font-size: 11px; color: rgba(255,255,255,0.22); margin-top: 3px; }

        .view-link {
            font-size: 11px; color: rgba(255,255,255,0.35);
            text-decoration: none; transition: color 0.15s;
        }

        .view-link:hover { color: rgba(255,255,255,0.75); text-decoration: none; }

        /* ── Chart + top products ────────────────────── */
        .content-grid {
            display: grid;
            grid-template-columns: 1.7fr 1fr;
            gap: 14px;
            margin-bottom: 14px;
        }

        .chart-card, .top-products-card {
            background: #111113;
            border: 1px solid rgba(255,255,255,0.05);
            border-radius: 10px;
            padding: 22px;
        }

        .card-header {
            display: flex; justify-content: space-between;
            align-items: center; margin-bottom: 20px;
        }

        .card-header h3 {
            font-size: 13px; font-weight: 600; color: #fff; letter-spacing: -0.01em;
        }

        .card-tag {
            font-size: 10px; font-weight: 600; letter-spacing: 0.10em;
            text-transform: uppercase; color: rgba(255,255,255,0.22);
            background: rgba(255,255,255,0.04);
            padding: 3px 9px; border-radius: 3px;
        }

        .chart-wrapper { height: 210px; position: relative; }

        /* Top products */
        .product-list { display: flex; flex-direction: column; gap: 0; }

        .product-item {
            display: flex; align-items: center; gap: 12px;
            padding: 11px 0; border-bottom: 1px solid rgba(255,255,255,0.04);
        }

        .product-item:last-child { border-bottom: none; padding-bottom: 0; }

        .product-rank {
            width: 22px; height: 22px; border-radius: 5px;
            background: rgba(255,255,255,0.04); color: rgba(255,255,255,0.30);
            font-size: 11px; font-weight: 700;
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        }

        .rank-1 { background: rgba(255,255,255,0.10); color: rgba(255,255,255,0.75); }
        .rank-2 { background: rgba(255,255,255,0.07); color: rgba(255,255,255,0.55); }
        .rank-3 { background: rgba(255,255,255,0.05); color: rgba(255,255,255,0.40); }

        .product-info { flex: 1; min-width: 0; }

        .product-name {
            font-size: 13px; font-weight: 600; color: #fff;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }

        .product-category { font-size: 11px; color: rgba(255,255,255,0.26); margin-top: 2px; }

        .product-stats { text-align: right; flex-shrink: 0; }
        .product-revenue { font-size: 13px; font-weight: 600; color: #fff; }
        .product-units   { font-size: 11px; color: rgba(255,255,255,0.26); margin-top: 2px; }

        /* ── Low stock alerts ───────────────────────── */
        .low-stock-card {
            background: rgba(255,255,255,0.02); border: 1px solid rgba(251,191,36,0.18);
            border-radius: 10px; padding: 22px 24px; margin-bottom: 24px;
        }
        .low-stock-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 18px;
        }
        .low-stock-title {
            display: flex; align-items: center; gap: 8px;
            font-size: 13px; font-weight: 600; color: rgba(255,255,255,0.75);
        }
        .low-stock-title i { width: 15px; height: 15px; color: #fbbf24; }
        .low-stock-badge {
            font-size: 10px; font-weight: 600; letter-spacing: 0.08em; text-transform: uppercase;
            background: rgba(251,191,36,0.12); color: #fbbf24;
            padding: 2px 8px; border-radius: 10px;
        }
        .low-stock-list { display: flex; flex-direction: column; gap: 2px; }
        .low-stock-item {
            display: flex; align-items: center; justify-content: space-between;
            padding: 10px 12px; border-radius: 7px; text-decoration: none;
            transition: background 0.12s;
        }
        .low-stock-item:hover { background: rgba(255,255,255,0.04); text-decoration: none; }
        .low-stock-left  { display: flex; align-items: center; gap: 12px; }
        .low-stock-dot   { width: 9px; height: 9px; border-radius: 50%; flex-shrink: 0; }
        .dot-mouse     { background: #00ff87; }
        .dot-keyboard  { background: #a78bfa; }
        .dot-headset   { background: #f9a8d4; }
        .dot-monitor   { background: #7dd3fc; }
        .dot-chair     { background: #fcd34d; }
        .low-stock-name { font-size: 13px; font-weight: 500; color: rgba(255,255,255,0.78); }
        .low-stock-cat  { font-size: 11px; color: rgba(255,255,255,0.24); margin-top: 1px; }
        .low-stock-qty  { font-size: 12px; font-weight: 600; border-radius: 6px; padding: 3px 10px; }
        .qty-low  { background: rgba(251,191,36,0.10); color: #fbbf24; }
        .qty-zero { background: rgba(239,68,68,0.10);  color: #f87171; }

        /* light mode */
        html[data-theme="light"] .low-stock-card  { background: rgba(0,0,0,0.02); border-color: rgba(217,119,6,0.20); }
        html[data-theme="light"] .low-stock-title { color: rgba(0,0,0,0.70); }
        html[data-theme="light"] .low-stock-item:hover { background: rgba(0,0,0,0.03); }
        html[data-theme="light"] .low-stock-name  { color: rgba(0,0,0,0.75); }
        html[data-theme="light"] .low-stock-cat   { color: rgba(0,0,0,0.30); }

        /* ── Recent orders ───────────────────────────── */
        .orders-card {
            background: #111113;
            border: 1px solid rgba(255,255,255,0.05);
            border-radius: 10px;
            padding: 22px;
        }

        .orders-header {
            display: flex; justify-content: space-between;
            align-items: center; margin-bottom: 18px;
        }

        .orders-header h3 { font-size: 13px; font-weight: 600; color: #fff; letter-spacing: -0.01em; }

        .admin-table {
            width: 100%; border-collapse: collapse;
            font-size: 13px; color: #fff;
        }

        .admin-table th {
            text-align: left; padding: 0 14px 12px;
            color: rgba(255,255,255,0.22); font-weight: 600;
            font-size: 10px; text-transform: uppercase;
            letter-spacing: 0.10em;
            border-bottom: 1px solid rgba(255,255,255,0.06);
        }

        .admin-table th:first-child { padding-left: 0; }

        .admin-table td {
            padding: 13px 14px;
            border-bottom: 1px solid rgba(255,255,255,0.04);
            vertical-align: middle;
        }

        .admin-table td:first-child { padding-left: 0; }
        .admin-table tr:last-child td { border-bottom: none; }
        .admin-table tr:hover td { background: rgba(255,255,255,0.015); }

        .order-id-cell { color: rgba(255,255,255,0.35); font-size: 12px; font-family: monospace; }
        .customer-name { font-weight: 500; }
        .amount-cell   { font-weight: 600; }
        .date-cell     { color: rgba(255,255,255,0.30); font-size: 12px; }

        .status-badge {
            display: inline-block; padding: 3px 9px; border-radius: 3px;
            font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em;
        }

        .status-pending   { background: rgba(251,191,36,0.10);  color: #fbbf24; }
        .status-shipped   { background: rgba(96,165,250,0.10);  color: #60a5fa; }
        .status-delivered { background: rgba(255,255,255,0.07); color: rgba(255,255,255,0.65); }
        .status-cancelled { background: rgba(255,68,68,0.10);   color: #ff5555; }

        /* ── Responsive ──────────────────────────────── */
        @media (max-width: 1280px) { .metric-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 1024px) { .content-grid { grid-template-columns: 1fr; } .secondary-grid { grid-template-columns: 1fr 1fr; } }
        @media (max-width: 768px)  { .metric-grid { grid-template-columns: 1fr; } .secondary-grid { grid-template-columns: 1fr; } }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Top bar --%>
    <div class="top-bar">
        <div class="greeting-block">
                <h1><asp:Label ID="lblGreeting" runat="server" /></h1>
            <div class="greeting-meta">
                <i data-lucide="map-pin"></i>
                <asp:Label ID="lblCurrentDate" runat="server" />
                &nbsp;&middot;&nbsp; Kuala Lumpur, Malaysia
            </div>
        </div>
        <div class="user-profile">
            <div class="notif-wrap">
                <button type="button" class="notif-btn" id="notifToggle" title="Notifications">
                    <i data-lucide="bell"></i>
                </button>
                <div class="notif-dot"></div>

                <div class="notif-panel" id="notifPanel">
                    <div class="notif-header">Recent Activity</div>
                    <asp:Repeater ID="NotifRepeater" runat="server">
                        <ItemTemplate>
                            <div class="notif-item">
                                <div class="notif-icon">
                                    <i data-lucide="<%# Eval("Icon") %>"></i>
                                </div>
                                <div style="flex:1;min-width:0;">
                                    <div class="notif-title"><%# Eval("Title") %></div>
                                    <div class="notif-sub"><%# Eval("Sub") %></div>
                                    <div class="notif-time"><%# Eval("TimeLabel") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
            <div class="user-avatar"><asp:Label ID="lblAvatar" runat="server" /></div>
        </div>
    </div>

    <%-- KPI row --%>
    <div class="metric-grid">

        <div class="kpi-card">
            <div class="kpi-icon"><i data-lucide="trending-up"></i></div>
            <div class="kpi-label">Today's Sales</div>
            <div class="kpi-value"><asp:Label ID="lblTodaySales" runat="server" Text="RM 0.00" /></div>
            <div class="kpi-trend trend-up"><asp:Label ID="lblTodaySalesTrend" runat="server" Text="" /></div>
        </div>

        <div class="kpi-card">
            <div class="kpi-icon"><i data-lucide="dollar-sign"></i></div>
            <div class="kpi-label">Revenue (This Month)</div>
            <div class="kpi-value"><asp:Label ID="lblTotalRevenue" runat="server" Text="RM 0.00" /></div>
            <div class="kpi-trend trend-up"><asp:Label ID="lblRevenueTrend" runat="server" Text="" /></div>
        </div>

        <div class="kpi-card">
            <div class="kpi-icon"><i data-lucide="shopping-bag"></i></div>
            <div class="kpi-label">Orders (This Month)</div>
            <div class="kpi-value"><asp:Label ID="lblTotalOrders" runat="server" Text="0" /></div>
            <div class="kpi-trend trend-up"><asp:Label ID="lblOrdersTrend" runat="server" Text="" /></div>
        </div>

        <div class="kpi-card">
            <div class="kpi-icon"><i data-lucide="receipt"></i></div>
            <div class="kpi-label">Avg. Order Value</div>
            <div class="kpi-value"><asp:Label ID="lblAOV" runat="server" Text="RM 0.00" /></div>
            <div class="kpi-trend trend-up"><asp:Label ID="lblAOVTrend" runat="server" Text="" /></div>
        </div>

    </div>

    <%-- Secondary row --%>
    <div class="secondary-grid">

        <div class="sec-card">
            <div class="sec-icon icon-neutral"><i data-lucide="percent"></i></div>
            <div>
                <div class="sec-label">Conversion Rate</div>
                <div class="sec-value"><asp:Label ID="lblConversionRate" runat="server" Text="0.0%" /></div>
                <div class="sec-sub"><asp:Label ID="lblConversionTrend" runat="server" Text="" /></div>
            </div>
        </div>

        <div class="sec-card">
            <div class="sec-icon icon-blue"><i data-lucide="repeat-2"></i></div>
            <div>
                <div class="sec-label">Returning Customers</div>
                <div class="sec-value"><asp:Label ID="lblReturningRate" runat="server" Text="0.0%" /></div>
                <div class="sec-sub">of all purchases this month</div>
            </div>
        </div>

        <div class="sec-card">
            <div class="sec-icon icon-amber"><i data-lucide="alert-triangle"></i></div>
            <div>
                <div class="sec-label">Low Stock Alerts</div>
                <div class="sec-value"><asp:Label ID="lblLowStock" runat="server" Text="0 items" /></div>
                <a href="onyx_admin_products.aspx" class="view-link">View inventory &rarr;</a>
            </div>
        </div>

    </div>

    <%-- Chart + Top Products --%>
    <div class="content-grid">

        <div class="chart-card">
            <div class="card-header">
                <h3>Revenue Trend</h3>
                <span class="card-tag">Last 7 days</span>
            </div>
            <div class="chart-wrapper">
                <canvas id="revenueChart"></canvas>
            </div>
        </div>

        <div class="top-products-card">
            <div class="card-header">
                <h3>Top Products</h3>
                <span class="card-tag">This month</span>
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
                                <div class="product-category"><%# Eval("Category") %></div>
                            </div>
                            <div class="product-stats">
                                <div class="product-revenue">RM <%# string.Format("{0:N2}", Eval("Price")) %></div>
                                <div class="product-units"><%# Eval("StockQty") %> in stock</div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

    </div>

    <%-- Low Stock Alerts (visible only when stock_qty < 5 exists) --%>
    <asp:Panel ID="pnlLowStock" runat="server" Visible="false" CssClass="low-stock-card">
        <div class="low-stock-header">
            <div class="low-stock-title">
                <i data-lucide="alert-triangle"></i>
                Low Stock Alerts
                <span class="low-stock-badge">Needs attention</span>
            </div>
            <a href="onyx_admin_products.aspx" class="view-link">Manage inventory &rarr;</a>
        </div>
        <div class="low-stock-list">
            <asp:Repeater ID="LowStockRepeater" runat="server">
                <ItemTemplate>
                    <a href='<%# "onyx_admin_product_detail.aspx?id=" + Eval("Id") %>' class="low-stock-item">
                        <div class="low-stock-left">
                            <span class='<%# "low-stock-dot dot-" + Eval("Category").ToString().ToLower() %>'></span>
                            <div>
                                <div class="low-stock-name"><%# Server.HtmlEncode(Eval("Name").ToString()) %></div>
                                <div class="low-stock-cat"><%# Server.HtmlEncode(Eval("Category").ToString()) %></div>
                            </div>
                        </div>
                        <div class='<%# (int)Eval("StockQty") == 0 ? "low-stock-qty qty-zero" : "low-stock-qty qty-low" %>'>
                            <%# (int)Eval("StockQty") == 0 ? "Out of stock" : Eval("StockQty") + " left" %>
                        </div>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <%-- Recent orders --%>
    <div class="orders-card">
        <div class="orders-header">
            <h3>Recent Orders</h3>
            <a href="onyx_admin_orders.aspx" class="view-link">View all &rarr;</a>
        </div>
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Order</th>
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

    <%-- Notification toggle --%>
    <script>
        (function () {
            var btn   = document.getElementById('notifToggle');
            var panel = document.getElementById('notifPanel');
            if (!btn || !panel) return;

            btn.addEventListener('click', function (e) {
                e.stopPropagation();
                panel.classList.toggle('open');
                // Re-render any lucide icons inside the panel on first open
                if (typeof lucide !== 'undefined') lucide.createIcons();
            });

            document.addEventListener('click', function (e) {
                if (!panel.contains(e.target) && e.target !== btn) {
                    panel.classList.remove('open');
                }
            });
        })();
    </script>

    <%-- Chart init --%>
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
                        borderColor: 'rgba(255,255,255,0.65)',
                        backgroundColor: 'rgba(255,255,255,0.04)',
                        borderWidth: 1.5,
                        fill: true,
                        tension: 0.40,
                        pointBackgroundColor: 'rgba(255,255,255,0.80)',
                        pointBorderColor: '#111113',
                        pointBorderWidth: 2,
                        pointRadius: 4,
                        pointHoverRadius: 6,
                        pointHoverBackgroundColor: '#fff',
                        pointHoverBorderColor: 'rgba(255,255,255,0.30)'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: '#0c0c0e',
                            borderColor: 'rgba(255,255,255,0.08)',
                            borderWidth: 1,
                            titleColor: 'rgba(255,255,255,0.35)',
                            bodyColor: '#ffffff',
                            padding: 12,
                            cornerRadius: 6,
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
                            ticks: { color: 'rgba(255,255,255,0.25)', font: { size: 11 } }
                        },
                        y: {
                            grid: { color: 'rgba(255,255,255,0.04)', drawBorder: false },
                            ticks: {
                                color: 'rgba(255,255,255,0.25)',
                                font: { size: 11 },
                                callback: function (val) { return 'RM ' + val.toLocaleString('en-MY'); }
                            }
                        }
                    }
                }
            });
        })();
    </script>

</asp:Content>
