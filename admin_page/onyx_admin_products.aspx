<%@ Page Title="Products" Language="C#" MasterPageFile="~/admin_page/admin.Master" AutoEventWireup="true" CodeBehind="onyx_admin_products.aspx.cs" Inherits="ONYX_DDAC.admin_page.onyx_admin_products" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">Products</h1>
        <a class="btn onyx-btn" href="onyx_admin_product_form.aspx">Add New Product</a>
    </div>
    <div class="admin-panel">
        <asp:GridView ID="ProductsGridView" runat="server" CssClass="table table-dark table-striped mb-0" AutoGenerateColumns="false">
            <Columns>
                <asp:BoundField HeaderText="Name" DataField="Name" />
                <asp:BoundField HeaderText="Category" DataField="Category" />
                <asp:BoundField HeaderText="Price" DataField="Price" DataFormatString="RM {0:N2}" />
                <asp:BoundField HeaderText="Stock" DataField="StockQty" />
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
