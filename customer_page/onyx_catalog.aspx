<%@ Page Title="Catalog" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_catalog.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_catalog" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-catalog.css") %>" />

</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-catalog-page">
        <div class="onyx-catalog-shell">
            <header class="onyx-catalog-banner">
                <div class="onyx-catalog-banner-content">
                    <div class="onyx-catalog-kicker">Gear for every move</div>
                    <h1 class="onyx-catalog-title"><%= CatalogTitle %></h1>
                    <p class="onyx-catalog-copy"><%= CatalogDescription %></p>
                </div>
            </header>

            <div class="onyx-catalog-toolbar">
                <nav class="onyx-catalog-filters" aria-label="Catalog filters">
                    <a class='<%= GetFilterClass(string.Empty) %>' href="<%= GetCatalogUrl(string.Empty) %>">All</a>
                    <a class='<%= GetFilterClass("Mouse") %>' href="<%= GetCatalogUrl("Mouse") %>">Gaming Mice</a>
                    <a class='<%= GetFilterClass("Keyboard") %>' href="<%= GetCatalogUrl("Keyboard") %>">Keyboards</a>
                    <a class='<%= GetFilterClass("Headset") %>' href="<%= GetCatalogUrl("Headset") %>">Audio</a>
                    <a class='<%= GetFilterClass("Accessory") %>' href="<%= GetCatalogUrl("Accessory") %>">Accessories</a>
                </nav>

                <div class="onyx-catalog-tools">
                    <label class="onyx-catalog-search" for="onyx-catalog-search">
                        <span class="sr-only">Search catalog</span>
                        <input id="onyx-catalog-search" type="search" value="<%= Server.HtmlEncode(SearchTerm) %>" placeholder="Search gaming gear" />
                    </label>
                    <label class="onyx-catalog-sort" for="onyx-catalog-sort">
                        <span>Sort</span>
                        <select id="onyx-catalog-sort">
                            <option value="recommended"<%= GetSelectedSortAttribute("recommended") %>>Recommended</option>
                            <option value="newest"<%= GetSelectedSortAttribute("newest") %>>Newest</option>
                            <option value="name"<%= GetSelectedSortAttribute("name") %>>Name A-Z</option>
                            <option value="price-asc"<%= GetSelectedSortAttribute("price-asc") %>>Price Low-High</option>
                            <option value="price-desc"<%= GetSelectedSortAttribute("price-desc") %>>Price High-Low</option>
                        </select>
                    </label>
                    <button type="button" class="onyx-glass-button" onclick="onyxApplyCatalogFilters()">Apply</button>
                    <asp:Literal ID="CatalogCountLiteral" runat="server" />
                </div>
            </div>

            <asp:Repeater ID="ProductsRepeater" runat="server" OnItemCommand="ProductsRepeater_ItemCommand">
                <HeaderTemplate><div class="onyx-product-grid"></HeaderTemplate>
                <ItemTemplate>
                    <article class="onyx-product-card">
                        <div class="onyx-product-media">
                            <asp:LinkButton ID="btnWishlist" runat="server"
                                CommandName="ToggleWishlist"
                                CommandArgument='<%# Eval("Id") %>'
                                CssClass='<%# GetWishlistButtonClass(Eval("Id")) %>'
                                ToolTip='<%# GetWishlistButtonLabel(Eval("Id")) %>'>
                                <svg viewBox="0 0 24 24" aria-hidden="true">
                                    <path d="M20.8 4.6c-1.8-1.7-4.7-1.7-6.5 0L12 6.8 9.7 4.6c-1.8-1.7-4.7-1.7-6.5 0-1.9 1.8-1.9 4.7 0 6.5l8.8 8.4 8.8-8.4c1.9-1.8 1.9-4.7 0-6.5z" />
                                </svg>
                            </asp:LinkButton>
                            <img src='<%# GetProductImageUrl(Eval("ImageUrl"), Eval("Category")) %>' alt='<%# Server.HtmlEncode(Eval("Name").ToString()) %>' loading="lazy" />
                        </div>
                        <div class="onyx-product-body">
                            <div class="onyx-product-meta">
                                <span><%# Eval("Brand") %> / <%# GetCategoryDisplayName(Eval("Category")) %></span>
                                <span><%# GetStockLabel(Eval("StockQty")) %></span>
                            </div>
                            <h2 class="onyx-product-name"><%# Eval("Name") %></h2>
                            <p class="onyx-product-description"><%# Eval("Description") %></p>
                            <div class="onyx-product-actions">
                                <span class="onyx-product-price"><%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("Price")) %></span>
                                <a class="onyx-product-view" href='<%# "onyx_product_details.aspx?id=" + Eval("Id") %>'>View <span>+</span></a>
                            </div>
                        </div>
                    </article>
                </ItemTemplate>
                <FooterTemplate></div></FooterTemplate>
            </asp:Repeater>
            <asp:Label ID="CatalogFeedbackLabel" runat="server" CssClass="onyx-catalog-feedback" Visible="false" />
            <asp:Literal ID="CatalogPagerLiteral" runat="server" />

            <asp:Panel ID="EmptyCatalogPanel" runat="server" CssClass="onyx-empty-catalog" Visible="false">
                No products match this catalog filter.
            </asp:Panel>
        </div>
    </section>
</asp:Content>
