<%@ Page Title="Voucher Form" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_voucher_form.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_voucher_form"
    MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .form-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        gap: 18px; margin-bottom: 40px; flex-wrap: wrap;
    }
    .page-title { font-size: 22px; font-weight: 600; color: #fff; letter-spacing: -0.02em; margin: 0; }
    .page-subtitle { font-size: 12px; color: rgba(255,255,255,0.58); margin-top: 5px; line-height: 1.6; }
    .back-link {
        display: inline-flex; align-items: center; gap: 6px; font-size: 13px;
        color: rgba(255,255,255,0.28); text-decoration: none; transition: color 0.15s;
        flex-shrink: 0; margin-top: 4px;
    }
    .back-link:hover { color: rgba(255,255,255,0.68); text-decoration: none; }
    .back-link i { width: 14px; height: 14px; }

    .message-banner {
        display: block; margin-bottom: 24px; padding: 12px 14px; border-radius: 10px;
        border: 1px solid rgba(255,68,68,0.20); background: rgba(255,68,68,0.08);
        color: #ffd6d6; font-size: 12px; line-height: 1.6;
    }
    .message-banner.success {
        border-color: rgba(255,255,255,0.16); background: rgba(255,255,255,0.05);
        color: rgba(255,255,255,0.84);
    }

    .form-body { max-width: 960px; width: 100%; }
    .form-section { margin-bottom: 40px; }
    .section-label {
        font-size: 10px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase;
        color: rgba(255,255,255,0.18); margin-bottom: 22px;
        padding-bottom: 10px; border-bottom: 1px solid rgba(255,255,255,0.05);
    }

    .field-row { display: grid; gap: 28px 36px; margin-bottom: 26px; }
    .field-row:last-child { margin-bottom: 0; }
    .fr-2 { grid-template-columns: 1fr 1fr; }
    .fr-1 { grid-template-columns: 1fr; }
    .field-group { display: flex; flex-direction: column; min-width: 0; }

    .field-label {
        font-size: 10px; font-weight: 600; letter-spacing: 0.10em; text-transform: uppercase;
        color: rgba(255,255,255,0.62); margin-bottom: 10px;
    }
    .req { color: rgba(255,68,68,0.75); margin-left: 3px; }

    .field-input, .field-select, .field-textarea {
        background: transparent; border: none;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        color: #fff; font-size: 14px; font-weight: 400;
        padding: 8px 0; width: 100%; outline: none;
        transition: border-color 0.18s; font-family: inherit;
    }
    .field-input::placeholder, .field-textarea::placeholder { color: rgba(255,255,255,0.46); }
    .field-input:focus, .field-select:focus, .field-textarea:focus { border-bottom-color: rgba(255,255,255,0.40); }
    .field-input:focus-visible, .field-select:focus-visible, .field-textarea:focus-visible {
        outline: 2px solid #fff; outline-offset: 3px; border-bottom-color: rgba(255,255,255,0.40);
    }
    .field-input:disabled, .field-select:disabled, .field-textarea:disabled { opacity: 0.40; cursor: not-allowed; }
    .field-input[readonly], .field-textarea[readonly] { color: rgba(255,255,255,0.72); cursor: default; }

    .code-input {
        font-family: 'Courier New', monospace; letter-spacing: 0.10em; text-transform: uppercase;
    }

    .field-select {
        appearance: none; -webkit-appearance: none; cursor: pointer;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='rgba(255,255,255,0.25)' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
        background-repeat: no-repeat; background-position: right 2px center; padding-right: 22px;
        color: rgba(255,255,255,0.85);
    }
    .field-select option { background-color: #111113; color: #fff; }
    .field-textarea { resize: vertical; min-height: 160px; line-height: 1.65; }
    .field-hint { font-size: 11px; color: rgba(255,255,255,0.52); margin-top: 7px; line-height: 1.5; }
    .field-hint.warning { color: #ffb1b1; }

    .toggle-stack { display: grid; gap: 14px; }
    .field-toggle {
        display: inline-flex; align-items: center; gap: 10px;
        color: rgba(255,255,255,0.76); font-size: 13px; font-weight: 600;
    }
    .field-toggle input { width: 16px; height: 16px; accent-color: #fff; }

    .category-panel {
        margin-top: 18px; padding: 18px; border-radius: 10px;
        border: 1px solid rgba(255,255,255,0.08); background: rgba(255,255,255,0.025);
    }
    .category-grid {
        display: grid; grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 12px 18px; margin: 0; padding: 0;
    }
    .category-grid span {
        display: inline-flex; align-items: center; gap: 8px;
        min-width: 0; color: rgba(255,255,255,0.82); font-size: 13px;
    }
    .category-grid input { width: 16px; height: 16px; margin: 0; accent-color: #fff; }
    .category-grid input:focus-visible { outline: 2px solid #fff; outline-offset: 3px; }
    .category-grid.disabled { opacity: 0.42; }

    .lock-banner {
        margin-top: 18px; padding: 12px 14px; border-radius: 10px;
        border: 1px solid rgba(255,255,255,0.10); background: rgba(255,255,255,0.04);
        color: rgba(255,255,255,0.74); font-size: 12px; line-height: 1.6;
    }

    .form-actions {
        position: sticky; bottom: 18px; z-index: 20;
        display: flex; align-items: center; gap: 10px;
        margin: 34px -18px 0; padding: 12px 14px;
        border: 1px solid rgba(255,255,255,0.10); border-top-color: rgba(255,255,255,0.18);
        border-radius: 9px; background: rgba(12,12,15,0.88);
        box-shadow: 0 18px 46px rgba(0,0,0,0.34);
        backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
    }
    .form-actions__main { display: flex; align-items: center; gap: 10px; }
    .btn-save, .btn-cancel {
        min-height: 42px; display: inline-flex; align-items: center; justify-content: center;
        border-radius: 6px; font-family: inherit; font-size: 11px; font-weight: 750;
        letter-spacing: 0.09em; line-height: 1; text-decoration: none; text-transform: uppercase;
        transition: transform 140ms ease, background 140ms ease, border-color 140ms ease, color 140ms ease;
    }
    .btn-save { padding: 0 24px; border: 1px solid #fff; background: #fff; color: #08080a; cursor: pointer; }
    .btn-save:hover { transform: translateY(-1px); background: #e8e8ea; border-color: #e8e8ea; }
    .btn-save:disabled { cursor: wait; opacity: 0.58; transform: none; }
    .btn-cancel { padding: 0 18px; border: 1px solid rgba(255,255,255,0.14); color: rgba(255,255,255,0.68); }
    .btn-cancel:hover { transform: translateY(-1px); border-color: rgba(255,255,255,0.32); color: #fff; text-decoration: none; }
    .btn-save:focus-visible, .btn-cancel:focus-visible { outline: 2px solid #fff; outline-offset: 3px; }
    .required-note { margin-left: auto; font-size: 10px; color: rgba(255,255,255,0.28); letter-spacing: 0.08em; text-transform: uppercase; }

    @media (prefers-reduced-motion: reduce) {
        .btn-save, .btn-cancel { transition: none; }
    }

    @media (max-width: 760px) {
        .form-header { flex-direction: column; gap: 16px; margin-bottom: 30px; }
        .field-row, .category-grid { grid-template-columns: 1fr; gap: 18px; }
        .form-actions { align-items: stretch; bottom: 10px; flex-direction: column; margin-left: -8px; margin-right: -8px; }
        .form-actions .form-actions__main { display: grid; grid-template-columns: 1fr 1fr; width: 100%; }
        .btn-save, .btn-cancel { box-sizing: border-box; justify-content: center; min-height: 42px; text-align: center; width: 100%; }
        .required-note { margin-left: 0; text-align: center; }
    }

    html[data-theme="light"] .page-title { color: #0d0d0f; }
    html[data-theme="light"] .page-subtitle { color: rgba(0,0,0,0.35); }
    html[data-theme="light"] .section-label { color: rgba(0,0,0,0.22); border-bottom-color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .field-label { color: rgba(0,0,0,0.30); }
    html[data-theme="light"] .field-input,
    html[data-theme="light"] .field-select,
    html[data-theme="light"] .field-textarea { color: #0d0d0f; border-bottom-color: rgba(0,0,0,0.10); }
    html[data-theme="light"] .field-input:focus,
    html[data-theme="light"] .field-select:focus,
    html[data-theme="light"] .field-textarea:focus { border-bottom-color: rgba(0,0,0,0.38); }
    html[data-theme="light"] .field-input:focus-visible,
    html[data-theme="light"] .field-select:focus-visible,
    html[data-theme="light"] .field-textarea:focus-visible { outline-color: #0d0d0f; border-bottom-color: rgba(0,0,0,0.38); }
    html[data-theme="light"] .field-input::placeholder,
    html[data-theme="light"] .field-textarea::placeholder { color: rgba(0,0,0,0.18); }
    html[data-theme="light"] .field-input[readonly],
    html[data-theme="light"] .field-textarea[readonly] { color: rgba(0,0,0,0.62); }
    html[data-theme="light"] .field-hint { color: rgba(0,0,0,0.22); }
    html[data-theme="light"] .field-hint.warning { color: #c42a2a; }
    html[data-theme="light"] .field-toggle { color: rgba(0,0,0,0.72); }
    html[data-theme="light"] .field-select {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='rgba(0,0,0,0.30)' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
        color: rgba(0,0,0,0.75);
    }
    html[data-theme="light"] .field-select option { background: #fff; color: #0d0d0f; }
    html[data-theme="light"] .category-panel,
    html[data-theme="light"] .lock-banner {
        border-color: rgba(0,0,0,0.08); background: rgba(0,0,0,0.02);
    }
    html[data-theme="light"] .category-grid span,
    html[data-theme="light"] .lock-banner { color: rgba(0,0,0,0.72); }
    html[data-theme="light"] .message-banner {
        border-color: rgba(196,42,42,0.20); background: rgba(196,42,42,0.06); color: #c42a2a;
    }
    html[data-theme="light"] .message-banner.success {
        border-color: rgba(0,0,0,0.10); background: rgba(0,0,0,0.03); color: #0d0d0f;
    }
    html[data-theme="light"] .form-actions {
        background: rgba(255,255,255,0.90); border-color: rgba(0,0,0,0.10); border-top-color: rgba(0,0,0,0.18);
        box-shadow: 0 18px 46px rgba(16,16,20,0.12);
    }
    html[data-theme="light"] .btn-save { background: #0d0d0f; color: #fff; border-color: #0d0d0f; }
    html[data-theme="light"] .btn-save:hover { background: #2a2a2a; border-color: #2a2a2a; }
    html[data-theme="light"] .btn-cancel { border-color: rgba(0,0,0,0.14); color: rgba(0,0,0,0.58); }
    html[data-theme="light"] .btn-cancel:hover { border-color: rgba(0,0,0,0.32); color: rgba(0,0,0,0.90); }
    html[data-theme="light"] .btn-save:focus-visible, html[data-theme="light"] .btn-cancel:focus-visible { outline-color: #0d0d0f; }
    html[data-theme="light"] .category-grid input:focus-visible { outline-color: #0d0d0f; }
    html[data-theme="light"] .required-note { color: rgba(0,0,0,0.20); }
</style>
<script type="text/javascript">
    (function () {
        function toggleVoucherCategories() {
            var allCategories = document.getElementById('<%= chkAllCategories.ClientID %>');
            var categoryList = document.getElementById('<%= cblCategories.ClientID %>');
            if (!allCategories || !categoryList) {
                return;
            }

            var allowSpecific = !allCategories.checked && !allCategories.disabled;
            categoryList.className = allowSpecific ? 'category-grid' : 'category-grid disabled';

            var inputs = categoryList.querySelectorAll('input[type="checkbox"]');
            for (var i = 0; i < inputs.length; i++) {
                inputs[i].disabled = !allowSpecific;
            }
        }

        document.addEventListener('DOMContentLoaded', function () {
            var allCategories = document.getElementById('<%= chkAllCategories.ClientID %>');
            if (!allCategories) {
                return;
            }

            allCategories.addEventListener('change', toggleVoucherCategories);
            toggleVoucherCategories();
        });
    })();
</script>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="form-header">
        <div>
            <h1 class="page-title"><asp:Literal ID="litPageTitle" runat="server" Text="Create Voucher" /></h1>
            <p class="page-subtitle"><asp:Literal ID="litPageSubtitle" runat="server" Text="Voucher Details" /></p>
        </div>
        <asp:HyperLink ID="lnkBack" runat="server" CssClass="back-link" NavigateUrl="onyx_admin_promos.aspx">
            <i data-lucide="arrow-left"></i> Back
        </asp:HyperLink>
    </div>

    <asp:Label ID="lblMessage" runat="server" CssClass="message-banner" Visible="false" />

    <div class="form-body">
        <div class="form-section">
            <div class="section-label">Voucher Details</div>
            <div class="field-row fr-2">
                <div class="field-group">
                    <asp:Label ID="lblName" runat="server" CssClass="field-label" AssociatedControlID="txtName">Name <span class="req">*</span></asp:Label>
                    <asp:TextBox ID="txtName" runat="server" MaxLength="120" CssClass="field-input" />
                    <div class="field-hint">Public-facing voucher name, up to 120 characters.</div>
                </div>
                <div class="field-group">
                    <asp:Label ID="lblCode" runat="server" CssClass="field-label" AssociatedControlID="txtCode">Voucher code <span class="req">*</span></asp:Label>
                    <asp:TextBox ID="txtCode" runat="server" MaxLength="40" CssClass="field-input code-input" />
                    <div class="field-hint">Use only letters, numbers, underscores, or hyphens.</div>
                </div>
            </div>
            <div class="field-row fr-1">
                <div class="field-group toggle-stack">
                    <div class="field-toggle">
                        <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" />
                        <asp:Label ID="lblIsActive" runat="server" AssociatedControlID="chkIsActive">Voucher is active</asp:Label>
                    </div>
                    <asp:Panel ID="pnlRedemptionLock" runat="server" CssClass="lock-banner" Visible="false">
                        This voucher already has redemptions. Code, discount rules, valid-from date, and category eligibility are locked to protect existing usage.
                    </asp:Panel>
                </div>
            </div>
        </div>

        <div class="form-section">
            <div class="section-label">Discount Rules</div>
            <div class="field-row fr-2">
                <div class="field-group">
                    <asp:Label ID="lblDiscountType" runat="server" CssClass="field-label" AssociatedControlID="ddlDiscountType">Discount type <span class="req">*</span></asp:Label>
                    <asp:DropDownList ID="ddlDiscountType" runat="server" CssClass="field-select">
                        <asp:ListItem Value="percentage">Percentage (%)</asp:ListItem>
                        <asp:ListItem Value="fixed">Fixed amount (RM)</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="field-group">
                    <asp:Label ID="lblDiscountValue" runat="server" CssClass="field-label" AssociatedControlID="txtDiscountValue">Discount value <span class="req">*</span></asp:Label>
                    <asp:TextBox ID="txtDiscountValue" runat="server" TextMode="Number" CssClass="field-input" />
                    <div class="field-hint">Use percentages up to 100, or a fixed Ringgit amount.</div>
                </div>
            </div>
            <div class="field-row fr-2">
                <div class="field-group">
                    <asp:Label ID="lblMaximumDiscount" runat="server" CssClass="field-label" AssociatedControlID="txtMaximumDiscount">Maximum discount cap</asp:Label>
                    <asp:TextBox ID="txtMaximumDiscount" runat="server" TextMode="Number" CssClass="field-input" />
                    <div class="field-hint">Leave blank for uncapped percentage vouchers. Fixed vouchers must keep this empty.</div>
                </div>
                <div class="field-group">
                    <asp:Label ID="lblMinimumPurchase" runat="server" CssClass="field-label" AssociatedControlID="txtMinimumPurchase">Minimum purchase (RM)</asp:Label>
                    <asp:TextBox ID="txtMinimumPurchase" runat="server" TextMode="Number" Text="0" CssClass="field-input" />
                    <div class="field-hint">Set 0 when no minimum spend is required.</div>
                </div>
            </div>
        </div>

        <div class="form-section">
            <div class="section-label">Eligible Categories</div>
            <div class="field-group">
                <div class="field-toggle">
                    <asp:CheckBox ID="chkAllCategories" runat="server" Checked="true" />
                    <asp:Label ID="lblAllCategories" runat="server" AssociatedControlID="chkAllCategories">All categories</asp:Label>
                </div>
                <div class="field-hint">Uncheck this to target only specific product categories.</div>
                <div class="category-panel">
                    <asp:Label ID="lblCategories" runat="server" CssClass="field-label" AssociatedControlID="cblCategories">Eligible categories</asp:Label>
                    <asp:CheckBoxList ID="cblCategories" runat="server" RepeatLayout="Flow" CssClass="category-grid" />
                </div>
            </div>
        </div>

        <div class="form-section">
            <div class="section-label">Validity &amp; Usage Limits</div>
            <div class="field-row fr-2">
                <div class="field-group">
                    <asp:Label ID="lblValidFrom" runat="server" CssClass="field-label" AssociatedControlID="txtValidFrom">Valid from <span class="req">*</span></asp:Label>
                    <asp:TextBox ID="txtValidFrom" runat="server" TextMode="DateTimeLocal" CssClass="field-input" />
                    <div class="field-hint">Uses the application local timezone.</div>
                </div>
                <div class="field-group">
                    <asp:Label ID="lblExpiresAt" runat="server" CssClass="field-label" AssociatedControlID="txtExpiresAt">Expires at <span class="req">*</span></asp:Label>
                    <asp:TextBox ID="txtExpiresAt" runat="server" TextMode="DateTimeLocal" CssClass="field-input" />
                    <div class="field-hint">Must be later than the valid-from date.</div>
                </div>
            </div>
            <div class="field-row fr-2">
                <div class="field-group">
                    <asp:Label ID="lblTotalLimit" runat="server" CssClass="field-label" AssociatedControlID="txtTotalLimit">Total redemption limit</asp:Label>
                    <asp:TextBox ID="txtTotalLimit" runat="server" TextMode="Number" CssClass="field-input" />
                    <div class="field-hint">Leave blank for no overall cap.</div>
                </div>
                <div class="field-group">
                    <asp:Label ID="lblPerUserLimit" runat="server" CssClass="field-label" AssociatedControlID="txtPerUserLimit">Per-customer limit <span class="req">*</span></asp:Label>
                    <asp:TextBox ID="txtPerUserLimit" runat="server" TextMode="Number" Text="1" CssClass="field-input" />
                    <div class="field-hint">At least 1 redemption per customer.</div>
                </div>
            </div>
        </div>

        <div class="form-section">
            <div class="section-label">Terms &amp; Conditions</div>
            <div class="field-group">
                <asp:Label ID="lblTerms" runat="server" CssClass="field-label" AssociatedControlID="txtTerms">Plain-text terms <span class="req">*</span></asp:Label>
                <asp:TextBox ID="txtTerms" runat="server" TextMode="MultiLine" Rows="10" MaxLength="8000" CssClass="field-textarea" />
                <div class="field-hint">Plain text only. Line breaks are preserved for customers.</div>
            </div>
        </div>

        <div class="form-actions" data-voucher-actions>
            <div class="form-actions__main">
                <asp:Button ID="btnSave" runat="server" Text="Create voucher" CssClass="btn-save" OnClick="btnSave_Click" />
                <a href="onyx_admin_promos.aspx" class="btn-cancel">Cancel</a>
            </div>
            <div class="required-note">Required fields marked *</div>
        </div>
    </div>
</asp:Content>
