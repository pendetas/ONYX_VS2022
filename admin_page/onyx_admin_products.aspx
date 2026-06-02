<%@ Page Title="Products" Language="C#" MasterPageFile="~/admin_page/admin.Master" AutoEventWireup="true" CodeBehind="onyx_admin_products.aspx.cs" Inherits="ONYX_DDAC.admin_page.onyx_admin_products" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .add-btn {
            background-color: var(--accent-green);
            color: #000;
            padding: 10px 20px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: opacity 0.2s;
        }

        .add-btn:hover {
            opacity: 0.8;
            color: #000;
        }

        .data-table-card {
            background-color: var(--card-dark);
            border-radius: 16px;
            padding: 20px;
        }
        
        /* Basic styling to make the GridView look good on dark mode */
        .admin-table {
            width: 100%;
            border-collapse: collapse;
            color: var(--text-main);
            font-size: 14px;
        }
        
        .admin-table th {
            text-align: left;
            padding: 15px;
            color: var(--text-muted);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            font-weight: 500;
        }

        .admin-table td {
            padding: 15px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }
    </style>

    <div class="page-header">
        <h1>Product Catalog</h1>
        <a href="onyx_admin_product_form.aspx" class="add-btn">
            <i data-lucide="plus" style="width: 18px;"></i> Add New Product
        </a>
    </div>

    <div class="data-table-card">
        <asp:GridView ID="ProductsGridView" runat="server" CssClass="admin-table" AutoGenerateColumns="false" GridLines="None">
            <Columns>
                <asp:BoundField HeaderText="Name" DataField="Name" />
                <asp:BoundField HeaderText="Category" DataField="Category" />
                <asp:BoundField HeaderText="Price" DataField="Price" DataFormatString="RM {0:N2}" />
                <asp:BoundField HeaderText="Stock" DataField="StockQty" />
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>