<%@ Page Title="Profile" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_profile.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_profile" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="/Content/onyx-account.css" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-profile-page">
        <div class="onyx-account-layout">
            <aside class="onyx-account-sidebar">
                <h1 class="onyx-account-title">My Account</h1>
                <p class="onyx-account-subtitle">Manage your profile and preferences.</p>

                <nav class="onyx-account-nav" aria-label="Account navigation">
                    <a class="is-active" href="/customer_page/onyx_profile">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 21a8 8 0 0 0-16 0" /><circle cx="12" cy="7" r="4" /></svg>
                        <span>Profile Details</span>
                    </a>
                    <a href="/customer_page/onyx_order_history">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m21 16-9 5-9-5V8l9-5 9 5v8Z" /><path d="m3.3 7.3 8.7 4.9 8.7-4.9" /><path d="M12 22V12" /></svg>
                        <span>Order History</span>
                    </a>
                    <a href="/customer_page/onyx_wishlist">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20.8 4.6c-1.5-1.4-3.9-1.4-5.4.1L12 8.1 8.6 4.7c-1.5-1.5-3.9-1.5-5.4-.1-1.6 1.5-1.6 4.1 0 5.7L12 19l8.8-8.7c1.6-1.6 1.6-4.2 0-5.7Z" /></svg>
                        <span>Wishlist</span>
                    </a>
                    <a href="/customer_page/onyx_reviews">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 17.3 18.2 21l-1.6-7 5.4-4.7-7.1-.6L12 2 9.1 8.7 2 9.3 7.4 14l-1.6 7L12 17.3Z" /></svg>
                        <span>Reviews</span>
                    </a>
                </nav>
            </aside>

            <div class="onyx-account-main">
                <section class="onyx-account-section" aria-labelledby="profile-details-title" aria-describedby="profile-details-description">
                    <div class="onyx-account-section-header">
                        <div class="onyx-profile-photo" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21a8 8 0 0 0-16 0" /><circle cx="12" cy="7" r="4" /></svg>
                        </div>
                        <div>
                            <h2 id="profile-details-title" class="onyx-section-title">Profile details</h2>
                            <p id="profile-details-description" class="onyx-page-lede">Keep your contact details and default shipping address ready for faster checkout.</p>
                        </div>
                    </div>

                    <div class="onyx-settings-grid">
                        <div class="onyx-profile-field">
                            <label for="<%= txtSettingsFirstName.ClientID %>">First Name</label>
                            <asp:TextBox ID="txtSettingsFirstName" runat="server" CssClass="onyx-profile-input" MaxLength="80" autocomplete="given-name" />
                        </div>
                        <div class="onyx-profile-field">
                            <label for="<%= txtSettingsLastName.ClientID %>">Last Name</label>
                            <asp:TextBox ID="txtSettingsLastName" runat="server" CssClass="onyx-profile-input" MaxLength="80" autocomplete="family-name" />
                        </div>
                        <asp:TextBox ID="txtSettingsFullName" runat="server" CssClass="onyx-hidden-field" MaxLength="120" aria-hidden="true" tabindex="-1" />
                        <div class="onyx-profile-field full">
                            <label for="<%= txtSettingsEmail.ClientID %>">Email Address</label>
                            <asp:TextBox ID="txtSettingsEmail" runat="server" CssClass="onyx-profile-input" TextMode="Email" MaxLength="180" autocomplete="email" />
                        </div>
                        <div class="onyx-profile-field">
                            <label for="<%= txtSettingsPhone.ClientID %>">Phone Number</label>
                            <asp:TextBox ID="txtSettingsPhone" runat="server" CssClass="onyx-profile-input" MaxLength="40" autocomplete="tel" inputmode="tel" />
                        </div>
                        <div class="onyx-profile-field full">
                            <label for="<%= txtSettingsAddress.ClientID %>">Default Shipping Address</label>
                            <asp:TextBox ID="txtSettingsAddress" runat="server" CssClass="onyx-profile-textarea" TextMode="MultiLine" Rows="4" MaxLength="500" autocomplete="street-address" />
                        </div>
                    </div>
                    <div class="onyx-settings-actions">
                        <asp:Button ID="btnSaveSettings" runat="server" Text="Save Changes" CssClass="onyx-profile-button" OnClick="btnSaveSettings_Click" />
                        <asp:Label ID="lblSettingsFeedback" runat="server" CssClass="onyx-profile-feedback" Visible="false" role="status" aria-live="polite" />
                    </div>
                </section>
            </div>
        </div>
    </section>
</asp:Content>
