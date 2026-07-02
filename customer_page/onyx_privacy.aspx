<%@ Page Title="Privacy Policy" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_privacy.aspx.cs" Inherits="ONYX_DDAC.customer_page.Privacy" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-content.css") %>" />

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
