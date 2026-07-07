<%@ Page Title="Pro Gears" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="proGears.aspx.cs" Inherits="ONYX_DDAC.customer_page.proGears" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-pro-page {
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

        .onyx-pro-page *,
        .onyx-pro-page h1,
        .onyx-pro-page h2,
        .onyx-pro-page h3,
        .onyx-pro-page p,
        .onyx-pro-page a,
        .onyx-pro-page span {
            box-sizing: border-box;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif !important;
            font-weight: 400 !important;
            letter-spacing: 0 !important;
        }

        .onyx-pro-shell {
            margin: 0 auto;
            max-width: 1180px;
            width: min(100% - 48px, 1180px);
        }

        .onyx-pro-kicker,
        .onyx-pro-label,
        .onyx-pro-button {
            color: var(--soft);
            font-family: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace !important;
            font-size: 12px;
            line-height: 1.4;
            text-transform: uppercase;
        }

        .onyx-pro-hero {
            border-bottom: 1px solid var(--line);
            padding: 156px 0 72px;
        }

        .onyx-pro-hero-grid,
        .onyx-pro-feature,
        .onyx-pro-cta {
            display: grid;
            gap: 36px;
            grid-template-columns: minmax(0, 1fr) minmax(300px, 420px);
        }

        .onyx-pro-hero-grid,
        .onyx-pro-feature,
        .onyx-pro-cta {
            align-items: center;
        }

        .onyx-pro-kicker {
            display: inline-flex;
            gap: 12px;
            margin-bottom: 24px;
        }

        .onyx-pro-kicker::before {
            background: var(--soft);
            content: "";
            height: 1px;
            margin-top: 8px;
            width: 36px;
        }

        .onyx-pro-page h1 {
            color: var(--text) !important;
            font-size: 84px;
            line-height: 0.96;
            margin: 0;
            max-width: 860px;
        }

        .onyx-pro-page h2 {
            color: var(--text) !important;
            font-size: 52px;
            line-height: 1.03;
            margin: 0;
            max-width: 820px;
        }

        .onyx-pro-page h3 {
            color: var(--text) !important;
            font-size: 22px;
            line-height: 1.2;
            margin: 0 0 12px;
        }

        .onyx-pro-lede,
        .onyx-pro-card p,
        .onyx-pro-row p,
        .onyx-pro-cta p {
            color: var(--muted) !important;
            font-size: 17px;
            line-height: 1.68;
            margin: 0;
        }

        .onyx-pro-lede {
            margin-top: 28px;
            max-width: 700px;
        }

        .onyx-pro-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 34px;
        }

        .onyx-pro-button {
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

        .onyx-pro-button:hover {
            background: var(--text);
            border-color: var(--text);
            color: var(--bg) !important;
            transform: translateY(-2px);
        }

        .onyx-pro-stage,
        .onyx-pro-card,
        .onyx-pro-row {
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 8px;
        }

        .onyx-pro-stage {
            overflow: hidden;
        }

        .onyx-pro-stage img {
            aspect-ratio: 4 / 3;
            background: #050505;
            display: block;
            object-fit: contain;
            padding: 26px;
            width: 100%;
        }

        .onyx-pro-stage-body {
            border-top: 1px solid var(--line);
            padding: 22px;
        }

        .onyx-pro-stage-body p {
            color: var(--muted) !important;
            font-size: 15px;
            line-height: 1.6;
            margin: 12px 0 0;
        }

        .onyx-pro-section {
            border-bottom: 1px solid var(--line);
            padding: 84px 0;
        }

        .onyx-pro-heading {
            display: grid;
            gap: 22px;
            grid-template-columns: 180px minmax(0, 1fr);
            margin-bottom: 36px;
        }

        .onyx-pro-card-grid {
            display: grid;
            gap: 14px;
            grid-template-columns: repeat(4, minmax(0, 1fr));
        }

        .onyx-pro-card {
            color: var(--text);
            display: block;
            min-height: 320px;
            overflow: hidden;
            text-decoration: none;
            transition: border-color 160ms ease, transform 160ms ease;
        }

        .onyx-pro-card:hover {
            border-color: rgba(255, 255, 255, 0.42);
            transform: translateY(-3px);
        }

        .onyx-pro-card img {
            aspect-ratio: 4 / 3;
            background: #050505;
            display: block;
            object-fit: contain;
            padding: 24px;
            width: 100%;
        }

        .onyx-pro-card-body {
            border-top: 1px solid var(--line);
            padding: 20px;
        }

        .onyx-pro-card-body .onyx-pro-label {
            display: block;
            margin-bottom: 18px;
        }

        .onyx-pro-row-list {
            display: grid;
            gap: 12px;
        }

        .onyx-pro-row {
            align-items: start;
            display: grid;
            gap: 24px;
            grid-template-columns: 150px minmax(170px, 0.75fr) minmax(0, 1fr);
            padding: 22px;
        }

        .onyx-pro-cta p {
            margin-top: 18px;
            max-width: 620px;
        }

        @media (max-width: 1080px) {
            .onyx-pro-card-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 980px) {
            .onyx-pro-hero-grid,
            .onyx-pro-feature,
            .onyx-pro-cta {
                grid-template-columns: 1fr;
            }

            .onyx-pro-page h1 {
                font-size: 62px;
            }

            .onyx-pro-page h2 {
                font-size: 40px;
            }
        }

        @media (max-width: 680px) {
            .onyx-pro-shell {
                width: min(100% - 32px, 1180px);
            }

            .onyx-pro-hero {
                padding: 124px 0 54px;
            }

            .onyx-pro-section {
                padding: 62px 0;
            }

            .onyx-pro-heading,
            .onyx-pro-card-grid,
            .onyx-pro-row {
                grid-template-columns: 1fr;
            }

            .onyx-pro-page h1 {
                font-size: 42px;
            }

            .onyx-pro-page h2 {
                font-size: 32px;
            }

            .onyx-pro-card {
                min-height: 0;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-pro-page" aria-labelledby="pro-title">
        <section class="onyx-pro-hero">
            <div class="onyx-pro-shell onyx-pro-hero-grid">
                <div>
                    <span class="onyx-pro-kicker">Pro gear</span>
                    <h1 id="pro-title">A focused ONYX setup, category by category.</h1>
                    <p class="onyx-pro-lede">
                        Start here when you want a clean performance setup without browsing every product first. Choose the part of your desk that changes your game the most.
                    </p>
                    <div class="onyx-pro-actions">
                        <a class="onyx-pro-button hover-trigger" href="/customer_page/onyx_catalog.aspx">Shop all gear</a>
                        <a class="onyx-pro-button hover-trigger" href="#pro-categories">Browse categories</a>
                    </div>
                </div>

                <aside class="onyx-pro-stage" aria-label="Featured ONYX pro mouse">
                    <img src="/Content/home/onyx-pro-mouse.png?v=20260702-pro" alt="ONYX pro gaming mouse" />
                    <div class="onyx-pro-stage-body">
                        <span class="onyx-pro-label">Featured setup signal</span>
                        <p>Precision first: mouse, keyboard, audio, then the desk pieces that keep everything stable.</p>
                    </div>
                </aside>
            </div>
        </section>

        <section id="pro-categories" class="onyx-pro-section">
            <div class="onyx-pro-shell">
                <div class="onyx-pro-heading">
                    <span class="onyx-pro-label">Categories</span>
                    <h2>Build from the control point outward.</h2>
                </div>

                <div class="onyx-pro-card-grid">
                    <a class="onyx-pro-card hover-trigger" href="/customer_page/onyx_catalog.aspx?category=Mouse">
                        <img src="/Content/home/products/onyx-mouse.png?v=20260702-pro" alt="ONYX gaming mouse" />
                        <div class="onyx-pro-card-body">
                            <span class="onyx-pro-label">Mice</span>
                            <h3>Tracking and grip.</h3>
                            <p>Start here if aim, comfort, or hand feel is the main upgrade.</p>
                        </div>
                    </a>
                    <a class="onyx-pro-card hover-trigger" href="/customer_page/onyx_catalog.aspx?category=Keyboard">
                        <img src="/Content/home/products/onyx-keyboard.png?v=20260702-pro" alt="ONYX gaming keyboard" />
                        <div class="onyx-pro-card-body">
                            <span class="onyx-pro-label">Keyboards</span>
                            <h3>Fast, repeatable inputs.</h3>
                            <p>Use this path when movement, binds, and desk rhythm matter most.</p>
                        </div>
                    </a>
                    <a class="onyx-pro-card hover-trigger" href="/customer_page/onyx_catalog.aspx?category=Headset">
                        <img src="/Content/home/products/onyx-headset.png?v=20260702-pro" alt="ONYX gaming headset" />
                        <div class="onyx-pro-card-body">
                            <span class="onyx-pro-label">Audio</span>
                            <h3>Cleaner cues.</h3>
                            <p>Choose audio gear when positioning, clarity, and team comms need attention.</p>
                        </div>
                    </a>
                    <a class="onyx-pro-card hover-trigger" href="/customer_page/onyx_catalog.aspx?category=Accessory">
                        <img src="/Content/home/products/onyx-monitor.png?v=20260702-pro" alt="ONYX setup display" />
                        <div class="onyx-pro-card-body">
                            <span class="onyx-pro-label">Accessories</span>
                            <h3>Desk support.</h3>
                            <p>Finish the setup with the pieces that keep daily play stable and organized.</p>
                        </div>
                    </a>
                </div>
            </div>
        </section>

        <section class="onyx-pro-section">
            <div class="onyx-pro-shell">
                <div class="onyx-pro-heading">
                    <span class="onyx-pro-label">Setup order</span>
                    <h2>A practical upgrade path.</h2>
                </div>

                <div class="onyx-pro-row-list">
                    <article class="onyx-pro-row">
                        <span class="onyx-pro-label">01</span>
                        <h3>Fix control first.</h3>
                        <p>Pick the mouse shape and connection style that matches how you aim and how long you play.</p>
                    </article>
                    <article class="onyx-pro-row">
                        <span class="onyx-pro-label">02</span>
                        <h3>Match inputs to habit.</h3>
                        <p>Choose keyboard gear around the inputs you repeat most: movement, abilities, shortcuts, and macros.</p>
                    </article>
                    <article class="onyx-pro-row">
                        <span class="onyx-pro-label">03</span>
                        <h3>Complete the support layer.</h3>
                        <p>Add audio and desk accessories once the main control pieces feel right.</p>
                    </article>
                </div>
            </div>
        </section>

        <section class="onyx-pro-section">
            <div class="onyx-pro-shell onyx-pro-cta">
                <div>
                    <span class="onyx-pro-kicker">Ready</span>
                    <h2>Open the catalog with a clearer target.</h2>
                    <p>Use the category links above when you know the part to upgrade, or browse the full catalog for the complete ONYX lineup.</p>
                </div>
                <div class="onyx-pro-actions">
                    <a class="onyx-pro-button hover-trigger" href="/customer_page/onyx_catalog.aspx">Full catalog</a>
                    <a class="onyx-pro-button hover-trigger" href="/customer_page/Support.aspx">Ask support</a>
                </div>
            </div>
        </section>
    </main>
</asp:Content>
