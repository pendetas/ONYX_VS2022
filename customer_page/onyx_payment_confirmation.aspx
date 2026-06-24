<%@ Page Title="Confirming Payment" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_payment_confirmation.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_payment_confirmation" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-commerce.css") %>" />
    <asp:Literal ID="litRefresh" runat="server" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-payment-state-page">
        <article class="onyx-payment-state-panel">
            <span class="onyx-payment-state-kicker">Stripe Checkout</span>
            <h1><asp:Literal ID="litTitle" runat="server" Text="Confirming your payment" /></h1>
            <p><asp:Literal ID="litMessage" runat="server" Text="Please wait while ONYX verifies your payment securely." /></p>
            <a class="onyx-payment-state-link" href="onyx_order_history.aspx">View order history</a>
        </article>
    </section>
</asp:Content>
