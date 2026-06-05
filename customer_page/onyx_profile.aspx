<%@ Page Title="Profile" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_profile.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_profile" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-profile-page {
            background:
                radial-gradient(circle at 86% 8%, rgba(216, 221, 227, 0.13), transparent 24rem),
                radial-gradient(circle at 8% 28%, rgba(255, 255, 255, 0.07), transparent 18rem),
                linear-gradient(180deg, #050505 0%, #0a0a0a 46%, #050505 100%);
            color: #ffffff;
            min-height: 100vh;
            padding: 154px 32px 112px;
        }

        .onyx-profile-shell {
            margin: 0 auto;
            max-width: 1400px;
        }

        .onyx-profile-hero {
            align-items: end;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            display: grid;
            gap: 28px;
            grid-template-columns: minmax(0, 1fr) minmax(280px, 460px);
            padding-bottom: 42px;
        }

        .onyx-profile-kicker,
        .onyx-panel-kicker {
            color: rgba(255, 255, 255, 0.48);
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.22em;
            text-transform: uppercase;
        }

        .onyx-profile-kicker {
            margin-bottom: 18px;
        }

        .onyx-profile-title {
            font-family: Syne, Inter, sans-serif;
            font-size: clamp(58px, 9vw, 132px);
            font-weight: 800;
            letter-spacing: -0.06em;
            line-height: 0.86;
            margin: 0;
            text-transform: uppercase;
        }

        .onyx-profile-copy {
            color: rgba(255, 255, 255, 0.62);
            font-size: clamp(16px, 1.5vw, 20px);
            line-height: 1.6;
            margin: 0;
        }

        .onyx-account-dashboard {
            align-items: start;
            display: grid;
            gap: 24px;
            grid-template-columns: 320px minmax(0, 1fr);
            padding-top: 34px;
        }

        .onyx-profile-sidebar {
            background:
                linear-gradient(180deg, rgba(255, 255, 255, 0.075), rgba(255, 255, 255, 0.026));
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 18px;
            overflow: hidden;
            position: sticky;
            top: 118px;
        }

        .onyx-sidebar-inner {
            padding: 26px;
        }

        .onyx-profile-avatar {
            align-items: center;
            background: #ffffff;
            border-radius: 50%;
            color: #050505;
            display: flex;
            font-family: Syne, Inter, sans-serif;
            font-size: 30px;
            font-weight: 800;
            height: 82px;
            justify-content: center;
            margin-bottom: 22px;
            width: 82px;
        }

        .onyx-profile-name {
            font-family: Syne, Inter, sans-serif;
            font-size: 30px;
            font-weight: 800;
            letter-spacing: -0.04em;
            line-height: 1;
            margin: 0 0 8px;
            text-transform: uppercase;
        }

        .onyx-profile-muted {
            color: rgba(255, 255, 255, 0.58);
            line-height: 1.55;
            margin: 0;
        }

        .onyx-profile-sidebar-nav {
            border-top: 1px solid rgba(255, 255, 255, 0.09);
            display: grid;
            gap: 8px;
            margin-top: 24px;
            padding-top: 22px;
        }

        .onyx-profile-sidebar-nav a {
            align-items: center;
            border: 1px solid transparent;
            border-radius: 12px;
            color: rgba(255, 255, 255, 0.72);
            display: flex;
            font-size: 13px;
            font-weight: 800;
            justify-content: space-between;
            letter-spacing: 0.08em;
            min-height: 44px;
            padding: 0 14px;
            text-decoration: none;
            text-transform: uppercase;
            transition: background 160ms ease, border-color 160ms ease, color 160ms ease, transform 160ms ease;
        }

        .onyx-profile-sidebar-nav a:hover {
            background: rgba(255, 255, 255, 0.08);
            border-color: rgba(255, 255, 255, 0.1);
            color: #ffffff;
            transform: translateX(2px);
        }

        .onyx-profile-sidebar-nav span {
            color: rgba(255, 255, 255, 0.32);
            font-size: 10px;
        }

        .onyx-profile-quick-links {
            display: grid;
            gap: 10px;
            margin-top: 24px;
        }

        .onyx-profile-content {
            display: grid;
            gap: 22px;
        }

        .onyx-profile-panel {
            background:
                linear-gradient(180deg, rgba(255, 255, 255, 0.066), rgba(255, 255, 255, 0.024));
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 18px;
            overflow: hidden;
        }

        .onyx-profile-panel-inner {
            padding: clamp(24px, 3vw, 34px);
        }

        .onyx-panel-heading {
            align-items: end;
            display: flex;
            gap: 18px;
            justify-content: space-between;
            margin-bottom: 24px;
        }

        .onyx-profile-panel h2 {
            font-family: Syne, Inter, sans-serif;
            font-size: clamp(30px, 4vw, 52px);
            font-weight: 800;
            letter-spacing: -0.05em;
            line-height: 0.96;
            margin: 8px 0 0;
            text-transform: uppercase;
        }

        .onyx-overview-grid,
        .onyx-profile-stat-grid {
            display: grid;
            gap: 14px;
            grid-template-columns: repeat(3, minmax(0, 1fr));
        }

        .onyx-profile-stat,
        .onyx-profile-detail-card {
            background: rgba(0, 0, 0, 0.22);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px;
            padding: 20px;
        }

        .onyx-profile-stat strong {
            display: block;
            font-family: Syne, Inter, sans-serif;
            font-size: 36px;
            line-height: 1;
        }

        .onyx-profile-stat span,
        .onyx-profile-detail-card span {
            color: rgba(255, 255, 255, 0.46);
            display: block;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 0.15em;
            margin-bottom: 9px;
            text-transform: uppercase;
        }

        .onyx-profile-stat span {
            margin: 12px 0 0;
        }

        .onyx-profile-detail-card strong {
            color: #ffffff;
            display: block;
            font-size: 15px;
            line-height: 1.55;
        }

        .onyx-detail-grid {
            display: grid;
            gap: 14px;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            margin-top: 14px;
        }

        .onyx-profile-button,
        .onyx-profile-ghost,
        .onyx-review-submit {
            align-items: center;
            border-radius: 999px;
            display: inline-flex;
            font-size: 11px;
            font-weight: 800;
            justify-content: center;
            letter-spacing: 0.08em;
            min-height: 42px;
            padding: 0 18px;
            text-decoration: none;
            text-transform: uppercase;
            transition: background 160ms ease, border-color 160ms ease, color 160ms ease, transform 160ms ease;
            white-space: nowrap;
        }

        .onyx-profile-button,
        .onyx-review-submit {
            background: #ffffff;
            border: 1px solid #ffffff;
            color: #050505;
        }

        .onyx-profile-ghost {
            background: transparent;
            border: 1px solid rgba(255, 255, 255, 0.16);
            color: rgba(255, 255, 255, 0.78);
        }

        .onyx-profile-button:hover,
        .onyx-profile-ghost:hover,
        .onyx-review-submit:hover {
            transform: translateY(-2px);
        }

        .onyx-settings-grid,
        .onyx-review-grid {
            display: grid;
            gap: 16px;
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }

        .onyx-profile-field,
        .onyx-review-field {
            display: grid;
            gap: 8px;
        }

        .onyx-profile-field.full,
        .onyx-review-field.full {
            grid-column: 1 / -1;
        }

        .onyx-profile-field label,
        .onyx-review-field label {
            color: rgba(255, 255, 255, 0.48);
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 0.16em;
            text-transform: uppercase;
        }

        .onyx-profile-input,
        .onyx-profile-textarea,
        .onyx-review-input,
        .onyx-review-textarea {
            background: #080808;
            border: 1px solid rgba(255, 255, 255, 0.14);
            border-radius: 14px;
            color: #ffffff;
            font: inherit;
            outline: none;
            padding: 14px 16px;
            width: 100%;
        }

        .onyx-profile-textarea,
        .onyx-review-textarea {
            min-height: 120px;
            resize: vertical;
        }

        .onyx-profile-input:focus,
        .onyx-profile-textarea:focus,
        .onyx-review-input:focus,
        .onyx-review-textarea:focus {
            border-color: #d8dde3;
            box-shadow: 0 0 0 3px rgba(216, 221, 227, 0.08);
        }

        .onyx-rating-source {
            left: -9999px;
            position: absolute;
        }

        .onyx-star-rating {
            background: rgba(8, 8, 8, 0.92);
            border: 1px solid rgba(255, 255, 255, 0.14);
            border-radius: 16px;
            display: grid;
            gap: 12px;
            padding: 13px 16px;
        }

        .onyx-star-row {
            display: flex;
            gap: 8px;
        }

        .onyx-star-button {
            align-items: center;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            color: rgba(255, 255, 255, 0.34);
            cursor: none;
            display: inline-flex;
            font-size: 22px;
            height: 44px;
            justify-content: center;
            line-height: 1;
            transition: background 150ms ease, border-color 150ms ease, color 150ms ease, transform 150ms ease;
            width: 44px;
        }

        .onyx-star-button::before {
            content: "\2605";
        }

        .onyx-star-button:hover,
        .onyx-star-button:focus-visible {
            border-color: rgba(216, 221, 227, 0.55);
            color: #ffffff;
            outline: none;
            transform: translateY(-2px);
        }

        .onyx-star-button.is-active {
            background: #ffffff;
            border-color: #ffffff;
            color: #050505;
        }

        .onyx-rating-copy {
            color: rgba(255, 255, 255, 0.56);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.04em;
            margin: 0;
        }

        .onyx-settings-actions {
            align-items: center;
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 18px;
        }

        .onyx-profile-feedback {
            color: #d8dde3;
            display: inline-flex;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.12em;
            text-transform: uppercase;
        }

        .onyx-order-list {
            display: grid;
            gap: 14px;
        }

        .onyx-order-card {
            background: rgba(0, 0, 0, 0.22);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px;
            padding: 20px;
        }

        .onyx-order-top,
        .onyx-order-footer {
            align-items: center;
            display: flex;
            gap: 18px;
            justify-content: space-between;
        }

        .onyx-order-id {
            color: rgba(255, 255, 255, 0.48);
            display: block;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 0.16em;
            margin-bottom: 7px;
            text-transform: uppercase;
        }

        .onyx-order-date {
            font-family: Syne, Inter, sans-serif;
            font-size: 22px;
            font-weight: 800;
            letter-spacing: -0.02em;
            text-transform: uppercase;
        }

        .onyx-order-status {
            align-items: center;
            border: 1px solid rgba(216, 221, 227, 0.32);
            border-radius: 999px;
            color: #d8dde3;
            display: inline-flex;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 0.14em;
            min-height: 30px;
            padding: 0 12px;
            text-transform: uppercase;
        }

        .onyx-order-summary {
            color: rgba(255, 255, 255, 0.58);
            font-size: 14px;
            line-height: 1.6;
            margin: 15px 0 0;
        }

        .onyx-order-footer {
            border-top: 1px solid rgba(255, 255, 255, 0.09);
            margin-top: 18px;
            padding-top: 16px;
        }

        .onyx-order-total {
            font-weight: 800;
        }

        .onyx-profile-empty {
            border: 1px dashed rgba(255, 255, 255, 0.18);
            border-radius: 16px;
            color: rgba(255, 255, 255, 0.6);
            line-height: 1.7;
            padding: 28px;
        }

        @media (max-width: 1100px) {
            .onyx-profile-hero,
            .onyx-account-dashboard {
                grid-template-columns: 1fr;
            }

            .onyx-profile-sidebar {
                position: static;
            }

            .onyx-profile-sidebar-nav {
                grid-template-columns: repeat(4, minmax(0, 1fr));
            }
        }

        @media (max-width: 720px) {
            .onyx-profile-page {
                padding: 132px 18px 84px;
            }

            .onyx-profile-sidebar-nav,
            .onyx-overview-grid,
            .onyx-profile-stat-grid,
            .onyx-detail-grid,
            .onyx-settings-grid,
            .onyx-review-grid {
                grid-template-columns: 1fr;
            }

            .onyx-panel-heading,
            .onyx-order-top,
            .onyx-order-footer {
                align-items: flex-start;
                flex-direction: column;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section id="profile" class="onyx-profile-page">
        <div class="onyx-profile-shell">
            <div class="onyx-profile-hero">
                <div>
                    <div class="onyx-profile-kicker">ONYX Account</div>
                    <h1 class="onyx-profile-title">Dashboard</h1>
                </div>
                <p class="onyx-profile-copy">
                    Your account is now split into focused sections, so purchases, reviews, and settings are easier to scan.
                </p>
            </div>

            <div class="onyx-account-dashboard">
                <aside class="onyx-profile-sidebar">
                    <div class="onyx-sidebar-inner">
                        <div class="onyx-profile-avatar">
                            <asp:Literal ID="litInitials" runat="server" />
                        </div>
                        <h2 class="onyx-profile-name"><asp:Literal ID="litDisplayName" runat="server" /></h2>
                        <p class="onyx-profile-muted">@<asp:Literal ID="litUsername" runat="server" /></p>

                        <nav class="onyx-profile-sidebar-nav" aria-label="Profile sections">
                            <a class="hover-trigger" href="#overview">Overview <span>01</span></a>
                            <a class="hover-trigger" href="#orders">Orders <span>02</span></a>
                            <a class="hover-trigger" href="#reviews">Reviews <span>03</span></a>
                            <a class="hover-trigger" href="#settings">Settings <span>04</span></a>
                        </nav>

                        <div class="onyx-profile-quick-links">
                            <a href="/customer_page/onyx_wishlist.aspx" class="onyx-profile-button hover-trigger">Open Wishlist</a>
                            <a href="/customer_page/onyx_catalog.aspx" class="onyx-profile-ghost hover-trigger">Shop Catalog</a>
                        </div>
                    </div>
                </aside>

                <div class="onyx-profile-content">
                    <section id="overview" class="onyx-profile-panel">
                        <div class="onyx-profile-panel-inner">
                            <div class="onyx-panel-heading">
                                <div>
                                    <span class="onyx-panel-kicker">Account Overview</span>
                                    <h2>At a glance</h2>
                                </div>
                                <a href="#settings" class="onyx-profile-ghost hover-trigger">Edit Profile</a>
                            </div>

                            <div class="onyx-profile-stat-grid">
                                <div class="onyx-profile-stat">
                                    <strong><asp:Literal ID="litOrderCount" runat="server" /></strong>
                                    <span>Orders</span>
                                </div>
                                <div class="onyx-profile-stat">
                                    <strong><asp:Literal ID="litReviewableCount" runat="server" /></strong>
                                    <span>Can Review</span>
                                </div>
                                <div class="onyx-profile-stat">
                                    <strong><asp:Literal ID="litWishlistCount" runat="server" /></strong>
                                    <span>Saved Gear</span>
                                </div>
                            </div>

                            <div class="onyx-detail-grid">
                                <div class="onyx-profile-detail-card">
                                    <span>Email</span>
                                    <strong><asp:Literal ID="litEmail" runat="server" /></strong>
                                </div>
                                <div class="onyx-profile-detail-card">
                                    <span>Phone</span>
                                    <strong><asp:Literal ID="litPhone" runat="server" /></strong>
                                </div>
                                <div class="onyx-profile-detail-card">
                                    <span>Shipping Address</span>
                                    <strong><asp:Literal ID="litAddress" runat="server" /></strong>
                                </div>
                                <div class="onyx-profile-detail-card">
                                    <span>Member Since</span>
                                    <strong><asp:Literal ID="litMemberSince" runat="server" /></strong>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section id="orders" class="onyx-profile-panel">
                        <div class="onyx-profile-panel-inner">
                            <div class="onyx-panel-heading">
                                <div>
                                    <span class="onyx-panel-kicker">Purchase History</span>
                                    <h2>Recent Buy</h2>
                                </div>
                                <a href="/customer_page/onyx_cart.aspx" class="onyx-profile-ghost hover-trigger">View Cart</a>
                            </div>
                            <asp:Panel ID="pnlEmptyOrders" runat="server" Visible="false" CssClass="onyx-profile-empty">
                                Your order history is empty for now. Browse the catalog and build your ONYX setup.
                            </asp:Panel>
                            <asp:Repeater ID="rptRecentOrders" runat="server">
                                <HeaderTemplate><div class="onyx-order-list"></HeaderTemplate>
                                <ItemTemplate>
                                    <article class="onyx-order-card">
                                        <div class="onyx-order-top">
                                            <div>
                                                <span class="onyx-order-id">Order #<%# Eval("Id") %></span>
                                                <div class="onyx-order-date"><%# FormatOrderDate(Eval("OrderedAt")) %></div>
                                            </div>
                                            <span class="onyx-order-status"><%# Eval("Status") %></span>
                                        </div>
                                        <p class="onyx-order-summary"><%# GetOrderSummary(Container.DataItem) %></p>
                                        <div class="onyx-order-footer">
                                            <span class="onyx-order-total"><%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("TotalAmount")) %></span>
                                            <a class="onyx-profile-ghost hover-trigger" href='<%# "onyx_invoice.aspx?orderId=" + Eval("Id") %>'>View Receipt</a>
                                        </div>
                                    </article>
                                </ItemTemplate>
                                <FooterTemplate></div></FooterTemplate>
                            </asp:Repeater>
                        </div>
                    </section>

                    <section id="reviews" class="onyx-profile-panel">
                        <div class="onyx-profile-panel-inner">
                            <div class="onyx-panel-heading">
                                <div>
                                    <span class="onyx-panel-kicker">Gear Feedback</span>
                                    <h2>Post Review</h2>
                                </div>
                            </div>
                            <asp:Panel ID="pnlReviewForm" runat="server">
                                <div class="onyx-review-grid">
                                    <div class="onyx-review-field">
                                        <label for="<%= ddlReviewProduct.ClientID %>">Purchased Product</label>
                                        <asp:DropDownList ID="ddlReviewProduct" runat="server" CssClass="onyx-review-input" />
                                    </div>
                                    <div class="onyx-review-field">
                                        <label for="<%= ddlRating.ClientID %>">Rating</label>
                                        <asp:DropDownList ID="ddlRating" runat="server" CssClass="onyx-review-input onyx-rating-source" aria-hidden="true" TabIndex="-1">
                                            <asp:ListItem Value="5">5 / Award ready</asp:ListItem>
                                            <asp:ListItem Value="4">4 / Strong</asp:ListItem>
                                            <asp:ListItem Value="3">3 / Solid</asp:ListItem>
                                            <asp:ListItem Value="2">2 / Needs work</asp:ListItem>
                                            <asp:ListItem Value="1">1 / Not for me</asp:ListItem>
                                        </asp:DropDownList>
                                        <div class="onyx-star-rating" data-rating-select="<%= ddlRating.ClientID %>">
                                            <div class="onyx-star-row" role="radiogroup" aria-label="Choose review rating">
                                                <button type="button" class="hover-trigger onyx-star-button" data-rating="1" aria-label="1 star" aria-pressed="false"></button>
                                                <button type="button" class="hover-trigger onyx-star-button" data-rating="2" aria-label="2 stars" aria-pressed="false"></button>
                                                <button type="button" class="hover-trigger onyx-star-button" data-rating="3" aria-label="3 stars" aria-pressed="false"></button>
                                                <button type="button" class="hover-trigger onyx-star-button" data-rating="4" aria-label="4 stars" aria-pressed="false"></button>
                                                <button type="button" class="hover-trigger onyx-star-button" data-rating="5" aria-label="5 stars" aria-pressed="false"></button>
                                            </div>
                                            <p class="onyx-rating-copy" aria-live="polite">5 stars selected: Award ready</p>
                                        </div>
                                    </div>
                                    <div class="onyx-review-field full">
                                        <label for="<%= txtReviewComment.ClientID %>">Review Notes</label>
                                        <asp:TextBox ID="txtReviewComment" runat="server" TextMode="MultiLine" CssClass="onyx-review-textarea" MaxLength="1200" placeholder="Share what stood out after using the gear." />
                                    </div>
                                </div>
                                <div class="onyx-settings-actions">
                                    <asp:Button ID="btnSubmitReview" runat="server" Text="Submit Review" CssClass="onyx-review-submit hover-trigger" OnClick="btnSubmitReview_Click" />
                                    <asp:Label ID="lblReviewFeedback" runat="server" CssClass="onyx-profile-feedback" Visible="false" />
                                </div>
                            </asp:Panel>
                            <asp:Panel ID="pnlNoReviewProducts" runat="server" Visible="false" CssClass="onyx-profile-empty">
                                Reviews unlock after your first purchase. Your purchased gear will appear here automatically.
                            </asp:Panel>
                        </div>
                    </section>

                    <section id="settings" class="onyx-profile-panel">
                        <div class="onyx-profile-panel-inner">
                            <div class="onyx-panel-heading">
                                <div>
                                    <span class="onyx-panel-kicker">Account Settings</span>
                                    <h2>Edit Profile</h2>
                                </div>
                            </div>
                            <div class="onyx-settings-grid">
                                <div class="onyx-profile-field">
                                    <label for="<%= txtSettingsFullName.ClientID %>">Full Name</label>
                                    <asp:TextBox ID="txtSettingsFullName" runat="server" CssClass="onyx-profile-input" MaxLength="120" />
                                </div>
                                <div class="onyx-profile-field">
                                    <label for="<%= txtSettingsEmail.ClientID %>">Email Address</label>
                                    <asp:TextBox ID="txtSettingsEmail" runat="server" CssClass="onyx-profile-input" TextMode="Email" MaxLength="180" />
                                </div>
                                <div class="onyx-profile-field">
                                    <label for="<%= txtSettingsPhone.ClientID %>">Phone Number</label>
                                    <asp:TextBox ID="txtSettingsPhone" runat="server" CssClass="onyx-profile-input" MaxLength="40" />
                                </div>
                                <div class="onyx-profile-field full">
                                    <label for="<%= txtSettingsAddress.ClientID %>">Default Shipping Address</label>
                                    <asp:TextBox ID="txtSettingsAddress" runat="server" CssClass="onyx-profile-textarea" TextMode="MultiLine" Rows="4" MaxLength="500" />
                                </div>
                            </div>
                            <div class="onyx-settings-actions">
                                <asp:Button ID="btnSaveSettings" runat="server" Text="Save Settings" CssClass="onyx-profile-button hover-trigger" OnClick="btnSaveSettings_Click" />
                                <asp:Label ID="lblSettingsFeedback" runat="server" CssClass="onyx-profile-feedback" Visible="false" />
                            </div>
                        </div>
                    </section>
                </div>
            </div>
        </div>
    </section>
    <script>
        (function initOnyxStarRating() {
            var widgets = document.querySelectorAll('.onyx-star-rating[data-rating-select]');

            widgets.forEach(function (widget) {
                var select = document.getElementById(widget.getAttribute('data-rating-select'));
                var buttons = Array.prototype.slice.call(widget.querySelectorAll('.onyx-star-button'));
                var copy = widget.querySelector('.onyx-rating-copy');
                var labels = {
                    1: '1 star selected: Not for me',
                    2: '2 stars selected: Needs work',
                    3: '3 stars selected: Solid',
                    4: '4 stars selected: Strong',
                    5: '5 stars selected: Award ready'
                };

                if (!select || buttons.length === 0) {
                    return;
                }

                function setRating(value) {
                    select.value = value;

                    buttons.forEach(function (button) {
                        var active = parseInt(button.getAttribute('data-rating'), 10) <= parseInt(value, 10);
                        button.classList.toggle('is-active', active);
                        button.setAttribute('aria-pressed', active ? 'true' : 'false');
                    });

                    if (copy) {
                        copy.textContent = labels[value] || '';
                    }
                }

                buttons.forEach(function (button) {
                    button.addEventListener('click', function () {
                        setRating(button.getAttribute('data-rating'));
                    });
                });

                setRating(select.value || '5');
            });
        })();
    </script>
</asp:Content>
