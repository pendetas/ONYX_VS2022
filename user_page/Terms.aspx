<%@ Page Title="Terms and Conditions" Language="C#" MasterPageFile="~/user_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="Terms.aspx.cs" Inherits="ONYX_DDAC.user_page.Terms" %>

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
            max-width: 900px;
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
    <main class="onyx-legal" aria-labelledby="terms-title">
        <div class="onyx-legal-shell">
            <aside class="onyx-legal-aside">
                <p class="onyx-legal-toc-title">Contents</p>
                <nav class="onyx-legal-toc" aria-label="Terms contents">
                    <a class="hover-trigger" href="#acceptance">Acceptance</a>
                    <a class="hover-trigger" href="#products">Products and pricing</a>
                    <a class="hover-trigger" href="#orders">Orders and payment</a>
                    <a class="hover-trigger" href="#shipping">Shipping</a>
                    <a class="hover-trigger" href="#returns">Returns and warranty</a>
                    <a class="hover-trigger" href="#property">Intellectual property</a>
                    <a class="hover-trigger" href="#liability">Liability</a>
                    <a class="hover-trigger" href="#law">Governing law</a>
                </nav>
            </aside>

            <div>
                <header>
                    <p class="onyx-legal-kicker">Use standard</p>
                    <h1 id="terms-title">Terms for the ONYX store.</h1>
                    <p class="onyx-legal-lede">
                        These terms explain how purchases, accounts, shipping, returns, warranties, and site use work across ONYX Gaming Technologies.
                    </p>
                    <div class="onyx-legal-meta">
                        <span>Effective: January 2026</span>
                        <span>Currency: MYR</span>
                    </div>
                </header>

                <div class="onyx-legal-content">
                    <section id="acceptance" class="onyx-legal-section">
                        <span>01</span>
                        <h2>Acceptance of terms</h2>
                        <p>By accessing the ONYX website, creating an account, or purchasing products, you agree to these Terms and Conditions. If you do not agree, you should not use the website or services.</p>
                    </section>

                    <section id="products" class="onyx-legal-section">
                        <span>02</span>
                        <h2>Products and pricing</h2>
                        <p>We work to show product details, colors, specifications, availability, and pricing accurately. Product information may change without notice, and minor differences can appear between screen previews and real products.</p>
                        <ul>
                            <li>Prices are listed in Malaysian Ringgit unless stated otherwise.</li>
                            <li>Promotions, bundles, and limited drops may have separate rules.</li>
                            <li>We may update or discontinue products at any time.</li>
                        </ul>
                    </section>

                    <section id="orders" class="onyx-legal-section">
                        <span>03</span>
                        <h2>Orders and payment</h2>
                        <p>You agree to provide accurate order, billing, and contact information. We may refuse or cancel an order if payment cannot be verified, stock is unavailable, fraud is suspected, or account details are incomplete.</p>
                        <div class="onyx-legal-card">
                            <p>Payment methods shown at checkout are supported for that session. Your order is not confirmed until payment is authorized and an order confirmation is issued.</p>
                        </div>
                    </section>

                    <section id="shipping" class="onyx-legal-section">
                        <span>04</span>
                        <h2>Shipping and delivery</h2>
                        <p>Shipping cost and estimated delivery time are calculated during checkout. Delivery times can be affected by carrier delays, customs review, weather, public holidays, or incorrect address information.</p>
                    </section>

                    <section id="returns" class="onyx-legal-section">
                        <span>05</span>
                        <h2>Returns and warranty</h2>
                        <p>Eligible unused products may be returned according to the return window shown at checkout or in the product documentation. ONYX warranties cover manufacturing defects and do not cover misuse, accidents, unauthorized modification, or normal wear.</p>
                    </section>

                    <section id="property" class="onyx-legal-section">
                        <span>06</span>
                        <h2>Intellectual property</h2>
                        <p>The ONYX website, brand assets, product names, design language, copy, photos, graphics, and code are owned by ONYX Gaming Technologies or our licensors. You may not copy, resell, modify, or distribute this material without written permission.</p>
                    </section>

                    <section id="liability" class="onyx-legal-section">
                        <span>07</span>
                        <h2>Limitation of liability</h2>
                        <p>To the fullest extent allowed by law, ONYX is not liable for indirect, incidental, punitive, special, or consequential damages related to website use, order delays, product availability, or third-party service interruptions.</p>
                    </section>

                    <section id="law" class="onyx-legal-section">
                        <span>08</span>
                        <h2>Governing law</h2>
                        <p>These terms are governed by the laws of Malaysia. Any dispute connected to these terms will be handled by the courts of Malaysia unless another written agreement applies.</p>
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
                    if (window.scrollY >= section.offsetTop - 160) {
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
