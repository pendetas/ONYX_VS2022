<%@ Page Title="Reviews" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_reviews.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_reviews" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="/Content/onyx-account.css" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-account-page">
        <div class="onyx-account-layout">
            <aside class="onyx-account-sidebar">
                <h1 class="onyx-account-title">My Account</h1>
                <p class="onyx-account-subtitle">Post reviews for gear you already own.</p>

                <nav class="onyx-account-nav" aria-label="Account navigation">
                    <a class="hover-trigger" href="/customer_page/onyx_profile">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 21a8 8 0 0 0-16 0" /><circle cx="12" cy="7" r="4" /></svg>
                        <span>Profile Details</span>
                    </a>
                    <a class="hover-trigger" href="/customer_page/onyx_order_history">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m21 16-9 5-9-5V8l9-5 9 5v8Z" /><path d="m3.3 7.3 8.7 4.9 8.7-4.9" /><path d="M12 22V12" /></svg>
                        <span>Order History</span>
                    </a>
                    <a class="hover-trigger" href="/customer_page/onyx_wishlist">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20.8 4.6c-1.5-1.4-3.9-1.4-5.4.1L12 8.1 8.6 4.7c-1.5-1.5-3.9-1.5-5.4-.1-1.6 1.5-1.6 4.1 0 5.7L12 19l8.8-8.7c1.6-1.6 1.6-4.2 0-5.7Z" /></svg>
                        <span>Wishlist</span>
                    </a>
                    <a class="hover-trigger is-active" href="/customer_page/onyx_reviews">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 17.3 18.2 21l-1.6-7 5.4-4.7-7.1-.6L12 2 9.1 8.7 2 9.3 7.4 14l-1.6 7L12 17.3Z" /></svg>
                        <span>Reviews</span>
                    </a>
                </nav>
            </aside>

            <div class="onyx-account-main">
                <section class="onyx-account-section">
                    <h2 class="onyx-section-title">Post Review</h2>
                    <p class="onyx-page-lede">Choose a purchased product, rate it from 1 to 5 stars, and share what stood out.</p>

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
                </section>
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
