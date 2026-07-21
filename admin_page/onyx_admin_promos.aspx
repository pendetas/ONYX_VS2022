<%@ Page Title="Loyalty Management" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_promos.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_promos" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .page-header {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 18px;
        margin-bottom: 32px;
        flex-wrap: wrap;
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

    .primary-action {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        min-height: 40px;
        padding: 0 16px;
        border-radius: 10px;
        border: 1px solid rgba(255,255,255,0.08);
        background: #111113;
        color: #fff;
        text-decoration: none;
        font-size: 12px;
        font-weight: 600;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        transition: border-color 0.15s, background 0.15s, color 0.15s;
    }

    .primary-action i { width: 14px; height: 14px; }
    .primary-action:hover {
        border-color: rgba(255,255,255,0.18);
        background: rgba(255,255,255,0.04);
        color: #fff;
        text-decoration: none;
    }

    .primary-action:focus-visible {
        outline: none;
        border-color: rgba(255,255,255,0.34);
        box-shadow: 0 0 0 2px rgba(17,17,19,0.95), 0 0 0 4px rgba(255,255,255,0.22);
    }

    .message-banner {
        display: block;
        margin-bottom: 18px;
        padding: 12px 14px;
        border-radius: 10px;
        border: 1px solid rgba(255,68,68,0.20);
        background: rgba(255,68,68,0.08);
        color: #ffd6d6;
        font-size: 12px;
    }

    .toolbar {
        display: flex;
        align-items: end;
        gap: 12px;
        margin-bottom: 18px;
        flex-wrap: wrap;
    }

    .toolbar-field {
        min-width: 0;
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .toolbar-field--search {
        flex: 1;
        min-width: 240px;
    }

    .toolbar-label {
        font-size: 10px;
        font-weight: 600;
        letter-spacing: 0.10em;
        text-transform: uppercase;
        color: rgba(255,255,255,0.26);
    }

    .search-line,
    .filter-select {
        min-height: 42px;
        border-radius: 10px;
        border: 1px solid rgba(255,255,255,0.08);
        background: #111113;
        color: #fff;
    }

    .search-line {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 0 12px;
    }

    .search-line i {
        width: 14px;
        height: 14px;
        color: rgba(255,255,255,0.24);
        flex-shrink: 0;
    }

    .search-input,
    .filter-select {
        width: 100%;
        font-size: 13px;
        font-family: inherit;
    }

    .search-input {
        border: none;
        background: transparent;
        color: #fff;
        outline: none;
    }

    .search-input::placeholder {
        color: rgba(255,255,255,0.22);
    }

    .filter-select {
        padding: 0 12px;
        appearance: none;
        -webkit-appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='rgba(255,255,255,0.25)' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 10px center;
        padding-right: 28px;
    }

    .search-line:focus-within,
    .filter-select:focus,
    .filter-select:focus-visible {
        border-color: rgba(255,255,255,0.26);
        outline: none;
    }

    .toolbar-button {
        min-height: 42px;
        padding: 0 16px;
        border-radius: 10px;
        border: 1px solid rgba(255,255,255,0.10);
        background: #111113;
        color: #fff;
        font-size: 11px;
        font-weight: 600;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        cursor: pointer;
    }

    .toolbar-button:hover {
        border-color: rgba(255,255,255,0.20);
        background: rgba(255,255,255,0.04);
    }

    .toolbar-button:focus-visible,
    .search-input:focus-visible,
    .filter-select:focus-visible {
        outline: none;
        box-shadow: 0 0 0 2px rgba(17,17,19,0.95), 0 0 0 4px rgba(255,255,255,0.18);
    }

    .stat-strip {
        display: flex;
        gap: 12px;
        margin-bottom: 26px;
        flex-wrap: wrap;
    }

    .stat-box {
        flex: 1;
        min-width: 160px;
        display: flex;
        flex-direction: column;
        gap: 6px;
        background: #111113;
        border: 1px solid rgba(255,255,255,0.05);
        border-radius: 10px;
        padding: 16px 20px;
        color: #fff;
        font-size: 22px;
        font-weight: 700;
        letter-spacing: -0.02em;
    }

    .stat-box span {
        font-size: 10px;
        color: rgba(255,255,255,0.26);
        font-weight: 500;
        letter-spacing: 0.08em;
        text-transform: uppercase;
    }

    .panel {
        background: #111113;
        border: 1px solid rgba(255,255,255,0.05);
        border-radius: 10px;
        overflow: hidden;
    }

    .table-wrap {
        width: 100%;
        overflow-x: auto;
    }

    .voucher-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
        min-width: 980px;
    }

    .voucher-table thead th {
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

    .voucher-table thead th:first-child,
    .voucher-table tbody td:first-child { padding-left: 18px; }

    .voucher-table tbody td {
        padding: 16px 14px;
        border-bottom: 1px solid rgba(255,255,255,0.04);
        color: #fff;
        vertical-align: middle;
    }

    .voucher-table tbody tr:last-child td { border-bottom: none; }
    .voucher-table tbody tr:hover td { background: rgba(255,255,255,0.018); }

    .voucher-name {
        display: block;
        font-weight: 600;
        color: #fff;
        margin-bottom: 4px;
    }

    .code {
        display: inline-flex;
        align-items: center;
        padding: 4px 8px;
        border-radius: 999px;
        background: rgba(255,255,255,0.05);
        color: rgba(255,255,255,0.56);
        font-family: 'Courier New', monospace;
        font-size: 11px;
        letter-spacing: 0.10em;
        text-transform: uppercase;
    }

    .muted-cell {
        color: rgba(255,255,255,0.42);
    }

    .status {
        display: inline-block;
        padding: 4px 10px;
        border-radius: 999px;
        font-size: 10px;
        font-weight: 600;
        letter-spacing: 0.08em;
        text-transform: uppercase;
    }

    .status--active { background: rgba(255,255,255,0.10); color: #fff; }
    .status--upcoming { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.72); }
    .status--paused { background: rgba(251,191,36,0.14); color: #fbbf24; }
    .status--expired,
    .status--archived { background: rgba(255,68,68,0.12); color: #ff9d9d; }
    .status--exhausted { background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.76); }

    .actions {
        white-space: nowrap;
    }

    .actions a,
    .actions .link-button {
        display: inline-flex;
        align-items: center;
        margin-right: 12px;
        padding: 0;
        border: none;
        background: transparent;
        color: rgba(255,255,255,0.50);
        text-decoration: none;
        font-size: 11px;
        font-weight: 600;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        cursor: pointer;
        transition: color 0.15s;
    }

    .actions a:last-child,
    .actions .link-button:last-child { margin-right: 0; }

    .actions a:hover,
    .actions .link-button:hover {
        color: #fff;
        text-decoration: none;
    }

    .actions a:focus-visible,
    .actions .link-button:focus-visible {
        outline: none;
        border-radius: 4px;
        color: #fff;
        box-shadow: 0 0 0 2px rgba(17,17,19,0.95), 0 0 0 4px rgba(255,255,255,0.20);
    }

    .empty-state {
        margin-top: 16px;
        padding: 22px 20px;
        border-radius: 10px;
        border: 1px solid rgba(255,255,255,0.05);
        background: #111113;
        color: #fff;
    }

    .empty-state__title {
        font-size: 13px;
        font-weight: 600;
        margin-bottom: 6px;
    }

    .empty-state__copy {
        font-size: 12px;
        color: rgba(255,255,255,0.46);
        line-height: 1.6;
    }

    html[data-theme="light"] .page-title,
    html[data-theme="light"] .stat-box,
    html[data-theme="light"] .voucher-table tbody td,
    html[data-theme="light"] .voucher-name,
    html[data-theme="light"] .primary-action:hover,
    html[data-theme="light"] .actions a:hover,
    html[data-theme="light"] .actions .link-button:hover { color: #0d0d0f; }

    html[data-theme="light"] .page-subtitle,
    html[data-theme="light"] .stat-box span,
    html[data-theme="light"] .voucher-table thead th,
    html[data-theme="light"] .muted-cell,
    html[data-theme="light"] .code,
    html[data-theme="light"] .toolbar-label,
    html[data-theme="light"] .actions a,
    html[data-theme="light"] .actions .link-button { color: rgba(0,0,0,0.42); }

    html[data-theme="light"] .primary-action,
    html[data-theme="light"] .stat-box,
    html[data-theme="light"] .panel,
    html[data-theme="light"] .search-line,
    html[data-theme="light"] .filter-select,
    html[data-theme="light"] .toolbar-button,
    html[data-theme="light"] .empty-state {
        background: #ffffff;
        border-color: rgba(0,0,0,0.07);
    }

    html[data-theme="light"] .primary-action:hover {
        border-color: rgba(0,0,0,0.16);
        background: rgba(0,0,0,0.03);
    }

    html[data-theme="light"] .primary-action:focus-visible {
        border-color: rgba(0,0,0,0.28);
        box-shadow: 0 0 0 2px rgba(255,255,255,0.95), 0 0 0 4px rgba(0,0,0,0.18);
    }

    html[data-theme="light"] .voucher-table thead th { border-bottom-color: rgba(0,0,0,0.07); }
    html[data-theme="light"] .voucher-table tbody td { border-bottom-color: rgba(0,0,0,0.04); }
    html[data-theme="light"] .voucher-table tbody tr:hover td { background: rgba(0,0,0,0.02); }
    html[data-theme="light"] .code { background: rgba(0,0,0,0.05); }
    html[data-theme="light"] .status--active { background: rgba(0,0,0,0.08); color: #0d0d0f; }
    html[data-theme="light"] .status--upcoming { background: rgba(0,0,0,0.05); color: rgba(0,0,0,0.62); }
    html[data-theme="light"] .status--exhausted { background: rgba(0,0,0,0.07); color: rgba(0,0,0,0.62); }
    html[data-theme="light"] .status--paused { color: #8a5a00; }
    html[data-theme="light"] .status--expired,
    html[data-theme="light"] .status--archived { color: #9b3d3d; }
    html[data-theme="light"] .message-banner {
        border-color: rgba(255,68,68,0.18);
        background: rgba(255,68,68,0.07);
        color: #7d1f1f;
    }

    html[data-theme="light"] .search-line i,
    html[data-theme="light"] .search-input::placeholder,
    html[data-theme="light"] .empty-state__copy {
        color: rgba(0,0,0,0.30);
    }

    html[data-theme="light"] .search-input,
    html[data-theme="light"] .filter-select,
    html[data-theme="light"] .toolbar-button,
    html[data-theme="light"] .empty-state__title {
        color: #0d0d0f;
    }

    html[data-theme="light"] .actions a:focus-visible,
    html[data-theme="light"] .actions .link-button:focus-visible {
        color: #0d0d0f;
        box-shadow: 0 0 0 2px rgba(255,255,255,0.95), 0 0 0 4px rgba(0,0,0,0.16);
    }

    @media (max-width: 900px) {
        .page-header {
            margin-bottom: 24px;
        }

        .primary-action {
            width: 100%;
            justify-content: center;
        }

        .stat-box {
            min-width: calc(50% - 6px);
        }
    }

    @media (max-width: 640px) {
        .stat-box {
            min-width: 100%;
        }
    }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1 class="page-title">Loyalty Management</h1>
            <p class="page-subtitle">Create and control checkout vouchers.</p>
        </div>
        <a class="primary-action" href="onyx_admin_voucher_form.aspx"><i data-lucide="plus"></i>Add voucher</a>
    </div>

    <asp:Label ID="lblMessage" runat="server" CssClass="message-banner" Visible="false" />

    <div class="toolbar">
        <div class="toolbar-field toolbar-field--search">
            <label for="<%= txtSearch.ClientID %>" class="toolbar-label">Search vouchers</label>
            <div class="search-line">
                <i data-lucide="search"></i>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Search by voucher name or code" />
            </div>
        </div>
        <div class="toolbar-field">
            <label for="<%= ddlStatusFilter.ClientID %>" class="toolbar-label">Status</label>
            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                <asp:ListItem Value="all" Text="All statuses" />
                <asp:ListItem Value="active" Text="Active" />
                <asp:ListItem Value="upcoming" Text="Upcoming" />
                <asp:ListItem Value="paused" Text="Paused" />
                <asp:ListItem Value="expired" Text="Expired" />
                <asp:ListItem Value="exhausted" Text="Exhausted" />
                <asp:ListItem Value="archived" Text="Archived" />
            </asp:DropDownList>
        </div>
        <div class="toolbar-field">
            <span class="toolbar-label">Apply</span>
            <asp:Button ID="btnApplyFilters" runat="server" Text="Filter" CssClass="toolbar-button" OnClick="btnApplyFilters_Click" />
        </div>
    </div>

    <div class="stat-strip">
        <div class="stat-box"><asp:Literal ID="litActiveCount" runat="server" /><span>Active vouchers</span></div>
        <div class="stat-box"><asp:Literal ID="litRedeemedCount" runat="server" /><span>Redemptions</span></div>
        <div class="stat-box"><asp:Literal ID="litSavingsGiven" runat="server" /><span>Total savings</span></div>
    </div>

    <div class="panel">
        <div class="table-wrap">
            <table class="voucher-table">
                <thead>
                    <tr>
                        <th>Voucher</th>
                        <th>Discount</th>
                        <th>Eligibility</th>
                        <th>Minimum</th>
                        <th>Usage</th>
                        <th>Validity</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptVouchers" runat="server" OnItemCommand="rptVouchers_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <strong class="voucher-name"><%#: Eval("Name") %></strong>
                                    <span class="code"><%#: Eval("Code") %></span>
                                </td>
                                <td><%#: GetDiscountText(Container.DataItem) %></td>
                                <td class="muted-cell"><%#: GetEligibilityText(Container.DataItem) %></td>
                                <td class="muted-cell"><%#: GetMinimumText(Container.DataItem) %></td>
                                <td class="muted-cell"><%#: GetUsageText(Container.DataItem) %></td>
                                <td class="muted-cell"><%#: GetValidityText(Container.DataItem) %></td>
                                <td><span class='<%#: "status status--" + GetStatusKey(Container.DataItem) %>'><%#: GetStatusText(Container.DataItem) %></span></td>
                                <td class="actions">
                                    <a href='<%#: "onyx_admin_voucher_form.aspx?id=" + Eval("Id") %>'>Edit</a>
                                    <asp:LinkButton ID="btnToggle" runat="server" CssClass="link-button" CommandName="Toggle" CommandArgument='<%# Eval("Id") %>' Text='<%# GetToggleText(Container.DataItem) %>' />
                                    <asp:LinkButton ID="btnArchive" runat="server" CssClass="link-button" CommandName="Archive" CommandArgument='<%# Eval("Id") %>' Text="Archive" OnClientClick="return confirm('Archive this voucher?');" />
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>

    <asp:Panel ID="pnlEmptyState" runat="server" CssClass="empty-state" Visible="false">
        <div class="empty-state__title">No vouchers found</div>
        <div class="empty-state__copy"><asp:Literal ID="litEmptyStateText" runat="server" /></div>
    </asp:Panel>
</asp:Content>
