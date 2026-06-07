<%@ Page Title="Order Details" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_order_details.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_order_details" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #0d0d0d !important; }

        .admin-panel {
            background: #1a1a1a;
            border: 1px solid #2b2b2b;
            border-radius: 0;
            padding: 22px 24px;
        }

        .page-title { font-size: 22px; font-weight: 700; color: #ffffff; margin-bottom: 0; }

        /* ── SECTION LABELS ──────────────────────────────────────── */
        .section-label {
            font-size: 11px;
            font-weight: 600;
            color: #9c9ca4;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            padding-bottom: 12px;
            margin-bottom: 16px;
            border-bottom: 1px solid #2b2b2b;
        }

        /* ── INFO ROWS ───────────────────────────────────────────── */
        .info-row {
            display: flex;
            align-items: baseline;
            margin-bottom: 11px;
            font-size: 14px;
        }

        .info-key   { color: #9c9ca4; width: 140px; flex-shrink: 0; }
        .info-value { color: #ffffff; font-weight: 500; }

        /* ── STATUS BADGES ───────────────────────────────────────── */
        .status-badge {
            display: inline-block;
            padding: 4px 14px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            text-transform: capitalize;
            letter-spacing: 0.3px;
            vertical-align: middle;
        }

        .status-pending   { background: rgba(251, 191, 36,  0.12); color: #fbbf24; }
        .status-shipped   { background: rgba(96,  165, 250, 0.12); color: #60a5fa; }
        .status-delivered { background: rgba(0,   255, 135, 0.12); color: #00ff87; }
        .status-cancelled { background: rgba(255, 68,  68,  0.12); color: #ff4444; }

        /* ── ITEMS TABLE ─────────────────────────────────────────── */
        .items-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .items-table thead th {
            background: #141414;
            color: #9c9ca4;
            font-size: 11px;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            padding: 12px 16px;
            border-bottom: 1px solid #2b2b2b;
        }

        .items-table tbody td {
            padding: 14px 16px;
            border-bottom: 1px solid #222222;
            color: #ffffff;
            vertical-align: middle;
        }

        .items-table tbody tr:last-child td { border-bottom: none; }
        .items-table tbody tr:hover td      { background: rgba(255,255,255,0.02); }

        .product-name { font-weight: 600; }
        .product-cat  { font-size: 12px; color: #9c9ca4; margin-top: 2px; }

        /* ── ORDER SUMMARY ───────────────────────────────────────── */
        .summary-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            font-size: 14px;
            border-bottom: 1px solid #2b2b2b;
        }

        .summary-row:last-child { border-bottom: none; padding-bottom: 0; }

        .summary-key   { color: #9c9ca4; }
        .summary-value { color: #ffffff; font-weight: 500; }

        .summary-total .summary-key   { color: #ffffff; font-weight: 700; font-size: 15px; }
        .summary-total .summary-value { color: #00ff87; font-weight: 700; font-size: 16px; }

        /* ── UPDATE STATUS ───────────────────────────────────────── */
        .status-select {
            width: 100%;
            background: #0d0d0d;
            border: 1px solid #2b2b2b;
            border-radius: 0;
            color: #ffffff;
            padding: 9px 12px;
            font-size: 13px;
            font-family: 'Inter', sans-serif;
            margin-bottom: 12px;
        }

        .status-select:focus { outline: none; border-color: #00ff87; }
        .status-select option { background: #1a1a1a; }

        .btn-onyx {
            width: 100%;
            background: #00ff87;
            color: #000000;
            border: none;
            border-radius: 0;
            font-weight: 700;
            font-size: 13px;
            padding: 10px;
            font-family: 'Inter', sans-serif;
            cursor: pointer;
            transition: background 0.2s;
        }

        .btn-onyx:hover { background: #00e077; color: #000; }

        .status-updated-msg {
            margin-top: 10px;
            font-size: 13px;
            color: #00ff87;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        /* ── BACK LINK ───────────────────────────────────────────── */
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            color: #9c9ca4;
            text-decoration: none;
            border: 1px solid #2b2b2b;
            padding: 8px 16px;
            transition: all 0.2s;
        }

        .back-link:hover { border-color: #555; color: #ffffff; }

        /* ── TIMELINE ────────────────────────────────────────────── */
        .timeline { list-style: none; padding: 0; margin: 0; }

        .timeline-item {
            display: flex;
            gap: 14px;
            padding-bottom: 18px;
            position: relative;
        }

        .timeline-item:not(:last-child)::before {
            content: '';
            position: absolute;
            left: 7px;
            top: 18px;
            width: 2px;
            height: calc(100% - 10px);
            background: #2b2b2b;
        }

        .timeline-dot {
            width: 16px;
            height: 16px;
            border-radius: 50%;
            flex-shrink: 0;
            margin-top: 2px;
        }

        .dot-green  { background: #00ff87; }
        .dot-blue   { background: #60a5fa; }
        .dot-yellow { background: #fbbf24; }
        .dot-gray   { background: #2b2b2b; border: 2px solid #444; }

        .timeline-label { font-size: 13px; font-weight: 600; color: #ffffff; }
        .timeline-date  { font-size: 12px; color: #9c9ca4; margin-top: 2px; }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ======================================================
         PAGE HEADER
    ====================================================== --%>
    <div class="d-flex justify-content-between align-items-start mb-4">
        <div>
            <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap; margin-bottom:5px;">
                <h1 class="page-title">
                    Order <asp:Literal ID="litOrderId" runat="server" />
                </h1>
                <%-- Status badge rendered as HTML by code-behind for dynamic class --%>
                <asp:Label ID="lblStatusBadge" runat="server" />
            </div>
            <p style="font-size:13px; color:#9c9ca4; margin:0;">
                Placed on
                <strong style="color:#fff;"><asp:Literal ID="litOrderDate" runat="server" /></strong>
                &nbsp;·&nbsp; Customer:
                <strong style="color:#fff;"><asp:Literal ID="litCustomerNameHeader" runat="server" /></strong>
            </p>
        </div>
        <a href="onyx_admin_orders.aspx" class="back-link">
            <i data-lucide="arrow-left" style="width:14px;height:14px;"></i> Back to Orders
        </a>
    </div>

    <div class="row g-3">

        <%-- ====================================================
             LEFT COLUMN (8 cols): info + items + timeline
        ==================================================== --%>
        <div class="col-12 col-lg-8">

            <%-- Customer Information --%>
            <div class="admin-panel mb-3">
                <div class="section-label">Customer Information</div>
                <div class="info-row">
                    <div class="info-key">Full Name</div>
                    <div class="info-value"><asp:Literal ID="litCustName" runat="server" /></div>
                </div>
                <div class="info-row">
                    <div class="info-key">Email</div>
                    <div class="info-value"><asp:Literal ID="litCustEmail" runat="server" /></div>
                </div>
                <div class="info-row">
                    <div class="info-key">Phone</div>
                    <div class="info-value"><asp:Literal ID="litCustPhone" runat="server" /></div>
                </div>
                <div class="info-row">
                    <div class="info-key">Member Since</div>
                    <div class="info-value"><asp:Literal ID="litCustSince" runat="server" /></div>
                </div>
            </div>

            <%-- Shipping Address --%>
            <div class="admin-panel mb-3">
                <div class="section-label">Shipping Address</div>
                <div style="font-size:14px; color:#ffffff; line-height:1.8;">
                    <asp:Literal ID="litShippingAddress" runat="server" />
                </div>
            </div>

            <%-- Ordered Items --%>
            <div class="admin-panel mb-3">
                <div class="section-label">Ordered Items</div>
                <table class="items-table">
                    <thead>
                        <tr>
                            <th style="width:40%;">Product</th>
                            <th>Variant</th>
                            <th>Qty</th>
                            <th>Unit Price</th>
                            <th>Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="OrderItemsRepeater" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <div class="product-name"><%# Eval("ProductName") %></div>
                                        <div class="product-cat"><%# Eval("Category") %></div>
                                    </td>
                                    <td style="color:#9c9ca4; font-size:13px;"><%# Eval("Variant") %></td>
                                    <td><%# Eval("Quantity") %></td>
                                    <td style="color:#9c9ca4;"><%# Eval("UnitPrice") %></td>
                                    <td style="font-weight:600;"><%# Eval("Subtotal") %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>

            <%-- Order Timeline --%>
            <div class="admin-panel">
                <div class="section-label">Order Timeline</div>
                <ul class="timeline">
                    <asp:Repeater ID="TimelineRepeater" runat="server">
                        <ItemTemplate>
                            <li class="timeline-item">
                                <div class="timeline-dot <%# Eval("DotClass") %>"></div>
                                <div>
                                    <div class="timeline-label"><%# Eval("Event") %></div>
                                    <div class="timeline-date"><%# Eval("Timestamp") %></div>
                                </div>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                </ul>
            </div>

        </div>

        <%-- ====================================================
             RIGHT COLUMN (4 cols): summary + status update + meta
        ==================================================== --%>
        <div class="col-12 col-lg-4">

            <%-- Order Summary --%>
            <div class="admin-panel mb-3">
                <div class="section-label">Order Summary</div>
                <div class="summary-row">
                    <div class="summary-key">Subtotal</div>
                    <div class="summary-value"><asp:Literal ID="litSubtotal" runat="server" /></div>
                </div>
                <div class="summary-row">
                    <div class="summary-key">Shipping Fee</div>
                    <div class="summary-value">RM 10.00</div>
                </div>
                <div class="summary-row summary-total">
                    <div class="summary-key">Total Charged</div>
                    <div class="summary-value"><asp:Literal ID="litTotal" runat="server" /></div>
                </div>
            </div>

            <%-- Update Status --%>
            <div class="admin-panel mb-3">
                <div class="section-label">Update Order Status</div>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="status-select">
                    <asp:ListItem Value="pending"   Text="Pending"   />
                    <asp:ListItem Value="shipped"   Text="Shipped"   />
                    <asp:ListItem Value="delivered" Text="Delivered" />
                    <asp:ListItem Value="cancelled" Text="Cancelled" />
                </asp:DropDownList>
                <asp:Button ID="btnUpdateStatus" runat="server" Text="Update Status"
                    CssClass="btn btn-onyx" OnClick="btnUpdateStatus_Click" />
                <asp:Panel ID="pnlStatusMsg" runat="server" Visible="false"
                    CssClass="status-updated-msg">
                    <i data-lucide="check-circle" style="width:15px;height:15px;flex-shrink:0;"></i>
                    <asp:Literal ID="litStatusMsg" runat="server" />
                </asp:Panel>
            </div>

            <%-- Order Metadata --%>
            <div class="admin-panel">
                <div class="section-label">Metadata</div>
                <div class="info-row">
                    <div class="info-key">Order ID</div>
                    <div class="info-value" style="font-family:monospace; font-size:13px;">
                        <asp:Literal ID="litMetaOrderId" runat="server" />
                    </div>
                </div>
                <div class="info-row">
                    <div class="info-key">Ordered At</div>
                    <div class="info-value"><asp:Literal ID="litMetaDate" runat="server" /></div>
                </div>
                <div class="info-row">
                    <div class="info-key">Receipt S3</div>
                    <div class="info-value" style="font-size:12px; color:#9c9ca4; word-break:break-all;">
                        <asp:Literal ID="litReceiptKey" runat="server" />
                    </div>
                </div>
            </div>

        </div>
    </div>

</asp:Content>
