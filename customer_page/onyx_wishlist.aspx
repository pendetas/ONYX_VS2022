<%@ Page Title="Wishlist" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_wishlist.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_wishlist" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-wishlist-page {
            background:
                radial-gradient(circle at 74% 12%, rgba(216, 221, 227, 0.12), transparent 24rem),
                linear-gradient(180deg, #050505 0%, #0a0a0a 48%, #050505 100%);
            color: #ffffff;
            min-height: 100vh;
            padding: 168px 32px 120px;
        }

        .onyx-wishlist-shell {
            margin: 0 auto;
            max-width: 1440px;
        }

        .onyx-wishlist-hero {
            align-items: end;
            border-bottom: 1px solid rgba(255, 255, 255, 0.12);
            display: grid;
            gap: 32px;
            grid-template-columns: minmax(0, 1.1fr) minmax(280px, 0.6fr);
            padding-bottom: 52px;
        }

        .onyx-wishlist-kicker {
            color: rgba(255, 255, 255, 0.45);
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.24em;
            margin-bottom: 22px;
            text-transform: uppercase;
        }

        .onyx-wishlist-title {
            font-family: Syne, Inter, sans-serif;
            font-size: clamp(54px, 8vw, 126px);
            font-weight: 800;
            letter-spacing: -0.05em;
            line-height: 0.88;
            margin: 0;
            text-transform: uppercase;
        }

        .onyx-wishlist-copy {
            color: rgba(255, 255, 255, 0.66);
            font-size: clamp(17px, 2vw, 22px);
            line-height: 1.55;
            margin: 0 0 26px;
        }

        .onyx-wishlist-count {
            align-items: center;
            border: 1px solid rgba(255, 255, 255, 0.16);
            border-radius: 999px;
            color: #d8dde3;
            display: inline-flex;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.16em;
            min-height: 42px;
            padding: 0 18px;
            text-transform: uppercase;
        }

        .onyx-wishlist-feedback {
            color: #d8dde3;
            display: block;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.08em;
            margin-top: 24px;
            text-transform: uppercase;
        }

        .onyx-wishlist-grid {
            display: grid;
            gap: 22px;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            padding-top: 48px;
        }

        .onyx-wishlist-card {
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.07), rgba(255, 255, 255, 0.025));
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 18px;
            min-height: 100%;
            overflow: hidden;
            position: relative;
        }

        .onyx-wishlist-card::before {
            background: radial-gradient(circle at 30% 0%, rgba(255, 255, 255, 0.14), transparent 36%);
            content: "";
            inset: 0;
            opacity: 0;
            pointer-events: none;
            position: absolute;
            transition: opacity 180ms ease;
        }

        .onyx-wishlist-card:hover::before {
            opacity: 1;
        }

        .onyx-wishlist-media {
            align-items: center;
            aspect-ratio: 1.28;
            background: #030303;
            display: flex;
            justify-content: center;
            overflow: hidden;
            padding: 28px;
        }

        .onyx-wishlist-media img {
            filter: drop-shadow(0 28px 42px rgba(0, 0, 0, 0.68));
            height: 100%;
            max-width: 100%;
            object-fit: contain;
            transform: scale(1.02);
            transition: transform 220ms ease;
        }

        .onyx-wishlist-card:hover .onyx-wishlist-media img {
            transform: scale(1.08);
        }

        .onyx-wishlist-body {
            display: flex;
            flex-direction: column;
            gap: 16px;
            min-height: 280px;
            padding: 24px;
            position: relative;
            z-index: 1;
        }

        .onyx-wishlist-meta {
            color: rgba(255, 255, 255, 0.44);
            display: flex;
            font-size: 10px;
            font-weight: 800;
            justify-content: space-between;
            letter-spacing: 0.16em;
            text-transform: uppercase;
        }

        .onyx-wishlist-name {
            font-family: Syne, Inter, sans-serif;
            font-size: 25px;
            font-weight: 800;
            letter-spacing: -0.02em;
            line-height: 1;
            margin: 0;
            text-transform: uppercase;
        }

        .onyx-wishlist-description {
            color: rgba(255, 255, 255, 0.58);
            font-size: 14px;
            line-height: 1.55;
            margin: 0;
        }

        .onyx-wishlist-actions {
            align-items: center;
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            justify-content: space-between;
            margin-top: auto;
        }

        .onyx-wishlist-price {
            color: #ffffff;
            font-size: 15px;
            font-weight: 800;
        }

        .onyx-wishlist-button,
        .onyx-wishlist-link {
            align-items: center;
            border-radius: 999px;
            display: inline-flex;
            font-size: 11px;
            font-weight: 800;
            justify-content: center;
            letter-spacing: 0.07em;
            min-height: 40px;
            padding: 0 16px;
            text-decoration: none;
            text-transform: uppercase;
            transition: background 160ms ease, border-color 160ms ease, color 160ms ease, transform 160ms ease;
            white-space: nowrap;
        }

        .onyx-wishlist-button {
            background: #ffffff;
            border: 1px solid #ffffff;
            color: #050505;
        }

        .onyx-wishlist-button:hover,
        .onyx-wishlist-link:hover {
            transform: translateY(-2px);
        }

        .onyx-wishlist-link {
            background: transparent;
            border: 1px solid rgba(255, 255, 255, 0.16);
            color: rgba(255, 255, 255, 0.78);
        }

        .onyx-wishlist-link:hover {
            border-color: #d8dde3;
            color: #ffffff;
        }

        .onyx-wishlist-remove {
            background: transparent;
            border: 0;
            color: rgba(255, 255, 255, 0.46);
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.14em;
            padding: 0;
            text-transform: uppercase;
            transition: color 160ms ease;
        }

        .onyx-wishlist-remove:hover {
            color: #ffffff;
        }

        .onyx-empty-wishlist {
            border: 1px solid rgba(255, 255, 255, 0.14);
            border-radius: 18px;
            margin-top: 48px;
            overflow: hidden;
        }

        .onyx-empty-wishlist-inner {
            background:
                radial-gradient(circle at 50% 0%, rgba(216, 221, 227, 0.13), transparent 22rem),
                rgba(255, 255, 255, 0.025);
            padding: clamp(48px, 7vw, 92px);
            text-align: center;
        }

        .onyx-empty-wishlist h2 {
            font-family: Syne, Inter, sans-serif;
            font-size: clamp(34px, 5vw, 72px);
            font-weight: 800;
            letter-spacing: -0.04em;
            line-height: 0.95;
            margin: 0 0 20px;
            text-transform: uppercase;
        }

        .onyx-empty-wishlist p {
            color: rgba(255, 255, 255, 0.62);
            font-size: 17px;
            line-height: 1.7;
            margin: 0 auto 30px;
            max-width: 620px;
        }

        @media (max-width: 1080px) {
            .onyx-wishlist-hero {
                grid-template-columns: 1fr;
            }

            .onyx-wishlist-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 720px) {
            .onyx-wishlist-page {
                padding: 132px 18px 84px;
            }

            .onyx-wishlist-grid {
                grid-template-columns: 1fr;
            }

            .onyx-wishlist-actions {
                align-items: stretch;
                flex-direction: column;
            }

            .onyx-wishlist-button,
            .onyx-wishlist-link {
                width: 100%;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-wishlist-page">
        <div class="onyx-wishlist-shell">
            <div class="onyx-wishlist-hero">
                <div>
                    <div class="onyx-wishlist-kicker">ONYX Saved Gear</div>
                    <h1 class="onyx-wishlist-title">Wishlist</h1>
                </div>
                <div>
                    <p class="onyx-wishlist-copy">
                        Keep your next upgrade staged here. Move saved ONYX gear into your cart when the setup is ready.
                    </p>
                    <asp:Literal ID="litWishlistCount" runat="server" />
                    <asp:Label ID="lblFeedback" runat="server" CssClass="onyx-wishlist-feedback" Visible="false" />
                </div>
            </div>

            <asp:Panel ID="pnlEmptyWishlist" runat="server" Visible="false" CssClass="onyx-empty-wishlist">
                <div class="onyx-empty-wishlist-inner">
                    <h2>No saved gear yet.</h2>
                    <p>Browse the catalog and save products you want to compare, revisit, or move into your cart later.</p>
                    <a href="/customer_page/onyx_catalog.aspx" class="onyx-wishlist-button hover-trigger">Explore Catalog</a>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlWishlist" runat="server">
                <asp:Repeater ID="rptWishlistItems" runat="server" OnItemCommand="rptWishlistItems_ItemCommand">
                    <HeaderTemplate><div class="onyx-wishlist-grid"></HeaderTemplate>
                    <ItemTemplate>
                        <article class="onyx-wishlist-card hover-trigger">
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
                                <div class="onyx-wishlist-actions">
                                    <span class="onyx-wishlist-price"><%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("Price")) %></span>
                                    <a class="onyx-wishlist-link hover-trigger" href='<%# "onyx_product_details.aspx?id=" + Eval("Id") %>'>View</a>
                                    <asp:LinkButton ID="btnMoveToCart" runat="server"
                                        CommandName="MoveToCart"
                                        CommandArgument='<%# Eval("Id") %>'
                                        CssClass="onyx-wishlist-button hover-trigger">
                                        Move to Cart
                                    </asp:LinkButton>
                                </div>
                                <asp:LinkButton ID="btnRemoveWishlist" runat="server"
                                    CommandName="Remove"
                                    CommandArgument='<%# Eval("Id") %>'
                                    CssClass="onyx-wishlist-remove hover-trigger">
                                    Remove from wishlist
                                </asp:LinkButton>
                            </div>
                        </article>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                </asp:Repeater>
            </asp:Panel>
        </div>
    </section>
</asp:Content>
