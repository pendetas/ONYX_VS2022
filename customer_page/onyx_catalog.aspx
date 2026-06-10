<%@ Page Title="Catalog" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_catalog.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_catalog" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-catalog-page {
            background: #050505;
            color: #ffffff;
            min-height: 100vh;
            padding: 168px 32px 120px;
        }

        .onyx-catalog-shell {
            margin: 0 auto;
            max-width: 1500px;
        }

        .onyx-catalog-kicker {
            color: rgba(255,255,255,0.42);
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.22em;
            margin-bottom: 22px;
            text-transform: uppercase;
        }

        /* FIXED: Removed display: grid so Bootstrap's row/col works properly */
        .onyx-catalog-hero {
            border-bottom: 1px solid rgba(255,255,255,0.12);
            padding-bottom: 52px;
            margin-bottom: 48px; 
        }

        .onyx-catalog-title {
            font-family: Syne, Inter, sans-serif;
            font-size: clamp(54px, 8vw, 132px);
            font-weight: 800;
            letter-spacing: -0.04em;
            line-height: 0.88;
            margin: 0;
            text-transform: uppercase;
            /* Ensures super long words don't break the layout on small mobiles */
            word-wrap: break-word; 
        }

        .onyx-catalog-copy {
            color: rgba(255,255,255,0.68);
            font-size: clamp(17px, 2vw, 24px);
            line-height: 1.55;
            margin: 0;
            max-width: 680px;
        }

        .onyx-catalog-toolbar {
            align-items: center;
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            justify-content: space-between;
            padding: 34px 0 44px;
        }

        .onyx-catalog-filters {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .onyx-catalog-pill {
            align-items: center;
            border: 1px solid rgba(255,255,255,0.16);
            border-radius: 999px;
            color: rgba(255,255,255,0.68);
            display: inline-flex;
            font-size: 12px;
            font-weight: 700;
            gap: 10px;
            letter-spacing: 0.11em;
            min-height: 42px;
            padding: 0 18px;
            text-decoration: none;
            text-transform: uppercase;
            transition: background 160ms ease, border-color 160ms ease, color 160ms ease;
        }

        .onyx-catalog-pill:hover,
        .onyx-catalog-pill.is-active {
            background: #ffffff;
            border-color: #ffffff;
            color: #050505;
        }

        .onyx-catalog-count {
            color: rgba(255,255,255,0.48);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.16em;
            text-transform: uppercase;
        }

        .onyx-product-grid {
            display: grid;
            gap: 22px;
            grid-template-columns: repeat(3, minmax(0, 1fr));
        }

        .onyx-product-card {
            background: linear-gradient(180deg, rgba(255,255,255,0.065), rgba(255,255,255,0.025));
            border: 1px solid rgba(255,255,255,0.11);
            border-radius: 18px;
            min-height: 100%;
            overflow: hidden;
            position: relative;
        }

        .onyx-product-card::before {
            background: radial-gradient(circle at 30% 0%, rgba(255,255,255,0.14), transparent 34%);
            content: "";
            inset: 0;
            opacity: 0;
            pointer-events: none;
            position: absolute;
            transition: opacity 180ms ease;
        }

        .onyx-product-card:hover::before {
            opacity: 1;
        }

        .onyx-product-media {
            align-items: center;
            aspect-ratio: 1.28;
            background: #030303;
            display: flex;
            justify-content: center;
            overflow: hidden;
            padding: 24px;
            position: relative;
        }

        .onyx-product-media img {
            filter: drop-shadow(0 28px 40px rgba(0,0,0,0.65));
            height: 100%;
            max-width: 100%;
            object-fit: contain;
            transform: scale(1.02);
            transition: transform 220ms ease;
        }

        .onyx-product-card:hover .onyx-product-media img {
            transform: scale(1.08);
        }

        .onyx-product-love {
            align-items: center;
            background: rgba(8,8,8,0.68);
            border: 1px solid rgba(255,255,255,0.22);
            border-radius: 999px;
            color: #ffffff;
            display: inline-flex;
            height: 44px;
            justify-content: center;
            position: absolute;
            right: 18px;
            text-decoration: none;
            top: 18px;
            transition: background 160ms ease, border-color 160ms ease, color 160ms ease, transform 160ms ease;
            width: 44px;
            z-index: 2;
        }

        .onyx-product-love svg {
            fill: transparent;
            height: 19px;
            stroke: currentColor;
            stroke-width: 2.2;
            width: 19px;
        }

        .onyx-product-love:hover,
        .onyx-product-love.is-active {
            background: #ffffff;
            border-color: #ffffff;
            color: #050505;
            transform: translateY(-1px);
        }

        .onyx-product-love.is-active svg {
            fill: currentColor;
        }

        .onyx-catalog-feedback {
            color: rgba(255,255,255,0.72);
            display: block;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.13em;
            margin-top: 12px;
            text-transform: uppercase;
        }

        .onyx-product-body {
            display: flex;
            flex-direction: column;
            gap: 16px;
            min-height: 260px;
            padding: 22px;
        }

        .onyx-product-meta {
            color: rgba(255,255,255,0.42);
            display: flex;
            font-size: 10px;
            font-weight: 700;
            justify-content: space-between;
            letter-spacing: 0.16em;
            text-transform: uppercase;
        }

        .onyx-product-name {
            font-family: Syne, Inter, sans-serif;
            font-size: 24px;
            font-weight: 800;
            letter-spacing: -0.02em;
            line-height: 1;
            margin: 0;
            text-transform: uppercase;
        }

        .onyx-product-description {
            color: rgba(255,255,255,0.58);
            font-size: 14px;
            line-height: 1.55;
            margin: 0;
        }

        .onyx-product-actions {
            align-items: center;
            display: flex;
            gap: 14px;
            justify-content: space-between;
            margin-top: auto;
        }

        .onyx-product-price {
            color: #ffffff;
            font-size: 15px;
            font-weight: 800;
        }

        .onyx-product-view {
            align-items: center;
            background: #ffffff;
            border-radius: 999px;
            color: #050505;
            display: inline-flex;
            font-size: 11px;
            font-weight: 800;
            gap: 8px;
            letter-spacing: 0.04em;
            min-height: 38px;
            padding: 0 15px;
            text-decoration: none;
            text-transform: uppercase;
            white-space: nowrap;
        }

        .onyx-empty-catalog {
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 18px;
            color: rgba(255,255,255,0.62);
            padding: 42px;
        }

        @media (max-width: 1080px) {
            .onyx-product-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 720px) {
            .onyx-catalog-page {
                padding: 132px 18px 84px;
            }

            .onyx-catalog-toolbar {
                align-items: stretch;
                flex-direction: column;
            }

            .onyx-catalog-filters {
                display: grid;
                grid-template-columns: 1fr 1fr;
            }

            .onyx-catalog-pill {
                justify-content: center;
            }

            .onyx-product-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-catalog-page">
        <div class="onyx-catalog-shell">
            <!-- FIXED: Using proper Bootstrap layout for the hero section -->
            <div class="onyx-catalog-hero row align-items-end">
    
                <!-- Left Side: Kicker and Title -->
                <!-- Takes 7 columns on giant screens, 12 columns (stacking) on smaller screens -->
                <div class="col-xl-7 col-lg-12">
                    <div class="onyx-catalog-kicker">ONYX Catalog</div>
                    <h1 class="onyx-catalog-title"><%= CatalogTitle %></h1>
                </div>
    
                <!-- Right Side: Description -->
                <!-- Takes 5 columns on giant screens, stacks below title otherwise -->
                <div class="col-xl-5 col-lg-12 pb-xl-2 mt-4 mt-xl-0">
                    <p class="onyx-catalog-copy" style="max-width: 500px;">
                        <%= CatalogDescription %>
                    </p>
                </div>

            </div>
            <div class="onyx-catalog-toolbar">
                <nav class="onyx-catalog-filters" aria-label="Catalog filters">
                    <a class='<%= GetFilterClass(string.Empty) %>' href="/customer_page/onyx_catalog.aspx">All</a>
                    <a class='<%= GetFilterClass("Mouse") %>' href="/customer_page/onyx_catalog.aspx?category=Mouse">Gaming Mice</a>
                    <a class='<%= GetFilterClass("Keyboard") %>' href="/customer_page/onyx_catalog.aspx?category=Keyboard">Keyboards</a>
                    <a class='<%= GetFilterClass("Headset") %>' href="/customer_page/onyx_catalog.aspx?category=Headset">Audio</a>
                    <a class='<%= GetFilterClass("Accessory") %>' href="/customer_page/onyx_catalog.aspx?category=Accessory">Accessories</a>
                </nav>
                <asp:Literal ID="CatalogCountLiteral" runat="server" />
            </div>

            <asp:Repeater ID="ProductsRepeater" runat="server" OnItemCommand="ProductsRepeater_ItemCommand">
                <HeaderTemplate><div class="onyx-product-grid"></HeaderTemplate>
                <ItemTemplate>
                    <article class="onyx-product-card hover-trigger">
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

            <asp:Panel ID="EmptyCatalogPanel" runat="server" CssClass="onyx-empty-catalog" Visible="false">
                No products match this catalog filter.
            </asp:Panel>
        </div>
    </section>
</asp:Content>
