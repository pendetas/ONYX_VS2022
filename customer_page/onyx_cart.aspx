<%@ Page Title="Cart" Language="C#" MasterPageFile="~/customer_page/onyx_layout.Master" AutoEventWireup="true" CodeBehind="onyx_cart.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_cart" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="h3 mb-4">Cart</h1>
    <div class="onyx-card">
        <asp:Literal ID="CartSummaryLiteral" runat="server" />
        <div class="mt-3">
            <a class="btn onyx-btn" href="onyx_checkout.aspx">Checkout</a>
            <a class="btn onyx-btn-secondary ms-2" href="onyx_products.aspx">Continue Shopping</a>
        </div>
    </div>
</asp:Content>
