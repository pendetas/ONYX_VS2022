<%@ Page Title="Support" Language="C#" MasterPageFile="~/user_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="Support.aspx.cs" Inherits="ONYX_DDAC.user_page.Support" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-support {
            background:
                radial-gradient(circle at 84% 12%, rgba(216, 221, 227, 0.18), transparent 18rem),
                linear-gradient(180deg, rgba(255, 255, 255, 0.04), transparent 32rem),
                #050505;
            color: #ffffff;
            min-height: 100vh;
            overflow: hidden;
            padding-top: 140px;
        }

        .onyx-support h1,
        .onyx-support h2,
        .onyx-support h3 {
            font-family: Syne, Inter, sans-serif;
            letter-spacing: -0.04em;
        }

        .onyx-support-wrap {
            margin: 0 auto;
            max-width: 1440px;
            padding: 0 6vw;
        }

        .onyx-support-hero {
            align-items: center;
            display: grid;
            gap: clamp(34px, 4vw, 72px);
            grid-template-columns: minmax(0, 0.9fr) minmax(360px, 520px);
            min-height: auto;
            padding: clamp(70px, 8vh, 96px) 0 clamp(84px, 10vh, 124px);
        }

        .onyx-support-hero-copy {
            max-width: 660px;
            min-width: 0;
        }

        .onyx-support-kicker {
            color: #d8dde3;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.2em;
            margin-bottom: 24px;
            text-transform: uppercase;
        }

        .onyx-support h1 {
            font-size: clamp(46px, 4.4vw, 72px);
            font-weight: 800;
            line-height: 0.96;
            margin: 0;
            max-width: 660px;
            text-wrap: balance;
            text-transform: uppercase;
        }

        .onyx-support-lede {
            color: #aab1bb;
            font-size: clamp(17px, 1.7vw, 23px);
            line-height: 1.68;
            margin: 34px 0 0;
            max-width: 720px;
        }

        .onyx-support-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
            margin-top: 42px;
        }

        .onyx-support-pill {
            align-items: center;
            border: 1px solid rgba(255, 255, 255, 0.22);
            border-radius: 999px;
            color: #ffffff;
            display: inline-flex;
            font-size: 12px;
            font-weight: 800;
            gap: 10px;
            letter-spacing: 0.1em;
            min-height: 52px;
            padding: 0 24px;
            text-transform: uppercase;
            transition: background 180ms ease, border-color 180ms ease, color 180ms ease, transform 180ms ease;
        }

        .onyx-support-pill:hover {
            background: #ffffff;
            border-color: #ffffff;
            color: #050505;
            transform: translateY(-2px);
        }

        .onyx-support-panel {
            align-self: center;
            background: linear-gradient(160deg, rgba(255, 255, 255, 0.08), rgba(255, 255, 255, 0.025));
            border: 1px solid rgba(255, 255, 255, 0.13);
            justify-self: end;
            max-width: 520px;
            min-height: auto;
            padding: clamp(28px, 4vw, 48px);
            position: relative;
            width: 100%;
        }

        .onyx-support-panel::before {
            background:
                linear-gradient(rgba(255, 255, 255, 0.055) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.055) 1px, transparent 1px);
            background-size: 44px 44px;
            content: "";
            inset: 0;
            opacity: 0.18;
            pointer-events: none;
            position: absolute;
        }

        .onyx-support-ticket {
            background: #080808;
            border: 1px solid rgba(255, 255, 255, 0.14);
            display: grid;
            gap: 26px;
            padding: 28px;
            position: relative;
            z-index: 1;
        }

        .onyx-support-ticket-row {
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            display: grid;
            gap: 8px;
            padding-top: 18px;
        }

        .onyx-support-ticket-row:first-child {
            border-top: 0;
            padding-top: 0;
        }

        .onyx-support-ticket-row span {
            color: #8f98a5;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.16em;
            text-transform: uppercase;
        }

        .onyx-support-ticket-row strong {
            color: #ffffff;
            font-family: Syne, Inter, sans-serif;
            font-size: clamp(24px, 2.4vw, 38px);
            letter-spacing: -0.04em;
            line-height: 1;
            overflow-wrap: anywhere;
        }

        .onyx-support-ticket-row p {
            color: #b7bec8;
            line-height: 1.65;
            margin: 0;
        }

        .onyx-support-section {
            border-top: 1px solid rgba(255, 255, 255, 0.12);
            padding: 104px 0;
        }

        .onyx-support-section-head {
            align-items: end;
            display: grid;
            gap: 24px;
            grid-template-columns: 1fr minmax(260px, 420px);
            margin-bottom: 38px;
        }

        .onyx-support-section h2 {
            font-size: clamp(42px, 6vw, 94px);
            line-height: 0.94;
            margin: 0;
            max-width: 900px;
            text-transform: uppercase;
        }

        .onyx-support-section-head p {
            color: #aab1bb;
            font-size: 17px;
            line-height: 1.65;
            margin: 0;
        }

        .onyx-support-grid {
            display: grid;
            gap: 18px;
            grid-template-columns: repeat(4, minmax(0, 1fr));
        }

        .onyx-support-card {
            background: rgba(255, 255, 255, 0.045);
            border: 1px solid rgba(255, 255, 255, 0.12);
            color: #ffffff;
            display: grid;
            min-height: 280px;
            padding: 26px;
            position: relative;
            transition: background 180ms ease, border-color 180ms ease, transform 180ms ease;
        }

        .onyx-support-card:hover {
            background: rgba(255, 255, 255, 0.07);
            border-color: rgba(216, 221, 227, 0.42);
            transform: translateY(-4px);
        }

        .onyx-support-card span {
            color: rgba(216, 221, 227, 0.62);
            font-family: Syne, Inter, sans-serif;
            font-size: 46px;
            font-weight: 800;
            letter-spacing: -0.06em;
        }

        .onyx-support-card h3 {
            align-self: end;
            font-size: 27px;
            margin: 0 0 14px;
        }

        .onyx-support-card p {
            color: #aab1bb;
            line-height: 1.6;
            margin: 0;
        }

        .onyx-support-contact {
            background:
                radial-gradient(circle at 70% 20%, rgba(216, 221, 227, 0.16), transparent 18rem),
                #090909;
            border: 1px solid rgba(255, 255, 255, 0.12);
            display: grid;
            gap: 0;
            grid-template-columns: 1fr 1fr;
            overflow: hidden;
        }

        .onyx-support-contact-copy,
        .onyx-support-form {
            padding: clamp(30px, 5vw, 68px);
        }

        .onyx-support-contact-copy {
            border-right: 1px solid rgba(255, 255, 255, 0.1);
            display: grid;
            align-content: end;
        }

        .onyx-support-contact-copy h2 {
            font-size: clamp(40px, 5vw, 76px);
            line-height: 0.95;
            margin: 0;
            text-transform: uppercase;
        }

        .onyx-support-contact-copy p {
            color: #aab1bb;
            font-size: 17px;
            line-height: 1.7;
            margin: 24px 0 0;
            max-width: 560px;
        }

        .onyx-support-channel-list {
            display: grid;
            gap: 16px;
            margin-top: 38px;
        }

        .onyx-support-channel {
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            display: flex;
            gap: 18px;
            justify-content: space-between;
            padding-top: 18px;
        }

        .onyx-support-channel span {
            color: #8f98a5;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.14em;
            text-transform: uppercase;
        }

        .onyx-support-channel a,
        .onyx-support-channel strong {
            color: #ffffff;
            font-weight: 800;
            text-align: right;
        }

        .onyx-support-form {
            display: grid;
            gap: 18px;
        }

        .onyx-support-field {
            display: grid;
            gap: 8px;
        }

        .onyx-support-field label {
            color: #9ca3af;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.16em;
            text-transform: uppercase;
        }

        .onyx-support-field input,
        .onyx-support-field select,
        .onyx-support-field textarea {
            background: rgba(255, 255, 255, 0.045);
            border: 1px solid rgba(255, 255, 255, 0.13);
            color: #ffffff;
            font: inherit;
            min-height: 52px;
            padding: 14px 16px;
            width: 100%;
        }

        .onyx-support-field select option {
            background: #080808;
            color: #ffffff;
        }

        .onyx-support-field textarea {
            min-height: 132px;
            resize: vertical;
        }

        .onyx-support-form-note {
            color: #8f98a5;
            font-size: 13px;
            line-height: 1.55;
            margin: 0;
        }

        .onyx-support-faq {
            display: grid;
            gap: 12px;
        }

        .onyx-support-faq details {
            background: rgba(255, 255, 255, 0.035);
            border: 1px solid rgba(255, 255, 255, 0.1);
            padding: 0 26px;
        }

        .onyx-support-faq summary {
            color: #ffffff;
            cursor: pointer;
            font-family: Syne, Inter, sans-serif;
            font-size: clamp(22px, 3vw, 36px);
            font-weight: 700;
            letter-spacing: -0.04em;
            list-style: none;
            padding: 24px 0;
        }

        .onyx-support-faq summary::-webkit-details-marker {
            display: none;
        }

        .onyx-support-faq p {
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            color: #aab1bb;
            font-size: 17px;
            line-height: 1.7;
            margin: 0;
            padding: 22px 0 26px;
        }

        @media (max-width: 1100px) {
            .onyx-support-hero,
            .onyx-support-section-head,
            .onyx-support-contact {
                grid-template-columns: 1fr;
            }

            .onyx-support-panel {
                justify-self: stretch;
                max-width: none;
                min-height: auto;
            }

            .onyx-support-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .onyx-support-contact-copy {
                border-bottom: 1px solid rgba(255, 255, 255, 0.1);
                border-right: 0;
            }
        }

        @media (max-width: 700px) {
            .onyx-support {
                padding-top: 112px;
            }

            .onyx-support-wrap {
                padding: 0 24px;
            }

            .onyx-support-hero,
            .onyx-support-section {
                padding-bottom: 72px;
            }

            .onyx-support-grid {
                grid-template-columns: 1fr;
            }

            .onyx-support-channel {
                display: grid;
            }

            .onyx-support-channel a,
            .onyx-support-channel strong {
                text-align: left;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-support" aria-labelledby="support-title">
        <div class="onyx-support-wrap">
            <section class="onyx-support-hero">
                <div class="onyx-support-hero-copy">
                    <p class="onyx-support-kicker">Player support / Warranty desk</p>
                    <h1 id="support-title">Support that keeps you in the match.</h1>
                    <p class="onyx-support-lede">
                        Get help with orders, warranty checks, device setup, returns, and product care. ONYX support is built around quick diagnosis, clean replacements, and less downtime.
                    </p>
                    <div class="onyx-support-actions">
                        <a href="#contact-support" class="onyx-support-pill hover-trigger">Open support <span>+</span></a>
                        <a href="#support-faq" class="onyx-support-pill hover-trigger">Read FAQ <span>+</span></a>
                    </div>
                </div>

                <aside class="onyx-support-panel" aria-label="ONYX support response standards">
                    <div class="onyx-support-ticket">
                        <div class="onyx-support-ticket-row">
                            <span>Average first reply</span>
                            <strong>24h</strong>
                            <p>Most tickets receive the first human response within one business day.</p>
                        </div>
                        <div class="onyx-support-ticket-row">
                            <span>Warranty coverage</span>
                            <strong>2 years</strong>
                            <p>Manufacturing defects are covered for eligible ONYX peripherals.</p>
                        </div>
                        <div class="onyx-support-ticket-row">
                            <span>Priority lane</span>
                            <strong>Order + serial</strong>
                            <p>Include your order ID and product serial number so we can verify faster.</p>
                        </div>
                    </div>
                </aside>
            </section>

            <section class="onyx-support-section" aria-labelledby="support-lanes-title">
                <div class="onyx-support-section-head">
                    <h2 id="support-lanes-title">Choose the right support lane.</h2>
                    <p>Start with the closest issue type so the request lands with the correct specialist.</p>
                </div>

                <div class="onyx-support-grid">
                    <a href="#contact-support" class="onyx-support-card hover-trigger">
                        <span>01</span>
                        <div>
                            <h3>Orders</h3>
                            <p>Payment status, delivery tracking, invoice requests, address updates, and missing items.</p>
                        </div>
                    </a>
                    <a href="#contact-support" class="onyx-support-card hover-trigger">
                        <span>02</span>
                        <div>
                            <h3>Warranty</h3>
                            <p>Switch faults, sensor behavior, charging issues, headset audio problems, and manufacturing defects.</p>
                        </div>
                    </a>
                    <a href="#contact-support" class="onyx-support-card hover-trigger">
                        <span>03</span>
                        <div>
                            <h3>Returns</h3>
                            <p>Return eligibility, replacement flow, unopened products, wrong items, and damaged deliveries.</p>
                        </div>
                    </a>
                    <a href="#support-faq" class="onyx-support-card hover-trigger">
                        <span>04</span>
                        <div>
                            <h3>Setup</h3>
                            <p>Firmware, pairing, DPI profiles, keyboard modes, headset tuning, and care guidance.</p>
                        </div>
                    </a>
                </div>
            </section>

            <section id="contact-support" class="onyx-support-section" aria-labelledby="contact-support-title">
                <div class="onyx-support-contact">
                    <div class="onyx-support-contact-copy">
                        <p class="onyx-support-kicker">Contact ONYX</p>
                        <h2 id="contact-support-title">Send the details. We will take it from there.</h2>
                        <p>Attach your order ID, product serial number, proof of purchase, and a short description of what happened. For device issues, a quick video helps us diagnose faster.</p>

                        <div class="onyx-support-channel-list">
                            <div class="onyx-support-channel">
                                <span>Email</span>
                                <a class="hover-trigger" href="mailto:support@onyxgaming.com">support@onyxgaming.com</a>
                            </div>
                            <div class="onyx-support-channel">
                                <span>Hours</span>
                                <strong>Mon-Fri / 10:00-18:00 MYT</strong>
                            </div>
                            <div class="onyx-support-channel">
                                <span>Location</span>
                                <strong>Kuala Lumpur, Malaysia</strong>
                            </div>
                        </div>
                    </div>

                    <div class="onyx-support-form" aria-label="Support request guide">
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
                            </select>
                        </div>
                        <div class="onyx-support-field">
                            <label for="support-message">Message</label>
                            <textarea id="support-message" placeholder="Order ID, product, serial number, and what happened"></textarea>
                        </div>
                        <a class="onyx-support-pill hover-trigger" href="mailto:support@onyxgaming.com?subject=ONYX%20Support%20Request">Email support <span>+</span></a>
                        <p class="onyx-support-form-note">This front-end form is a guide for the information support needs. Use the email button to send the request through your mail app.</p>
                    </div>
                </div>
            </section>

            <section id="support-faq" class="onyx-support-section" aria-labelledby="support-faq-title">
                <div class="onyx-support-section-head">
                    <h2 id="support-faq-title">Fast answers.</h2>
                    <p>Most support delays happen when the first request is missing order or device details. These answers help you prepare the right information.</p>
                </div>

                <div class="onyx-support-faq">
                    <details>
                        <summary>What should I include in a warranty request?</summary>
                        <p>Send your order ID, product name, serial number, purchase date, a description of the problem, and photos or video if the issue is visible or repeatable.</p>
                    </details>
                    <details>
                        <summary>Can I return an opened product?</summary>
                        <p>Opened products are reviewed case by case. Unused and unopened items are usually simpler to return, while defective products should go through warranty support.</p>
                    </details>
                    <details>
                        <summary>My mouse or keyboard is not detected. What first?</summary>
                        <p>Try another USB port, restart the device, remove any USB hub, and test on a second computer if possible. Include those results when contacting support.</p>
                    </details>
                    <details>
                        <summary>How do replacement timelines work?</summary>
                        <p>After eligibility is confirmed, support will explain whether the product needs inspection first or whether a replacement can be prepared immediately.</p>
                    </details>
                </div>
            </section>

        </div>
    </main>
</asp:Content>
