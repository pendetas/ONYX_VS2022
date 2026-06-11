<%@ Page Title="User Detail" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_user_detail.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_user_detail" %>

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

    .page-title { font-size: 22px; font-weight: 600; color: #fff; letter-spacing: -0.02em; margin: 0; }
    .page-meta  { font-size: 12px; color: rgba(255,255,255,0.28); margin-top: 5px; }
    .page-meta strong { color: rgba(255,255,255,0.65); }

    .back-link {
        display: inline-flex; align-items: center; gap: 6px;
        font-size: 13px; color: rgba(255,255,255,0.28);
        text-decoration: none; transition: color 0.15s; flex-shrink: 0; margin-top: 4px;
    }
    .back-link:hover { color: rgba(255,255,255,0.68); text-decoration: none; }
    .back-link i { width: 14px; height: 14px; }

    /* â”€â”€ Not found â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .not-found {
        text-align: center; padding: 100px 20px;
        color: rgba(255,255,255,0.22); font-size: 13px; letter-spacing: 0.04em;
    }
    .not-found i { width: 40px; height: 40px; margin-bottom: 14px; opacity: 0.15; }

    /* â”€â”€ Two-column layout â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .detail-layout {
        display: grid;
        grid-template-columns: 1fr 278px;
        gap: 18px;
        align-items: start;
    }

    .left-col, .right-col { display: flex; flex-direction: column; gap: 18px; }

    /* â”€â”€ Panel card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .panel {
        background: #111113;
        border: 1px solid rgba(255,255,255,0.05);
        border-radius: 10px;
        padding: 20px 22px;
    }

    .section-label {
        font-size: 10px; font-weight: 600; letter-spacing: 0.14em;
        text-transform: uppercase; color: rgba(255,255,255,0.18);
        margin-bottom: 18px; padding-bottom: 10px;
        border-bottom: 1px solid rgba(255,255,255,0.05);
    }

    /* â”€â”€ Avatar hero â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .user-hero {
        display: flex; align-items: center; gap: 16px; margin-bottom: 18px;
    }

    .hero-avatar {
        width: 52px; height: 52px; border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: 16px; font-weight: 700; flex-shrink: 0;
        background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.55);
        letter-spacing: 0.5px;
    }

    .hero-name  { font-size: 16px; font-weight: 600; color: #fff; }
    .hero-email { font-size: 12px; color: rgba(255,255,255,0.30); margin-top: 3px; }

    /* â”€â”€ Underline inputs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .field-group { margin-bottom: 20px; }
    .field-group:last-child { margin-bottom: 0; }

    .field-label {
        font-size: 10px; font-weight: 600; letter-spacing: 0.12em;
        text-transform: uppercase; color: rgba(255,255,255,0.22);
        margin-bottom: 6px; display: block;
    }

    .field-input {
        width: 100%; background: transparent; border: none;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        color: #fff; font-size: 13px; font-family: inherit;
        padding: 6px 0; outline: none; transition: border-color 0.18s;
        box-sizing: border-box;
    }

    .field-input:focus { border-bottom-color: rgba(255,255,255,0.40); }
    .field-input::placeholder { color: rgba(255,255,255,0.18); }

    .field-select {
        width: 100%; background: transparent; border: none;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        color: #fff; font-size: 13px; font-family: inherit;
        padding: 6px 20px 6px 0; outline: none; cursor: pointer;
        appearance: none; -webkit-appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='rgba(255,255,255,0.30)' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
        background-repeat: no-repeat; background-position: right 2px center;
        transition: border-color 0.18s;
    }

    .field-select:focus { border-bottom-color: rgba(255,255,255,0.40); }
    .field-select option { background: #111113; color: #fff; }

    .field-row { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }

    /* â”€â”€ Buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .btn-save {
        width: 100%; padding: 9px; background: #fff; color: #000;
        border: none; border-radius: 5px; font-size: 11px; font-weight: 700;
        letter-spacing: 0.08em; text-transform: uppercase; cursor: pointer;
        transition: background 0.15s; font-family: inherit; margin-bottom: 8px;
    }

    .btn-save:hover { background: rgba(255,255,255,0.84); }

    .btn-delete {
        width: 100%; padding: 9px; background: transparent;
        color: rgba(255,68,68,0.65); border: 1px solid rgba(255,68,68,0.20);
        border-radius: 5px; font-size: 11px; font-weight: 600;
        letter-spacing: 0.06em; text-transform: uppercase; cursor: pointer;
        transition: all 0.15s; font-family: inherit;
    }

    .btn-delete:hover {
        background: rgba(255,68,68,0.07);
        border-color: rgba(255,68,68,0.40);
        color: #ff5555;
    }

    /* â”€â”€ Alert â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .alert-success {
        padding: 10px 14px; margin-bottom: 16px; font-size: 12px;
        border-left: 2px solid rgba(255,255,255,0.30);
        background: rgba(255,255,255,0.04); border-radius: 0 4px 4px 0;
        color: rgba(255,255,255,0.70);
    }

    .alert-error {
        padding: 10px 14px; margin-bottom: 16px; font-size: 12px;
        border-left: 2px solid rgba(255,68,68,0.55);
        background: rgba(255,68,68,0.05); border-radius: 0 4px 4px 0;
        color: rgba(255,255,255,0.70);
    }

    /* â”€â”€ Stat row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .stat-row {
        display: flex; justify-content: space-between; align-items: center;
        padding: 9px 0; font-size: 13px;
        border-bottom: 1px solid rgba(255,255,255,0.04);
    }

    .stat-row:last-child { border-bottom: none; padding-bottom: 0; }
    .stat-key   { color: rgba(255,255,255,0.30); font-size: 12px; }
    .stat-val   { color: #fff; font-weight: 500; }

    /* â”€â”€ Role badge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .role-badge {
        display: inline-block; padding: 3px 9px; border-radius: 3px;
        font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em;
    }

    .role-admin    { background: rgba(255,255,255,0.07); color: rgba(255,255,255,0.60); }
    .role-customer { background: rgba(255,255,255,0.04); color: rgba(255,255,255,0.38); }

    /* â”€â”€ Status badge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .status-badge { display: inline-block; padding: 3px 9px; border-radius: 3px; font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; }
    .status-pending   { background: rgba(251,191,36,0.10);  color: #fbbf24; }
    .status-shipped   { background: rgba(96,165,250,0.10);  color: #60a5fa; }
    .status-delivered { background: rgba(255,255,255,0.07); color: rgba(255,255,255,0.65); }
    .status-cancelled { background: rgba(255,68,68,0.10);   color: #ff5555; }

    /* â”€â”€ Orders mini-table â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
    .orders-mini { width: 100%; border-collapse: collapse; font-size: 12px; }

    .orders-mini thead th {
        color: rgba(255,255,255,0.22); font-size: 10px; font-weight: 600;
        text-transform: uppercase; letter-spacing: 0.09em;
        padding: 0 10px 10px; border-bottom: 1px solid rgba(255,255,255,0.05); text-align: left;
    }

    .orders-mini thead th:first-child { padding-left: 0; }

    .orders-mini tbody td {
        padding: 10px 10px; border-bottom: 1px solid rgba(255,255,255,0.04); color: #fff; vertical-align: middle;
    }

    .orders-mini tbody td:first-child { padding-left: 0; }
    .orders-mini tbody tr:last-child td { border-bottom: none; }

    .order-link { color: rgba(255,255,255,0.38); font-family: monospace; font-size: 11px; text-decoration: none; }
    .order-link:hover { color: rgba(255,255,255,0.75); }

    .empty-orders { color: rgba(255,255,255,0.20); font-size: 12px; font-style: italic; padding: 6px 0; }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Not Found --%>
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="not-found">
        <div><i data-lucide="user-x"></i></div>
        <div>User not found.</div>
        <div style="margin-top:14px;">
            <a href="onyx_admin_users.aspx" class="back-link" style="justify-content:center;">
                <i data-lucide="arrow-left"></i> Back to Users
            </a>
        </div>
    </asp:Panel>

    <%-- User Detail --%>
    <asp:Panel ID="pnlUserDetail" runat="server" Visible="false">

        <%-- Header --%>
        <div class="page-header">
            <div>
                <div class="page-title"><asp:Literal ID="litPageTitle" runat="server" /></div>
                <div class="page-meta">
                    Member since <strong><asp:Literal ID="litJoinDate" runat="server" /></strong>
                    &nbsp;&middot;&nbsp; @<asp:Literal ID="litUsername" runat="server" />
                </div>
            </div>
            <a href="onyx_admin_users.aspx" class="back-link">
                <i data-lucide="arrow-left"></i> Back
            </a>
        </div>

        <div class="detail-layout">

            <%-- LEFT --%>
            <div class="left-col">

                <%-- Edit Form --%>
                <div class="panel">
                    <div class="user-hero">
                        <div class="hero-avatar"><asp:Literal ID="litInitials" runat="server" /></div>
                        <div>
                            <div class="hero-name"><asp:Literal ID="litHeroName" runat="server" /></div>
                            <div class="hero-email"><asp:Literal ID="litHeroEmail" runat="server" /></div>
                        </div>
                    </div>

                    <div class="section-label">Edit Profile</div>

                    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
                        <asp:Literal ID="litAlertMsg" runat="server" />
                    </asp:Panel>

                    <div class="field-row">
                        <div class="field-group">
                            <label class="field-label">Full Name</label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="field-input" placeholder="Full name" data-gramm="false" data-gramm_editor="false" />
                        </div>
                        <div class="field-group">
                            <label class="field-label">Email</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="field-input" placeholder="Email address" TextMode="Email" data-gramm="false" data-gramm_editor="false" />
                        </div>
                    </div>

                    <div class="field-row">
                        <div class="field-group">
                            <label class="field-label">Phone</label>
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="field-input" placeholder="Phone number" data-gramm="false" data-gramm_editor="false" />
                        </div>
                        <div class="field-group">
                            <label class="field-label">Role</label>
                            <asp:DropDownList ID="ddlRole" runat="server" CssClass="field-select">
                                <asp:ListItem Value="customer" Text="Customer" />
                                <asp:ListItem Value="admin"    Text="Admin"    />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="field-group">
                        <label class="field-label">Address</label>
                        <asp:TextBox ID="txtAddress" runat="server" CssClass="field-input" placeholder="Address" TextMode="MultiLine" Rows="2" style="resize:none;" data-gramm="false" data-gramm_editor="false" />
                    </div>

                    <asp:Button ID="btnSave" runat="server" Text="Save Changes"
                        CssClass="btn-save" OnClick="btnSave_Click" />
                </div>

                <%-- Order History --%>
                <div class="panel">
                    <div class="section-label">Recent Orders</div>

                    <asp:Panel ID="pnlNoOrders" runat="server" Visible="false">
                        <div class="empty-orders">No orders placed yet.</div>
                    </asp:Panel>

                    <asp:Panel ID="pnlOrders" runat="server" Visible="false">
                        <table class="orders-mini">
                            <thead>
                                <tr>
                                    <th>Order</th>
                                    <th>Date</th>
                                    <th>Total</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="OrdersRepeater" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <a href="onyx_admin_order_details.aspx?id=<%# Eval("RawId") %>" class="order-link">
                                                    <%# Eval("OrderId") %>
                                                </a>
                                            </td>
                                            <td style="color:rgba(255,255,255,0.35);"><%# Eval("Date") %></td>
                                            <td style="font-weight:600;"><%# Eval("Total") %></td>
                                            <td>
                                                <span class="status-badge status-<%# Eval("StatusKey") %>">
                                                    <%# Eval("Status") %>
                                                </span>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </asp:Panel>
                </div>

            </div>

            <%-- RIGHT --%>
            <div class="right-col">

                <%-- Stats --%>
                <div class="panel">
                    <div class="section-label">Account Stats</div>
                    <div class="stat-row">
                        <div class="stat-key">Role</div>
                        <div class="stat-val"><asp:Label ID="lblRoleBadge" runat="server" /></div>
                    </div>
                    <div class="stat-row">
                        <div class="stat-key">Total Orders</div>
                        <div class="stat-val"><asp:Literal ID="litTotalOrders" runat="server" /></div>
                    </div>
                    <div class="stat-row">
                        <div class="stat-key">Total Spent</div>
                        <div class="stat-val"><asp:Literal ID="litTotalSpent" runat="server" /></div>
                    </div>
                    <div class="stat-row">
                        <div class="stat-key">Member Since</div>
                        <div class="stat-val"><asp:Literal ID="litMemberSince" runat="server" /></div>
                    </div>
                </div>

                <%-- Danger Zone --%>
                <div class="panel">
                    <div class="section-label">Danger Zone</div>
                    <asp:Button ID="btnDelete" runat="server"
                        CssClass="btn-delete"
                        Text="Delete User"
                        OnClick="btnDelete_Click"
                        OnClientClick="return confirm('Permanently delete this user and all their orders? This cannot be undone.');" />
                </div>

            </div>
        </div>

    </asp:Panel>

</asp:Content>
