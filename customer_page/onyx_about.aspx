<%@ Page Title="About" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_about.aspx.cs" Inherits="ONYX_DDAC.customer_page.About" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-content.css") %>" />

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
                        <a class="onyx-about-button" href="onyx_support.aspx">Support promise</a>
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
