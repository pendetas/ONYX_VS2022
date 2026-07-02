<%@ Page Title="Checkout" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_checkout.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_checkout" %>
<%@ Import Namespace="ONYX_DDAC.Helpers" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-commerce.css") %>" />
</asp:Content>

<asp:Content ID="CheckoutContent" ContentPlaceHolderID="MainContent" runat="server">


    <section class="onyx-checkout-page">
        <div class="onyx-checkout-shell">
            <h1 class="onyx-checkout-title">Checkout</h1>

            <asp:Panel ID="pnlEmptyCheckout" runat="server" Visible="false" CssClass="onyx-checkout-panel">
                <h2>Your cart is empty</h2>
                <a href="onyx_catalog.aspx" class="onyx-pay-btn" style="display: inline-block; max-width: 240px; text-align: center;">Return to Catalog</a>
            </asp:Panel>

            <asp:Panel ID="pnlCheckout" runat="server" Visible="false" CssClass="onyx-checkout-grid">
                <div class="onyx-checkout-panel">
                    <h2>Selected Products</h2>
                    <asp:Repeater ID="rptCheckoutItems" runat="server">
                        <ItemTemplate>
                            <div class="onyx-checkout-item">
                                <img src='<%# GetSafeImageUrl(Eval("ImageUrl")) %>' alt='<%# EncodeProductName(Eval("ProductName")) %>' />
                                <div>
                                    <div class="onyx-checkout-name"><%# EncodeProductName(Eval("ProductName")) %></div>
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
                        <label for="<%= txtShippingAddress.ClientID %>">Shipping Address</label>
                        <asp:TextBox ID="txtShippingAddress" runat="server" TextMode="MultiLine" Rows="4" CssClass="onyx-checkout-input" />
                    </div>

                    <div class="onyx-checkout-total">
                        <span>Total</span>
                        <asp:Literal ID="litCheckoutTotal" runat="server" />
                    </div>

                    <div class="onyx-stripe-checkout-note">
                        <strong>Secure Stripe Checkout</strong>
                        <span>Stripe will show the eligible payment methods enabled for ONYX test mode. Delivery is free.</span>
                    </div>

                    <asp:Button
                        ID="btnPayWithStripe"
                        runat="server"
                        Text="Pay With Stripe"
                        CssClass="onyx-pay-btn"
                        OnClientClick="var button=this; button.value='Redirecting...'; setTimeout(function(){ button.disabled=true; }, 0);"
                        OnClick="btnPayWithStripe_Click" />
                    <asp:Label ID="lblCheckoutMessage" runat="server" Visible="false" CssClass="onyx-checkout-message" />
                </div>
            </asp:Panel>
        </div>
    </section>
</asp:Content>
