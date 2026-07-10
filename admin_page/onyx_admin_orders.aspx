<%@ Page Title="Orders" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_orders.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_orders" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* ── Page header ─────────────────────────────── */
    .page-header {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        margin-bottom: 32px;
    }

    .page-title {
        font-size: 22px;
        font-weight: 600;
        color: #fff;
        letter-spacing: -0.02em;
        margin: 0;
    }

    .page-subtitle {
        font-size: 12px;
        color: rgba(255,255,255,0.28);
        margin-top: 5px;
    }

    .last-updated {
        font-size: 12px;
        color: rgba(255,255,255,0.22);
        display: flex;
        align-items: center;
        gap: 6px;
        margin-top: 6px;
    }

    .last-updated i { width: 13px; height: 13px; }

    /* ── Stat strip ──────────────────────────────── */
    .stat-strip {
        display: flex;
        gap: 12px;
        margin-bottom: 32px;
        flex-wrap: wrap;
    }

    .stat-box {
        flex: 1;
        min-width: 130px;
        background: #111113;
        border: 1px solid rgba(255,255,255,0.05);
        border-radius: 10px;
        padding: 16px 20px;
    }

    .stat-value {
        font-size: 22px;
        font-weight: 700;
        color: #fff;
        letter-spacing: -0.02em;
    }

    .stat-label {
        font-size: 10px;
        color: rgba(255,255,255,0.26);
        margin-top: 5px;
        font-weight: 500;
        letter-spacing: 0.08em;
        text-transform: uppercase;
    }

    /* ── Toolbar: filter tabs + search ───────────── */
    .toolbar {
        display: flex;
        align-items: flex-end;
        justify-content: space-between;
        gap: 20px;
        margin-bottom: 0;
        flex-wrap: wrap;
    }

    .filter-tabs {
        display: flex;
        align-items: stretch;
        border-bottom: 1px solid rgba(255,255,255,0.07);
        overflow-x: auto;
        scrollbar-width: none;
        -ms-overflow-style: none;
    }

    .filter-tabs::-webkit-scrollbar { display: none; }

    .tab {
        padding: 9px 16px;
        font-size: 11px;
        font-weight: 500;
        letter-spacing: 0.10em;
        text-transform: uppercase;
        color: rgba(255,255,255,0.26);
        cursor: pointer;
        border: none;
        background: transparent;
        border-bottom: 1.5px solid transparent;
        margin-bottom: -1px;
        transition: color 0.15s, border-color 0.15s;
        white-space: nowrap;
        font-family: inherit;
    }

    .tab:first-child { padding-left: 0; }
    .tab:hover { color: rgba(255,255,255,0.62); }
    .tab.active { color: #fff; border-bottom-color: #fff; }

    .search-wrap {
        max-width: 240px;
        flex: 1;
    }

    .search-line {
        display: flex;
        align-items: center;
        gap: 8px;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        padding: 7px 0;
        transition: border-color 0.18s;
    }

    .search-line:focus-within { border-color: rgba(255,255,255,0.38); }
    .search-line i { width: 13px; height: 13px; color: rgba(255,255,255,0.22); flex-shrink: 0; }

    .search-input {
        flex: 1;
        background: transparent;
        border: none;
        outline: none;
        color: #fff;
        font-size: 13px;
        font-family: inherit;
    }

    .search-input::placeholder { color: rgba(255,255,255,0.16); }

    /* ── Orders table ────────────────────────────── */
    .orders-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
        margin-top: 0;
    }

    .orders-table thead th {
        color: rgba(255,255,255,0.26);
        font-size: 10px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.10em;
        padding: 16px 14px 12px;
        border-bottom: 1px solid rgba(255,255,255,0.06);
        white-space: nowrap;
        text-align: left;
    }

    .orders-table thead th:first-child { padding-left: 0; }

    .orders-table tbody td {
        padding: 14px;
        border-bottom: 1px solid rgba(255,255,255,0.04);
        color: #fff;
        vertical-align: middle;
    }

    .orders-table tbody td:first-child { padding-left: 0; }
    .orders-table tbody tr:last-child td { border-bottom: none; }
    .orders-table tbody tr:hover td { background: rgba(255,255,255,0.018); }

    .order-id {
        font-family: 'Courier New', monospace;
        font-size: 12px;
        color: rgba(255,255,255,0.40);
    }

    .date-cell, .items-cell { color: rgba(255,255,255,0.38); }

    /* Status badges */
    .status-badge {
        display: inline-block;
        padding: 3px 9px;
        border-radius: 3px;
        font-size: 10px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.06em;
    }

    .status-pending   { background: rgba(251,191,36,0.10);  color: #fbbf24; }
    .status-shipped   { background: rgba(96,165,250,0.10);  color: #60a5fa; }
    .status-delivered { background: rgba(255,255,255,0.07); color: rgba(255,255,255,0.65); }
    .status-cancelled { background: rgba(255,68,68,0.10);   color: #ff5555; }

    /* View button */
    .btn-view {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        font-size: 11px;
        color: rgba(255,255,255,0.30);
        text-decoration: none;
        letter-spacing: 0.04em;
        transition: color 0.15s;
        white-space: nowrap;
    }

    .btn-view i { width: 12px; height: 12px; }
    .btn-view:hover { color: rgba(255,255,255,0.75); text-decoration: none; }

    /* ── Summary bar ─────────────────────────────── */
    .summary-bar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding-top: 16px;
        border-top: 1px solid rgba(255,255,255,0.05);
        margin-top: 4px;
        font-size: 12px;
        color: rgba(255,255,255,0.22);
    }

    .summary-bar strong { color: rgba(255,255,255,0.60); }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Header --%>
    <div class="page-header">
        <div>
            <div class="page-title">Orders</div>
            <div class="page-subtitle">Track and manage all customer orders.</div>
        </div>
        <div class="last-updated">
            <i data-lucide="clock"></i>
            Updated: <asp:Literal ID="litLastUpdated" runat="server" />
        </div>
    </div>

    <%-- Stat strip --%>
    <div class="stat-strip">
        <div class="stat-box">
            <div class="stat-value"><asp:Literal ID="litStatTotal" runat="server" Text="0" /></div>
            <div class="stat-label">Total</div>
        </div>
        <div class="stat-box">
            <div class="stat-value" style="color:#fbbf24;">
                <asp:Literal ID="litStatPending" runat="server" Text="0" />
            </div>
            <div class="stat-label">Pending</div>
        </div>
        <div class="stat-box">
            <div class="stat-value" style="color:#60a5fa;">
                <asp:Literal ID="litStatShipped" runat="server" Text="0" />
            </div>
            <div class="stat-label">Shipped</div>
        </div>
        <div class="stat-box">
            <div class="stat-value">
                <asp:Literal ID="litStatDelivered" runat="server" Text="0" />
            </div>
            <div class="stat-label">Delivered</div>
        </div>
    </div>

    <%-- Toolbar --%>
    <div class="toolbar">
        <div class="filter-tabs">
            <button type="button" class="tab active" onclick="filterOrders(this,'all')">All</button>
            <button type="button" class="tab" onclick="filterOrders(this,'pending')">Pending</button>
            <button type="button" class="tab" onclick="filterOrders(this,'shipped')">Shipped</button>
            <button type="button" class="tab" onclick="filterOrders(this,'delivered')">Delivered</button>
            <button type="button" class="tab" onclick="filterOrders(this,'cancelled')">Cancelled</button>
        </div>
        <div class="search-wrap">
            <div class="search-line">
                <i data-lucide="search"></i>
                <input type="text" class="search-input" id="orderSearch"
                       placeholder="Search order or customer..." oninput="searchOrders(this.value)" />
            </div>
        </div>
    </div>

    <%-- Orders table --%>
    <table class="orders-table" id="ordersTable">
        <thead>
            <tr>
                <th>Order</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Items</th>
                <th>Total</th>
                <th>Status</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <asp:Repeater ID="OrdersRepeater" runat="server">
                <ItemTemplate>
                    <tr class="order-row" data-status="<%# Eval("StatusKey") %>">
                        <td class="order-id"><%# Eval("OrderId") %></td>
                        <td><%# Eval("CustomerName") %></td>
                        <td class="date-cell"><%# Eval("Date") %></td>
                        <td class="items-cell"><%# Eval("ItemCount") %> item(s)</td>
                        <td style="font-weight:600;"><%# Eval("Total") %></td>
                        <td>
                            <span class="status-badge status-<%# Eval("StatusKey") %>">
                                <%# Eval("Status") %>
                            </span>
                        </td>
                        <td>
                            <a href="onyx_admin_order_details.aspx?id=<%# Eval("RawId") %>" class="btn-view">
                                <i data-lucide="eye"></i> View
                            </a>
                        </td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>

    <%-- Summary bar --%>
    <div class="summary-bar">
        <span>
            <asp:Literal ID="litOrderCount" runat="server" /> orders
        </span>
        <span>
            Revenue: <strong><asp:Literal ID="litTotalRevenue" runat="server" /></strong>
        </span>
    </div>

    <script>
        function filterOrders(btn, status) {
            document.querySelectorAll('.tab').forEach(function (b) { b.classList.remove('active'); });
            btn.classList.add('active');
            document.querySelectorAll('.order-row').forEach(function (row) {
                row.style.display = (status === 'all' || row.dataset.status === status) ? '' : 'none';
            });
        }

        function searchOrders(q) {
            q = q.toLowerCase();
            document.querySelectorAll('.order-row').forEach(function (row) {
                row.style.display = row.textContent.toLowerCase().indexOf(q) !== -1 ? '' : 'none';
            });
        }
    </script>

</asp:Content>
