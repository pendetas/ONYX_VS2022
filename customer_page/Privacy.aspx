<%@ Page Title="Privacy Policy" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="Privacy.aspx.cs" Inherits="ONYX_DDAC.customer_page.Privacy" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-privacy-page {
            --bg: #09090b;
            --panel: #121214;
            --line: #27272a;
            --text: #ffffff;
            --muted: #a1a1aa;
            --soft: #d8dde3;
            background: var(--bg);
            color: var(--text);
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            min-height: 100vh;
            padding: 156px 0 84px;
        }

        .onyx-privacy-page *,
        .onyx-privacy-page h1,
        .onyx-privacy-page h2,
        .onyx-privacy-page p,
        .onyx-privacy-page li,
        .onyx-privacy-page a,
        .onyx-privacy-page span {
            box-sizing: border-box;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif !important;
            font-weight: 400 !important;
            letter-spacing: 0 !important;
        }

        .onyx-privacy-shell {
            display: grid;
            gap: 56px;
            grid-template-columns: 240px minmax(0, 1fr);
            margin: 0 auto;
            max-width: 1180px;
            width: min(100% - 48px, 1180px);
        }

        .onyx-privacy-aside {
            align-self: start;
            position: sticky;
            top: 128px;
        }

        .onyx-privacy-kicker,
        .onyx-privacy-label,
        .onyx-privacy-toc a {
            color: var(--soft);
            font-family: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace !important;
            font-size: 12px;
            line-height: 1.4;
            text-transform: uppercase;
        }

        .onyx-privacy-toc {
            border-left: 1px solid var(--line);
            display: grid;
            gap: 10px;
            margin-top: 18px;
            padding-left: 18px;
        }

        .onyx-privacy-toc a {
            color: var(--muted) !important;
            text-decoration: none;
            text-transform: none;
            transition: color 160ms ease, transform 160ms ease;
        }

        .onyx-privacy-toc a:hover {
            color: var(--text) !important;
            transform: translateX(4px);
        }

        .onyx-privacy-page h1 {
            color: var(--text) !important;
            font-size: 84px;
            line-height: 0.96;
            margin: 18px 0 28px;
            max-width: 860px;
        }

        .onyx-privacy-page h2 {
            color: var(--text) !important;
            font-size: 38px;
            line-height: 1.08;
            margin: 10px 0 18px;
        }

        .onyx-privacy-lede,
        .onyx-privacy-section p,
        .onyx-privacy-section li {
            color: var(--muted) !important;
            font-size: 17px;
            line-height: 1.75;
        }

        .onyx-privacy-lede {
            margin: 0;
            max-width: 760px;
        }

        .onyx-privacy-meta {
            border-top: 1px solid var(--line);
            color: var(--muted);
            display: flex;
            flex-wrap: wrap;
            gap: 12px 26px;
            margin-top: 34px;
            padding-top: 20px;
        }

        .onyx-privacy-content {
            display: grid;
            gap: 34px;
            margin-top: 56px;
        }

        .onyx-privacy-section {
            border-top: 1px solid var(--line);
            scroll-margin-top: 130px;
            padding-top: 34px;
        }

        .onyx-privacy-section ul {
            display: grid;
            gap: 10px;
            list-style: none;
            margin: 18px 0 0;
            padding: 0;
        }

        .onyx-privacy-section li {
            border-left: 1px solid rgba(216, 221, 227, 0.32);
            padding-left: 16px;
        }

        .onyx-privacy-note {
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 8px;
            margin-top: 22px;
            padding: 22px;
        }

        .onyx-privacy-note p {
            margin: 0;
        }

        @media (max-width: 980px) {
            .onyx-privacy-page {
                padding-top: 124px;
            }

            .onyx-privacy-shell {
                grid-template-columns: 1fr;
            }

            .onyx-privacy-aside {
                position: static;
            }

            .onyx-privacy-toc {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .onyx-privacy-page h1 {
                font-size: 62px;
            }
        }

        @media (max-width: 680px) {
            .onyx-privacy-shell {
                width: min(100% - 32px, 1180px);
            }

            .onyx-privacy-page h1 {
                font-size: 42px;
            }

            .onyx-privacy-page h2 {
                font-size: 30px;
            }

            .onyx-privacy-toc {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-privacy-page" aria-labelledby="privacy-title">
        <div class="onyx-privacy-shell">
            <aside class="onyx-privacy-aside">
                <span class="onyx-privacy-label">Contents</span>
                <nav class="onyx-privacy-toc" aria-label="Privacy contents">
                    <a class="hover-trigger" href="#collect">Information we collect</a>
                    <a class="hover-trigger" href="#use">How we use it</a>
                    <a class="hover-trigger" href="#sharing">Data sharing</a>
                    <a class="hover-trigger" href="#cookies">Cookies</a>
                    <a class="hover-trigger" href="#rights">Your rights</a>
                    <a class="hover-trigger" href="#security">Security</a>
                    <a class="hover-trigger" href="#contact">Contact</a>
                </nav>
            </aside>

            <div>
                <header>
                    <span class="onyx-privacy-kicker">Privacy standard</span>
                    <h1 id="privacy-title">Your data stays practical and protected.</h1>
                    <p class="onyx-privacy-lede">
                        ONYX uses personal information to run accounts, process orders, provide support, protect the store, and improve the shopping experience.
                    </p>
                    <div class="onyx-privacy-meta">
                        <span>Last updated: January 2026</span>
                        <span>Region: Malaysia</span>
                    </div>
                </header>

                <div class="onyx-privacy-content">
                    <section id="collect" class="onyx-privacy-section">
                        <span class="onyx-privacy-label">01</span>
                        <h2>Information we collect</h2>
                        <p>We collect information you provide when you create an account, place an order, contact support, join a promotion, or interact with ONYX services.</p>
                        <ul>
                            <li>Name, email address, phone number, username, and account credentials.</li>
                            <li>Shipping address, billing details, order history, returns, and warranty requests.</li>
                            <li>Device, browser, approximate location, session activity, and security logs.</li>
                        </ul>
                    </section>

                    <section id="use" class="onyx-privacy-section">
                        <span class="onyx-privacy-label">02</span>
                        <h2>How we use it</h2>
                        <p>We use your information to deliver products, provide support, secure the platform, improve website performance, and communicate important updates about your account or orders.</p>
                        <div class="onyx-privacy-note">
                            <p>Marketing messages are only sent when allowed by law or your preferences. Service messages about orders or account security may still be sent.</p>
                        </div>
                    </section>

                    <section id="sharing" class="onyx-privacy-section">
                        <span class="onyx-privacy-label">03</span>
                        <h2>Data sharing</h2>
                        <p>We do not sell your personal information. We share it with service providers who help us run the store, including payment processors, delivery partners, hosting providers, analytics services, and customer support tools.</p>
                    </section>

                    <section id="cookies" class="onyx-privacy-section">
                        <span class="onyx-privacy-label">04</span>
                        <h2>Cookies</h2>
                        <p>Cookies and similar technologies help us keep you signed in, remember preferences, measure site performance, and protect against abuse. Some store features may stop working correctly if cookies are blocked.</p>
                    </section>

                    <section id="rights" class="onyx-privacy-section">
                        <span class="onyx-privacy-label">05</span>
                        <h2>Your rights</h2>
                        <p>You may request access, correction, deletion, or restriction of your personal information where applicable. You may also ask how your data is used or withdraw consent for optional processing.</p>
                    </section>

                    <section id="security" class="onyx-privacy-section">
                        <span class="onyx-privacy-label">06</span>
                        <h2>Security</h2>
                        <p>We use technical and organizational measures to protect personal information, including access controls, encrypted connections, monitoring, and account safeguards. Protect your login details carefully.</p>
                    </section>

                    <section id="contact" class="onyx-privacy-section">
                        <span class="onyx-privacy-label">07</span>
                        <h2>Contact</h2>
                        <p>Questions about privacy can be sent to privacy@onyxgaming.com or mailed to ONYX Gaming Technologies, Kuala Lumpur, Malaysia.</p>
                    </section>
                </div>
            </div>
        </div>
    </main>
</asp:Content>
