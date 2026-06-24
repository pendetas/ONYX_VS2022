<%@ Page Title="Wishlist" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_wishlist.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_wishlist" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-commerce.css") %>" />

</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-wishlist-page">
        <div class="onyx-wishlist-shell">
            <header class="onyx-wishlist-hero" aria-labelledby="wishlist-title" aria-describedby="wishlist-description">
                <div>
                    <h1 id="wishlist-title" class="onyx-wishlist-title">Saved gear</h1>
                    <p id="wishlist-description" class="onyx-wishlist-copy">
                        Review saved products, check availability, and move your next upgrade into the cart.
                    </p>
                </div>
                <div class="onyx-wishlist-summary">
                    <asp:Literal ID="litWishlistCount" runat="server" />
                    <asp:Label ID="lblFeedback" runat="server" CssClass="onyx-wishlist-feedback" Visible="false" role="status" aria-live="polite" />
                </div>
            </header>

            <asp:Panel ID="pnlEmptyWishlist" runat="server" Visible="false" CssClass="onyx-empty-wishlist" role="status">
                <div class="onyx-empty-wishlist-inner">
                    <h2>No saved gear yet.</h2>
                    <p>Browse the catalog and save products you want to compare, revisit, or move into your cart later.</p>
                    <a href="/customer_page/onyx_catalog.aspx" class="onyx-wishlist-button">Explore Catalog</a>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlWishlist" runat="server">
                <asp:Repeater ID="rptWishlistItems" runat="server" OnItemCommand="rptWishlistItems_ItemCommand">
                    <HeaderTemplate>
                        <div class="onyx-wishlist-ledger-labels" aria-hidden="true">
                            <span>Product</span>
                            <span>Details</span>
                            <span>Price &amp; actions</span>
                        </div>
                        <div class="onyx-wishlist-grid" role="list">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <article class="onyx-wishlist-card" role="listitem" aria-label='<%# Server.HtmlEncode(Eval("Name").ToString()) %>'>
                            <div class="onyx-wishlist-media">
                                <img src='<%# GetProductImageUrl(Eval("ImageUrl"), Eval("Category")) %>' alt='<%# Server.HtmlEncode(Eval("Name").ToString()) %>' loading="lazy" />
                            </div>
                            <div class="onyx-wishlist-body">
                                <div class="onyx-wishlist-meta">
                                    <span><%# Eval("Brand") %> / <%# GetCategoryDisplayName(Eval("Category")) %></span>
                                    <span><%# GetStockLabel(Eval("StockQty")) %></span>
                                </div>
                                <h2 class="onyx-wishlist-name"><%# Eval("Name") %></h2>
                                <p class="onyx-wishlist-description"><%# Eval("Description") %></p>
                            </div>
                            <div class="onyx-wishlist-commerce">
                                <span class="onyx-wishlist-price"><%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("Price")) %></span>
                                <div class="onyx-wishlist-actions">
                                    <a class="onyx-wishlist-link" href='<%# "onyx_product_details.aspx?id=" + Eval("Id") %>'>View</a>
                                    <asp:LinkButton ID="btnMoveToCart" runat="server"
                                        CommandName="MoveToCart"
                                        CommandArgument='<%# Eval("Id") %>'
                                        CssClass="onyx-wishlist-button">
                                        Move to Cart
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnRemoveWishlist" runat="server"
                                        CommandName="Remove"
                                        CommandArgument='<%# Eval("Id") %>'
                                        CssClass="onyx-wishlist-remove">
                                        Remove
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </article>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                </asp:Repeater>
            </asp:Panel>
        </div>
    </section>
</asp:Content>
