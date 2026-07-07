<%@ Page Title="Support" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="Support.aspx.cs" Inherits="ONYX_DDAC.customer_page.Support" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-support-page {
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

        .onyx-support-page *,
        .onyx-support-page h1,
        .onyx-support-page h2,
        .onyx-support-page h3,
        .onyx-support-page p,
        .onyx-support-page a,
        .onyx-support-page span {
            box-sizing: border-box;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif !important;
            font-weight: 400 !important;
            letter-spacing: 0 !important;
        }

        .onyx-support-shell {
            margin: 0 auto;
            max-width: 1180px;
            width: min(100% - 48px, 1180px);
        }

        .onyx-support-kicker,
        .onyx-support-label,
        .onyx-support-button {
            color: var(--soft);
            font-family: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace !important;
            font-size: 12px;
            line-height: 1.4;
            text-transform: uppercase;
        }

        .onyx-support-hero {
            border-bottom: 1px solid var(--line);
            padding: 156px 0 72px;
        }

        .onyx-support-hero-grid,
        .onyx-support-contact {
            align-items: end;
            display: grid;
            gap: 36px;
            grid-template-columns: minmax(0, 1fr) minmax(300px, 420px);
        }

        .onyx-support-contact {
            align-items: start;
            grid-template-columns: minmax(300px, 0.82fr) minmax(0, 1.18fr);
        }

        .onyx-support-kicker {
            display: inline-flex;
            gap: 12px;
            margin-bottom: 24px;
        }

        .onyx-support-kicker::before {
            background: var(--soft);
            content: "";
            height: 1px;
            margin-top: 8px;
            width: 36px;
        }

        .onyx-support-page h1 {
            color: var(--text) !important;
            font-size: 84px;
            line-height: 0.96;
            margin: 0;
            max-width: 860px;
        }

        .onyx-support-page h2 {
            color: var(--text) !important;
            font-size: 52px;
            line-height: 1.03;
            margin: 0;
            max-width: 820px;
        }

        .onyx-support-page h3 {
            color: var(--text) !important;
            font-size: 22px;
            line-height: 1.2;
            margin: 0 0 12px;
        }

        .onyx-support-lede,
        .onyx-support-copy,
        .onyx-support-card p,
        .onyx-support-row p,
        .onyx-support-faq p {
            color: var(--muted) !important;
            font-size: 17px;
            line-height: 1.68;
            margin: 0;
        }

        .onyx-support-lede {
            margin-top: 28px;
            max-width: 700px;
        }

        .onyx-support-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 34px;
        }

        .onyx-support-button {
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

        .onyx-support-button:hover {
            background: var(--text);
            border-color: var(--text);
            color: var(--bg) !important;
            transform: translateY(-2px);
        }

        .onyx-support-status,
        .onyx-support-card,
        .onyx-support-row,
        .onyx-support-faq details {
            background: var(--panel) !important;
            border: 1px solid var(--line) !important;
            border-radius: 8px !important;
            box-shadow: none !important;
        }

        .onyx-support-status {
            overflow: hidden;
        }

        .onyx-support-status-item {
            border-top: 1px solid var(--line);
            padding: 24px;
        }

        .onyx-support-status-item:first-child {
            border-top: 0;
        }

        .onyx-support-status strong {
            color: var(--text);
            display: block;
            font-size: 34px;
            line-height: 1;
            margin: 10px 0;
        }

        .onyx-support-status p {
            color: var(--muted) !important;
            font-size: 15px;
            line-height: 1.6;
            margin: 0;
        }

        .onyx-support-section {
            border-bottom: 1px solid var(--line);
            padding: 84px 0;
        }

        .onyx-support-heading {
            display: grid;
            gap: 22px;
            grid-template-columns: 180px minmax(0, 1fr);
            margin-bottom: 36px;
        }

        .onyx-support-card-grid {
            display: grid;
            gap: 14px;
            grid-template-columns: repeat(4, minmax(0, 1fr));
        }

        .onyx-support-card {
            min-height: 250px;
            padding: 24px;
        }

        .onyx-support-card .onyx-support-label {
            display: block;
            margin-bottom: 42px;
        }

        .onyx-support-contact-card {
            background: var(--panel-strong);
            border: 1px solid var(--line);
            border-radius: 8px;
            padding: 28px;
        }

        .onyx-support-contact-list {
            display: grid;
            gap: 0;
            margin-top: 28px;
        }

        .onyx-support-contact-line {
            align-items: start;
            border-top: 1px solid var(--line);
            display: grid;
            gap: 14px;
            grid-template-columns: 130px minmax(0, 1fr);
            padding: 16px 0;
        }

        .onyx-support-contact-line:last-child {
            border-bottom: 1px solid var(--line);
        }

        .onyx-support-contact-line a,
        .onyx-support-contact-line strong {
            color: var(--text) !important;
            overflow-wrap: anywhere;
            text-decoration: none;
        }

        .onyx-support-checklist {
            display: grid;
            gap: 12px;
        }

        .onyx-support-row {
            align-items: start;
            display: grid;
            gap: 24px;
            grid-template-columns: 140px minmax(160px, 0.7fr) minmax(0, 1fr);
            padding: 22px;
        }

        .onyx-support-faq {
            display: grid;
            gap: 12px;
        }

        .onyx-support-faq details {
            padding: 0 22px;
        }

        .onyx-support-faq summary {
            color: var(--text);
            cursor: pointer;
            font-size: 20px;
            line-height: 1.3;
            list-style: none;
            padding: 22px 0;
        }

        .onyx-support-faq summary::-webkit-details-marker {
            display: none;
        }

        .onyx-support-faq p {
            border-top: 1px solid var(--line);
            padding: 18px 0 22px;
        }

        @media (max-width: 1080px) {
            .onyx-support-card-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 980px) {
            .onyx-support-hero-grid,
            .onyx-support-contact {
                grid-template-columns: 1fr;
            }

            .onyx-support-page h1 {
                font-size: 62px;
            }

            .onyx-support-page h2 {
                font-size: 40px;
            }
        }

        @media (max-width: 680px) {
            .onyx-support-shell {
                width: min(100% - 32px, 1180px);
            }

            .onyx-support-hero {
                padding: 124px 0 54px;
            }

            .onyx-support-section {
                padding: 62px 0;
            }

            .onyx-support-heading,
            .onyx-support-card-grid,
            .onyx-support-row,
            .onyx-support-contact-line {
                grid-template-columns: 1fr;
            }

            .onyx-support-page h1 {
                font-size: 42px;
            }

            .onyx-support-page h2 {
                font-size: 32px;
            }

            .onyx-support-card {
                min-height: 0;
            }

            .onyx-support-card .onyx-support-label {
                margin-bottom: 24px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-support-page" aria-labelledby="support-title">
        <section class="onyx-support-hero">
            <div class="onyx-support-shell onyx-support-hero-grid">
                <div>
                    <span class="onyx-support-kicker">ONYX Support</span>
                    <h1 id="support-title">Clear help for orders, gear, and accounts.</h1>
                    <p class="onyx-support-lede">
                        Start with the right lane and send the details support needs first. ONYX handles orders, warranty, returns, setup, and account questions through one support address.
                    </p>
                    <div class="onyx-support-actions">
                        <a class="onyx-support-button hover-trigger" href="mailto:support@onyxgaming.com?subject=ONYX%20Support%20Request">Email support</a>
                        <a class="onyx-support-button hover-trigger" href="#support-lanes">Choose a lane</a>
                    </div>
                </div>

                <aside class="onyx-support-status" aria-label="ONYX support standards">
                    <div class="onyx-support-status-item">
                        <span class="onyx-support-label">Average first reply</span>
                        <strong>24h</strong>
                        <p>Usually around one business day.</p>
                    </div>
                    <div class="onyx-support-status-item">
                        <span class="onyx-support-label">Support hours</span>
                        <strong>10:00-18:00</strong>
                        <p>Monday to Friday, MYT.</p>
                    </div>
                    <div class="onyx-support-status-item">
                        <span class="onyx-support-label">Fastest route</span>
                        <strong>Order + serial</strong>
                        <p>Include both when the issue is product or order related.</p>
                    </div>
                </aside>
            </div>
        </section>

        <section id="support-lanes" class="onyx-support-section">
            <div class="onyx-support-shell">
                <div class="onyx-support-heading">
                    <span class="onyx-support-label">Support lanes</span>
                    <h2>Pick the lane that matches the problem.</h2>
                </div>

                <div class="onyx-support-card-grid">
                    <article class="onyx-support-card">
                        <span class="onyx-support-label">Orders</span>
                        <h3>Tracking, receipt, delivery, or missing item.</h3>
                        <p>Use for payment, invoice, wrong address, receipt, tracking, delivery, and missing item questions.</p>
                    </article>
                    <article class="onyx-support-card">
                        <span class="onyx-support-label">Warranty</span>
                        <h3>Defect or hardware fault.</h3>
                        <p>Use for sensor issues, switch faults, charging problems, headset audio faults, and manufacturing defects.</p>
                    </article>
                    <article class="onyx-support-card">
                        <span class="onyx-support-label">Returns</span>
                        <h3>Return or replacement review.</h3>
                        <p>Use for unopened items, damaged delivery, wrong products, and replacement eligibility.</p>
                    </article>
                    <article class="onyx-support-card">
                        <span class="onyx-support-label">Setup</span>
                        <h3>Device, profile, cart, or account flow.</h3>
                        <p>Use for pairing, DPI, macros, login, wishlist, cart, profile, and order history guidance.</p>
                    </article>
                </div>
            </div>
        </section>

        <section class="onyx-support-section">
            <div class="onyx-support-shell onyx-support-contact">
                <div class="onyx-support-contact-card">
                    <span class="onyx-support-kicker">Contact</span>
                    <h2>Email the support team.</h2>
                    <p class="onyx-support-copy">Send the request to support with the details listed beside this panel. Do not include passwords or payment card details.</p>

                    <div class="onyx-support-contact-list">
                        <div class="onyx-support-contact-line">
                            <span class="onyx-support-label">Email</span>
                            <a class="hover-trigger" href="mailto:support@onyxgaming.com">support@onyxgaming.com</a>
                        </div>
                        <div class="onyx-support-contact-line">
                            <span class="onyx-support-label">Location</span>
                            <strong>Kuala Lumpur, Malaysia</strong>
                        </div>
                    </div>
                </div>

                <div class="onyx-support-checklist">
                    <article class="onyx-support-row">
                        <span class="onyx-support-label">Orders</span>
                        <h3>Send purchase context.</h3>
                        <p>Order ID, purchase date, account email, what happened, and evidence if available.</p>
                    </article>
                    <article class="onyx-support-row">
                        <span class="onyx-support-label">Warranty</span>
                        <h3>Identify the unit.</h3>
                        <p>Product name, variant, serial number, order ID, purchase date, issue description, troubleshooting tried, and photo or short video if available.</p>
                    </article>
                    <article class="onyx-support-row">
                        <span class="onyx-support-label">Returns</span>
                        <h3>Describe condition.</h3>
                        <p>Order ID, product name, purchase date, whether the item is unopened, damaged, wrong, or defective, plus packaging photos if available.</p>
                    </article>
                </div>
            </div>
        </section>

        <section class="onyx-support-section">
            <div class="onyx-support-shell">
                <div class="onyx-support-heading">
                    <span class="onyx-support-label">FAQ</span>
                    <h2>Quick answers before you wait.</h2>
                </div>

                <div class="onyx-support-faq">
                    <details>
                        <summary>What should I include in a warranty request?</summary>
                        <p>Include your order ID, purchase date, account email, product name, variant, serial number, issue description, when it started, what you already tried, and photos, screenshots, or a short video if available.</p>
                    </details>
                    <details>
                        <summary>Can I return an opened product?</summary>
                        <p>The current ONYX policy shown on this site does not specify opened-product return eligibility. Email support@onyxgaming.com with your order ID, product name, purchase date, and item condition.</p>
                    </details>
                    <details>
                        <summary>Where do I find order history?</summary>
                        <p>Log in to your ONYX account and open the profile or order history area. If you cannot access it, email support with your account email and any available order details.</p>
                    </details>
                    <details>
                        <summary>How long does ONYX support take to reply?</summary>
                        <p>ONYX lists an average first reply of around 24 hours, usually around one business day.</p>
                    </details>
                </div>
            </div>
        </section>
    </main>
</asp:Content>
