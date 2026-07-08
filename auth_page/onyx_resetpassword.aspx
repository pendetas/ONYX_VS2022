<%@ Page Title="Reset Password - ONYX" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_resetpassword.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_resetpassword" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .auth-takeover {
            align-items: center;
            background-color: #050505;
            color: #ffffff;
            display: flex;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            height: 100vh;
            justify-content: center;
            left: 0;
            overflow: hidden;
            position: fixed;
            top: 0;
            width: 100vw;
            z-index: 12000;
        }

        body.auth-lock-scroll {
            height: 100vh;
            overflow: hidden !important;
        }

        .auth-container {
            background-color: #0a0a0a;
            border: 1px solid #1f1f1f;
            border-radius: 24px;
            box-shadow: 0 0 50px rgba(0, 0, 0, 0.8);
            display: flex;
            height: 90vh;
            max-width: 1400px;
            overflow: hidden;
            width: 95vw;
        }

        .auth-left {
            align-items: center;
            background: #030303;
            border-right: 1px solid #1f1f1f;
            display: flex;
            flex: 1;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        .auth-brand {
            color: #ffffff;
            font-size: 28px;
            font-weight: 400;
            left: 40px;
            letter-spacing: -0.08em;
            line-height: 1;
            position: absolute;
            text-decoration: none;
            text-transform: lowercase;
            top: 30px;
            z-index: 2;
        }

        .auth-brand:hover {
            color: #d8dde3;
        }

        .auth-copyright {
            bottom: 30px;
            color: #555;
            font-size: 11px;
            left: 40px;
            position: absolute;
            z-index: 2;
        }

        .auth-video-bg {
            height: 100%;
            left: 0;
            object-fit: cover;
            opacity: 0.46;
            position: absolute;
            top: 0;
            width: 100%;
            z-index: 1;
        }

        .auth-right {
            background: linear-gradient(135deg, #0a0a0a 0%, #111111 100%);
            display: flex;
            flex: 1;
            flex-direction: column;
            overflow: hidden;
            padding: 50px 60px;
            position: relative;
            z-index: 2;
        }

        .auth-top-nav {
            display: flex;
            justify-content: flex-end;
            text-align: right;
            z-index: 10;
        }

        .auth-top-nav a,
        .auth-secondary-link {
            color: #8a8f98;
            display: inline-flex;
            font-size: 11px;
            font-weight: 400;
            gap: 12px;
            letter-spacing: 1.2px;
            text-decoration: none;
            text-transform: uppercase;
            transition: color 0.2s ease;
        }

        .auth-top-nav a:hover,
        .auth-secondary-link:hover {
            color: #ffffff;
        }

        .auth-form-wrapper {
            margin: auto 0;
            max-width: 560px;
            width: 100%;
        }

        .auth-kicker {
            color: #71717a;
            display: block;
            font-size: 11px;
            letter-spacing: 1.2px;
            margin-bottom: 20px;
            text-transform: uppercase;
        }

        .auth-title {
            color: #ffffff;
            font-size: clamp(48px, 7vw, 76px);
            font-weight: 400;
            letter-spacing: -2.6px;
            line-height: 0.96;
            margin: 0 0 22px;
        }

        .auth-copy {
            color: #a1a1aa;
            font-size: 16px;
            line-height: 1.7;
            margin: 0 0 34px;
            max-width: 500px;
        }

        .auth-field {
            display: flex;
            flex-direction: column;
            margin-bottom: 30px;
        }

        .auth-field label {
            color: #8a8f98;
            font-size: 11px;
            font-weight: 400;
            letter-spacing: 1.2px;
            margin-bottom: 8px;
            text-transform: uppercase;
        }

        .auth-input {
            background: transparent;
            border: 0;
            border-bottom: 1px solid #333;
            color: #ffffff;
            font-size: 17px;
            outline: none;
            padding: 10px 0;
            transition: border-color 0.2s ease;
        }

        .auth-input:focus {
            border-bottom-color: #ffffff;
        }

        .auth-action-row {
            align-items: center;
            display: flex;
            gap: 16px;
            justify-content: space-between;
        }

        .auth-submit-btn {
            appearance: none;
            -webkit-appearance: none;
            align-items: center;
            background-color: #ffffff;
            border: 0;
            border-radius: 999px;
            color: #050505;
            display: inline-flex;
            font-size: 12px;
            font-weight: 400;
            height: 52px;
            justify-content: center;
            letter-spacing: 1.2px;
            min-width: 180px;
            padding: 0 30px;
            text-transform: uppercase;
            transition: background-color 0.2s ease, transform 0.2s ease, box-shadow 0.2s ease;
        }

        .auth-submit-btn:hover {
            background-color: #d8dde3;
            box-shadow: 0 16px 40px rgba(216, 221, 227, 0.18);
            transform: translateY(-2px);
        }

        .auth-alert {
            color: #d8dde3;
            display: block;
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 24px;
        }

        @media (max-width: 760px) {
            .auth-left {
                display: none;
            }

            .auth-right {
                padding: 40px 28px;
            }

            .auth-action-row {
                align-items: stretch;
                flex-direction: column;
            }

            .auth-submit-btn {
                width: 100%;
            }
        }
    </style>

    <div class="auth-takeover">
        <div class="auth-container">
            <div class="auth-left">
                <a href="<%= ResolveUrl("~/customer_page/onyx_home.aspx") %>" class="auth-brand" aria-label="Back to ONYX home">onyx</a>
                <video autoplay loop muted playsinline class="auth-video-bg">
                    <source src="<%= ResolveUrl("~/Videos/ONYX_Cinematic_Logo.mp4") %>" type="video/mp4" />
                </video>
                <div class="auth-copyright">&copy; 2026 ONYX Gaming Technologies.</div>
            </div>

            <div class="auth-right">
                <div class="auth-top-nav">
                    <a href="onyx_login.aspx"><span>Back to login</span></a>
                </div>

                <div class="auth-form-wrapper">
                    <span class="auth-kicker">Account Recovery</span>
                    <h1 class="auth-title">Set new password.</h1>
                    <p class="auth-copy">
                        Choose a new password for your ONYX account. The reset link can only be used once.
                    </p>

                    <asp:Panel ID="MessagePanel" runat="server" Visible="false">
                        <asp:Literal ID="MessageLiteral" runat="server" />
                    </asp:Panel>

                    <asp:Panel ID="ResetFormPanel" runat="server">
                        <div class="auth-field">
                            <label>New Password</label>
                            <asp:TextBox ID="NewPasswordTextBox" runat="server" TextMode="Password" CssClass="auth-input" />
                        </div>

                        <div class="auth-field">
                            <label>Confirm New Password</label>
                            <asp:TextBox ID="ConfirmPasswordTextBox" runat="server" TextMode="Password" CssClass="auth-input" />
                        </div>

                        <div class="auth-action-row">
                            <a href="onyx_login.aspx" class="auth-secondary-link">Back to login</a>
                            <asp:Button ID="ResetPasswordButton" runat="server" CssClass="auth-submit-btn" Text="UPDATE PASSWORD" OnClick="ResetPasswordButton_Click" />
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            document.body.classList.add("auth-lock-scroll");

            if (window.gsap) {
                var tl = gsap.timeline();
                tl.from(".auth-container", { duration: 1.0, scale: 0.96, opacity: 0, ease: "power4.out" })
                    .from(".auth-video-bg", { duration: 1.4, opacity: 0, ease: "power2.out" }, "-=0.7")
                    .from(".auth-brand, .auth-copyright", { duration: 0.65, x: -24, opacity: 0, stagger: 0.14, ease: "power3.out" }, "-=1.0")
                    .from(".auth-top-nav, .auth-kicker, .auth-title, .auth-copy, .auth-field, .auth-action-row", { duration: 0.55, y: 18, opacity: 0, stagger: 0.06, ease: "power3.out" }, "-=0.7");
            }
        });
    </script>
</asp:Content>
