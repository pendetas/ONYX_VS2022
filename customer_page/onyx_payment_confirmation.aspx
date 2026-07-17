<%@ Page Title="Confirming Payment" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_payment_confirmation.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_payment_confirmation" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-commerce.css") %>" />
    <asp:Literal ID="litRefresh" runat="server" />
    <style>
        .onyx-payment-summary {
            border-top: 1px solid rgba(255,255,255,0.12);
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-top: 22px;
            padding-top: 18px;
            text-align: left;
        }

        .onyx-payment-summary-row {
            align-items: baseline;
            display: flex;
            gap: 16px;
            justify-content: space-between;
        }

        .onyx-payment-summary-row span {
            color: #9eb0c4;
            font-size: 0.7rem;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .onyx-payment-summary-row strong {
            color: #f4f8fc;
            font-size: 0.95rem;
            font-weight: 800;
        }

        .onyx-payment-summary-row--total {
            border-top: 1px solid rgba(255,255,255,0.12);
            margin-top: 4px;
            padding-top: 12px;
        }

        .onyx-payment-summary-row--total strong {
            font-size: 1.15rem;
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-payment-state-page">
        <article class="onyx-payment-state-panel">
            <span class="onyx-payment-state-kicker">Stripe Checkout</span>
            <h1><asp:Literal ID="litTitle" runat="server" Text="Confirming your payment" /></h1>
            <asp:Literal ID="litMessage" runat="server" />
            <a class="onyx-payment-state-link" href="onyx_order_history.aspx">View order history</a>
        </article>
    </section>
</asp:Content>
