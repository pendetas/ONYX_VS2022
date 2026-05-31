<%@ Page Title="Products" Language="C#" MasterPageFile="~/customer_page/onyx_layout.Master" AutoEventWireup="true" CodeBehind="onyx_products.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_products" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="h3 mb-1">Products</h1>
            <p class="onyx-muted mb-0">Browse ONYX gaming gear.</p>
        </div>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <asp:DropDownList ID="CategoryDropDown" runat="server" CssClass="form-select onyx-select">
                <asp:ListItem Text="All categories" Value="" />
                <asp:ListItem Text="Mouse" Value="Mouse" />
                <asp:ListItem Text="Keyboard" Value="Keyboard" />
                <asp:ListItem Text="Headset" Value="Headset" />
                <asp:ListItem Text="Monitor" Value="Monitor" />
                <asp:ListItem Text="Chair" Value="Chair" />
            </asp:DropDownList>
        </div>
        <div class="col-md-3">
            <asp:TextBox ID="BrandTextBox" runat="server" CssClass="form-control onyx-input" placeholder="Brand" />
        </div>
        <div class="col-md-3">
            <asp:DropDownList ID="SortDropDown" runat="server" CssClass="form-select onyx-select">
                <asp:ListItem Text="Newest" Value="newest" />
                <asp:ListItem Text="Price low-high" Value="price_asc" />
                <asp:ListItem Text="Price high-low" Value="price_desc" />
            </asp:DropDownList>
        </div>
        <div class="col-md-3">
            <asp:Button ID="FilterButton" runat="server" CssClass="btn onyx-btn w-100" Text="Filter" />
        </div>
    </div>

    <asp:Repeater ID="ProductsRepeater" runat="server">
        <HeaderTemplate><div class="row g-4"></HeaderTemplate>
        <ItemTemplate>
            <div class="col-md-3">
                <article class="onyx-card h-100">
                    <div class="onyx-product-placeholder mb-3">OX</div>
                    <p class="onyx-muted mb-1"><%# Eval("Brand") %> / <%# Eval("Category") %></p>
                    <h2 class="h5"><%# Eval("Name") %></h2>
                    <strong><%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("Price")) %></strong>
                    <a class="btn onyx-btn-secondary w-100 mt-3" href='<%# "onyx_product_details.aspx?id=" + Eval("Id") %>'>View</a>
                </article>
            </div>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>
</asp:Content>
