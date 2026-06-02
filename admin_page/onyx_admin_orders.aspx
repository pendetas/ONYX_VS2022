<%@ Page Title="Orders" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_orders.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_orders" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #0d0d0d !important; }

        .admin-panel {
            background: #1a1a1a;
            border: 1px solid #2b2b2b;
            border-radius: 0;
        }

        .page-title   { font-size: 22px; font-weight: 700; color: #ffffff; margin-bottom: 0; }
        .page-subtitle { font-size: 13px; color: #9c9ca4; margin-top: 4px; }

        /* ── FILTER BAR ──────────────────────────────────────────── */
        .filter-bar {
            padding: 14px 20px;
            border-bottom: 1px solid #2b2b2b;
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .filter-btn {
            background: transparent;
            border: 1px solid #2b2b2b;
            color: #9c9ca4;
            border-radius: 0;
            padding: 6px 16px;
            font-size: 12px;
            font-family: 'Inter', sans-serif;
            cursor: pointer;
            transition: all 0.2s;
        }

        .filter-btn:hover { border-color: #555; color: #ffffff; }

        .filter-btn.active {
            border-color: #00ff87;
            color: #00ff87;
            background: rgba(0, 255, 135, 0.06);
        }

        .search-input {
            margin-left: auto;
            background: #0d0d0d;
            border: 1px solid #2b2b2b;
            border-radius: 0;
            color: #ffffff;
            padding: 7px 14px;
            font-size: 13px;
            font-family: 'Inter', sans-serif;
            width: 240px;
        }

        .search-input:focus { outline: none; border-color: #00ff87; }
        .search-input::placeholder { color: #484848; }

        /* ── ORDERS TABLE ────────────────────────────────────────── */
        .orders-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .orders-table thead th {
            background: #141414;
            color: #9c9ca4;
            font-size: 11px;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            padding: 13px 20px;
            border-bottom: 1px solid #2b2b2b;
            white-space: nowrap;
        }

        .orders-table tbody td {
            padding: 15px 20px;
            border-bottom: 1px solid #202020;
            color: #ffffff;
            vertical-align: middle;
        }

        .orders-table tbody tr:last-child td { border-bottom: none; }

        .orders-table tbody tr:hover td { background: rgba(255, 255, 255, 0.02); }

        .order-id {
            font-family: 'Courier New', monospace;
            font-size: 13px;
            font-weight: 600;
            color: #9c9ca4;
        }

        .customer-cell { font-weight: 500; }

        .date-cell  { color: #9c9ca4; font-size: 13px; }
        .items-cell { color: #9c9ca4; font-size: 13px; }
        .amount-cell { font-weight: 600; }

        /* Status badges */
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            text-transform: capitalize;
            letter-spacing: 0.3px;
        }

        .status-pending   { background: rgba(251, 191, 36,  0.12); color: #fbbf24; }
        .status-shipped   { background: rgba(96,  165, 250, 0.12); color: #60a5fa; }
        .status-delivered { background: rgba(0,   255, 135, 0.12); color: #00ff87; }
        .status-cancelled { background: rgba(255, 68,  68,  0.12); color: #ff4444; }

        /* View button */
        .btn-view {
            background: transparent;
            border: 1px solid #2b2b2b;
            color: #9c9ca4;
            padding: 5px 14px;
            font-size: 12px;
            border-radius: 0;
            font-family: 'Inter', sans-serif;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.2s;
            white-space: nowrap;
        }

        .btn-view:hover { border-color: #00ff87; color: #00ff87; }

        /* ── SUMMARY BAR ─────────────────────────────────────────── */
        .summary-bar {
            padding: 12px 20px;
            border-top: 1px solid #2b2b2b;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 13px;
            color: #9c9ca4;
        }

        /* ── STAT ROW (above table) ─────────────────────────────── */
        .stat-strip {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1px;
            background: #2b2b2b;
            border: 1px solid #2b2b2b;
            margin-bottom: 20px;
        }

        .stat-box {
            background: #1a1a1a;
            padding: 16px 20px;
            text-align: center;
        }

        .stat-value { font-size: 20px; font-weight: 700; color: #ffffff; }
        .stat-label { font-size: 12px; color: #9c9ca4; margin-top: 3px; }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ======================================================
         PAGE HEADER
    ====================================================== --%>
    <div class="d-flex justify-content-between align-items-start mb-4">
        <div>
            <h1 class="page-title">Order Management</h1>
            <p class="page-subtitle">
                Track, filter, and manage all customer orders in real time.
            </p>
        </div>
        <div style="font-size:13px; color:#9c9ca4; display:flex; align-items:center; gap:6px; padding-top:4px;">
            <i data-lucide="clock" style="width:14px;height:14px;"></i>
            Last updated: <strong style="color:#fff; margin-left:4px;">
                <asp:Literal ID="litLastUpdated" runat="server" />
            </strong>
        </div>
    </div>

    <%-- ======================================================
         QUICK STAT STRIP
    ====================================================== --%>
    <div class="stat-strip mb-4">
        <div class="stat-box">
            <div class="stat-value"><asp:Literal ID="litStatTotal"     runat="server" Text="0" /></div>
            <div class="stat-label">Total Orders</div>
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
            <div class="stat-value" style="color:#00ff87;">
                <asp:Literal ID="litStatDelivered" runat="server" Text="0" />
            </div>
            <div class="stat-label">Delivered</div>
        </div>
    </div>

    <%-- ======================================================
         ORDERS PANEL
    ====================================================== --%>
    <div class="admin-panel">

        <%-- Filter Bar --%>
        <div class="filter-bar">
            <button class="filter-btn active" onclick="filterOrders(this, 'all')">All</button>
            <button class="filter-btn" onclick="filterOrders(this, 'pending')">Pending</button>
            <button class="filter-btn" onclick="filterOrders(this, 'shipped')">Shipped</button>
            <button class="filter-btn" onclick="filterOrders(this, 'delivered')">Delivered</button>
            <button class="filter-btn" onclick="filterOrders(this, 'cancelled')">Cancelled</button>
            <input type="text" class="search-input" id="orderSearch"
                   placeholder="Search order # or customer..."
                   oninput="searchOrders(this.value)">
        </div>

        <%-- Orders Table --%>
        <table class="orders-table" id="ordersTable">
            <thead>
                <tr>
                    <th>Order ID</th>
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
                            <td class="customer-cell"><%# Eval("CustomerName") %></td>
                            <td class="date-cell"><%# Eval("Date") %></td>
                            <td class="items-cell"><%# Eval("ItemCount") %> item(s)</td>
                            <td class="amount-cell"><%# Eval("Total") %></td>
                            <td>
                                <span class="status-badge status-<%# Eval("StatusKey") %>">
                                    <%# Eval("Status") %>
                                </span>
                            </td>
                            <td>
                                <a href="onyx_admin_order_details.aspx?id=<%# Eval("RawId") %>"
                                   class="btn-view">
                                    <i data-lucide="eye" style="width:13px;height:13px;"></i> View
                                </a>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>

        <%-- Summary Bar --%>
        <div class="summary-bar">
            <span>
                Showing <strong style="color:#fff;">
                    <asp:Literal ID="litOrderCount" runat="server" />
                </strong> orders
            </span>
            <span>
                Total Revenue (all): <strong style="color:#00ff87; margin-left:4px;">
                    <asp:Literal ID="litTotalRevenue" runat="server" />
                </strong>
            </span>
        </div>
    </div>

    <%-- ======================================================
         CLIENT-SIDE FILTER & SEARCH (progressive enhancement)
    ====================================================== --%>
    <script>
        function filterOrders(btn, status) {
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            document.querySelectorAll('.order-row').forEach(row => {
                row.style.display = (status === 'all' || row.dataset.status === status) ? '' : 'none';
            });
        }

        function searchOrders(q) {
            q = q.toLowerCase();
            document.querySelectorAll('.order-row').forEach(row => {
                row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
            });
        }
    </script>

</asp:Content>
