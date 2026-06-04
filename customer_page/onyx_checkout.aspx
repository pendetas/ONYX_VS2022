<%@ Page Title="Checkout" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_checkout.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_checkout" %>
<%@ Import Namespace="ONYX_DDAC.Helpers" %>

<asp:Content ID="CheckoutContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .onyx-checkout-page {
            background: #050505;
            color: #fff;
            min-height: 100vh;
            padding: 180px 48px 80px;
        }

        .onyx-checkout-shell {
            margin: 0 auto;
            max-width: 1100px;
        }

        .onyx-checkout-title {
            font-family: Syne, sans-serif;
            font-size: clamp(2.5rem, 5vw, 5rem);
            font-weight: 800;
            letter-spacing: 0.02em;
            margin: 0 0 32px;
            text-transform: uppercase;
        }

        .onyx-checkout-grid {
            display: grid;
            gap: 28px;
            grid-template-columns: minmax(0, 1.3fr) minmax(320px, 0.7fr);
        }

        .onyx-checkout-panel {
            border: 1px solid rgba(255, 255, 255, 0.12);
            padding: 28px;
        }

        .onyx-checkout-panel h2 {
            font-family: Syne, sans-serif;
            font-size: 1.3rem;
            margin: 0 0 20px;
            text-transform: uppercase;
        }

        .onyx-checkout-item {
            align-items: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            display: grid;
            gap: 18px;
            grid-template-columns: 78px minmax(0, 1fr) auto;
            padding: 18px 0;
        }

        .onyx-checkout-item:first-child {
            padding-top: 0;
        }

        .onyx-checkout-item img {
            aspect-ratio: 1;
            background: #111;
            object-fit: contain;
            width: 78px;
        }

        .onyx-checkout-name {
            font-weight: 700;
            margin-bottom: 6px;
        }

        .onyx-checkout-meta {
            color: #9ca3af;
            font-size: 0.9rem;
        }

        .onyx-checkout-field {
            margin-bottom: 18px;
        }

        .onyx-checkout-field label {
            color: #d8dde3;
            display: block;
            font-size: 0.8rem;
            font-weight: 700;
            letter-spacing: 0.08em;
            margin-bottom: 8px;
            text-transform: uppercase;
        }

        .onyx-checkout-input {
            background: #0b0b0b;
            border: 1px solid rgba(255, 255, 255, 0.18);
            color: #fff;
            min-height: 46px;
            padding: 12px 14px;
            width: 100%;
        }

        .onyx-checkout-total {
            align-items: center;
            border-top: 1px solid rgba(255, 255, 255, 0.14);
            display: flex;
            font-size: 1.2rem;
            font-weight: 800;
            justify-content: space-between;
            margin-top: 22px;
            padding-top: 22px;
        }

        .onyx-pay-btn {
            background: #fff;
            border: 0;
            color: #050505;
            font-weight: 800;
            letter-spacing: 0.08em;
            margin-top: 18px;
            padding: 15px 22px;
            text-transform: uppercase;
            width: 100%;
        }

        .onyx-checkout-message {
            display: block;
            font-weight: 700;
            margin-top: 16px;
        }

        @media (max-width: 860px) {
            .onyx-checkout-page {
                padding: 150px 20px 60px;
            }

            .onyx-checkout-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <section class="onyx-checkout-page">
        <div class="onyx-checkout-shell">
            <h1 class="onyx-checkout-title">Checkout</h1>

            <asp:Panel ID="pnlEmptyCheckout" runat="server" Visible="false" CssClass="onyx-checkout-panel">
                <h2>Your cart is empty</h2>
                <a href="onyx_catalog.aspx" class="onyx-pay-btn" style="display: inline-block; max-width: 240px; text-align: center;">Return to Catalog</a>
            </asp:Panel>

            <asp:Panel ID="pnlOrderSuccess" runat="server" Visible="false" CssClass="onyx-checkout-panel">
                <h2>Payment successful</h2>
                <asp:Literal ID="litOrderSuccess" runat="server" />
                <a href="onyx_catalog.aspx" class="onyx-pay-btn" style="display: inline-block; max-width: 240px; text-align: center;">Continue Shopping</a>
            </asp:Panel>

            <asp:Panel ID="pnlCheckout" runat="server" Visible="false" CssClass="onyx-checkout-grid">
                <div class="onyx-checkout-panel">
                    <h2>Selected Products</h2>
                    <asp:Repeater ID="rptCheckoutItems" runat="server">
                        <ItemTemplate>
                            <div class="onyx-checkout-item">
                                <img src='<%# GetImageUrl(Eval("ImageUrl")) %>' alt='<%# Server.HtmlEncode(Eval("ProductName").ToString()) %>' />
                                <div>
                                    <div class="onyx-checkout-name"><%# Eval("ProductName") %></div>
                                    <div class="onyx-checkout-meta">Qty <%# Eval("Quantity") %> x <%# CurrencyHelper.FormatMyr((decimal)Eval("Price")) %></div>
                                </div>
                                <strong><%# CurrencyHelper.FormatMyr((decimal)Eval("Subtotal")) %></strong>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="onyx-checkout-panel">
                    <h2>Delivery & Payment</h2>

                    <div class="onyx-checkout-field">
                        <label for="<%= ddlDeliveryMethod.ClientID %>">Delivery Method</label>
                        <asp:DropDownList ID="ddlDeliveryMethod" runat="server" CssClass="onyx-checkout-input">
                            <asp:ListItem Text="Standard Delivery" Value="Standard Delivery" />
                            <asp:ListItem Text="Express Delivery" Value="Express Delivery" />
                            <asp:ListItem Text="Self Pickup" Value="Self Pickup" />
                        </asp:DropDownList>
                    </div>

                    <div class="onyx-checkout-field">
                        <label for="<%= ddlPaymentMethod.ClientID %>">Payment Method</label>
                        <asp:DropDownList ID="ddlPaymentMethod" runat="server" CssClass="onyx-checkout-input">
                            <asp:ListItem Text="Dummy Card Payment" Value="Dummy Card Payment" />
                            <asp:ListItem Text="Dummy Online Banking" Value="Dummy Online Banking" />
                            <asp:ListItem Text="Cash on Delivery" Value="Cash on Delivery" />
                        </asp:DropDownList>
                    </div>

                    <div class="onyx-checkout-field">
                        <label for="<%= txtShippingAddress.ClientID %>">Shipping Address</label>
                        <asp:TextBox ID="txtShippingAddress" runat="server" TextMode="MultiLine" Rows="4" CssClass="onyx-checkout-input" />
                    </div>

                    <div class="onyx-checkout-total">
                        <span>Total</span>
                        <asp:Literal ID="litCheckoutTotal" runat="server" />
                    </div>

                    <asp:Button ID="btnPay" runat="server" Text="Pay" CssClass="onyx-pay-btn hover-trigger" OnClick="btnPay_Click" />
                    <asp:Label ID="lblCheckoutMessage" runat="server" Visible="false" CssClass="onyx-checkout-message" />
                </div>
            </asp:Panel>
        </div>
    </section>
</asp:Content>
