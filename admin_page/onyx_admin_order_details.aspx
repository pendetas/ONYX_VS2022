<%@ Page Title="Order Details" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_order_details.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_order_details" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* â”€â”€ Page header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .page-header {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        margin-bottom: 32px;
        gap: 20px;
    }

    .order-heading {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
        margin-bottom: 6px;
    }

    .page-title {
        font-size: 22px;
        font-weight: 600;
        color: #fff;
        letter-spacing: -0.02em;
        margin: 0;
    }

    .page-meta {
        font-size: 12px;
        color: rgba(255,255,255,0.28);
    }

    .page-meta strong { color: rgba(255,255,255,0.65); }

    .back-link {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        color: rgba(255,255,255,0.28);
        text-decoration: none;
        transition: color 0.15s;
        flex-shrink: 0;
        margin-top: 4px;
    }

    .back-link:hover { color: rgba(255,255,255,0.68); text-decoration: none; }
    .back-link i { width: 14px; height: 14px; }

    /* â”€â”€ Status badges â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .status-badge {
        display: inline-block;
        padding: 3px 10px;
        border-radius: 3px;
        font-size: 10px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.08em;
    }

    .status-pending   { background: rgba(251,191,36,0.10);  color: #fbbf24; }
    .status-shipped   { background: rgba(96,165,250,0.10);  color: #60a5fa; }
    .status-delivered { background: rgba(255,255,255,0.07); color: rgba(255,255,255,0.65); }
    .status-cancelled { background: rgba(255,68,68,0.10);   color: #ff5555; }

    /* â”€â”€ Not found â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .not-found {
        text-align: center;
        padding: 100px 20px;
        color: rgba(255,255,255,0.22);
        font-size: 13px;
        letter-spacing: 0.04em;
    }

    .not-found i { width: 40px; height: 40px; margin-bottom: 14px; opacity: 0.15; }

    /* â”€â”€ Two-column layout â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .detail-layout {
        display: grid;
        grid-template-columns: 1fr 278px;
        gap: 18px;
        align-items: start;
    }

    .left-col, .right-col {
        display: flex;
        flex-direction: column;
        gap: 18px;
    }

    /* â”€â”€ Panel card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .panel {
        background: #111113;
        border: 1px solid rgba(255,255,255,0.05);
        border-radius: 10px;
        padding: 20px 22px;
    }

    .section-label {
        font-size: 10px;
        font-weight: 600;
        letter-spacing: 0.14em;
        text-transform: uppercase;
        color: rgba(255,255,255,0.18);
        margin-bottom: 18px;
        padding-bottom: 10px;
        border-bottom: 1px solid rgba(255,255,255,0.05);
    }

    /* â”€â”€ Info rows â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .info-row {
        display: flex;
        align-items: baseline;
        gap: 14px;
        margin-bottom: 10px;
        font-size: 13px;
    }

    .info-row:last-child { margin-bottom: 0; }
    .info-key   { color: rgba(255,255,255,0.28); width: 110px; flex-shrink: 0; font-size: 12px; }
    .info-value { color: #fff; font-weight: 500; }

    /* â”€â”€ Items table â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .items-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
    }

    .items-table thead th {
        color: rgba(255,255,255,0.26);
        font-size: 10px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.10em;
        padding: 0 12px 12px;
        border-bottom: 1px solid rgba(255,255,255,0.06);
        text-align: left;
        white-space: nowrap;
    }

    .items-table thead th:first-child { padding-left: 0; }

    .items-table tbody td {
        padding: 13px 12px;
        border-bottom: 1px solid rgba(255,255,255,0.04);
        color: #fff;
        vertical-align: middle;
    }

    .items-table tbody td:first-child { padding-left: 0; }
    .items-table tbody tr:last-child td { border-bottom: none; }
    .items-table tbody tr:hover td { background: rgba(255,255,255,0.015); }

    .product-name { font-weight: 600; }
    .product-cat  { font-size: 11px; color: rgba(255,255,255,0.28); margin-top: 3px; }

    /* â”€â”€ Summary rows â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .summary-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 9px 0;
        font-size: 13px;
        border-bottom: 1px solid rgba(255,255,255,0.04);
    }

    .summary-row:last-child {
        border-bottom: none;
        padding-bottom: 0;
        margin-top: 4px;
    }

    .summary-key   { color: rgba(255,255,255,0.35); }
    .summary-value { color: #fff; font-weight: 500; }
    .summary-total .summary-key   { color: #fff; font-weight: 700; font-size: 14px; }
    .summary-total .summary-value { color: #fff; font-weight: 700; font-size: 15px; }

    /* â”€â”€ Status select â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .status-select {
        width: 100%;
        background: transparent;
        border: none;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        color: #fff;
        font-size: 14px;
        padding: 8px 20px 8px 0;
        margin-bottom: 16px;
        outline: none;
        appearance: none;
        -webkit-appearance: none;
        cursor: pointer;
        font-family: inherit;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='rgba(255,255,255,0.30)' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 2px center;
        transition: border-color 0.18s;
    }

    .status-select:focus { border-bottom-color: rgba(255,255,255,0.40); }
    .status-select option { background: #111113; color: #fff; }

    /* â”€â”€ Buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .btn-save {
        width: 100%;
        padding: 9px;
        background: #fff;
        color: #000;
        border: none;
        border-radius: 5px;
        font-size: 11px;
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        cursor: pointer;
        transition: background 0.15s;
        font-family: inherit;
        margin-bottom: 8px;
    }

    .btn-save:hover { background: rgba(255,255,255,0.84); }

    .btn-delete {
        width: 100%;
        padding: 9px;
        background: transparent;
        color: rgba(255,68,68,0.65);
        border: 1px solid rgba(255,68,68,0.20);
        border-radius: 5px;
        font-size: 11px;
        font-weight: 600;
        letter-spacing: 0.06em;
        text-transform: uppercase;
        cursor: pointer;
        transition: all 0.15s;
        font-family: inherit;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
    }

    .btn-delete i { width: 12px; height: 12px; }
    .btn-delete:hover {
        background: rgba(255,68,68,0.07);
        border-color: rgba(255,68,68,0.40);
        color: #ff5555;
    }

    /* Status updated message */
    .status-msg {
        margin-top: 10px;
        font-size: 12px;
        color: rgba(255,255,255,0.55);
        display: flex;
        align-items: center;
        gap: 6px;
        letter-spacing: 0.02em;
    }

    .status-msg i { width: 13px; height: 13px; }

    /* â”€â”€ Timeline â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .timeline { list-style: none; padding: 0; margin: 0; }

    .timeline-item {
        display: flex;
        gap: 14px;
        padding-bottom: 18px;
        position: relative;
    }

    .timeline-item:last-child { padding-bottom: 0; }

    .timeline-item:not(:last-child)::before {
        content: '';
        position: absolute;
        left: 6px;
        top: 16px;
        width: 1px;
        height: calc(100% - 8px);
        background: rgba(255,255,255,0.06);
    }

    .timeline-dot {
        width: 14px;
        height: 14px;
        border-radius: 50%;
        flex-shrink: 0;
        margin-top: 3px;
    }

    .dot-done    { background: rgba(255,255,255,0.22); }
    .dot-pending { background: rgba(251,191,36,0.55); }
    .dot-cancel  { background: rgba(255,68,68,0.50); }

    .timeline-label { font-size: 13px; font-weight: 500; color: #fff; }
    .timeline-date  { font-size: 11px; color: rgba(255,255,255,0.26); margin-top: 3px; }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Not Found --%>
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="not-found">
        <div><i data-lucide="package-x"></i></div>
        <div>Order not found.</div>
        <div style="margin-top:14px;">
            <a href="onyx_admin_orders.aspx" class="back-link" style="justify-content:center;">
                <i data-lucide="arrow-left"></i> Back to Orders
            </a>
        </div>
    </asp:Panel>

    <%-- Order Detail --%>
    <asp:Panel ID="pnlOrderDetail" runat="server" Visible="false">

        <%-- Header --%>
        <div class="page-header">
            <div>
                <div class="order-heading">
                    <div class="page-title">
                        Order <asp:Literal ID="litOrderId" runat="server" />
                    </div>
                    <asp:Label ID="lblStatusBadge" runat="server" />
                </div>
                <div class="page-meta">
                    Placed on <strong><asp:Literal ID="litOrderDate" runat="server" /></strong>
                    &nbsp;&middot;&nbsp;
                    <strong><asp:Literal ID="litCustomerNameHeader" runat="server" /></strong>
                </div>
            </div>
            <a href="onyx_admin_orders.aspx" class="back-link">
                <i data-lucide="arrow-left"></i> Back
            </a>
        </div>

        <%-- Two-column layout --%>
        <div class="detail-layout">

            <%-- LEFT: customer + shipping + items + timeline --%>
            <div class="left-col">

                <%-- Customer --%>
                <div class="panel">
                    <div class="section-label">Customer</div>
                    <div class="info-row">
                        <div class="info-key">Name</div>
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

                <%-- Shipping --%>
                <div class="panel">
                    <div class="section-label">Shipping Address</div>
                    <div style="font-size:13px; color:#fff; line-height:1.8;">
                        <asp:Literal ID="litShippingAddress" runat="server" />
                    </div>
                </div>

                <%-- Items --%>
                <div class="panel">
                    <div class="section-label">Ordered Items</div>
                    <table class="items-table">
                        <thead>
                            <tr>
                                <th style="width:40%;">Product</th>
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
                                        <td style="color:rgba(255,255,255,0.55);"><%# Eval("Quantity") %></td>
                                        <td style="color:rgba(255,255,255,0.45);"><%# Eval("UnitPriceFmt") %></td>
                                        <td style="font-weight:600;"><%# Eval("SubtotalFmt") %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>

                <%-- Timeline --%>
                <div class="panel">
                    <div class="section-label">Timeline</div>
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

            <%-- RIGHT: summary + status + metadata --%>
            <div class="right-col">

                <%-- Order Summary --%>
                <div class="panel">
                    <div class="section-label">Summary</div>
                    <div class="summary-row">
                        <div class="summary-key">Items subtotal</div>
                        <div class="summary-value"><asp:Literal ID="litSubtotal" runat="server" /></div>
                    </div>
                    <div class="summary-row">
                        <div class="summary-key">Shipping</div>
                        <div class="summary-value" style="color:rgba(255,255,255,0.40);">RM 10.00</div>
                    </div>
                    <div class="summary-row summary-total">
                        <div class="summary-key">Total Charged</div>
                        <div class="summary-value"><asp:Literal ID="litTotal" runat="server" /></div>
                    </div>
                </div>

                <%-- Update Status --%>
                <div class="panel">
                    <div class="section-label">Update Status</div>

                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="status-select">
                        <asp:ListItem Value="pending"   Text="Pending"   />
                        <asp:ListItem Value="shipped"   Text="Shipped"   />
                        <asp:ListItem Value="delivered" Text="Delivered" />
                        <asp:ListItem Value="cancelled" Text="Cancelled" />
                    </asp:DropDownList>

                    <asp:Button ID="btnUpdateStatus" runat="server" Text="Save Status"
                        CssClass="btn-save" OnClick="btnUpdateStatus_Click" />

                    <asp:Panel ID="pnlStatusMsg" runat="server" Visible="false" CssClass="status-msg">
                        <i data-lucide="check-circle"></i>
                        <asp:Literal ID="litStatusMsg" runat="server" />
                    </asp:Panel>
                </div>

                <%-- Danger Zone --%>
                <div class="panel">
                    <div class="section-label">Danger Zone</div>
                    <asp:Button ID="btnDeleteOrder" runat="server"
                        CssClass="btn-delete"
                        Text="Delete Order"
                        OnClick="btnDeleteOrder_Click"
                        OnClientClick="return confirm('Permanently delete this order and all its items? This cannot be undone.');" />
                </div>

                <%-- Metadata --%>
                <div class="panel">
                    <div class="section-label">Metadata</div>
                    <div class="info-row">
                        <div class="info-key">Order ID</div>
                        <div class="info-value" style="font-family:monospace; font-size:12px;">
                            <asp:Literal ID="litMetaOrderId" runat="server" />
                        </div>
                    </div>
                    <div class="info-row">
                        <div class="info-key">Placed At</div>
                        <div class="info-value"><asp:Literal ID="litMetaDate" runat="server" /></div>
                    </div>
                    <div class="info-row">
                        <div class="info-key">Receipt</div>
                        <div class="info-value" style="font-size:11px; color:rgba(255,255,255,0.35); word-break:break-all;">
                            <asp:Literal ID="litReceiptKey" runat="server" />
                        </div>
                    </div>
                </div>

            </div>
        </div>

    </asp:Panel>

</asp:Content>
