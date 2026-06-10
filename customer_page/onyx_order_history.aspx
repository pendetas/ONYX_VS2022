<%@ Page Title="Order History" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_order_history.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_order_history" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="/Content/onyx-account.css" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-account-page">
        <div class="onyx-account-layout">
            <aside class="onyx-account-sidebar">
                <h1 class="onyx-account-title">My Account</h1>
                <p class="onyx-account-subtitle">Review your purchases and receipts.</p>

                <nav class="onyx-account-nav" aria-label="Account navigation">
                    <a class="hover-trigger" href="/customer_page/onyx_profile">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 21a8 8 0 0 0-16 0" /><circle cx="12" cy="7" r="4" /></svg>
                        <span>Profile Details</span>
                    </a>
                    <a class="hover-trigger is-active" href="/customer_page/onyx_order_history">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m21 16-9 5-9-5V8l9-5 9 5v8Z" /><path d="m3.3 7.3 8.7 4.9 8.7-4.9" /><path d="M12 22V12" /></svg>
                        <span>Order History</span>
                    </a>
                    <a class="hover-trigger" href="/customer_page/onyx_wishlist">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20.8 4.6c-1.5-1.4-3.9-1.4-5.4.1L12 8.1 8.6 4.7c-1.5-1.5-3.9-1.5-5.4-.1-1.6 1.5-1.6 4.1 0 5.7L12 19l8.8-8.7c1.6-1.6 1.6-4.2 0-5.7Z" /></svg>
                        <span>Wishlist</span>
                    </a>
                    <a class="hover-trigger" href="/customer_page/onyx_reviews">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 17.3 18.2 21l-1.6-7 5.4-4.7-7.1-.6L12 2 9.1 8.7 2 9.3 7.4 14l-1.6 7L12 17.3Z" /></svg>
                        <span>Reviews</span>
                    </a>
                </nav>
            </aside>

            <div class="onyx-account-main">
                <section class="onyx-account-section">
                    <h2 class="onyx-section-title">Order History</h2>
                    <p class="onyx-page-lede">Track recent ONYX purchases, payment status, and receipt downloads from one focused page.</p>

                    <asp:Panel ID="pnlEmptyOrders" runat="server" Visible="false" CssClass="onyx-profile-empty">
                        Your order history is empty for now. Browse the catalog and build your ONYX setup.
                    </asp:Panel>
                    <asp:Repeater ID="rptRecentOrders" runat="server">
                        <HeaderTemplate><div class="onyx-order-list"></HeaderTemplate>
                        <ItemTemplate>
                            <article class="onyx-order-card">
                                <div class="onyx-order-top">
                                    <div>
                                        <span class="onyx-order-id">Order #<%# Eval("Id") %></span>
                                        <div class="onyx-order-date"><%# FormatOrderDate(Eval("OrderedAt")) %></div>
                                    </div>
                                    <span class="onyx-order-status"><%# Eval("Status") %></span>
                                </div>
                                <p class="onyx-order-summary"><%# GetOrderSummary(Container.DataItem) %></p>
                                <div class="onyx-order-footer">
                                    <span class="onyx-order-total"><%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("TotalAmount")) %></span>
                                    <a class="onyx-profile-ghost hover-trigger" href='<%# "onyx_invoice.aspx?orderId=" + Eval("Id") %>'>View Receipt</a>
                                </div>
                            </article>
                        </ItemTemplate>
                        <FooterTemplate></div></FooterTemplate>
                    </asp:Repeater>
                </section>
            </div>
        </div>
    </section>
</asp:Content>
