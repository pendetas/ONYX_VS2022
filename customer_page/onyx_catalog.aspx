<%@ Page Title="Catalog" Language="C#" MasterPageFile="~/customer_page/onyx_layout.Master" AutoEventWireup="true" CodeBehind="onyx_catalog.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_catalog" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-hero">
        <div class="onyx-hero-surface">
            <p class="onyx-hero-label">ONYX</p>
            <h1>Level up your setup with gear built for serious play.</h1>
            <p>Curated gaming essentials for fast decisions, clear specs and clean desk setups.</p>
            <div class="onyx-hero-actions">
                <a class="onyx-pill onyx-pill-light" href="onyx_products.aspx">Shop new drops <span>+</span></a>
                <a class="onyx-pill onyx-pill-dark" href="onyx_products.aspx?deal=1">Pro-grade gear <small>New drop</small></a>
            </div>
        </div>
    </section>

    <section class="onyx-section">
        <div class="onyx-section-kicker">
            <span>1</span>
            <small>Built for competitive play</small>
        </div>
        <div class="onyx-split">
            <div>
                <h2>Premium gaming essentials, tuned for speed, comfort and control.</h2>
            </div>
            <div>
                <p>Shop curated keyboards, headsets, mice and desk upgrades selected for players who care about every frame.</p>
                <a class="onyx-pill onyx-pill-light" href="onyx_products.aspx">Explore gear <span>+</span></a>
            </div>
        </div>
        <div class="onyx-benefit-grid">
            <article>
                <span>01</span>
                <strong>Fast dispatch</strong>
                <p>Ships in 24 hours across Malaysia.</p>
            </article>
            <article>
                <span>02</span>
                <strong>Player warranty</strong>
                <p>Covered for daily ranked sessions.</p>
            </article>
            <article>
                <span>03</span>
                <strong>Secure checkout</strong>
                <p>Cards, wallets and local payments.</p>
            </article>
        </div>
    </section>

    <section class="onyx-section onyx-section-raised">
        <div class="onyx-section-kicker">
            <span>2</span>
            <small>Featured drops</small>
        </div>
        <div class="onyx-section-heading">
            <h2>Shop the loudest drops.</h2>
            <a href="onyx_products.aspx">View all</a>
        </div>
        <div class="onyx-product-grid">
            <asp:Repeater ID="FeaturedProductsRepeater" runat="server">
                <ItemTemplate>
                    <article class="onyx-product-card">
                        <div class="onyx-product-media">
                            <span>ONYX</span>
                        </div>
                        <div class="onyx-product-body">
                            <p><%# Eval("Brand") %> / <%# Eval("Category") %></p>
                            <h3 class="h5"><%# Eval("Name") %></h3>
                            <div class="onyx-product-meta">
                                <strong><%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("Price")) %></strong>
                                <a href="onyx_products.aspx">View <span>+</span></a>
                            </div>
                        </div>
                    </article>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </section>
</asp:Content>
