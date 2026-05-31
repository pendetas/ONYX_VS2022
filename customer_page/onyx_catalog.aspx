<%@ Page Title="Catalog" Language="C#" MasterPageFile="~/customer_page/onyx_layout.Master" AutoEventWireup="true" CodeBehind="onyx_catalog.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_catalog" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-hero mb-4">
        <p class="onyx-muted mb-2">Gaming peripherals for every loadout</p>
        <h1 class="display-5 fw-bold">Gear Up. Game On.</h1>
        <p class="lead onyx-muted">Shop mice, keyboards, headsets, monitors, and chairs built for high-performance setups.</p>
        <div class="d-flex gap-3 mt-4">
            <a class="btn onyx-btn" href="onyx_products.aspx">Shop Now</a>
            <a class="btn onyx-btn-secondary" href="onyx_products.aspx?deal=1">View Deals</a>
        </div>
    </section>

    <section class="row g-3 mb-5">
        <div class="col-6 col-md"><div class="onyx-card text-center">Mouse</div></div>
        <div class="col-6 col-md"><div class="onyx-card text-center">Keyboard</div></div>
        <div class="col-6 col-md"><div class="onyx-card text-center">Headset</div></div>
        <div class="col-6 col-md"><div class="onyx-card text-center">Monitor</div></div>
        <div class="col-6 col-md"><div class="onyx-card text-center">Chair</div></div>
    </section>

    <section>
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2 class="h4 mb-0">Featured Products</h2>
            <a href="onyx_products.aspx">View all</a>
        </div>
        <div class="row g-4">
            <asp:Repeater ID="FeaturedProductsRepeater" runat="server">
                <ItemTemplate>
                    <div class="col-md-3">
                        <article class="onyx-card h-100">
                            <div class="onyx-product-placeholder mb-3">OX</div>
                            <p class="onyx-muted mb-1"><%# Eval("Brand") %> / <%# Eval("Category") %></p>
                            <h3 class="h5"><%# Eval("Name") %></h3>
                            <strong><%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("Price")) %></strong>
                        </article>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </section>
</asp:Content>
