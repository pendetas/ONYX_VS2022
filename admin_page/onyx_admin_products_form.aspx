<%@ Page Title="Product Form" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_products_form.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_products_form"
    MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* ── Page header ─────────────────────────────── */
    .form-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 44px;
    }
    .page-title    { font-size: 22px; font-weight: 600; color: #fff; letter-spacing: -0.02em; margin: 0; }
    .page-subtitle { font-size: 12px; color: rgba(255,255,255,0.28); margin-top: 5px; font-weight: 400; letter-spacing: 0.02em; }

    .back-link {
        display: inline-flex; align-items: center; gap: 6px; font-size: 13px;
        color: rgba(255,255,255,0.28); text-decoration: none; transition: color 0.15s;
        flex-shrink: 0; margin-top: 4px;
    }
    .back-link:hover { color: rgba(255,255,255,0.68); text-decoration: none; }
    .back-link i { width: 14px; height: 14px; }

    /* ── Alert ───────────────────────────────────── */
    .alert-panel { padding: 12px 16px; margin-bottom: 32px; font-size: 13px; line-height: 1.5; }
    .alert-success-dark { border-left: 2px solid rgba(255,255,255,0.30); background: rgba(255,255,255,0.03); color: rgba(255,255,255,0.68); padding-left: 14px; }
    .alert-error-dark   { border-left: 2px solid rgba(255,68,68,0.55);   background: rgba(255,68,68,0.05);    color: #ff5555;                padding-left: 14px; }

    /* ── Form body ───────────────────────────────── */
    .form-body { max-width: 700px; }

    /* ── Section ─────────────────────────────────── */
    .form-section { margin-bottom: 40px; }
    .section-label {
        font-size: 10px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase;
        color: rgba(255,255,255,0.18); margin-bottom: 22px;
        padding-bottom: 10px; border-bottom: 1px solid rgba(255,255,255,0.05);
    }

    /* ── Field rows ──────────────────────────────── */
    .field-row { display: grid; gap: 28px 36px; margin-bottom: 26px; }
    .field-row:last-child { margin-bottom: 0; }
    .fr-2 { grid-template-columns: 1fr 1fr; }
    .fr-1 { grid-template-columns: 1fr; }
    .field-group { display: flex; flex-direction: column; }

    .field-label {
        font-size: 10px; font-weight: 600; letter-spacing: 0.10em; text-transform: uppercase;
        color: rgba(255,255,255,0.26); margin-bottom: 10px;
    }
    .req { color: rgba(255,68,68,0.75); margin-left: 3px; }

    /* ── Underline inputs ────────────────────────── */
    .field-input, .field-select, .field-textarea {
        background: transparent; border: none;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        color: #fff; font-size: 14px; font-weight: 400;
        padding: 8px 0; width: 100%; outline: none;
        transition: border-color 0.18s; font-family: inherit;
    }
    .field-input::placeholder, .field-textarea::placeholder { color: rgba(255,255,255,0.14); }
    .field-input:focus, .field-select:focus, .field-textarea:focus { border-bottom-color: rgba(255,255,255,0.40); }
    .field-input:disabled { opacity: 0.40; cursor: not-allowed; }

    .field-select {
        appearance: none; -webkit-appearance: none; cursor: pointer;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='rgba(255,255,255,0.25)' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
        background-repeat: no-repeat; background-position: right 2px center; padding-right: 22px;
        color: rgba(255,255,255,0.85);
    }
    .field-select option { background-color: #111113; color: #fff; }

    .field-textarea { resize: vertical; min-height: 96px; line-height: 1.65; border-bottom: 1px solid rgba(255,255,255,0.10); }

    .field-hint { font-size: 11px; color: rgba(255,255,255,0.16); margin-top: 7px; line-height: 1.5; }
    .field-hint.managed { color: rgba(255,255,255,0.25); font-style: italic; }

    .category-wrap { max-width: 260px; }

    /* ── Image preview ───────────────────────────── */
    .image-preview-wrap {
        margin-top: 16px; height: 128px; border: 1px dashed rgba(255,255,255,0.07);
        border-radius: 4px; display: flex; align-items: center; justify-content: center; overflow: hidden;
    }
    #imgPreview { width: 100%; height: 100%; object-fit: contain; display: none; }
    .preview-empty { display: flex; flex-direction: column; align-items: center; gap: 7px; color: rgba(255,255,255,0.10); font-size: 10px; letter-spacing: 0.08em; text-transform: uppercase; }
    .preview-empty i { width: 18px; height: 18px; }

    /* ── Colors section ──────────────────────────── */
    .color-hint {
        font-size: 12px; color: rgba(255,255,255,0.22); margin-bottom: 18px; line-height: 1.6;
    }

    /* Color chip swatches */
    .color-swatches { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 24px; }

    .swatch-chip {
        display: inline-flex; align-items: center; gap: 7px;
        padding: 6px 14px 6px 8px; border-radius: 20px;
        border: 1px solid rgba(255,255,255,0.08);
        background: transparent; color: rgba(255,255,255,0.42);
        font-size: 12px; font-weight: 500; font-family: 'Inter', sans-serif;
        cursor: pointer; text-decoration: none;
        transition: border-color 0.15s, color 0.15s, background 0.15s;
        white-space: nowrap;
    }
    .swatch-chip:hover { border-color: rgba(255,255,255,0.22); color: rgba(255,255,255,0.75); }

    .swatch-dot {
        width: 11px; height: 11px; border-radius: 50%; flex-shrink: 0;
        border: 1px solid rgba(255,255,255,0.12);
    }

    .swatch-chip.active {
        border-color: rgba(255,255,255,0.30);
        background: rgba(255,255,255,0.06);
        color: rgba(255,255,255,0.88);
    }
    .swatch-chip.active:hover { background: rgba(255,255,255,0.09); }

    .swatch-stock {
        font-size: 10px; color: rgba(255,255,255,0.35);
        background: rgba(255,255,255,0.08); padding: 1px 6px; border-radius: 10px;
        margin-left: 2px;
    }

    /* Color variants table */
    .cv-table { width: 100%; border-collapse: collapse; }
    .cv-table th {
        text-align: left; font-size: 10px; font-weight: 600; letter-spacing: 0.08em;
        text-transform: uppercase; color: rgba(255,255,255,0.22);
        padding-bottom: 10px; border-bottom: 1px solid rgba(255,255,255,0.06);
    }
    .cv-table td { padding: 11px 0; border-bottom: 1px solid rgba(255,255,255,0.04); vertical-align: middle; }
    .cv-table tr:last-child td { border-bottom: none; }
    .cv-table tbody tr:hover td { background: rgba(255,255,255,0.015); }

    .cv-color-cell { display: flex; align-items: center; gap: 9px; }
    .cv-dot { width: 12px; height: 12px; border-radius: 50%; border: 1px solid rgba(255,255,255,0.15); flex-shrink: 0; }
    .cv-name { font-size: 13px; font-weight: 500; color: rgba(255,255,255,0.80); }

    .cv-input {
        background: transparent; border: none;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        color: #fff; font-size: 13px; font-family: 'Inter', sans-serif;
        padding: 4px 0; width: 90px; outline: none; transition: border-color 0.15s;
    }
    .cv-input:focus { border-bottom-color: rgba(255,255,255,0.40); }

    .cv-save-btn {
        background: rgba(255,255,255,0.88); color: #0d0d0f;
        border: none; border-radius: 5px; font-size: 11px; font-weight: 600;
        padding: 5px 14px; cursor: pointer; font-family: 'Inter', sans-serif; transition: opacity 0.12s;
    }
    .cv-save-btn:hover { opacity: 0.80; }

    /* ── Action bar ──────────────────────────────── */
    .form-actions {
        display: flex; align-items: center; gap: 18px;
        padding-top: 32px; border-top: 1px solid rgba(255,255,255,0.05); margin-top: 8px;
    }
    .btn-save {
        display: inline-flex; align-items: center; gap: 6px; padding: 9px 22px;
        background: #ffffff; color: #000; border: none; border-radius: 5px;
        font-size: 11px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase;
        cursor: pointer; transition: background 0.15s; font-family: inherit;
    }
    .btn-save:hover { background: rgba(255,255,255,0.82); }
    .btn-cancel { font-size: 12px; color: rgba(255,255,255,0.26); text-decoration: none; letter-spacing: 0.04em; transition: color 0.15s; }
    .btn-cancel:hover { color: rgba(255,255,255,0.62); text-decoration: none; }
    .required-note { margin-left: auto; font-size: 11px; color: rgba(255,255,255,0.16); letter-spacing: 0.04em; }

    /* ── Light mode ──────────────────────────────── */
    html[data-theme="light"] .page-title    { color: #0d0d0f; }
    html[data-theme="light"] .page-subtitle { color: rgba(0,0,0,0.35); }
    html[data-theme="light"] .section-label { color: rgba(0,0,0,0.22); border-bottom-color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .field-label   { color: rgba(0,0,0,0.30); }
    html[data-theme="light"] .field-input, html[data-theme="light"] .field-select, html[data-theme="light"] .field-textarea { color: #0d0d0f; border-bottom-color: rgba(0,0,0,0.10); }
    html[data-theme="light"] .field-input:focus, html[data-theme="light"] .field-select:focus, html[data-theme="light"] .field-textarea:focus { border-bottom-color: rgba(0,0,0,0.38); }
    html[data-theme="light"] .field-input::placeholder, html[data-theme="light"] .field-textarea::placeholder { color: rgba(0,0,0,0.18); }
    html[data-theme="light"] .field-hint   { color: rgba(0,0,0,0.22); }
    html[data-theme="light"] .field-select { background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='rgba(0,0,0,0.30)' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E"); color: rgba(0,0,0,0.75); }
    html[data-theme="light"] .field-select option { background: #fff; color: #0d0d0f; }
    html[data-theme="light"] .image-preview-wrap { border-color: rgba(0,0,0,0.08); }
    html[data-theme="light"] .preview-empty { color: rgba(0,0,0,0.12); }
    html[data-theme="light"] .form-actions { border-top-color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .btn-save     { background: #0d0d0f; color: #fff; }
    html[data-theme="light"] .btn-save:hover { background: #2a2a2a; }
    html[data-theme="light"] .btn-cancel   { color: rgba(0,0,0,0.28); }
    html[data-theme="light"] .btn-cancel:hover { color: rgba(0,0,0,0.60); }
    html[data-theme="light"] .required-note { color: rgba(0,0,0,0.20); }
    html[data-theme="light"] .color-hint   { color: rgba(0,0,0,0.30); }
    html[data-theme="light"] .swatch-chip  { border-color: rgba(0,0,0,0.10); color: rgba(0,0,0,0.45); }
    html[data-theme="light"] .swatch-chip:hover { border-color: rgba(0,0,0,0.25); color: rgba(0,0,0,0.75); }
    html[data-theme="light"] .swatch-chip.active { border-color: rgba(0,0,0,0.30); background: rgba(0,0,0,0.05); color: rgba(0,0,0,0.80); }
    html[data-theme="light"] .swatch-dot   { border-color: rgba(0,0,0,0.12); }
    html[data-theme="light"] .swatch-stock { color: rgba(0,0,0,0.38); background: rgba(0,0,0,0.06); }
    html[data-theme="light"] .cv-table th  { color: rgba(0,0,0,0.22); border-bottom-color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .cv-table td  { border-bottom-color: rgba(0,0,0,0.04); }
    html[data-theme="light"] .cv-name  { color: rgba(0,0,0,0.75); }
    html[data-theme="light"] .cv-dot   { border-color: rgba(0,0,0,0.12); }
    html[data-theme="light"] .cv-input { color: #0d0d0f; border-bottom-color: rgba(0,0,0,0.10); }
    html[data-theme="light"] .cv-input:focus { border-bottom-color: rgba(0,0,0,0.38); }
    html[data-theme="light"] .cv-save-btn { background: #0d0d0f; color: #fff; }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="form-header">
        <div>
            <h1 class="page-title"><asp:Literal ID="litPageTitle" runat="server" Text="Add New Product" /></h1>
            <p class="page-subtitle"><asp:Literal ID="litPageSubtitle" runat="server" Text="Fill in the details below to add a new product." /></p>
        </div>
        <asp:HyperLink ID="lnkBack" runat="server" CssClass="back-link" NavigateUrl="onyx_admin_products.aspx">
            <i data-lucide="arrow-left"></i> Back
        </asp:HyperLink>
    </div>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <asp:Literal ID="litAlertMessage" runat="server" />
    </asp:Panel>

    <div class="form-body">

        <%-- Product Info --%>
        <div class="form-section">
            <div class="section-label">Product Info</div>
            <div class="field-row fr-2">
                <div class="field-group">
                    <label class="field-label">Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtName" runat="server" CssClass="field-input" placeholder="e.g. Viper V2 Pro" MaxLength="100" />
                    <div class="field-hint">Max 100 characters.</div>
                </div>
                <div class="field-group">
                    <label class="field-label">Brand</label>
                    <asp:TextBox ID="txtBrand" runat="server" CssClass="field-input" placeholder="e.g. Razer" MaxLength="50" />
                </div>
            </div>
            <div class="field-row fr-1">
                <div class="field-group category-wrap">
                    <label class="field-label">Category <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="field-select">
                        <asp:ListItem Value=""         Text="Select category" />
                        <asp:ListItem Value="Mouse"    Text="Mouse" />
                        <asp:ListItem Value="Keyboard" Text="Keyboard" />
                        <asp:ListItem Value="Headset"  Text="Headset" />
                        <asp:ListItem Value="Monitor"  Text="Monitor" />
                        <asp:ListItem Value="Chair"    Text="Chair" />
                    </asp:DropDownList>
                </div>
            </div>
        </div>

        <%-- Pricing & Inventory --%>
        <div class="form-section">
            <div class="section-label">Pricing &amp; Inventory</div>
            <div class="field-row fr-2">
                <div class="field-group">
                    <label class="field-label">Price (RM) <span class="req">*</span></label>
                    <asp:TextBox ID="txtPrice" runat="server" CssClass="field-input" placeholder="0.00" TextMode="Number" />
                    <div class="field-hint">Malaysian Ringgit (MYR).</div>
                </div>
                <div class="field-group">
                    <label class="field-label">Stock Qty <span class="req">*</span></label>
                    <asp:TextBox ID="txtStock" runat="server" CssClass="field-input" placeholder="0" TextMode="Number" />
                    <asp:Label ID="lblStockHint" runat="server" CssClass="field-hint" Text="Set 0 to mark as out of stock." />
                </div>
            </div>
        </div>

        <%-- Colors — edit mode only (wrapped in UpdatePanel so chip clicks don't scroll to top) --%>
        <asp:UpdatePanel ID="upColors" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
        <ContentTemplate>
        <asp:Panel ID="pnlColors" runat="server" Visible="false">
            <div class="form-section">
                <div class="section-label">Colors</div>
                <p class="color-hint">
                    Click a color to add it as a variant. Click an active color to remove it.<br />
                    Set the stock per color in the table below.
                </p>

                <%-- Color chip row --%>
                <div class="color-swatches">
                    <asp:Repeater ID="ColorSwatchRepeater" runat="server"
                        OnItemCommand="ColorSwatchRepeater_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton runat="server"
                                CommandName="ToggleColor"
                                CommandArgument='<%# Eval("Name") %>'
                                CssClass='<%# "swatch-chip " + ((bool)Eval("IsActive") ? "active" : "") %>'
                                CausesValidation="false">
                                <span class="swatch-dot" style='<%# "background:" + Eval("Hex") %>'></span>
                                <%# Eval("Name") %>
                                <%# (bool)Eval("IsActive") ? "<span class=\"swatch-stock\">" + Eval("StockQty") + "</span>" : "" %>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <%-- Active color variants — stock editing --%>
                <asp:Panel ID="pnlColorVariants" runat="server" Visible="false">
                    <asp:Repeater ID="ColorVariantsRepeater" runat="server"
                        OnItemCommand="ColorVariantsRepeater_ItemCommand">
                        <HeaderTemplate>
                            <table class="cv-table">
                                <thead><tr>
                                    <th>Color</th>
                                    <th style="width:130px">Price (RM)</th>
                                    <th style="width:110px">Stock</th>
                                    <th style="width:80px"></th>
                                </tr></thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div class="cv-color-cell">
                                        <span class="cv-dot" style='<%# "background:" + GetColorHex(Eval("VariantValue").ToString()) %>'></span>
                                        <span class="cv-name"><%# Server.HtmlEncode(Eval("VariantValue").ToString()) %></span>
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCvPrice" runat="server"
                                        Text='<%# string.Format("{0:N2}", Eval("VariantPrice")) %>'
                                        CssClass="cv-input" data-gramm="false" data-gramm_editor="false" />
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCvStock" runat="server"
                                        Text='<%# Eval("StockQty") %>'
                                        CssClass="cv-input" data-gramm="false" data-gramm_editor="false" />
                                </td>
                                <td>
                                    <asp:Button ID="btnSaveCv" runat="server"
                                        CommandName="SaveColor"
                                        CommandArgument='<%# Eval("ProductVariantId") %>'
                                        Text="Save" CssClass="cv-save-btn" CausesValidation="false" />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </asp:Panel>

            </div>
        </asp:Panel>
        </ContentTemplate>
        </asp:UpdatePanel>

        <%-- Details --%>
        <div class="form-section">
            <div class="section-label">Details</div>
            <div class="field-group">
                <label class="field-label">Description</label>
                <asp:TextBox ID="txtDescription" runat="server" CssClass="field-textarea"
                    TextMode="MultiLine" Rows="5"
                    placeholder="Key features, compatibility, materials..."
                    MaxLength="2000" />
                <div class="field-hint">Max 2,000 characters. Plain text only.</div>
            </div>
        </div>

        <%-- Media --%>
        <div class="form-section">
            <div class="section-label">Media</div>
            <div class="field-group">
                <label class="field-label">Image URL</label>
                <asp:TextBox ID="txtImageUrl" runat="server" CssClass="field-input"
                    placeholder="https://..." />
                <div class="field-hint">Paste the full S3 URL. Leave blank to show the ONYX placeholder.</div>
                <div class="image-preview-wrap">
                    <img id="imgPreview" src="" alt="Image preview" />
                    <div class="preview-empty" id="previewEmpty">
                        <i data-lucide="image"></i>
                        No image
                    </div>
                </div>
            </div>
        </div>

        <%-- Actions --%>
        <div class="form-actions">
            <asp:Button ID="btnSave" runat="server" Text="Save Product"
                CssClass="btn-save" OnClick="btnSave_Click" />
            <a href="onyx_admin_products.aspx" class="btn-cancel">Cancel</a>
            <span class="required-note"><span class="req">*</span> Required</span>
        </div>

    </div>

    <script>
        // Image URL live preview
        (function () {
            var urlInput = document.getElementById('<%= txtImageUrl.ClientID %>');
            var imgEl    = document.getElementById('imgPreview');
            var emptyEl  = document.getElementById('previewEmpty');
            function updatePreview() {
                var url = urlInput ? urlInput.value.trim() : '';
                if (url) { imgEl.src = url; imgEl.style.display = 'block'; emptyEl.style.display = 'none'; }
                else      { imgEl.style.display = 'none'; emptyEl.style.display = 'flex'; }
            }
            if (urlInput) { urlInput.addEventListener('input', updatePreview); updatePreview(); }
        })();
    </script>

</asp:Content>
