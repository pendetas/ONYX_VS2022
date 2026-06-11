<%@ Page Title="About" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_about.aspx.cs" Inherits="ONYX_DDAC.customer_page.About" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-about {
            background: #09090b;
            color: #ffffff;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            overflow: hidden;
        }

        .onyx-about *,
        .onyx-about h1,
        .onyx-about h2,
        .onyx-about h3,
        .onyx-about p,
        .onyx-about a,
        .onyx-about span {
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            font-weight: 400;
        }

        .onyx-about-shell {
            margin: 0 auto;
            max-width: 1240px;
            width: min(100% - 48px, 1240px);
        }

        .onyx-about-kicker,
        .onyx-about-index,
        .onyx-about-label,
        .onyx-about-meta,
        .onyx-about-link {
            font-family: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace !important;
            font-size: 12px;
            letter-spacing: 1.2px;
            text-transform: uppercase;
        }

        .onyx-about-hero {
            border-bottom: 1px solid #27272a;
            min-height: 100vh;
            padding: 164px 0 78px;
        }

        .onyx-about-hero-grid {
            align-items: end;
            display: grid;
            gap: clamp(38px, 7vw, 96px);
            grid-template-columns: minmax(0, 1.08fr) minmax(320px, 0.92fr);
        }

        .onyx-about-kicker {
            color: #a1a1aa;
            display: inline-flex;
            gap: 14px;
            margin-bottom: 28px;
        }

        .onyx-about-kicker::before {
            background: #d8dde3;
            content: "";
            height: 1px;
            margin-top: 8px;
            width: 44px;
        }

        .onyx-about h1 {
            color: #ffffff;
            font-size: clamp(58px, 9vw, 136px);
            letter-spacing: -4.8px;
            line-height: 0.92;
            margin: 0;
            max-width: 900px;
        }

        .onyx-about-lede {
            color: #a1a1aa;
            font-size: clamp(18px, 2vw, 24px);
            line-height: 1.58;
            margin: 34px 0 0;
            max-width: 720px;
        }

        .onyx-about-lede strong {
            color: #ffffff;
            font-weight: 400;
        }

        .onyx-about-hero-panel {
            background: #121214;
            border: 1px solid #27272a;
            border-radius: 8px;
            overflow: hidden;
        }

        .onyx-about-hero-image {
            aspect-ratio: 4 / 3;
            background: #050505;
            overflow: hidden;
        }

        .onyx-about-hero-image img {
            display: block;
            height: 100%;
            object-fit: cover;
            width: 100%;
        }

        .onyx-about-hero-panel-body {
            border-top: 1px solid #27272a;
            padding: 24px;
        }

        .onyx-about-label {
            color: #71717a;
            display: block;
            margin-bottom: 16px;
        }

        .onyx-about-hero-panel-body p {
            color: #d4d4d8;
            font-size: 18px;
            line-height: 1.55;
            margin: 0;
        }

        .onyx-about-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 38px;
        }

        .onyx-about-button {
            align-items: center;
            border: 1px solid rgba(255, 255, 255, 0.28);
            border-radius: 999px;
            color: #ffffff;
            display: inline-flex;
            font-family: "JetBrains Mono", ui-monospace, monospace !important;
            font-size: 12px;
            gap: 10px;
            letter-spacing: 1.2px;
            min-height: 48px;
            padding: 0 22px;
            text-decoration: none;
            text-transform: uppercase;
            transition: background 160ms ease, border-color 160ms ease, color 160ms ease, transform 160ms ease;
        }

        .onyx-about-button:hover {
            background: #ffffff;
            border-color: #ffffff;
            color: #09090b;
            transform: translateY(-2px);
        }

        .onyx-about-section {
            border-bottom: 1px solid #27272a;
            padding: clamp(72px, 9vw, 118px) 0;
        }

        .onyx-about-section-heading {
            display: grid;
            gap: 28px;
            grid-template-columns: minmax(180px, 0.32fr) minmax(0, 1fr);
            margin-bottom: 46px;
        }

        .onyx-about-index {
            color: #71717a;
        }

        .onyx-about h2 {
            color: #ffffff;
            font-size: clamp(38px, 6vw, 78px);
            letter-spacing: -2.6px;
            line-height: 0.98;
            margin: 0;
            max-width: 860px;
        }

        .onyx-about-section-copy {
            color: #a1a1aa;
            font-size: clamp(17px, 1.7vw, 22px);
            line-height: 1.6;
            margin: 22px 0 0;
            max-width: 760px;
        }

        .onyx-about-principles {
            display: grid;
            gap: 14px;
            grid-template-columns: repeat(4, minmax(0, 1fr));
        }

        .onyx-about-principle {
            background: #121214;
            border: 1px solid #27272a;
            border-radius: 8px;
            min-height: 270px;
            padding: 24px;
        }

        .onyx-about-principle h3,
        .onyx-about-operation h3,
        .onyx-about-support-card h3 {
            color: #ffffff;
            font-size: 24px;
            letter-spacing: -0.9px;
            line-height: 1.12;
            margin: 0 0 14px;
        }

        .onyx-about-principle p,
        .onyx-about-operation p,
        .onyx-about-support-card p {
            color: #a1a1aa;
            font-size: 15px;
            line-height: 1.65;
            margin: 0;
        }

        .onyx-about-principle .onyx-about-label {
            margin-bottom: 48px;
        }

        .onyx-about-statement {
            display: grid;
            gap: 42px;
            grid-template-columns: minmax(0, 0.9fr) minmax(0, 1.1fr);
        }

        .onyx-about-statement-copy {
            align-self: end;
        }

        .onyx-about-statement-copy p {
            color: #a1a1aa;
            font-size: clamp(18px, 2vw, 25px);
            line-height: 1.55;
            margin: 0;
        }

        .onyx-about-statement-copy p + p {
            margin-top: 22px;
        }

        .onyx-about-statement-media {
            background: #121214;
            border: 1px solid #27272a;
            border-radius: 8px;
            overflow: hidden;
        }

        .onyx-about-statement-media img {
            aspect-ratio: 16 / 10;
            display: block;
            height: auto;
            object-fit: cover;
            width: 100%;
        }

        .onyx-about-operations {
            display: grid;
            gap: 0;
        }

        .onyx-about-operation {
            align-items: start;
            border-top: 1px solid #27272a;
            display: grid;
            gap: 32px;
            grid-template-columns: 150px 1fr 1.05fr;
            padding: 30px 0;
        }

        .onyx-about-operation:last-child {
            border-bottom: 1px solid #27272a;
        }

        .onyx-about-operation .onyx-about-label {
            margin: 0;
        }

        .onyx-about-support-grid {
            display: grid;
            gap: 14px;
            grid-template-columns: repeat(3, minmax(0, 1fr));
        }

        .onyx-about-support-card {
            background: #121214;
            border: 1px solid #27272a;
            border-radius: 8px;
            min-height: 220px;
            padding: 24px;
        }

        .onyx-about-support-card strong {
            color: #ffffff;
            display: block;
            font-size: clamp(26px, 3.2vw, 42px);
            letter-spacing: -1.2px;
            line-height: 1;
            margin-bottom: 22px;
        }

        .onyx-about-cta {
            align-items: center;
            display: grid;
            gap: 30px;
            grid-template-columns: 1fr auto;
        }

        .onyx-about-cta p {
            color: #a1a1aa;
            font-size: 18px;
            line-height: 1.6;
            margin: 22px 0 0;
            max-width: 720px;
        }

        @media (max-width: 1100px) {
            .onyx-about-hero-grid,
            .onyx-about-statement,
            .onyx-about-cta {
                grid-template-columns: 1fr;
            }

            .onyx-about-principles,
            .onyx-about-support-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 760px) {
            .onyx-about-shell {
                width: min(100% - 32px, 1240px);
            }

            .onyx-about-hero {
                padding-top: 124px;
            }

            .onyx-about-section-heading,
            .onyx-about-operation,
            .onyx-about-principles,
            .onyx-about-support-grid {
                grid-template-columns: 1fr;
            }

            .onyx-about-principle {
                min-height: 0;
            }

            .onyx-about-principle .onyx-about-label {
                margin-bottom: 26px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-about" aria-labelledby="about-title">
        <section class="onyx-about-hero">
            <div class="onyx-about-shell onyx-about-hero-grid">
                <div>
                    <span class="onyx-about-kicker">About ONYX</span>
                    <h1 id="about-title">Performance hardware for focused play.</h1>
                    <p class="onyx-about-lede">
                        <strong>ONYX is a black-and-silver gaming hardware company</strong> building peripherals for players who care about control, reliability, and a setup that stays quiet under pressure.
                    </p>
                    <div class="onyx-about-actions">
                        <a class="onyx-about-button" href="/customer_page/onyx_catalog.aspx">Explore catalog</a>
                        <a class="onyx-about-button" href="/customer_page/Support.aspx">Support promise</a>
                    </div>
                </div>

                <aside class="onyx-about-hero-panel" aria-label="ONYX product direction">
                    <div class="onyx-about-hero-image">
                        <img src="/Content/home/products/onyx-mouse.png?v=20260610-about" alt="ONYX black and silver gaming mouse on a dark studio surface" />
                    </div>
                    <div class="onyx-about-hero-panel-body">
                        <span class="onyx-about-label">Company focus</span>
                        <p>Make competitive gear feel precise, durable, and easy to trust from first click to final round.</p>
                    </div>
                </aside>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-shell">
                <div class="onyx-about-section-heading">
                    <span class="onyx-about-index">01 / Mission</span>
                    <div>
                        <h2>We design around the moments that decide a match.</h2>
                        <p class="onyx-about-section-copy">
                            A big setup does not need to be loud. ONYX keeps the visual language restrained so the engineering can do the talking: accurate sensors, crisp inputs, stable audio, and account tools that make ownership simple.
                        </p>
                    </div>
                </div>

                <div class="onyx-about-principles" aria-label="ONYX company principles">
                    <article class="onyx-about-principle">
                        <span class="onyx-about-label">Precision</span>
                        <h3>Control before spectacle</h3>
                        <p>Every product page and hardware promise starts with the same question: will this help the player act with more confidence?</p>
                    </article>
                    <article class="onyx-about-principle">
                        <span class="onyx-about-label">Durability</span>
                        <h3>Built for daily use</h3>
                        <p>Materials, switches, and finishes are selected for repeated sessions, travel, desk wear, and long ownership.</p>
                    </article>
                    <article class="onyx-about-principle">
                        <span class="onyx-about-label">Clarity</span>
                        <h3>No confusing ownership</h3>
                        <p>Wishlist, checkout, order history, settings, support, and reviews are connected around a single customer account.</p>
                    </article>
                    <article class="onyx-about-principle">
                        <span class="onyx-about-label">Restraint</span>
                        <h3>Black, silver, purpose</h3>
                        <p>The design system avoids noisy decoration so the gear feels premium, readable, and focused across every page.</p>
                    </article>
                </div>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-shell onyx-about-statement">
                <div class="onyx-about-statement-media">
                    <img src="/Content/home/products/onyx-keyboard.png?v=20260610-about" alt="ONYX keyboard product photograph in black and silver" />
                </div>
                <div class="onyx-about-statement-copy">
                    <span class="onyx-about-kicker">Product philosophy</span>
                    <p>
                        ONYX products are presented like professional tools, not collectibles. The store is built to help customers compare categories, save gear, buy confidently, and return to their profile when they need order history or reviews.
                    </p>
                    <p>
                        That is the company standard: the product experience and the website experience should feel like they came from the same engineering culture.
                    </p>
                </div>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-shell">
                <div class="onyx-about-section-heading">
                    <span class="onyx-about-index">02 / Operating model</span>
                    <div>
                        <h2>How ONYX turns a gaming setup into a serviceable product ecosystem.</h2>
                    </div>
                </div>

                <div class="onyx-about-operations">
                    <article class="onyx-about-operation">
                        <span class="onyx-about-label">Research</span>
                        <h3>Start with real player friction.</h3>
                        <p>We identify where hardware interrupts performance: missed tracking, unclear audio cues, poor grip, inconsistent switches, or messy account flows.</p>
                    </article>
                    <article class="onyx-about-operation">
                        <span class="onyx-about-label">Build</span>
                        <h3>Translate standards into products.</h3>
                        <p>Mice, keyboards, audio, and accessories are organized by use case so customers can build a complete setup without guessing.</p>
                    </article>
                    <article class="onyx-about-operation">
                        <span class="onyx-about-label">Support</span>
                        <h3>Keep ownership visible.</h3>
                        <p>Orders, reviews, wishlist items, and support paths are kept close to the profile so post-purchase care does not feel hidden.</p>
                    </article>
                </div>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-shell">
                <div class="onyx-about-section-heading">
                    <span class="onyx-about-index">03 / Customer promise</span>
                    <div>
                        <h2>What the ONYX experience should prove.</h2>
                    </div>
                </div>

                <div class="onyx-about-support-grid">
                    <article class="onyx-about-support-card">
                        <strong>Product</strong>
                        <h3>Performance before decoration.</h3>
                        <p>Every product section should make the practical difference clear: control, response, sound, comfort, and setup fit.</p>
                    </article>
                    <article class="onyx-about-support-card">
                        <strong>Account</strong>
                        <h3>Ownership stays connected.</h3>
                        <p>Wishlist, checkout, orders, reviews, and profile details should feel like one customer journey instead of separate pages.</p>
                    </article>
                    <article class="onyx-about-support-card">
                        <strong>Store</strong>
                        <h3>Shopping should stay focused.</h3>
                        <p>The site should guide customers toward the right setup quickly, with fewer repeated claims and clearer next actions.</p>
                    </article>
                </div>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-shell onyx-about-cta">
                <div>
                    <span class="onyx-about-kicker">Next step</span>
                    <h2>Build your ONYX setup.</h2>
                    <p>Browse the catalog, save the gear you are considering, and keep your order history and reviews connected to your account.</p>
                </div>
                <a class="onyx-about-button" href="/customer_page/onyx_catalog.aspx">Shop ONYX</a>
            </div>
        </section>
    </main>
</asp:Content>
