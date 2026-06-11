<%@ Page Title="Privacy Policy" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_privacy.aspx.cs" Inherits="ONYX_DDAC.customer_page.Privacy" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-legal {
            background:
                radial-gradient(circle at 76% 10%, rgba(216, 221, 227, 0.16), transparent 20rem),
                linear-gradient(180deg, rgba(255, 255, 255, 0.035), transparent 34rem),
                #050505;
            color: #ffffff;
            min-height: 100vh;
            padding: 180px 24px 80px;
        }

        .onyx-legal-shell {
            display: grid;
            gap: 72px;
            grid-template-columns: 260px minmax(0, 1fr);
            margin: 0 auto;
            max-width: 1220px;
        }

        .onyx-legal-aside {
            align-self: start;
            position: sticky;
            top: 140px;
        }

        .onyx-legal-kicker,
        .onyx-legal-toc-title,
        .onyx-legal-section span {
            color: #9ca3af;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.18em;
            text-transform: uppercase;
        }

        .onyx-legal h1,
        .onyx-legal h2 {
            font-family: Syne, Inter, sans-serif;
            letter-spacing: -0.04em;
        }

        .onyx-legal h1 {
            font-size: clamp(54px, 8vw, 112px);
            line-height: 0.92;
            margin: 18px 0 24px;
            max-width: 860px;
            text-transform: uppercase;
        }

        .onyx-legal-lede {
            color: #b8bec7;
            font-size: clamp(17px, 2vw, 22px);
            line-height: 1.65;
            margin: 0;
            max-width: 780px;
        }

        .onyx-legal-meta {
            border-top: 1px solid rgba(255, 255, 255, 0.12);
            color: #9ca3af;
            display: flex;
            flex-wrap: wrap;
            gap: 16px 32px;
            margin-top: 42px;
            padding-top: 24px;
        }

        .onyx-legal-toc {
            border-left: 1px solid rgba(255, 255, 255, 0.12);
            display: grid;
            gap: 10px;
            margin-top: 24px;
            padding-left: 20px;
        }

        .onyx-legal-toc a {
            color: #9ca3af;
            font-size: 14px;
            line-height: 1.4;
            transition: color 160ms ease, transform 160ms ease;
        }

        .onyx-legal-toc a:hover,
        .onyx-legal-toc a.active {
            color: #ffffff;
            transform: translateX(4px);
        }

        .onyx-legal-content {
            display: grid;
            gap: 42px;
        }

        .onyx-legal-section {
            border-top: 1px solid rgba(255, 255, 255, 0.12);
            padding-top: 42px;
        }

        .onyx-legal-section h2 {
            font-size: clamp(30px, 4vw, 58px);
            line-height: 1;
            margin: 12px 0 22px;
        }

        .onyx-legal-section p,
        .onyx-legal-section li {
            color: #c7ccd4;
            font-size: 17px;
            line-height: 1.8;
        }

        .onyx-legal-section ul {
            display: grid;
            gap: 12px;
            list-style: none;
            margin: 22px 0 0;
            padding: 0;
        }

        .onyx-legal-section li {
            border-left: 1px solid rgba(216, 221, 227, 0.28);
            padding-left: 18px;
        }

        .onyx-legal-card {
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.07), rgba(255, 255, 255, 0.025));
            border: 1px solid rgba(255, 255, 255, 0.13);
            margin-top: 28px;
            padding: 28px;
        }

        @media (max-width: 980px) {
            .onyx-legal {
                padding-top: 140px;
            }

            .onyx-legal-shell {
                grid-template-columns: 1fr;
            }

            .onyx-legal-aside {
                display: none;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-legal" aria-labelledby="privacy-title">
        <div class="onyx-legal-shell">
            <aside class="onyx-legal-aside">
                <p class="onyx-legal-toc-title">Contents</p>
                <nav class="onyx-legal-toc" aria-label="Privacy contents">
                    <a  href="#collect">Information we collect</a>
                    <a  href="#use">How we use it</a>
                    <a  href="#sharing">Data sharing</a>
                    <a  href="#cookies">Cookies</a>
                    <a  href="#rights">Your rights</a>
                    <a  href="#security">Security</a>
                    <a  href="#contact">Contact</a>
                </nav>
            </aside>

            <div>
                <header>
                    <p class="onyx-legal-kicker">Privacy standard</p>
                    <h1 id="privacy-title">Your data stays under control.</h1>
                    <p class="onyx-legal-lede">
                        ONYX uses personal information to run accounts, process orders, protect the store, and improve the player experience. We keep the policy direct so you know what is collected and why.
                    </p>
                    <div class="onyx-legal-meta">
                        <span>Last updated: January 2026</span>
                        <span>Region: Malaysia</span>
                    </div>
                </header>

                <div class="onyx-legal-content">
                    <section id="collect" class="onyx-legal-section">
                        <span>01</span>
                        <h2>Information we collect</h2>
                        <p>We collect information you provide when you create an account, place an order, contact support, join a promotion, or interact with ONYX services.</p>
                        <ul>
                            <li>Name, email address, phone number, username, and account credentials.</li>
                            <li>Shipping address, billing details, order history, returns, and warranty requests.</li>
                            <li>Device, browser, approximate location, session activity, and security logs.</li>
                        </ul>
                    </section>

                    <section id="use" class="onyx-legal-section">
                        <span>02</span>
                        <h2>How we use it</h2>
                        <p>We use your information to deliver products, provide support, secure the platform, improve website performance, and communicate important updates about your account or orders.</p>
                        <div class="onyx-legal-card">
                            <p>Marketing messages are only sent when allowed by law or your preferences. You can opt out of promotional email at any time while still receiving service messages about orders or account security.</p>
                        </div>
                    </section>

                    <section id="sharing" class="onyx-legal-section">
                        <span>03</span>
                        <h2>Data sharing</h2>
                        <p>We do not sell your personal information. We share it only with service providers who help us run the store, including payment processors, delivery partners, hosting providers, analytics services, and customer support tools.</p>
                    </section>

                    <section id="cookies" class="onyx-legal-section">
                        <span>04</span>
                        <h2>Cookies</h2>
                        <p>Cookies and similar technologies help us keep you signed in, remember preferences, measure site performance, and protect against abuse. Your browser settings may allow you to block or delete cookies, although some store features may stop working correctly.</p>
                    </section>

                    <section id="rights" class="onyx-legal-section">
                        <span>05</span>
                        <h2>Your rights</h2>
                        <p>You may request access, correction, deletion, or restriction of your personal information where applicable. You may also ask us to explain how your data is used or withdraw consent for optional processing.</p>
                    </section>

                    <section id="security" class="onyx-legal-section">
                        <span>06</span>
                        <h2>Security</h2>
                        <p>We use technical and organizational measures to protect personal information, including access controls, encrypted connections, monitoring, and account safeguards. No online service can be guaranteed completely secure, so protect your login details carefully.</p>
                    </section>

                    <section id="contact" class="onyx-legal-section">
                        <span>07</span>
                        <h2>Contact</h2>
                        <p>Questions about privacy can be sent to privacy@onyxgaming.com or mailed to ONYX Gaming Technologies, Kuala Lumpur, Malaysia.</p>
                    </section>
                </div>
            </div>
        </div>

    </main>

    <script>
        (function () {
            var links = document.querySelectorAll('.onyx-legal-toc a');
            var sections = document.querySelectorAll('.onyx-legal-section');

            links.forEach(function (link) {
                link.addEventListener('click', function (event) {
                    var target = document.querySelector(link.getAttribute('href'));
                    if (!target) {
                        return;
                    }

                    event.preventDefault();
                    window.scrollTo({
                        top: target.offsetTop - 120,
                        behavior: 'smooth'
                    });
                });
            });

            window.addEventListener('scroll', function () {
                var activeId = '';
                sections.forEach(function (section) {
                    if (window.scrollY>= section.offsetTop - 160) {
                        activeId = section.id;
                    }
                });

                links.forEach(function (link) {
                    link.classList.toggle('active', link.getAttribute('href') === '#' + activeId);
                });
            }, { passive: true });
        })();
    </script>
</asp:Content>
