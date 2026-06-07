<%@ Page Title="Users" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_users.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_users" %>

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

        /* ── STAT STRIP ──────────────────────────────────────────── */
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

        /* ── SEARCH / FILTER BAR ─────────────────────────────────── */
        .filter-bar {
            padding: 14px 20px;
            border-bottom: 1px solid #2b2b2b;
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .search-input {
            background: #0d0d0d;
            border: 1px solid #2b2b2b;
            border-radius: 0;
            color: #ffffff;
            padding: 8px 14px;
            font-size: 13px;
            font-family: 'Inter', sans-serif;
            width: 260px;
        }

        .search-input:focus { outline: none; border-color: #00ff87; }
        .search-input::placeholder { color: #484848; }

        .role-filter {
            background: #0d0d0d;
            border: 1px solid #2b2b2b;
            border-radius: 0;
            color: #ffffff;
            padding: 8px 12px;
            font-size: 13px;
            font-family: 'Inter', sans-serif;
        }

        .role-filter:focus { outline: none; border-color: #00ff87; }
        .role-filter option { background: #1a1a1a; }

        /* ── USERS TABLE ─────────────────────────────────────────── */
        .users-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .users-table thead th {
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

        .users-table tbody td {
            padding: 14px 20px;
            border-bottom: 1px solid #202020;
            color: #ffffff;
            vertical-align: middle;
        }

        .users-table tbody tr:last-child td { border-bottom: none; }
        .users-table tbody tr:hover td      { background: rgba(255,255,255,0.02); }

        /* Avatar + name cell */
        .user-cell { display: flex; align-items: center; gap: 12px; }

        .user-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
            flex-shrink: 0;
            letter-spacing: 0.5px;
        }

        .avatar-admin    { background: rgba(167, 139, 250, 0.18); color: #a78bfa; }
        .avatar-customer { background: rgba(96,  165, 250, 0.18); color: #60a5fa; }

        .user-name  { font-weight: 600; font-size: 14px; }
        .user-email { font-size: 12px; color: #9c9ca4; margin-top: 2px; }

        /* Role badge */
        .role-badge {
            display: inline-block;
            padding: 3px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            text-transform: capitalize;
        }

        .role-admin    { background: rgba(167, 139, 250, 0.12); color: #a78bfa; }
        .role-customer { background: rgba(96,  165, 250, 0.12); color: #60a5fa; }

        /* Spend cell */
        .spent-value { font-weight: 600; color: #00ff87; }
        .spent-dash  { color: #444; }

        .date-cell  { color: #9c9ca4; font-size: 13px; }
        .phone-cell { color: #9c9ca4; font-size: 13px; }

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
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ======================================================
         PAGE HEADER
    ====================================================== --%>
    <div class="d-flex justify-content-between align-items-start mb-4">
        <div>
            <h1 class="page-title">User Management</h1>
            <p class="page-subtitle">View and manage all registered customers and admins.</p>
        </div>
        <div style="font-size:13px; color:#9c9ca4; padding-top:5px; display:flex; align-items:center; gap:6px;">
            <i data-lucide="users" style="width:14px;height:14px;"></i>
            <asp:Literal ID="litUserCountHeader" runat="server" Text="0" /> registered accounts
        </div>
    </div>

    <%-- ======================================================
         STAT STRIP
    ====================================================== --%>
    <div class="stat-strip mb-4">
        <div class="stat-box">
            <div class="stat-value"><asp:Literal ID="litStatTotal"    runat="server" Text="0" /></div>
            <div class="stat-label">Total Users</div>
        </div>
        <div class="stat-box">
            <div class="stat-value" style="color:#a78bfa;">
                <asp:Literal ID="litStatAdmins" runat="server" Text="0" />
            </div>
            <div class="stat-label">Admins</div>
        </div>
        <div class="stat-box">
            <div class="stat-value" style="color:#60a5fa;">
                <asp:Literal ID="litStatCustomers" runat="server" Text="0" />
            </div>
            <div class="stat-label">Customers</div>
        </div>
        <div class="stat-box">
            <div class="stat-value" style="color:#00ff87;">
                <asp:Literal ID="litStatRevenue" runat="server" Text="RM 0" />
            </div>
            <div class="stat-label">Platform Revenue</div>
        </div>
    </div>

    <%-- ======================================================
         USERS PANEL
    ====================================================== --%>
    <div class="admin-panel">

        <%-- Filter Bar --%>
        <div class="filter-bar">
            <input type="text" class="search-input" id="userSearch"
                   placeholder="Search by name, email, or phone..."
                   oninput="searchUsers(this.value)">
            <select class="role-filter" id="roleFilter"
                    onchange="filterByRole(this.value)">
                <option value="all">All Roles</option>
                <option value="admin">Admin</option>
                <option value="customer">Customer</option>
            </select>
            <div style="margin-left:auto; font-size:13px; color:#9c9ca4;">
                Showing <strong id="visibleCount" style="color:#fff;">
                    <asp:Literal ID="litVisibleCount" runat="server" Text="0" />
                </strong>
                of <asp:Literal ID="litTotalCount" runat="server" Text="0" /> users
            </div>
        </div>

        <%-- Users Table --%>
        <table class="users-table" id="usersTable">
            <thead>
                <tr>
                    <th>User</th>
                    <th>Role</th>
                    <th>Phone</th>
                    <th>Join Date</th>
                    <th>Total Orders</th>
                    <th>Total Spent</th>
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
                            <td style="color:#9c9ca4; text-align:center;">
                                <%# Eval("TotalOrders") %>
                            </td>
                            <td>
                                <span class='<%# Eval("SpentClass") %>'>
                                    <%# Eval("TotalSpent") %>
                                </span>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>

        <%-- Summary Bar --%>
        <div class="summary-bar">
            <span>
                <i data-lucide="info" style="width:13px;height:13px;margin-right:5px;"></i>
                Total Spent column shows cumulative spend across all completed orders.
            </span>
            <span>
                New this month: <strong style="color:#00ff87; margin-left:4px;">
                    <asp:Literal ID="litNewThisMonth" runat="server" Text="0" />
                </strong>
            </span>
        </div>
    </div>

    <%-- ======================================================
         CLIENT-SIDE SEARCH & FILTER
    ====================================================== --%>
    <script>
        function searchUsers(q) {
            q = q.toLowerCase();
            document.querySelectorAll('.user-row').forEach(row => {
                row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
            });
        }

        function filterByRole(role) {
            document.querySelectorAll('.user-row').forEach(row => {
                row.style.display = (role === 'all' || row.dataset.role === role) ? '' : 'none';
            });
        }
    </script>

</asp:Content>
