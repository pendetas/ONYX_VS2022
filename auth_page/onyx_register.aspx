<%@ Page Title="Register - ONYX" Language="C#" MasterPageFile="~/customer_page/onyx_layout.Master" AutoEventWireup="true" CodeBehind="onyx_register.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_register" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-auth-page onyx-auth-page-wide">
        <div class="onyx-auth-copy">
            <div class="onyx-section-kicker">
                <span>1</span>
                <small>Join ONYX</small>
            </div>
            <p class="onyx-eyebrow">PLAYER-FIRST COMMERCE</p>
            <h1>Create an account for drops that fit your setup.</h1>
            <p class="onyx-lead">Register once, keep your profile ready and move from browse to checkout with less friction.</p>
            <div class="onyx-auth-note-grid">
                <div><strong>MYR</strong><span>Local pricing</span></div>
                <div><strong>24h</strong><span>Dispatch target</span></div>
            </div>
        </div>

        <div class="onyx-auth-panel onyx-auth-panel-wide">
            <div class="onyx-panel-heading">
                <span class="onyx-mini-label">REGISTER</span>
                <h2>Build your player profile</h2>
                <p>Required fields are marked with an asterisk.</p>
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="onyx-alert d-block" Visible="false"></asp:Label>

            <div class="onyx-form-grid">
                <label class="onyx-field">
                    <span>Full name *</span>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="onyx-input" required="true" placeholder="Enter your full name"></asp:TextBox>
                </label>

                <label class="onyx-field">
                    <span>Username *</span>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="onyx-input" required="true" placeholder="Choose a username"></asp:TextBox>
                </label>

                <label class="onyx-field">
                    <span>Email address *</span>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="onyx-input" required="true" placeholder="name@example.com"></asp:TextBox>
                </label>

                <label class="onyx-field">
                    <span>Date of birth *</span>
                    <asp:TextBox ID="txtDob" runat="server" TextMode="Date" CssClass="onyx-input" required="true"></asp:TextBox>
                </label>

                <label class="onyx-field">
                    <span>Phone number</span>
                    <asp:TextBox ID="txtPhone" runat="server" TextMode="Phone" CssClass="onyx-input" placeholder="+60 12-345 6789"></asp:TextBox>
                </label>

                <label class="onyx-field">
                    <span>Password *</span>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="onyx-input" required="true" placeholder="Create a strong password"></asp:TextBox>
                </label>

                <label class="onyx-field onyx-field-full">
                    <span>Shipping address</span>
                    <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="3" CssClass="onyx-input" placeholder="Enter your full shipping address"></asp:TextBox>
                </label>

                <label class="onyx-field">
                    <span>Confirm password *</span>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="onyx-input" required="true" placeholder="Confirm your password"></asp:TextBox>
                </label>

                <div class="onyx-field onyx-register-action">
                    <span>&nbsp;</span>
                    <asp:Button ID="btnRegister" runat="server" Text="Sign up" CssClass="onyx-submit" OnClick="btnRegister_Click" />
                </div>
            </div>

            <p class="onyx-form-footnote">
                Already have an account? <a href="onyx_login.aspx">Log in here</a>
            </p>
        </div>
    </section>
</asp:Content>
