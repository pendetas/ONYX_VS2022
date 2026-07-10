<%@ Page Title="Settings" Language="C#" MasterPageFile="~/admin_page/admin.Master" AutoEventWireup="true"
         CodeBehind="onyx_admin_settings.aspx.cs" Inherits="ONYX_DDAC.admin_page.onyx_admin_settings" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* ── Page chrome ────────────────────────────── */
    .page-header { margin-bottom: 32px; }
    .page-title  { font-size: 22px; font-weight: 600; letter-spacing: -0.02em; color: #fff; }
    .page-meta   { font-size: 12px; color: rgba(255,255,255,0.32); margin-top: 4px; }

    /* ── Settings columns ───────────────────────── */
    .settings-layout {
        display: grid;
        grid-template-columns: 1fr 320px;
        gap: 20px;
        align-items: start;
    }

    @media (max-width: 960px) {
        .settings-layout { grid-template-columns: 1fr; }
    }

    /* ── Panels ─────────────────────────────────── */
    .panel {
        background: #111113;
        border: 1px solid rgba(255,255,255,0.05);
        border-radius: 10px;
        padding: 24px;
        margin-bottom: 20px;
    }

    .section-label {
        font-size: 10px;
        font-weight: 600;
        letter-spacing: 0.09em;
        text-transform: uppercase;
        color: rgba(255,255,255,0.28);
        border-bottom: 1px solid rgba(255,255,255,0.06);
        padding-bottom: 10px;
        margin-bottom: 20px;
    }

    /* ── Alert banners ──────────────────────────── */
    .alert-success, .alert-error {
        font-size: 12px;
        padding: 10px 14px;
        border-radius: 6px;
        margin-bottom: 18px;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .alert-success {
        background: rgba(255,255,255,0.04);
        border-left: 3px solid rgba(255,255,255,0.22);
        color: rgba(255,255,255,0.65);
    }

    .alert-error {
        background: rgba(255,68,68,0.08);
        border-left: 3px solid rgba(255,68,68,0.55);
        color: rgba(255,100,100,0.90);
    }

    /* ── Form fields ────────────────────────────── */
    .field-row { margin-bottom: 20px; }

    .field-label {
        font-size: 10px;
        font-weight: 600;
        letter-spacing: 0.07em;
        text-transform: uppercase;
        color: rgba(255,255,255,0.30);
        display: block;
        margin-bottom: 6px;
    }

    .field-input {
        width: 100%;
        background: transparent;
        border: none;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        color: #fff;
        font-size: 13px;
        padding: 6px 0 8px;
        outline: none;
        transition: border-color 0.15s;
        font-family: 'Inter', sans-serif;
    }

    .field-input:focus { border-bottom-color: rgba(255,255,255,0.40); }
    .field-input::placeholder { color: rgba(255,255,255,0.18); }

    /* ── Save button ────────────────────────────── */
    .btn-save {
        background: #fff;
        color: #0d0d0f;
        border: none;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 600;
        padding: 9px 22px;
        cursor: pointer;
        letter-spacing: 0.02em;
        transition: opacity 0.12s;
        font-family: 'Inter', sans-serif;
    }

    .btn-save:hover { opacity: 0.88; }

    /* ── Appearance panel ───────────────────────── */
    .theme-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .theme-info h4 {
        font-size: 13px;
        font-weight: 500;
        color: rgba(255,255,255,0.80);
        margin: 0 0 3px;
    }

    .theme-info p {
        font-size: 11px;
        color: rgba(255,255,255,0.32);
        margin: 0;
    }

    /* Toggle switch */
    .toggle-wrap { position: relative; width: 44px; height: 24px; flex-shrink: 0; }

    .toggle-wrap input[type="checkbox"] {
        position: absolute; opacity: 0; width: 0; height: 0;
    }

    .toggle-track {
        position: absolute; inset: 0;
        background: rgba(255,255,255,0.10);
        border-radius: 12px;
        cursor: pointer;
        transition: background 0.2s;
        border: 1px solid rgba(255,255,255,0.10);
    }

    .toggle-track::after {
        content: '';
        position: absolute;
        left: 3px; top: 50%;
        transform: translateY(-50%);
        width: 16px; height: 16px;
        background: rgba(255,255,255,0.45);
        border-radius: 50%;
        transition: left 0.18s, background 0.18s;
    }

    .toggle-wrap input:checked + .toggle-track {
        background: rgba(255,255,255,0.85);
    }

    .toggle-wrap input:checked + .toggle-track::after {
        left: 23px;
        background: #111113;
    }

    html[data-theme="light"] .toggle-wrap input:checked + .toggle-track { background: #0d0d0f; }
    html[data-theme="light"] .toggle-wrap input:checked + .toggle-track::after { background: #fff; }
    html[data-theme="light"] .toggle-track { background: rgba(0,0,0,0.08); border-color: rgba(0,0,0,0.10); }
    html[data-theme="light"] .toggle-track::after { background: rgba(0,0,0,0.30); }

    /* ── Admin users table ──────────────────────── */
    .admin-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 12px;
    }

    .admin-table th {
        text-align: left;
        font-size: 10px;
        font-weight: 600;
        letter-spacing: 0.07em;
        text-transform: uppercase;
        color: rgba(255,255,255,0.28);
        padding: 0 0 10px;
        border-bottom: 1px solid rgba(255,255,255,0.06);
    }

    .admin-table td {
        padding: 11px 0;
        border-bottom: 1px solid rgba(255,255,255,0.04);
        vertical-align: middle;
    }

    .admin-table tr:last-child td { border-bottom: none; }

    .admin-table tr:hover td { background: rgba(255,255,255,0.015); }

    .adm-avatar {
        width: 28px; height: 28px;
        border-radius: 50%;
        background: rgba(255,255,255,0.07);
        color: rgba(255,255,255,0.45);
        display: inline-flex; align-items: center; justify-content: center;
        font-size: 10px; font-weight: 600;
        margin-right: 10px;
        flex-shrink: 0;
    }

    .adm-name-cell { display: flex; align-items: center; }
    .adm-name      { font-size: 12px; font-weight: 500; color: rgba(255,255,255,0.85); }
    .adm-email     { font-size: 11px; color: rgba(255,255,255,0.30); margin-top: 1px; }
    .adm-date      { font-size: 11px; color: rgba(255,255,255,0.28); }

    .empty-admins {
        text-align: center;
        padding: 20px 0;
        font-size: 12px;
        color: rgba(255,255,255,0.22);
    }

    /* light mode overrides for settings-specific classes */
    html[data-theme="light"] .panel { background: #fff; border-color: rgba(0,0,0,0.07); }
    html[data-theme="light"] .page-title { color: #0d0d0f; }
    html[data-theme="light"] .section-label { color: rgba(0,0,0,0.28); border-bottom-color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .theme-info h4 { color: rgba(0,0,0,0.75); }
    html[data-theme="light"] .theme-info p  { color: rgba(0,0,0,0.35); }
    html[data-theme="light"] .field-label   { color: rgba(0,0,0,0.28); }
    html[data-theme="light"] .field-input   { color: #0d0d0f; border-bottom-color: rgba(0,0,0,0.10); }
    html[data-theme="light"] .field-input:focus { border-bottom-color: rgba(0,0,0,0.38); }
    html[data-theme="light"] .field-input::placeholder { color: rgba(0,0,0,0.20); }
    html[data-theme="light"] .btn-save { background: #0d0d0f; color: #fff; }
    html[data-theme="light"] .admin-table th { color: rgba(0,0,0,0.28); border-bottom-color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .admin-table td { border-bottom-color: rgba(0,0,0,0.04); }
    html[data-theme="light"] .admin-table tr:hover td { background: rgba(0,0,0,0.02); }
    html[data-theme="light"] .adm-avatar  { background: rgba(0,0,0,0.05); color: rgba(0,0,0,0.40); }
    html[data-theme="light"] .adm-name    { color: rgba(0,0,0,0.80); }
    html[data-theme="light"] .adm-email   { color: rgba(0,0,0,0.30); }
    html[data-theme="light"] .adm-date    { color: rgba(0,0,0,0.28); }
    html[data-theme="light"] .empty-admins { color: rgba(0,0,0,0.22); }
    html[data-theme="light"] .alert-success { background: rgba(0,0,0,0.03); border-left-color: rgba(0,0,0,0.20); color: rgba(0,0,0,0.55); }
    html[data-theme="light"] .alert-error   { background: rgba(255,68,68,0.05); color: rgba(180,0,0,0.75); }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-header">
        <div class="page-title">Settings</div>
        <div class="page-meta">Manage your account and appearance preferences.</div>
    </div>

    <div class="settings-layout">

        <%-- ═══ LEFT COLUMN ═══════════════════════════════════════════════════ --%>
        <div>

            <%-- ── Appearance ───────────────────────────────────────────────── --%>
            <div class="panel">
                <div class="section-label">Appearance</div>

                <div class="theme-row">
                    <div class="theme-info">
                        <h4>Light mode</h4>
                        <p>Switches all admin pages to a light colour scheme.</p>
                    </div>
                    <label class="toggle-wrap">
                        <input type="checkbox" id="themeToggle" />
                        <span class="toggle-track"></span>
                    </label>
                </div>
            </div>

            <%-- ── Change Password ───────────────────────────────────────────── --%>
            <div class="panel">
                <div class="section-label">Change Password</div>

                <asp:Panel ID="pnlPwMsg" runat="server" Visible="false">
                    <div id="pwMsgBox" runat="server"></div>
                </asp:Panel>

                <div class="field-row">
                    <label class="field-label" for="txtCurrent">Current password</label>
                    <asp:TextBox ID="txtCurrent" runat="server" TextMode="Password" CssClass="field-input"
                        placeholder="Enter current password"
                        data-gramm="false" data-gramm_editor="false" />
                </div>

                <div class="field-row">
                    <label class="field-label" for="txtNewPass">New password</label>
                    <asp:TextBox ID="txtNewPass" runat="server" TextMode="Password" CssClass="field-input"
                        placeholder="At least 8 characters"
                        data-gramm="false" data-gramm_editor="false" />
                </div>

                <div class="field-row">
                    <label class="field-label" for="txtConfirm">Confirm new password</label>
                    <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" CssClass="field-input"
                        placeholder="Repeat new password"
                        data-gramm="false" data-gramm_editor="false" />
                </div>

                <asp:Button ID="btnChangePassword" runat="server" Text="Update Password"
                    CssClass="btn-save" OnClick="btnChangePassword_Click" CausesValidation="false" />
            </div>

        </div>

        <%-- ═══ RIGHT COLUMN ══════════════════════════════════════════════════ --%>
        <div>

            <%-- ── Admin Users ───────────────────────────────────────────────── --%>
            <div class="panel">
                <div class="section-label">Admin Users</div>

                <asp:Panel ID="pnlNoAdmins" runat="server" Visible="false">
                    <div class="empty-admins">No admin accounts found.</div>
                </asp:Panel>

                <asp:Repeater ID="AdminRepeater" runat="server">
                    <HeaderTemplate>
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>User</th>
                                    <th>Joined</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td>
                                <div class="adm-name-cell">
                                    <div class="adm-avatar"><%# Eval("Initials") %></div>
                                    <div>
                                        <div class="adm-name"><%# Server.HtmlEncode(Eval("FullName").ToString()) %></div>
                                        <div class="adm-email"><%# Server.HtmlEncode(Eval("Email").ToString()) %></div>
                                    </div>
                                </div>
                            </td>
                            <td class="adm-date"><%# Eval("JoinDate") %></td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                            </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
            </div>

        </div>
    </div>

    <script>
        (function () {
            var toggle = document.getElementById('themeToggle');

            // Sync toggle state to current theme on load
            var currentTheme = document.documentElement.getAttribute('data-theme') || 'dark';
            toggle.checked = (currentTheme === 'light');

            toggle.addEventListener('change', function () {
                var next = toggle.checked ? 'light' : 'dark';
                document.documentElement.setAttribute('data-theme', next);
                localStorage.setItem('onyx-theme', next);
            });
        })();
    </script>

</asp:Content>
