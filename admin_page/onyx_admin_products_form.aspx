<%@ Page Title="Product Form" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_products_form.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_products_form" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #0d0d0d !important; }

        .admin-panel {
            background: #1a1a1a;
            border: 1px solid #2b2b2b;
            border-radius: 0;
            padding: 30px 32px;
        }

        .page-title   { font-size: 22px; font-weight: 700; color: #ffffff; margin-bottom: 0; }
        .page-subtitle { font-size: 13px; color: #9c9ca4; margin-top: 4px; }

        /* Form controls — dark override */
        .form-label {
            color: #9c9ca4;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 6px;
        }

        .form-control,
        .form-select {
            background-color: #0d0d0d !important;
            border: 1px solid #2b2b2b !important;
            border-radius: 0 !important;
            color: #ffffff !important;
            font-size: 14px;
            padding: 10px 14px;
            font-family: 'Inter', sans-serif;
        }

        .form-control:focus,
        .form-select:focus {
            border-color: #00ff87 !important;
            box-shadow: 0 0 0 3px rgba(0, 255, 135, 0.10) !important;
        }

        .form-control::placeholder { color: #484848; }
        .form-select option         { background-color: #1a1a1a; color: #ffffff; }

        /* Required star */
        .req { color: #ff4444; margin-left: 2px; }

        /* Field hint */
        .field-hint { font-size: 12px; color: #4a4a4a; margin-top: 5px; }

        /* Section divider */
        hr.divider { border-color: #2b2b2b; margin: 28px 0; }

        /* Neon green save button */
        .btn-onyx {
            background: #00ff87;
            color: #000000;
            border: none;
            border-radius: 0;
            font-weight: 700;
            font-size: 14px;
            padding: 11px 30px;
            font-family: 'Inter', sans-serif;
            transition: background 0.2s;
            cursor: pointer;
        }

        .btn-onyx:hover,
        .btn-onyx:focus { background: #00e077; color: #000; }

        /* Secondary cancel button */
        .btn-secondary-dark {
            background: transparent;
            border: 1px solid #2b2b2b;
            color: #9c9ca4;
            border-radius: 0;
            font-size: 14px;
            padding: 11px 26px;
            font-family: 'Inter', sans-serif;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s;
            cursor: pointer;
        }

        .btn-secondary-dark:hover { border-color: #555; color: #ffffff; }

        /* Back link */
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            color: #9c9ca4;
            text-decoration: none;
            transition: color 0.2s;
        }

        .back-link:hover { color: #ffffff; }

        /* Alert box */
        .alert-panel {
            border-radius: 0;
            padding: 13px 18px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }

        .alert-success-dark {
            background: rgba(0, 255, 135, 0.07);
            border: 1px solid rgba(0, 255, 135, 0.25);
            color: #00ff87;
        }

        .alert-error-dark {
            background: rgba(255, 68, 68, 0.07);
            border: 1px solid rgba(255, 68, 68, 0.25);
            color: #ff4444;
        }

        /* Image preview placeholder */
        .image-placeholder {
            background: #0d0d0d;
            border: 2px dashed #2b2b2b;
            border-radius: 0;
            height: 120px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #444;
            font-size: 13px;
            gap: 8px;
            margin-top: 8px;
        }

        /* Stock warning */
        .stock-warning { color: #fbbf24; font-size: 12px; margin-top: 5px; }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ======================================================
         PAGE HEADER
    ====================================================== --%>
    <div class="d-flex justify-content-between align-items-start mb-4">
        <div>
            <h1 class="page-title">
                <asp:Literal ID="litPageTitle" runat="server" Text="Add New Product" />
            </h1>
            <p class="page-subtitle">
                <asp:Literal ID="litPageSubtitle" runat="server"
                    Text="Fill in the details below to add a new product to the catalog." />
            </p>
        </div>
        <a href="onyx_admin_products.aspx" class="back-link">
            <i data-lucide="arrow-left" style="width:15px;height:15px;"></i> Back to Products
        </a>
    </div>

    <%-- ======================================================
         ALERT PANEL (success / error messages)
    ====================================================== --%>
    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <div class="alert-panel">
            <i data-lucide="check-circle" style="width:16px;height:16px;flex-shrink:0;"></i>
            <asp:Literal ID="litAlertMessage" runat="server" />
        </div>
    </asp:Panel>

    <%-- ======================================================
         MAIN FORM PANEL
    ====================================================== --%>
    <div class="admin-panel">

        <div class="row g-4">

            <%-- Product Name --%>
            <div class="col-12 col-md-6">
                <label class="form-label">Product Name <span class="req">*</span></label>
                <asp:TextBox ID="txtName" runat="server" CssClass="form-control"
                    placeholder="e.g. Viper V2 Pro" MaxLength="100" />
                <div class="field-hint">Max 100 characters. This is shown on the product listing page.</div>
            </div>

            <%-- Brand --%>
            <div class="col-12 col-md-6">
                <label class="form-label">Brand</label>
                <asp:TextBox ID="txtBrand" runat="server" CssClass="form-control"
                    placeholder="e.g. Razer" MaxLength="50" />
                <div class="field-hint">Manufacturer or brand name.</div>
            </div>

            <%-- Category --%>
            <div class="col-12 col-md-4">
                <label class="form-label">Category <span class="req">*</span></label>
                <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select">
                    <asp:ListItem Value=""        Text="— Select Category —" />
                    <asp:ListItem Value="Mouse"   Text="Mouse" />
                    <asp:ListItem Value="Keyboard" Text="Keyboard" />
                    <asp:ListItem Value="Headset" Text="Headset" />
                    <asp:ListItem Value="Monitor" Text="Monitor" />
                    <asp:ListItem Value="Chair"   Text="Chair" />
                </asp:DropDownList>
            </div>

            <%-- Price --%>
            <div class="col-12 col-md-4">
                <label class="form-label">Price (RM) <span class="req">*</span></label>
                <asp:TextBox ID="txtPrice" runat="server" CssClass="form-control"
                    placeholder="0.00" TextMode="Number" />
                <div class="field-hint">Enter price in Malaysian Ringgit (MYR).</div>
            </div>

            <%-- Stock Quantity --%>
            <div class="col-12 col-md-4">
                <label class="form-label">Stock Quantity <span class="req">*</span></label>
                <asp:TextBox ID="txtStock" runat="server" CssClass="form-control"
                    placeholder="0" TextMode="Number" />
                <div class="field-hint">Set to 0 to mark product as out of stock.</div>
            </div>

            <%-- Description --%>
            <div class="col-12">
                <label class="form-label">Description</label>
                <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control"
                    TextMode="MultiLine" Rows="5"
                    placeholder="Describe the product — key features, compatibility, materials, etc."
                    MaxLength="2000" />
                <div class="field-hint">Max 2,000 characters. Supports plain text only.</div>
            </div>

            <%-- Image URL (S3) --%>
            <div class="col-12">
                <label class="form-label">Image URL (S3)</label>
                <asp:TextBox ID="txtImageUrl" runat="server" CssClass="form-control"
                    placeholder="https://onyx-assets.s3.ap-southeast-1.amazonaws.com/products/..." />
                <div class="field-hint">
                    Upload the image to the S3 bucket <strong style="color:#fff;">onyx-assets</strong>
                    and paste the full URL here. Leave blank to show the ONYX placeholder.
                </div>
                <div class="image-placeholder">
                    <i data-lucide="image" style="width:18px;height:18px;"></i>
                    Image preview will appear here when a URL is entered
                </div>
            </div>

        </div>

        <hr class="divider" />

        <%-- Action Buttons --%>
        <div class="d-flex align-items-center gap-3">
            <asp:Button ID="btnSave" runat="server" Text="Save Product"
                CssClass="btn btn-onyx" OnClick="btnSave_Click" />
            <a href="onyx_admin_products.aspx" class="btn-secondary-dark">Cancel</a>
            <div style="margin-left:auto; font-size:12px; color:#4a4a4a;">
                <span class="req">*</span> Required fields
            </div>
        </div>

    </div>

</asp:Content>
