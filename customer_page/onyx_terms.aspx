<%@ Page Title="Terms and Conditions" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_terms.aspx.cs" Inherits="ONYX_DDAC.customer_page.Terms" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-content.css") %>" />

</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-legal" aria-labelledby="terms-title">
        <div class="onyx-legal-shell">
            <aside class="onyx-legal-aside">
                <p class="onyx-legal-toc-title">Contents</p>
                <nav class="onyx-legal-toc" aria-label="Terms contents">
                    <a  href="#acceptance">Acceptance</a>
                    <a  href="#products">Products and pricing</a>
                    <a  href="#orders">Orders and payment</a>
                    <a  href="#shipping">Shipping</a>
                    <a  href="#returns">Returns and warranty</a>
                    <a  href="#property">Intellectual property</a>
                    <a  href="#liability">Liability</a>
                    <a  href="#law">Governing law</a>
                    <a  href="#contact">Contact</a>
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

                    <section id="contact" class="onyx-legal-section">
                        <span>09</span>
                        <h2>Contact</h2>
                        <p>Questions about these terms can be sent to <a href="mailto:support.onyxgaming@gmail.com">support.onyxgaming@gmail.com</a>.</p>
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
