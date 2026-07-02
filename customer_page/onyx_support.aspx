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
