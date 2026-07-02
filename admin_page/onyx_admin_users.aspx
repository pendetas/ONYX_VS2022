<%@ Page Title="Users" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_users.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_users" %>

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

    .header-count {
        font-size: 12px;
        color: rgba(255,255,255,0.22);
        display: flex;
        align-items: center;
        gap: 6px;
        margin-top: 6px;
    }

    .header-count i { width: 13px; height: 13px; }

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

    /* ── Toolbar ─────────────────────────────────── */
    .toolbar {
        display: flex;
        align-items: flex-end;
        gap: 16px;
        margin-bottom: 0;
        border-bottom: 1px solid rgba(255,255,255,0.07);
        padding-bottom: 0;
        flex-wrap: wrap;
    }

    .search-wrap {
        max-width: 260px;
        flex: 1;
        padding-bottom: 10px;
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

    /* Role select — underline style */
    .role-select {
        background: transparent;
        border: none;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        color: rgba(255,255,255,0.45);
        font-size: 11px;
        font-weight: 500;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        padding: 7px 20px 7px 0;
        outline: none;
        appearance: none;
        -webkit-appearance: none;
        cursor: pointer;
        font-family: inherit;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='rgba(255,255,255,0.25)' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 2px center;
        margin-bottom: 10px;
    }

    .role-select option { background: #111113; color: #fff; }

    .toolbar-right {
        margin-left: auto;
        font-size: 11px;
        color: rgba(255,255,255,0.20);
        letter-spacing: 0.04em;
        padding-bottom: 12px;
    }

    .toolbar-right strong { color: rgba(255,255,255,0.55); }

    /* ── Users table ─────────────────────────────── */
    .users-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
    }

    .users-table thead th {
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

    .users-table thead th:first-child { padding-left: 0; }

    .users-table tbody td {
        padding: 13px 14px;
        border-bottom: 1px solid rgba(255,255,255,0.04);
        color: #fff;
        vertical-align: middle;
    }

    .users-table tbody td:first-child { padding-left: 0; }
    .users-table tbody tr:last-child td { border-bottom: none; }
    .users-table tbody tr:hover td { background: rgba(255,255,255,0.018); }

    /* Avatar + name */
    .user-cell { display: flex; align-items: center; gap: 12px; }

    .user-avatar {
        width: 34px;
        height: 34px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 11px;
        font-weight: 700;
        flex-shrink: 0;
        letter-spacing: 0.5px;
    }

    .avatar-admin    { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.55); }
    .avatar-customer { background: rgba(255,255,255,0.04); color: rgba(255,255,255,0.40); }

    .user-name  { font-weight: 600; font-size: 13px; }
    .user-email { font-size: 11px; color: rgba(255,255,255,0.30); margin-top: 2px; }

    /* Role badge */
    .role-badge {
        display: inline-block;
        padding: 3px 9px;
        border-radius: 3px;
        font-size: 10px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.06em;
    }

    .role-admin    { background: rgba(255,255,255,0.07); color: rgba(255,255,255,0.60); }
    .role-customer { background: rgba(255,255,255,0.04); color: rgba(255,255,255,0.38); }

    .date-cell, .phone-cell { color: rgba(255,255,255,0.32); }

    .spent-value { font-weight: 600; color: rgba(255,255,255,0.85); }
    .spent-dash  { color: rgba(255,255,255,0.18); }

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
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Header --%>
    <div class="page-header">
        <div>
            <div class="page-title">Users</div>
            <div class="page-subtitle">View and manage all registered customers and admins.</div>
        </div>
        <div class="header-count">
            <i data-lucide="users"></i>
            <asp:Literal ID="litUserCountHeader" runat="server" Text="0" /> accounts
        </div>
    </div>

    <%-- Stat strip --%>
    <div class="stat-strip">
        <div class="stat-box">
            <div class="stat-value"><asp:Literal ID="litStatTotal" runat="server" Text="0" /></div>
            <div class="stat-label">Total</div>
        </div>
        <div class="stat-box">
            <div class="stat-value"><asp:Literal ID="litStatAdmins" runat="server" Text="0" /></div>
            <div class="stat-label">Admins</div>
        </div>
        <div class="stat-box">
            <div class="stat-value"><asp:Literal ID="litStatCustomers" runat="server" Text="0" /></div>
            <div class="stat-label">Customers</div>
        </div>
        <div class="stat-box">
            <div class="stat-value"><asp:Literal ID="litStatRevenue" runat="server" Text="RM 0" /></div>
            <div class="stat-label">Revenue</div>
        </div>
    </div>

    <%-- Toolbar --%>
    <div class="toolbar">
        <div class="search-wrap">
            <div class="search-line">
                <i data-lucide="search"></i>
                <input type="text" class="search-input" id="userSearch"
                       placeholder="Search name, email, phone..." oninput="searchUsers(this.value)" />
            </div>
        </div>
        <select class="role-select" id="roleFilter" onchange="filterByRole(this.value)">
            <option value="all">All Roles</option>
            <option value="admin">Admin</option>
            <option value="customer">Customer</option>
        </select>
        <div class="toolbar-right">
            <strong id="visibleCount"><asp:Literal ID="litVisibleCount" runat="server" Text="0" /></strong>
            of <asp:Literal ID="litTotalCount" runat="server" Text="0" /> users
        </div>
    </div>

    <%-- Users table --%>
    <table class="users-table" id="usersTable">
        <thead>
            <tr>
                <th>User</th>
                <th>Role</th>
                <th>Phone</th>
                <th>Joined</th>
                <th>Orders</th>
                <th>Spent</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <asp:Repeater ID="UsersRepeater" runat="server">
                <ItemTemplate>
                    <tr class="user-row" data-role="<%# Eval("RoleKey") %>">
                        <td>
                            <div class="user-cell">
                                <div class="user-avatar avatar-<%# Eval("RoleKey") %>">
                                    <%# Eval("Initials") %>
                                </div>
                                <div>
                                    <div class="user-name"><%# Eval("FullName") %></div>
                                    <div class="user-email"><%# Eval("Email") %></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="role-badge role-<%# Eval("RoleKey") %>">
                                <%# Eval("Role") %>
                            </span>
                        </td>
                        <td class="phone-cell"><%# Eval("Phone") %></td>
                        <td class="date-cell"><%# Eval("JoinDate") %></td>
                        <td style="color:rgba(255,255,255,0.32); text-align:center;">
                            <%# Eval("TotalOrders") %>
                        </td>
                        <td>
                            <span class="<%# Eval("SpentClass") %>"><%# Eval("TotalSpent") %></span>
                        </td>
                        <td>
                            <a href="onyx_admin_user_detail.aspx?id=<%# Eval("Id") %>" class="btn-view">
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
            New this month: <strong><asp:Literal ID="litNewThisMonth" runat="server" Text="0" /></strong>
        </span>
        <span>
            Total revenue across all completed orders shown in stats above.
        </span>
    </div>

    <script>
        function searchUsers(q) {
            q = q.toLowerCase();
            var visible = 0;
            document.querySelectorAll('.user-row').forEach(function (row) {
                var show = row.textContent.toLowerCase().indexOf(q) !== -1;
                row.style.display = show ? '' : 'none';
                if (show) visible++;
            });
            document.getElementById('visibleCount').textContent = visible;
        }

        function filterByRole(role) {
            var visible = 0;
            document.querySelectorAll('.user-row').forEach(function (row) {
                var show = role === 'all' || row.dataset.role === role;
                row.style.display = show ? '' : 'none';
                if (show) visible++;
            });
            document.getElementById('visibleCount').textContent = visible;
        }
    </script>

</asp:Content>
