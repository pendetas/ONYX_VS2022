<%@ Page Title="Support" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_support.aspx.cs" Inherits="ONYX_DDAC.customer_page.Support" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-support {
            background: #09090b;
            color: #ffffff;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            min-height: 100vh;
            overflow: hidden;
        }

        .onyx-support *,
        .onyx-support h1,
        .onyx-support h2,
        .onyx-support h3,
        .onyx-support p,
        .onyx-support a,
        .onyx-support span,
        .onyx-support label,
        .onyx-support input,
        .onyx-support select,
        .onyx-support textarea {
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            font-weight: 400;
        }

        .onyx-support-shell {
            margin: 0 auto;
            max-width: 1240px;
            width: min(100% - 48px, 1240px);
        }

        .onyx-support-kicker,
        .onyx-support-index,
        .onyx-support-label,
        .onyx-support-button,
        .onyx-support-meta,
        .onyx-support-field label {
            font-family: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace !important;
            font-size: 12px;
            letter-spacing: 1.2px;
            text-transform: uppercase;
        }

        .onyx-support-hero {
            border-bottom: 1px solid #27272a;
            padding: 164px 0 78px;
        }

        .onyx-support-hero-grid {
            align-items: end;
            display: grid;
            gap: clamp(38px, 7vw, 92px);
            grid-template-columns: minmax(0, 1.04fr) minmax(320px, 0.96fr);
        }

        .onyx-support-kicker {
            color: #a1a1aa;
            display: inline-flex;
            gap: 14px;
            margin-bottom: 28px;
        }

        .onyx-support-kicker::before {
            background: #d8dde3;
            content: "";
            height: 1px;
            margin-top: 8px;
            width: 44px;
        }

        .onyx-support h1 {
            color: #ffffff;
            font-size: clamp(56px, 8.4vw, 124px);
            letter-spacing: -4.6px;
            line-height: 0.92;
            margin: 0;
            max-width: 880px;
        }

        .onyx-support-lede {
            color: #a1a1aa;
            font-size: clamp(18px, 2vw, 24px);
            line-height: 1.58;
            margin: 34px 0 0;
            max-width: 720px;
        }

        .onyx-support-lede strong {
            color: #ffffff;
            font-weight: 400;
        }

        .onyx-support-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 38px;
        }

        .onyx-support-button {
            align-items: center;
            border: 1px solid rgba(255, 255, 255, 0.28);
            border-radius: 999px;
            color: #ffffff;
            display: inline-flex;
            gap: 10px;
            min-height: 48px;
            padding: 0 22px;
            text-decoration: none;
            transition: background 160ms ease, border-color 160ms ease, color 160ms ease, transform 160ms ease;
        }

        .onyx-support-button:hover {
            background: #ffffff;
            border-color: #ffffff;
            color: #09090b;
            transform: translateY(-2px);
        }

        .onyx-support-status {
            background: #121214;
            border: 1px solid #27272a;
            border-radius: 8px;
            overflow: hidden;
        }

        .onyx-support-status-row {
            border-top: 1px solid #27272a;
            display: grid;
            gap: 10px;
            padding: 24px;
        }

        .onyx-support-status-row:first-child {
            border-top: 0;
        }

        .onyx-support-label {
            color: #71717a;
            display: block;
        }

        .onyx-support-status-row strong {
            color: #ffffff;
            display: block;
            font-size: clamp(30px, 4vw, 52px);
            letter-spacing: -1.8px;
            line-height: 1;
        }

        .onyx-support-status-row p {
            color: #a1a1aa;
            font-size: 15px;
            line-height: 1.6;
            margin: 0;
        }

        .onyx-support-section {
            border-bottom: 1px solid #27272a;
            padding: clamp(72px, 9vw, 118px) 0;
        }

        .onyx-support-section-heading {
            display: grid;
            gap: 28px;
            grid-template-columns: minmax(180px, 0.32fr) minmax(0, 1fr);
            margin-bottom: 46px;
        }

        .onyx-support-index {
            color: #71717a;
        }

        .onyx-support h2 {
            color: #ffffff;
            font-size: clamp(38px, 6vw, 78px);
            letter-spacing: -2.6px;
            line-height: 0.98;
            margin: 0;
            max-width: 860px;
        }

        .onyx-support-section-copy {
            color: #a1a1aa;
            font-size: clamp(17px, 1.7vw, 22px);
            line-height: 1.6;
            margin: 22px 0 0;
            max-width: 760px;
        }

        .onyx-support-lanes {
            display: grid;
            gap: 14px;
            grid-template-columns: repeat(4, minmax(0, 1fr));
        }

        .onyx-support-lane {
            background: #121214;
            border: 1px solid #27272a;
            border-radius: 8px;
            color: #ffffff;
            display: block;
            min-height: 260px;
            padding: 24px;
            text-decoration: none;
            transition: border-color 160ms ease, transform 160ms ease, background 160ms ease;
        }

        .onyx-support-lane:hover {
            background: #18181b;
            border-color: rgba(255, 255, 255, 0.38);
            transform: translateY(-3px);
        }

        .onyx-support-lane .onyx-support-label {
            margin-bottom: 48px;
        }

        .onyx-support-lane h3,
        .onyx-support-process h3,
        .onyx-support-contact-card h3,
        .onyx-support-faq summary {
            color: #ffffff;
            font-size: 24px;
            letter-spacing: -0.9px;
            line-height: 1.12;
            margin: 0 0 14px;
        }

        .onyx-support-lane p,
        .onyx-support-process p,
        .onyx-support-contact-card p,
        .onyx-support-faq p {
            color: #a1a1aa;
            font-size: 15px;
            line-height: 1.65;
            margin: 0;
        }

        .onyx-support-process-list {
            display: grid;
        }

        .onyx-support-process {
            align-items: start;
            border-top: 1px solid #27272a;
            display: grid;
            gap: 32px;
            grid-template-columns: 150px 1fr 1.05fr;
            padding: 30px 0;
        }

        .onyx-support-process:last-child {
            border-bottom: 1px solid #27272a;
        }

        .onyx-support-process .onyx-support-label {
            margin: 0;
        }

        .onyx-support-contact {
            display: grid;
            gap: 14px;
            grid-template-columns: minmax(0, 0.95fr) minmax(0, 1.05fr);
        }

        .onyx-support-contact-card,
        .onyx-support-form-card {
            background: #121214;
            border: 1px solid #27272a;
            border-radius: 8px;
            padding: clamp(26px, 4vw, 42px);
        }

        .onyx-support-contact-card h3 {
            font-size: clamp(30px, 4vw, 48px);
            letter-spacing: -1.8px;
            margin-bottom: 18px;
        }

        .onyx-support-channel-list {
            display: grid;
            gap: 0;
            margin-top: 34px;
        }

        .onyx-support-channel {
            align-items: start;
            border-top: 1px solid #27272a;
            display: grid;
            gap: 12px;
            grid-template-columns: 140px 1fr;
            padding: 18px 0;
        }

        .onyx-support-channel:last-child {
            border-bottom: 1px solid #27272a;
        }

        .onyx-support-channel a,
        .onyx-support-channel strong {
            color: #ffffff;
            overflow-wrap: anywhere;
            text-decoration: none;
        }

        .onyx-support-form-card {
            display: grid;
            gap: 18px;
        }

        .onyx-support-field {
            display: grid;
            gap: 8px;
        }

        .onyx-support-field label {
            color: #8a8f98;
        }

        .onyx-support-field input,
        .onyx-support-field select,
        .onyx-support-field textarea {
            background: #09090b;
            border: 1px solid #27272a;
            border-radius: 8px;
            color: #ffffff;
            font-size: 16px;
            min-height: 52px;
            outline: none;
            padding: 14px 16px;
            width: 100%;
        }

        .onyx-support-field input:focus,
        .onyx-support-field select:focus,
        .onyx-support-field textarea:focus {
            border-color: rgba(255, 255, 255, 0.72);
        }

        .onyx-support-field select option {
            background: #09090b;
            color: #ffffff;
        }

        .onyx-support-field textarea {
            min-height: 132px;
            resize: vertical;
        }

        .onyx-support-form-note {
            color: #71717a;
            font-size: 13px;
            line-height: 1.55;
            margin: 0;
        }

        .onyx-support-docs {
            display: grid;
            gap: 14px;
            grid-template-columns: repeat(3, minmax(0, 1fr));
        }

        .onyx-support-doc {
            background: #121214;
            border: 1px solid #27272a;
            border-radius: 8px;
            min-height: 210px;
            padding: 24px;
        }

        .onyx-support-doc strong {
            color: #ffffff;
            display: block;
            font-size: clamp(26px, 3.2vw, 42px);
            letter-spacing: -1.2px;
            line-height: 1;
            margin-bottom: 22px;
        }

        .onyx-support-doc h3 {
            color: #ffffff;
            font-size: 23px;
            letter-spacing: -0.8px;
            line-height: 1.12;
            margin: 0 0 12px;
        }

        .onyx-support-doc p {
            color: #a1a1aa;
            font-size: 15px;
            line-height: 1.65;
            margin: 0;
        }

        .onyx-support-faq {
            display: grid;
            gap: 12px;
        }

        .onyx-support-faq details {
            background: #121214;
            border: 1px solid #27272a;
            border-radius: 8px;
            padding: 0 24px;
        }

        .onyx-support-faq summary {
            list-style: none;
            padding: 24px 0;
        }

        .onyx-support-faq summary::-webkit-details-marker {
            display: none;
        }

        .onyx-support-faq p {
            border-top: 1px solid #27272a;
            padding: 20px 0 24px;
        }

        @media (max-width: 1100px) {
            .onyx-support-hero-grid,
            .onyx-support-contact {
                grid-template-columns: 1fr;
            }

            .onyx-support-lanes,
            .onyx-support-docs {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 760px) {
            .onyx-support-shell {
                width: min(100% - 32px, 1240px);
            }

            .onyx-support-hero {
                padding-top: 124px;
            }

            .onyx-support-section-heading,
            .onyx-support-process,
            .onyx-support-lanes,
            .onyx-support-docs,
            .onyx-support-channel {
                grid-template-columns: 1fr;
            }

            .onyx-support-lane {
                min-height: 0;
            }

            .onyx-support-lane .onyx-support-label {
                margin-bottom: 26px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-support" aria-labelledby="support-title">
        <section class="onyx-support-hero">
            <div class="onyx-support-shell onyx-support-hero-grid">
                <div>
                    <span class="onyx-support-kicker">ONYX Support</span>
                    <h1 id="support-title">Help that keeps ownership clear.</h1>
                    <p class="onyx-support-lede">
                        <strong>ONYX support is built around fast diagnosis, transparent next steps, and reliable post-purchase care.</strong> Get help with orders, warranty coverage, returns, setup, and account access without guessing where to start.
                    </p>
                    <div class="onyx-support-actions">
                        <a href="#contact-support" class="onyx-support-button">Contact support</a>
                        <a href="#support-faq" class="onyx-support-button">Read FAQ</a>
                    </div>
                </div>

                <aside class="onyx-support-status" aria-label="ONYX support standards">
                    <div class="onyx-support-status-row">
                        <span class="onyx-support-label">Average first reply</span>
                        <strong>24h</strong>
                        <p>Most support requests are designed around a first human response within one business day.</p>
                    </div>
                    <div class="onyx-support-status-row">
                        <span class="onyx-support-label">Warranty coverage</span>
                        <strong>2 years</strong>
                        <p>Eligible manufacturing defects are covered for ONYX peripherals purchased through the store.</p>
                    </div>
                    <div class="onyx-support-status-row">
                        <span class="onyx-support-label">Fastest route</span>
                        <strong>Order + serial</strong>
                        <p>Include your order ID and product serial number so support can verify the request faster.</p>
                    </div>
                </aside>
            </div>
        </section>

        <section id="contact-support" class="onyx-support-section">
            <div class="onyx-support-shell">
                <div class="onyx-support-contact">
                    <div class="onyx-support-contact-card">
                        <span class="onyx-support-kicker">Contact ONYX</span>
                        <h3>Send the right details first.</h3>
                        <p>Support works faster when the first message includes the full context. Use the guide beside this panel, then send the request through email.</p>

                        <div class="onyx-support-channel-list">
                            <div class="onyx-support-channel">
                                <span class="onyx-support-label">Email</span>
                                <a  href="mailto:support@onyxgaming.com">support@onyxgaming.com</a>
                            </div>
                            <div class="onyx-support-channel">
                                <span class="onyx-support-label">Hours</span>
                                <strong>Mon-Fri / 10:00-18:00 MYT</strong>
                            </div>
                            <div class="onyx-support-channel">
                                <span class="onyx-support-label">Location</span>
                                <strong>Kuala Lumpur, Malaysia</strong>
                            </div>
                        </div>
                    </div>

                    <div class="onyx-support-form-card" aria-label="Support request preparation guide">
                        <div class="onyx-support-field">
                            <label for="support-name">Name</label>
                            <input id="support-name" type="text" placeholder="Your name" />
                        </div>
                        <div class="onyx-support-field">
                            <label for="support-email">Email</label>
                            <input id="support-email" type="email" placeholder="you@example.com" />
                        </div>
                        <div class="onyx-support-field">
                            <label for="support-topic">Topic</label>
                            <select id="support-topic">
                                <option>Order support</option>
                                <option>Warranty claim</option>
                                <option>Return request</option>
                                <option>Technical setup</option>
                                <option>Account access</option>
                            </select>
                        </div>
                        <div class="onyx-support-field">
                            <label for="support-message">Message</label>
                            <textarea id="support-message" placeholder="Order ID, product, serial number, and what happened"></textarea>
                        </div>
                        <a class="onyx-support-button" href="mailto:support@onyxgaming.com?subject=ONYX%20Support%20Request">Email support</a>
                        <p class="onyx-support-form-note">This form is a preparation guide. Use the email button to send your request through your mail app.</p>
                    </div>
                </div>
            </div>
        </section>

        <section class="onyx-support-section">
            <div class="onyx-support-shell">
                <div class="onyx-support-section-heading">
                    <span class="onyx-support-index">01 / Support lanes</span>
                    <div>
                        <h2>Match your request to the right support lane.</h2>
                        <p class="onyx-support-section-copy">Large companies route support by issue category because it reduces delay. ONYX uses the same principle: order problems, warranty claims, returns, and setup requests each need different information.</p>
                    </div>
                </div>

                <div class="onyx-support-lanes">
                    <a class="onyx-support-lane" href="#contact-support">
                        <span class="onyx-support-label">01 / Orders</span>
                        <h3>Payment, delivery, and invoices</h3>
                        <p>Use this path for tracking, receipt requests, delivery problems, wrong addresses, or missing items.</p>
                    </a>
                    <a class="onyx-support-lane" href="#contact-support">
                        <span class="onyx-support-label">02 / Warranty</span>
                        <h3>Defects and hardware faults</h3>
                        <p>Use this path for sensor issues, switch faults, charging problems, headset audio, and manufacturing defects.</p>
                    </a>
                    <a class="onyx-support-lane" href="#contact-support">
                        <span class="onyx-support-label">03 / Returns</span>
                        <h3>Return or replacement flow</h3>
                        <p>Use this path for unopened items, damaged deliveries, wrong products, or replacement eligibility.</p>
                    </a>
                    <a class="onyx-support-lane" href="#support-faq">
                        <span class="onyx-support-label">04 / Setup</span>
                        <h3>Device and account guidance</h3>
                        <p>Use this path for pairing, profiles, DPI, keyboard modes, care, login, wishlist, and order history questions.</p>
                    </a>
                </div>
            </div>
        </section>

        <section class="onyx-support-section">
            <div class="onyx-support-shell">
                <div class="onyx-support-section-heading">
                    <span class="onyx-support-index">02 / How it works</span>
                    <div>
                        <h2>A support flow customers can follow.</h2>
                    </div>
                </div>

                <div class="onyx-support-process-list">
                    <article class="onyx-support-process">
                        <span class="onyx-support-label">Step 01</span>
                        <h3>Identify the product and order.</h3>
                        <p>Find the product name, order ID, purchase date, and serial number. These details let support confirm ownership and warranty status.</p>
                    </article>
                    <article class="onyx-support-process">
                        <span class="onyx-support-label">Step 02</span>
                        <h3>Describe the issue clearly.</h3>
                        <p>Tell us what happened, when it started, what you already tried, and whether the issue happens every time or only sometimes.</p>
                    </article>
                    <article class="onyx-support-process">
                        <span class="onyx-support-label">Step 03</span>
                        <h3>Attach proof when possible.</h3>
                        <p>Photos or short videos help with physical damage, switch behavior, charging issues, audio faults, and delivery condition.</p>
                    </article>
                    <article class="onyx-support-process">
                        <span class="onyx-support-label">Step 04</span>
                        <h3>Receive the next action.</h3>
                        <p>Support will explain whether the case needs troubleshooting, inspection, replacement, return review, or account follow-up.</p>
                    </article>
                </div>
            </div>
        </section>

        <section class="onyx-support-section">
            <div class="onyx-support-shell">
                <div class="onyx-support-section-heading">
                    <span class="onyx-support-index">03 / Before you send</span>
                    <div>
                        <h2>Make the first message easier to solve.</h2>
                    </div>
                </div>

                <div class="onyx-support-docs">
                    <article class="onyx-support-doc">
                        <strong>Order ID</strong>
                        <h3>Start with purchase proof.</h3>
                        <p>Include your order number, purchase date, and account email so support can find the transaction without a second reply.</p>
                    </article>
                    <article class="onyx-support-doc">
                        <strong>Serial</strong>
                        <h3>Identify the exact unit.</h3>
                        <p>Share the product name, variant, serial number, and a short description of what changed or stopped working.</p>
                    </article>
                    <article class="onyx-support-doc">
                        <strong>Evidence</strong>
                        <h3>Show the issue clearly.</h3>
                        <p>Attach photos, screenshots, or a short video when the issue is physical, intermittent, or hard to describe in text.</p>
                    </article>
                </div>
            </div>
        </section>

        <section id="support-faq" class="onyx-support-section">
            <div class="onyx-support-shell">
                <div class="onyx-support-section-heading">
                    <span class="onyx-support-index">04 / FAQ</span>
                    <div>
                        <h2>Answers before you wait.</h2>
                        <p class="onyx-support-section-copy">These are the questions that usually slow down support when the first message is missing details.</p>
                    </div>
                </div>

                <div class="onyx-support-faq">
                    <details>
                        <summary>What should I include in a warranty request?</summary>
                        <p>Send your order ID, product name, serial number, purchase date, a description of the issue, and photos or a short video when the issue is visible.</p>
                    </details>
                    <details>
                        <summary>Can I return an opened product?</summary>
                        <p>Opened products are reviewed case by case. Unused and unopened items are simpler to return, while defective products should go through warranty support.</p>
                    </details>
                    <details>
                        <summary>What should I try before reporting a device issue?</summary>
                        <p>Try another USB port, remove hubs, restart the device, test on a second computer if available, and mention the result in your request.</p>
                    </details>
                    <details>
                        <summary>Where do I find my order history?</summary>
                        <p>Sign in to your ONYX account and open the profile menu. Order history is kept separate from profile settings so it is easier to review.</p>
                    </details>
                </div>
            </div>
        </section>
    </main>
</asp:Content>
