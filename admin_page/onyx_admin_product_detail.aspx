<%@ Page Title="Product Detail" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_product_detail.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_product_detail" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .back-link {
        display: inline-flex; align-items: center; gap: 6px;
        font-size: 13px; color: rgba(255,255,255,0.38);
        text-decoration: none; margin-bottom: 28px; transition: color 0.15s;
    }
    .back-link:hover { color: rgba(255,255,255,0.75); text-decoration: none; }
    .back-link i { width: 14px; height: 14px; }

    /* ── Two-column layout ───────────────────────── */
    .detail-layout {
        display: grid;
        grid-template-columns: 300px 1fr;
        gap: 28px;
        align-items: start;
    }

    /* ── Image panel ─────────────────────────────── */
    .image-panel {
        background: #18181c;
        border: 1px solid rgba(255,255,255,0.06);
        border-radius: 16px; overflow: hidden;
        aspect-ratio: 1 / 1;
        display: flex; align-items: center; justify-content: center;
        position: sticky; top: 24px;
    }
    .image-panel img { width: 100%; height: 100%; object-fit: cover; }
    .image-placeholder { font-size: 96px; font-weight: 700; color: rgba(255,255,255,0.06); user-select: none; }

    /* ── Info panel ──────────────────────────────── */
    .info-panel { display: flex; flex-direction: column; gap: 0; }

    .detail-category {
        font-size: 11px; font-weight: 600; letter-spacing: 0.12em;
        text-transform: uppercase; color: rgba(255,255,255,0.35); margin-bottom: 10px;
    }
    .detail-name  { font-size: 28px; font-weight: 700; color: #fff; line-height: 1.2; margin-bottom: 6px; }
    .detail-brand { font-size: 14px; color: rgba(255,255,255,0.38); margin-bottom: 24px; }

    /* ── Stat row ────────────────────────────────── */
    .stat-row { display: flex; gap: 14px; margin-bottom: 24px; flex-wrap: wrap; }
    .stat-box {
        background: #18181c; border: 1px solid rgba(255,255,255,0.06);
        border-radius: 12px; padding: 14px 20px; min-width: 110px;
    }
    .stat-label {
        font-size: 10px; font-weight: 600; letter-spacing: 0.1em;
        text-transform: uppercase; color: rgba(255,255,255,0.3); margin-bottom: 6px;
    }
    .stat-value { font-size: 20px; font-weight: 700; color: #fff; }
    .stat-value.stock-ok  { color: rgba(255,255,255,0.85); }
    .stat-value.stock-low { color: #fbbf24; }
    .stat-value.stock-out { color: #ff4444; }

    .divider { border: none; border-top: 1px solid rgba(255,255,255,0.05); margin: 20px 0; }

    .desc-label {
        font-size: 11px; font-weight: 600; letter-spacing: 0.1em;
        text-transform: uppercase; color: rgba(255,255,255,0.3); margin-bottom: 10px;
    }
    .desc-text  { font-size: 14px; line-height: 1.7; color: rgba(255,255,255,0.6); }
    .desc-empty { font-size: 13px; color: rgba(255,255,255,0.2); font-style: italic; }

    .meta-row { display: flex; gap: 24px; margin-top: 20px; flex-wrap: wrap; }
    .meta-item { font-size: 12px; color: rgba(255,255,255,0.28); }
    .meta-item strong { color: rgba(255,255,255,0.5); }

    .actions { display: flex; gap: 10px; margin-top: 28px; }
    .btn-edit {
        display: inline-flex; align-items: center; gap: 7px;
        padding: 10px 22px; background: #fff; color: #000;
        border-radius: 8px; font-size: 13px; font-weight: 600;
        text-decoration: none; transition: opacity 0.15s;
    }
    .btn-edit:hover { opacity: 0.85; color: #000; text-decoration: none; }
    .btn-edit i { width: 15px; height: 15px; }

    /* ── Variants section ────────────────────────── */
    .variants-section {
        margin-top: 36px;
        padding-top: 28px;
        border-top: 1px solid rgba(255,255,255,0.05);
    }

    .section-header {
        display: flex; align-items: center;
        margin-bottom: 18px;
    }

    .section-title {
        font-size: 11px; font-weight: 600; letter-spacing: 0.1em;
        text-transform: uppercase; color: rgba(255,255,255,0.28);
    }

    /* Variant alerts */
    .var-alert {
        font-size: 12px; padding: 9px 14px;
        border-radius: 6px; margin-bottom: 16px;
        display: flex; align-items: center; gap: 8px;
    }
    .var-alert-success {
        background: rgba(255,255,255,0.04);
        border-left: 3px solid rgba(255,255,255,0.22);
        color: rgba(255,255,255,0.65);
    }
    .var-alert-error {
        background: rgba(255,68,68,0.08);
        border-left: 3px solid rgba(255,68,68,0.45);
        color: rgba(255,100,100,0.90);
    }

    /* Variants table */
    .variants-table { width: 100%; border-collapse: collapse; }

    .variants-table th {
        text-align: left;
        font-size: 10px; font-weight: 600; letter-spacing: 0.08em;
        text-transform: uppercase; color: rgba(255,255,255,0.25);
        padding-bottom: 10px;
        border-bottom: 1px solid rgba(255,255,255,0.06);
    }
    .variants-table td {
        padding: 12px 0 12px;
        border-bottom: 1px solid rgba(255,255,255,0.04);
        vertical-align: middle;
    }
    .variants-table tr:last-child td { border-bottom: none; }
    .variants-table tbody tr:hover td { background: rgba(255,255,255,0.015); }

    /* Type badge */
    .var-type-badge {
        display: inline-block;
        font-size: 10px; font-weight: 600;
        letter-spacing: 0.05em; text-transform: uppercase;
        padding: 2px 8px; border-radius: 3px;
        background: rgba(255,255,255,0.07);
        color: rgba(255,255,255,0.42);
    }

    .var-value {
        font-size: 13px; font-weight: 500;
        color: rgba(255,255,255,0.82);
    }

    /* Inline inputs */
    .var-input {
        background: transparent; border: none;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        color: #fff; font-size: 13px;
        font-family: 'Inter', sans-serif;
        padding: 4px 0; width: 90px; outline: none;
        transition: border-color 0.15s;
    }
    .var-input:focus { border-bottom-color: rgba(255,255,255,0.40); }

    /* Stock indicator in table */
    .stock-ok-sm  { color: rgba(255,255,255,0.80); font-size: 13px; }
    .stock-low-sm { color: #fbbf24; font-size: 13px; }
    .stock-out-sm { color: #ff4444; font-size: 13px; }

    /* Row action buttons */
    .btn-var-save {
        background: rgba(255,255,255,0.88); color: #0d0d0f;
        border: none; border-radius: 5px; font-size: 11px; font-weight: 600;
        padding: 5px 14px; cursor: pointer; font-family: 'Inter', sans-serif;
        transition: opacity 0.12s; margin-right: 6px;
    }
    .btn-var-save:hover { opacity: 0.82; }

    .btn-var-delete {
        background: transparent;
        color: rgba(255,80,80,0.70);
        border: 1px solid rgba(255,80,80,0.25); border-radius: 5px;
        font-size: 11px; font-weight: 500; padding: 5px 12px;
        cursor: pointer; font-family: 'Inter', sans-serif;
        transition: border-color 0.15s, color 0.15s;
    }
    .btn-var-delete:hover { border-color: rgba(255,80,80,0.55); color: rgba(255,80,80,0.90); }

    /* Empty state */
    .variants-empty {
        text-align: center; padding: 28px 0;
        font-size: 13px; color: rgba(255,255,255,0.22);
    }

    /* Add variant form */
    .add-variant-wrap {
        margin-top: 20px;
        padding-top: 18px;
        border-top: 1px solid rgba(255,255,255,0.05);
    }

    .add-variant-grid {
        display: grid;
        grid-template-columns: 1fr 1fr 130px 110px auto;
        gap: 14px;
        align-items: end;
    }

    .add-field-label {
        font-size: 10px; font-weight: 600; letter-spacing: 0.07em;
        text-transform: uppercase; color: rgba(255,255,255,0.25);
        display: block; margin-bottom: 6px;
    }

    .add-input {
        width: 100%; background: transparent; border: none;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        color: #fff; font-size: 13px; font-family: 'Inter', sans-serif;
        padding: 6px 0; outline: none; transition: border-color 0.15s;
    }
    .add-input:focus { border-bottom-color: rgba(255,255,255,0.40); }
    .add-input::placeholder { color: rgba(255,255,255,0.18); }

    .btn-add-variant {
        background: rgba(255,255,255,0.07);
        color: rgba(255,255,255,0.60);
        border: 1px solid rgba(255,255,255,0.10); border-radius: 7px;
        font-size: 12px; font-weight: 600;
        padding: 9px 18px; cursor: pointer;
        font-family: 'Inter', sans-serif; white-space: nowrap;
        transition: background 0.15s, color 0.15s;
    }
    .btn-add-variant:hover { background: rgba(255,255,255,0.12); color: #fff; }

    /* ── Not found ───────────────────────────────── */
    .not-found { text-align: center; padding: 100px 20px; color: rgba(255,255,255,0.25); }
    .not-found i { width: 48px; height: 48px; margin-bottom: 14px; opacity: 0.2; }

    /* ── Light mode ──────────────────────────────── */
    html[data-theme="light"] .image-panel { background: #f5f5f7; border-color: rgba(0,0,0,0.07); }
    html[data-theme="light"] .image-placeholder { color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .detail-category { color: rgba(0,0,0,0.35); }
    html[data-theme="light"] .detail-name  { color: #0d0d0f; }
    html[data-theme="light"] .detail-brand { color: rgba(0,0,0,0.38); }
    html[data-theme="light"] .stat-box { background: #fff; border-color: rgba(0,0,0,0.07); }
    html[data-theme="light"] .stat-label { color: rgba(0,0,0,0.28); }
    html[data-theme="light"] .stat-value { color: #0d0d0f; }
    html[data-theme="light"] .divider { border-top-color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .desc-label { color: rgba(0,0,0,0.28); }
    html[data-theme="light"] .desc-text  { color: rgba(0,0,0,0.60); }
    html[data-theme="light"] .desc-empty { color: rgba(0,0,0,0.22); }
    html[data-theme="light"] .meta-item  { color: rgba(0,0,0,0.28); }
    html[data-theme="light"] .meta-item strong { color: rgba(0,0,0,0.50); }
    html[data-theme="light"] .btn-edit { background: #0d0d0f; color: #fff; }
    html[data-theme="light"] .btn-edit:hover { color: #fff; }
    html[data-theme="light"] .variants-section { border-top-color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .section-title { color: rgba(0,0,0,0.28); }
    html[data-theme="light"] .var-type-badge { background: rgba(0,0,0,0.06); color: rgba(0,0,0,0.42); }
    html[data-theme="light"] .var-value { color: rgba(0,0,0,0.80); }
    html[data-theme="light"] .variants-table th { color: rgba(0,0,0,0.25); border-bottom-color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .variants-table td { border-bottom-color: rgba(0,0,0,0.04); }
    html[data-theme="light"] .variants-table tbody tr:hover td { background: rgba(0,0,0,0.02); }
    html[data-theme="light"] .var-input { color: #0d0d0f; border-bottom-color: rgba(0,0,0,0.10); }
    html[data-theme="light"] .var-input:focus { border-bottom-color: rgba(0,0,0,0.38); }
    html[data-theme="light"] .stock-ok-sm { color: rgba(0,0,0,0.75); }
    html[data-theme="light"] .btn-var-save { background: #0d0d0f; color: #fff; }
    html[data-theme="light"] .add-variant-wrap { border-top-color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .add-field-label { color: rgba(0,0,0,0.25); }
    html[data-theme="light"] .add-input { color: #0d0d0f; border-bottom-color: rgba(0,0,0,0.10); }
    html[data-theme="light"] .add-input:focus { border-bottom-color: rgba(0,0,0,0.38); }
    html[data-theme="light"] .add-input::placeholder { color: rgba(0,0,0,0.18); }
    html[data-theme="light"] .btn-add-variant { background: rgba(0,0,0,0.05); color: rgba(0,0,0,0.55); border-color: rgba(0,0,0,0.10); }
    html[data-theme="light"] .btn-add-variant:hover { background: rgba(0,0,0,0.09); color: #0d0d0f; }
    html[data-theme="light"] .variants-empty { color: rgba(0,0,0,0.22); }
    html[data-theme="light"] .var-alert-success { background: rgba(0,0,0,0.03); border-left-color: rgba(0,0,0,0.20); color: rgba(0,0,0,0.55); }
    html[data-theme="light"] .var-alert-error   { background: rgba(255,68,68,0.05); color: rgba(180,0,0,0.75); }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <a href="onyx_admin_products.aspx" class="back-link">
        <i data-lucide="arrow-left"></i> Back to Products
    </a>

    <%-- Not found --%>
    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="not-found">
        <div><i data-lucide="package-x"></i></div>
        <div>Product not found.</div>
    </asp:Panel>

    <%-- Detail panel --%>
    <asp:Panel ID="pnlDetail" runat="server">

        <%-- ── Main product info ────────────────────── --%>
        <div class="detail-layout">

            <div class="image-panel">
                <asp:Image ID="imgProduct" runat="server" Visible="false" />
                <asp:Label ID="lblPlaceholder" runat="server" CssClass="image-placeholder" />
            </div>

            <div class="info-panel">
                <div class="detail-category"><asp:Label ID="lblCategory" runat="server" /></div>
                <div class="detail-name"><asp:Label ID="lblName" runat="server" /></div>
                <div class="detail-brand"><asp:Label ID="lblBrand" runat="server" /></div>

                <div class="stat-row">
                    <div class="stat-box">
                        <div class="stat-label">Base Price</div>
                        <div class="stat-value"><asp:Label ID="lblPrice" runat="server" /></div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-label">Total Stock</div>
                        <asp:Label ID="lblStock" runat="server" />
                    </div>
                </div>

                <hr class="divider" />

                <div class="desc-label">Description</div>
                <asp:Label ID="lblDescription" runat="server" />

                <div class="meta-row">
                    <div class="meta-item">Added <strong><asp:Label ID="lblCreatedAt" runat="server" /></strong></div>
                    <div class="meta-item">ID <strong>#<asp:Label ID="lblId" runat="server" /></strong></div>
                </div>

                <div class="actions">
                    <asp:HyperLink ID="lnkEdit" runat="server" CssClass="btn-edit">
                        <i data-lucide="pencil"></i> Edit Product
                    </asp:HyperLink>
                </div>
            </div>

        </div>

        <%-- ── Variants section ─────────────────────── --%>
        <div class="variants-section">

            <div class="section-header">
                <span class="section-title">Product Variants</span>
            </div>

            <%-- Alert --%>
            <asp:Panel ID="pnlVarMsg" runat="server" Visible="false">
                <div id="varMsgBox" runat="server" class="var-alert"></div>
            </asp:Panel>

            <%-- Empty state --%>
            <asp:Panel ID="pnlNoVariants" runat="server" Visible="false">
                <div class="variants-empty">No variants yet &mdash; add one below.</div>
            </asp:Panel>

            <%-- Variants repeater --%>
            <asp:Repeater ID="VariantsRepeater" runat="server"
                OnItemCommand="VariantsRepeater_ItemCommand">
                <HeaderTemplate>
                    <table class="variants-table">
                        <thead>
                            <tr>
                                <th style="width:120px">Type</th>
                                <th>Value</th>
                                <th style="width:140px">Price (RM)</th>
                                <th style="width:120px">Stock</th>
                                <th style="width:170px"></th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><span class="var-type-badge"><%# Server.HtmlEncode(Eval("VariantType").ToString()) %></span></td>
                        <td class="var-value"><%# Server.HtmlEncode(Eval("VariantValue").ToString()) %></td>
                        <td>
                            <asp:TextBox ID="txtRowPrice" runat="server"
                                Text='<%# string.Format("{0:N2}", Eval("VariantPrice")) %>'
                                CssClass="var-input"
                                data-gramm="false" data-gramm_editor="false" />
                        </td>
                        <td>
                            <asp:TextBox ID="txtRowStock" runat="server"
                                Text='<%# Eval("StockQty") %>'
                                CssClass="var-input"
                                data-gramm="false" data-gramm_editor="false" />
                        </td>
                        <td>
                            <asp:Button ID="btnSaveVariant" runat="server"
                                CommandName="SaveVariant"
                                CommandArgument='<%# Eval("ProductVariantId") %>'
                                Text="Save" CssClass="btn-var-save" CausesValidation="false" />
                            <asp:Button ID="btnDeleteVariant" runat="server"
                                CommandName="DeleteVariant"
                                CommandArgument='<%# Eval("ProductVariantId") %>'
                                Text="Delete" CssClass="btn-var-delete" CausesValidation="false"
                                OnClientClick="return confirm('Delete this variant?');" />
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>

            <%-- Add variant form --%>
            <div class="add-variant-wrap">
                <div class="add-variant-grid">
                    <div>
                        <label class="add-field-label">Type</label>
                        <asp:TextBox ID="txtVType" runat="server" CssClass="add-input"
                            placeholder="e.g. Color"
                            data-gramm="false" data-gramm_editor="false" />
                    </div>
                    <div>
                        <label class="add-field-label">Value</label>
                        <asp:TextBox ID="txtVValue" runat="server" CssClass="add-input"
                            placeholder="e.g. Black"
                            data-gramm="false" data-gramm_editor="false" />
                    </div>
                    <div>
                        <label class="add-field-label">Price (RM)</label>
                        <asp:TextBox ID="txtVPrice" runat="server" CssClass="add-input"
                            placeholder="0.00"
                            data-gramm="false" data-gramm_editor="false" />
                    </div>
                    <div>
                        <label class="add-field-label">Stock</label>
                        <asp:TextBox ID="txtVStock" runat="server" CssClass="add-input"
                            placeholder="0"
                            data-gramm="false" data-gramm_editor="false" />
                    </div>
                    <div>
                        <asp:Button ID="btnAddVariant" runat="server" Text="+ Add Variant"
                            CssClass="btn-add-variant" OnClick="btnAddVariant_Click"
                            CausesValidation="false" />
                    </div>
                </div>
            </div>

        </div>

    </asp:Panel>

</asp:Content>
