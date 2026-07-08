<%@ Page Title="Support" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_support.aspx.cs" Inherits="ONYX_DDAC.customer_page.Support" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-content.css") %>" />

</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-support" aria-labelledby="support-title">
        <section class="onyx-support-hero">
            <div class="onyx-support-shell onyx-support-hero-grid">
                <div>
                    <span class="onyx-support-kicker">ONYX Support</span>
                    <h1 id="support-title">Get help without guessing.</h1>
                    <p class="onyx-support-lede">
                        <strong>Email support with your order ID, product name, and what happened.</strong> That is the fastest path for orders, warranty, returns, setup, and account access.
                    </p>
                    <div class="onyx-support-actions">
                        <a href="mailto:support.onyxgaming@gmail.com?subject=ONYX%20Support%20Request" class="onyx-support-button">Email support</a>
                        <a href="#support-faq" class="onyx-support-button">Read FAQ</a>
                    </div>
                </div>

                <aside class="onyx-support-status" aria-label="ONYX support standards">
                    <div class="onyx-support-status-row">
                        <span class="onyx-support-label">Email</span>
                        <strong>support.onyxgaming@gmail.com</strong>
                        <p>Use this address for every support request.</p>
                    </div>
                    <div class="onyx-support-status-row">
                        <span class="onyx-support-label">Best details</span>
                        <strong>Order + serial</strong>
                        <p>Include both so support can check the product faster.</p>
                    </div>
                    <div class="onyx-support-status-row">
                        <span class="onyx-support-label">Hours</span>
                        <strong>Mon-Fri / 10:00-18:00 MYT</strong>
                        <p>Replies are handled during business hours.</p>
                    </div>
                </aside>
            </div>
        </section>

        <section id="contact-support" class="onyx-support-section">
            <div class="onyx-support-shell">
                <div class="onyx-support-contact">
                    <div class="onyx-support-contact-card">
                        <span class="onyx-support-kicker">Contact ONYX</span>
                        <h3>Send one clear email.</h3>
                        <p>Use the checklist beside this panel. Keep the first message short and complete.</p>

                        <div class="onyx-support-channel-list">
                            <div class="onyx-support-channel">
                                <span class="onyx-support-label">Email</span>
                                <a href="mailto:support.onyxgaming@gmail.com">support.onyxgaming@gmail.com</a>
                            </div>
                            <div class="onyx-support-channel">
                                <span class="onyx-support-label">Subject</span>
                                <strong>Order, warranty, return, setup, or account</strong>
                            </div>
                        </div>
                    </div>

                    <div class="onyx-support-form-card" aria-label="Support request checklist">
                        <div class="onyx-support-docs">
                            <article class="onyx-support-doc">
                                <strong>01</strong>
                                <h3>Order ID</h3>
                                <p>Order number, purchase date, and account email.</p>
                            </article>
                            <article class="onyx-support-doc">
                                <strong>02</strong>
                                <h3>Product</h3>
                                <p>Product name, variant, and serial number if available.</p>
                            </article>
                            <article class="onyx-support-doc">
                                <strong>03</strong>
                                <h3>Proof</h3>
                                <p>Photos or video if the issue is visible.</p>
                            </article>
                        </div>
                        <a class="onyx-support-button" href="mailto:support.onyxgaming@gmail.com?subject=ONYX%20Support%20Request&body=Order%20ID%3A%0AProduct%3A%0ASerial%20number%3A%0AIssue%3A%0AAttach%20photos%20or%20video%20if%20needed.">Start email</a>
                    </div>
                </div>
            </div>
        </section>

        <section id="support-faq" class="onyx-support-section">
            <div class="onyx-support-shell">
                <div class="onyx-support-section-heading">
                    <span class="onyx-support-index">FAQ</span>
                    <div>
                        <h2>Fast answers.</h2>
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
