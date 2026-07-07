<%@ Page Title="About" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="ONYX_DDAC.customer_page.About" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-about-page {
            --bg: #09090b;
            --panel: #121214;
            --panel-strong: #18181b;
            --line: #27272a;
            --text: #ffffff;
            --muted: #a1a1aa;
            --soft: #d8dde3;
            background: var(--bg);
            color: var(--text);
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            min-height: 100vh;
            overflow: hidden;
        }

        .onyx-about-page *,
        .onyx-about-page h1,
        .onyx-about-page h2,
        .onyx-about-page h3,
        .onyx-about-page p,
        .onyx-about-page a,
        .onyx-about-page span {
            box-sizing: border-box;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif !important;
            font-weight: 400 !important;
            letter-spacing: 0 !important;
        }

        .onyx-about-shell {
            margin: 0 auto;
            max-width: 1180px;
            width: min(100% - 48px, 1180px);
        }

        .onyx-about-kicker,
        .onyx-about-label,
        .onyx-about-button {
            color: var(--soft);
            font-family: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace !important;
            font-size: 12px;
            line-height: 1.4;
            text-transform: uppercase;
        }

        .onyx-about-hero {
            border-bottom: 1px solid var(--line);
            padding: 156px 0 72px;
        }

        .onyx-about-hero-grid,
        .onyx-about-split,
        .onyx-about-cta {
            display: grid;
            gap: 36px;
            grid-template-columns: minmax(0, 1fr) minmax(300px, 420px);
        }

        .onyx-about-hero-grid,
        .onyx-about-cta {
            align-items: end;
        }

        .onyx-about-kicker {
            display: inline-flex;
            gap: 12px;
            margin-bottom: 24px;
        }

        .onyx-about-kicker::before {
            background: var(--soft);
            content: "";
            height: 1px;
            margin-top: 8px;
            width: 36px;
        }

        .onyx-about-page h1 {
            color: var(--text) !important;
            font-size: 84px;
            line-height: 0.96;
            margin: 0;
            max-width: 880px;
        }

        .onyx-about-page h2 {
            color: var(--text) !important;
            font-size: 52px;
            line-height: 1.03;
            margin: 0;
            max-width: 820px;
        }

        .onyx-about-page h3 {
            color: var(--text) !important;
            font-size: 22px;
            line-height: 1.2;
            margin: 0 0 12px;
        }

        .onyx-about-lede,
        .onyx-about-copy,
        .onyx-about-card p,
        .onyx-about-row p,
        .onyx-about-cta p {
            color: var(--muted) !important;
            font-size: 17px;
            line-height: 1.68;
            margin: 0;
        }

        .onyx-about-lede {
            margin-top: 28px;
            max-width: 700px;
        }

        .onyx-about-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 34px;
        }

        .onyx-about-button {
            align-items: center;
            border: 1px solid rgba(255, 255, 255, 0.28);
            border-radius: 999px;
            color: var(--text) !important;
            display: inline-flex;
            min-height: 46px;
            padding: 0 20px;
            text-decoration: none;
            transition: background 160ms ease, border-color 160ms ease, color 160ms ease, transform 160ms ease;
        }

        .onyx-about-button:hover {
            background: var(--text);
            border-color: var(--text);
            color: var(--bg) !important;
            transform: translateY(-2px);
        }

        .onyx-about-product {
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 8px;
            overflow: hidden;
        }

        .onyx-about-product img {
            aspect-ratio: 4 / 3;
            background: #050505;
            display: block;
            object-fit: contain;
            padding: 26px;
            width: 100%;
        }

        .onyx-about-product-body {
            border-top: 1px solid var(--line);
            padding: 22px;
        }

        .onyx-about-product-body p {
            color: var(--muted) !important;
            font-size: 15px;
            line-height: 1.6;
            margin: 12px 0 0;
        }

        .onyx-about-section {
            border-bottom: 1px solid var(--line);
            padding: 84px 0;
        }

        .onyx-about-heading {
            display: grid;
            gap: 22px;
            grid-template-columns: 180px minmax(0, 1fr);
            margin-bottom: 36px;
        }

        .onyx-about-card-grid {
            display: grid;
            gap: 14px;
            grid-template-columns: repeat(3, minmax(0, 1fr));
        }

        .onyx-about-card,
        .onyx-about-row {
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 8px;
            padding: 24px;
        }

        .onyx-about-card {
            min-height: 220px;
        }

        .onyx-about-card .onyx-about-label {
            display: block;
            margin-bottom: 42px;
        }

        .onyx-about-row-list {
            display: grid;
            gap: 12px;
        }

        .onyx-about-row {
            align-items: start;
            display: grid;
            gap: 24px;
            grid-template-columns: 150px minmax(180px, 0.7fr) minmax(0, 1fr);
        }

        .onyx-about-split {
            align-items: center;
            grid-template-columns: minmax(280px, 0.9fr) minmax(0, 1.1fr);
        }

        .onyx-about-split img {
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 8px;
            display: block;
            object-fit: contain;
            padding: 28px;
            width: 100%;
        }

        .onyx-about-copy {
            margin-top: 24px;
            max-width: 700px;
        }

        .onyx-about-cta p {
            margin-top: 18px;
            max-width: 620px;
        }

        @media (max-width: 980px) {
            .onyx-about-hero-grid,
            .onyx-about-split,
            .onyx-about-cta {
                grid-template-columns: 1fr;
            }

            .onyx-about-card-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .onyx-about-page h1 {
                font-size: 62px;
            }

            .onyx-about-page h2 {
                font-size: 40px;
            }
        }

        @media (max-width: 680px) {
            .onyx-about-shell {
                width: min(100% - 32px, 1180px);
            }

            .onyx-about-hero {
                padding: 124px 0 54px;
            }

            .onyx-about-section {
                padding: 62px 0;
            }

            .onyx-about-heading,
            .onyx-about-card-grid,
            .onyx-about-row {
                grid-template-columns: 1fr;
            }

            .onyx-about-page h1 {
                font-size: 42px;
            }

            .onyx-about-page h2 {
                font-size: 32px;
            }

            .onyx-about-card {
                min-height: 0;
            }

            .onyx-about-card .onyx-about-label {
                margin-bottom: 24px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-about-page" aria-labelledby="about-title">
        <section class="onyx-about-hero">
            <div class="onyx-about-shell onyx-about-hero-grid">
                <div>
                    <span class="onyx-about-kicker">About ONYX</span>
                    <h1 id="about-title">Performance gear with a quiet edge.</h1>
                    <p class="onyx-about-lede">
                        ONYX is a black-and-silver gaming hardware brand for players who want precise control, reliable inputs, clean audio, and a setup that stays focused.
                    </p>
                    <div class="onyx-about-actions">
                        <a class="onyx-about-button hover-trigger" href="/customer_page/proGears.aspx">View pro gear</a>
                        <a class="onyx-about-button hover-trigger" href="/customer_page/Support.aspx">Get support</a>
                    </div>
                </div>

                <aside class="onyx-about-product" aria-label="ONYX product direction">
                    <img src="/Content/home/products/onyx-mouse.png?v=20260702-about" alt="Black and silver ONYX gaming mouse" />
                    <div class="onyx-about-product-body">
                        <span class="onyx-about-label">Brand focus</span>
                        <p>Hardware that feels controlled during long sessions and simple after purchase.</p>
                    </div>
                </aside>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-shell">
                <div class="onyx-about-heading">
                    <span class="onyx-about-label">What we build</span>
                    <h2>Gaming peripherals organized around real setup decisions.</h2>
                </div>

                <div class="onyx-about-card-grid">
                    <article class="onyx-about-card">
                        <span class="onyx-about-label">Control</span>
                        <h3>Aim and movement stay readable.</h3>
                        <p>Mice and accessories are framed around grip, response, and comfort instead of noisy product claims.</p>
                    </article>
                    <article class="onyx-about-card">
                        <span class="onyx-about-label">Response</span>
                        <h3>Inputs are treated like match tools.</h3>
                        <p>Keyboards, switches, and setup choices are presented by how they support fast, repeatable play.</p>
                    </article>
                    <article class="onyx-about-card">
                        <span class="onyx-about-label">Ownership</span>
                        <h3>Support is part of the product.</h3>
                        <p>Accounts, order history, warranty preparation, returns, and setup guidance stay close to the shopping flow.</p>
                    </article>
                </div>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-shell onyx-about-split">
                <img src="/Content/home/products/onyx-keyboard.png?v=20260702-about" alt="Black ONYX gaming keyboard" />
                <div>
                    <span class="onyx-about-kicker">Design standard</span>
                    <h2>Less visual noise. More useful signal.</h2>
                    <p class="onyx-about-copy">
                        ONYX uses a restrained black-and-silver system so product choices stay clear. The store should help customers compare gear, save items, buy confidently, and return later for support without hunting through unrelated pages.
                    </p>
                </div>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-shell">
                <div class="onyx-about-heading">
                    <span class="onyx-about-label">How it works</span>
                    <h2>A simple path from product discovery to post-purchase help.</h2>
                </div>

                <div class="onyx-about-row-list">
                    <article class="onyx-about-row">
                        <span class="onyx-about-label">Shop</span>
                        <h3>Choose by setup need.</h3>
                        <p>Browse by mouse, keyboard, headset, or accessory category, then compare products by fit and use case.</p>
                    </article>
                    <article class="onyx-about-row">
                        <span class="onyx-about-label">Own</span>
                        <h3>Keep account history visible.</h3>
                        <p>Wishlist, cart, orders, reviews, and profile details are connected to the customer account flow.</p>
                    </article>
                    <article class="onyx-about-row">
                        <span class="onyx-about-label">Support</span>
                        <h3>Route issues correctly.</h3>
                        <p>Orders, warranty, returns, setup, and account questions each have a clear support lane.</p>
                    </article>
                </div>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-shell onyx-about-cta">
                <div>
                    <span class="onyx-about-kicker">Next step</span>
                    <h2>Build a cleaner ONYX setup.</h2>
                    <p>Start with the pro gear page for a focused view of the core ONYX setup, or open the full catalog when you already know the category.</p>
                </div>
                <div class="onyx-about-actions">
                    <a class="onyx-about-button hover-trigger" href="/customer_page/proGears.aspx">Open pro gear</a>
                    <a class="onyx-about-button hover-trigger" href="/customer_page/onyx_catalog.aspx">Full catalog</a>
                </div>
            </div>
        </section>
    </main>
</asp:Content>
