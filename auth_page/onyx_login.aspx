<%@ Page Title="Login" Language="C#" MasterPageFile="~/customer_page/onyx_layout.Master" AutoEventWireup="true" CodeBehind="onyx_login.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_login" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-auth-page">
        <div class="onyx-auth-copy">
            <div class="onyx-section-kicker">
                <span>1</span>
                <small>Player access</small>
            </div>
            <p class="onyx-eyebrow">BUILT IN MALAYSIA FOR SERIOUS PLAY</p>
            <h1>Welcome back to your ONYX loadout.</h1>
            <p class="onyx-lead">Sign in to continue browsing curated drops, cart items and order activity from one clean setup.</p>
            <div class="onyx-auth-note">
                <strong>Fast checkout</strong>
                <span>Keep your shipping details ready for the next drop.</span>
            </div>
        </div>

        <div class="onyx-auth-panel">
            <div class="onyx-panel-heading">
                <span class="onyx-mini-label">LOGIN</span>
                <h2>Enter the lobby</h2>
                <p>Use the email and password linked to your ONYX account.</p>
            </div>

            <asp:Panel ID="MessagePanel" runat="server" CssClass="onyx-alert" Visible="false">
                    <asp:Literal ID="MessageLiteral" runat="server" />
            </asp:Panel>

            <div class="onyx-form-stack">
                <div class="onyx-field">
                    <asp:Label ID="EmailLabel" runat="server" AssociatedControlID="EmailTextBox" Text="Email" />
                    <asp:TextBox ID="EmailTextBox" runat="server" CssClass="onyx-input" TextMode="Email" placeholder="name@example.com" />
                </div>

                <div class="onyx-field">
                    <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="PasswordTextBox" Text="Password" />
                    <asp:TextBox ID="PasswordTextBox" runat="server" CssClass="onyx-input" TextMode="Password" placeholder="Enter your password" />
                </div>

                <asp:Button ID="LoginButton" runat="server" CssClass="onyx-submit" Text="Log in" OnClick="LoginButton_Click" />

                <p class="onyx-form-footnote">
                    New to ONYX? <a href="onyx_register.aspx">Create an account</a>
                </p>
            </div>
        </div>
    </section>
</asp:Content>
