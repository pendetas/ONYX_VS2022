<%@ Page Title="Register - ONYX" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" Async="true" CodeBehind="onyx_register.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_register" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        * {
            scrollbar-width: none !important;
            -ms-overflow-style: none !important;
        }
        ::-webkit-scrollbar {
            display: none !important;
            width: 0 !important;
            height: 0 !important;
            background: transparent !important;
            -webkit-appearance: none !important;
        }

        .auth-takeover {
            position: fixed;
            top: 0; left: 0;
            width: 100vw; height: 100vh;
            background: #000000 !important;
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Inter', 'Segoe UI', 'Helvetica Neue', Helvetica, Arial, sans-serif;
            color: #ffffff;
            overflow: hidden;
        }

        .auth-container {
            width: 95vw;
            max-width: 1480px;
            height: min(90vh, 820px);
            min-height: 650px;
            background-color: #000000;
            border-radius: 18px;
            display: flex;
            overflow: hidden;
            box-shadow: 0 34px 90px rgba(0,0,0,0.82);
            border: 1px solid rgba(255,255,255,0.075);
        }

        .auth-left {
            flex: 1;
            position: relative;
            border-right: 1px solid rgba(255,255,255,0.08);
            display: flex;
            align-items: center;
            justify-content: center;
            background: #000;
            overflow: hidden;
        }

        .auth-brand {
            color: #ffffff;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
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
            position: absolute;
            bottom: 30px; left: 40px;
            font-size: 11px;
            color: rgba(255,255,255,0.28);
            letter-spacing: 0.16em;
            text-transform: none;
            z-index: 2;
        }

        .auth-video-bg {
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 100%;
            object-fit: cover;
            opacity: 0.42;
            filter: grayscale(1) contrast(1.08) brightness(0.72);
            z-index: 1;
        }

        .auth-left::after {
            content: "";
            position: absolute;
            inset: 0;
            z-index: 1;
            background:
                linear-gradient(90deg, rgba(0,0,0,0.2), rgba(0,0,0,0.72)),
                linear-gradient(180deg, rgba(0,0,0,0.12), rgba(0,0,0,0.76));
            pointer-events: none;
        }

        .auth-right {
            flex: 1.2;
            position: relative;
            background: #000000 !important;
            overflow-y: auto !important;
        }

        .auth-scroll-content {
            padding: clamp(34px, 4vw, 58px) clamp(42px, 5vw, 76px);
            display: flex;
            flex-direction: column;
            min-height: 100%;
            justify-content: center;
            will-change: transform;
        }

        .auth-top-nav {
            text-align: right;
            margin-bottom: 24px;
            display: flex;
            justify-content: flex-end;
            z-index: 10;
            flex-shrink: 0;
        }

        .auth-top-nav a {
            color: rgba(255,255,255,0.42);
            text-decoration: none;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 2px;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 12px;
        }

        .auth-top-nav a::after {
            content: '';
            display: block;
            width: 30px;
            height: 1px;
            background-color: #666;
            transition: all 0.3s ease;
        }

        .auth-top-nav a:hover { color: #c0c0c0; }
        .auth-top-nav a:hover::after { width: 50px; background-color: #c0c0c0; }

        .auth-form-wrapper {
            max-width: 750px;
            margin-top: 0;
            width: 100%;
            padding-bottom: 24px;
            flex-shrink: 0;
            display: flex;
            flex-direction: column;
            position: relative;
        }

        .auth-title {
            font-size: clamp(42px, 4.7vw, 68px);
            line-height: 0.92;
            font-weight: 300;
            margin: 0 0 26px;
            letter-spacing: -0.035em;
        }

        .auth-form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px 28px;
            overflow: visible;
        }

        .auth-field {
            display: flex;
            flex-direction: column;
        }

        .auth-field.full-width { grid-column: 1 / -1; }

        .auth-field label {
            font-size: 11px;
            color: rgba(255,255,255,0.46);
            margin-bottom: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.22em;
        }

        .auth-input {
            background: transparent !important;
            border: none;
            border-bottom: 1px solid rgba(255,255,255,0.18);
            border-radius: 0;
            color: #fff;
            font-size: 15px;
            padding: 9px 0 12px;
            outline: none;
            min-height: 46px;
            transition: border-color 0.3s, box-shadow 0.3s, background 0.3s;
        }

        .auth-input:focus {
            background: transparent !important;
            border-bottom-color: rgba(255,255,255,0.86);
            box-shadow: 0 1px 0 rgba(255,255,255,0.86);
        }

        .cta {
            border: none;
            background: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            text-decoration: none;
            margin-top: 28px;
            align-self: flex-end;
        }

        .cta span {
            padding-bottom: 7px;
            letter-spacing: 4px;
            font-size: 13px;
            padding-right: 15px;
            text-transform: uppercase;
            color: #ffffff;
            font-weight: 600;
            transition: color 0.3s ease;
        }

        .cta svg { transform: translateX(-8px); transition: all 0.3s ease; fill: #ffffff; }
        .cta:hover svg { transform: translateX(0); fill: #c0c0c0; }
        .cta:active svg { transform: scale(0.9); }

        .hover-underline-animation { position: relative; }

        .hover-underline-animation:after {
            content: "";
            position: absolute;
            width: 100%;
            transform: scaleX(0);
            height: 2px;
            bottom: 0; left: 0;
            background-color: #c0c0c0;
            transform-origin: bottom right;
            transition: transform 0.25s ease-out;
        }

        .cta:hover .hover-underline-animation { color: #c0c0c0; }
        .cta:hover .hover-underline-animation:after { transform: scaleX(1); transform-origin: bottom left; }

        .auth-alert { color: #ff4444; font-size: 13px; margin-bottom: 20px; display: block; }

        .oauth-entry {
            display: flex;
            flex-direction: column;
            gap: 20px;
            margin-bottom: 26px;
        }

        .social-row {
            display: flex;
            justify-content: center;
            gap: 16px;
        }

        .social-button {
            width: 64px;
            height: 50px;
            border: 1px solid rgba(255,255,255,0.14);
            background: linear-gradient(180deg, #111111 0%, #030303 100%);
            color: #f5f5f5;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            opacity: 0;
            transform: translateY(16px) scale(0.92);
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.08), 0 18px 36px rgba(0,0,0,0.42);
            animation: oauthEnter 0.72s cubic-bezier(.19,1,.22,1) forwards;
            transition: transform 0.2s ease, background 0.2s ease, color 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .social-button.google { animation-delay: 0.16s; }
        .social-button.discord { animation-delay: 0.24s; }
        .social-button.facebook { animation-delay: 0.32s; }

        .social-button:hover {
            background: #ffffff;
            color: #111;
            transform: translateY(-2px);
            border-color: #ffffff;
            box-shadow: 0 20px 44px rgba(255,255,255,0.12);
        }

        .social-button.discord:hover {
            background: #ffffff;
            border-color: #ffffff;
            color: #111;
        }

        .social-icon {
            width: 23px;
            height: 23px;
            flex: 0 0 23px;
            display: block;
        }

        .sr-only {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            white-space: nowrap;
            border: 0;
        }

        .oauth-divider {
            display: flex;
            align-items: center;
            gap: 14px;
            color: rgba(255,255,255,0.42);
            font-size: 12px;
            letter-spacing: 0.08em;
        }

        .oauth-divider::before,
        .oauth-divider::after {
            content: "";
            height: 1px;
            flex: 1;
            background: rgba(255,255,255,0.12);
        }

        /* ============================
           SEGMENTED DATE INPUT
        ============================ */
        .date-seg-wrapper {
            display: flex;
            align-items: center;
            border: none;
            border-bottom: 1px solid rgba(255,255,255,0.18);
            padding: 9px 0 12px;
            gap: 0;
            transition: border-color 0.3s, box-shadow 0.3s;
        }

        .date-seg-wrapper:focus-within {
            border-bottom-color: rgba(255,255,255,0.86);
            box-shadow: 0 1px 0 rgba(255,255,255,0.86);
        }

        .date-seg-wrapper.has-error {
            border-bottom-color: #ff4444;
            box-shadow: 0 1px 0 #ff4444;
        }

        .date-seg {
            background: transparent;
            border: none;
            color: #fff;
            font-size: 15px;
            font-family: inherit;
            outline: none;
            text-align: center;
            width: 26px;
            padding: 0;
            caret-color: #c0c0c0;
        }

        .date-seg.yyyy { width: 50px; text-align: left; }

        .date-seg::placeholder { color: #383838; }

        .date-sep {
            color: #3a3a3a;
            font-size: 15px;
            user-select: none;
            padding: 0 3px;
            line-height: 1;
            transition: color 0.3s;
        }

        .date-seg-wrapper:focus-within .date-sep { color: #666; }

        .date-feedback {
            font-size: 10px;
            font-weight: 600;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            margin-top: 7px;
            min-height: 13px;
            transition: color 0.2s;
        }

        .date-feedback.error { color: #ff4444; }
        .date-feedback.valid { color: #c0c0c0; }

        /* ============================
           PASSWORD STRENGTH
        ============================ */
        .strength-wrapper {
            margin-top: 10px;
            display: none;
        }

        .strength-bars {
            display: flex;
            gap: 5px;
            margin-bottom: 5px;
        }

        .strength-bar {
            height: 2px;
            flex: 1;
            border-radius: 2px;
            background: #1e1e1e;
            transition: background 0.35s ease;
        }

        .strength-text {
            font-size: 10px;
            font-weight: 700;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: #333;
            transition: color 0.35s;
        }

        /* ============================
           PASSWORD MATCH
        ============================ */
        .match-indicator {
            margin-top: 8px;
            font-size: 10px;
            font-weight: 600;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            min-height: 14px;
            display: flex;
            align-items: center;
            gap: 5px;
            color: transparent;
            transition: color 0.3s;
        }

        .match-indicator.matched { color: #c0c0c0; }
        .match-indicator.unmatched { color: #ff4444; }

        @keyframes oauthEnter {
            0% {
                opacity: 0;
                transform: translateY(16px) scale(0.92);
                filter: blur(8px);
            }
            100% {
                opacity: 1;
                transform: translateY(0) scale(1);
                filter: blur(0);
            }
        }

        @media (max-width: 1100px) {
            .auth-left {
                flex: 0.82;
            }

            .auth-right {
                flex: 1.18;
            }

            .auth-form-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 900px) {
            .auth-container {
                width: 100vw;
                height: 100vh;
                min-height: 0;
                border-radius: 0;
            }

            .auth-left {
                display: none;
            }

            .auth-scroll-content {
                padding: 34px 24px;
                justify-content: flex-start;
            }

            .auth-form-wrapper {
                max-width: none;
            }
        }

        .auth-takeover input.auth-input,
        .auth-takeover textarea.auth-input,
        .auth-takeover select.auth-input,
        .auth-takeover .date-seg-wrapper {
            background: transparent !important;
            background-color: transparent !important;
            background-image: none !important;
            border: 0 !important;
            border-bottom: 1px solid rgba(255,255,255,0.22) !important;
            border-radius: 0 !important;
            box-shadow: none !important;
            color: #f2f2f2 !important;
            outline: 0 !important;
            padding: 8px 0 12px !important;
            -webkit-appearance: none !important;
            appearance: none !important;
        }

        .auth-takeover input.auth-input::placeholder,
        .auth-takeover textarea.auth-input::placeholder,
        .auth-takeover .date-seg::placeholder {
            color: rgba(255,255,255,0.42) !important;
            opacity: 1 !important;
        }

        .auth-takeover input.auth-input:hover,
        .auth-takeover textarea.auth-input:hover,
        .auth-takeover select.auth-input:hover,
        .auth-takeover .date-seg-wrapper:hover {
            border-bottom-color: rgba(255,255,255,0.34) !important;
        }

        .auth-takeover input.auth-input:focus,
        .auth-takeover textarea.auth-input:focus,
        .auth-takeover select.auth-input:focus,
        .auth-takeover .date-seg-wrapper:focus-within {
            border-bottom-color: rgba(255,255,255,0.82) !important;
            box-shadow: 0 1px 0 rgba(255,255,255,0.82) !important;
        }

        .auth-takeover .date-seg,
        .auth-takeover .date-seg:focus,
        .auth-takeover .date-seg:hover {
            background: transparent !important;
            background-color: transparent !important;
            border: 0 !important;
            border-radius: 0 !important;
            box-shadow: none !important;
            color: #f2f2f2 !important;
            outline: 0 !important;
            -webkit-appearance: none !important;
            appearance: none !important;
        }

        .auth-takeover input.auth-input:-webkit-autofill,
        .auth-takeover input.auth-input:-webkit-autofill:hover,
        .auth-takeover input.auth-input:-webkit-autofill:focus {
            -webkit-text-fill-color: #f2f2f2 !important;
            -webkit-box-shadow: 0 0 0 1000px #000 inset !important;
            border: 0 !important;
            border-bottom: 1px solid rgba(255,255,255,0.22) !important;
            caret-color: #ffffff !important;
        }
    </style>

    <div class="auth-takeover">
        <div class="auth-container">

            <div class="auth-left">
                <a href="<%= ResolveUrl("~/customer_page/onyx_home.aspx") %>" class="auth-brand" aria-label="Back to ONYX home">onyx</a>
                <video autoplay loop muted playsinline class="auth-video-bg">
                    <source src="<%= ResolveUrl("~/Videos/onyx_headset.mp4") %>" type="video/mp4" />
                </video>


                <div class="auth-copyright">&copy; 2026 ONYX Gaming Technologies.</div>
            </div>

            <div class="auth-right">
                <div class="auth-scroll-content">
                <div class="auth-top-nav">
                    <a href="onyx_login.aspx"><span>Already have an account? Sign In</span></a>
                </div>

                <div class="auth-form-wrapper">
                    <h1 class="auth-title">Register</h1>

                    <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

                    <div class="oauth-entry">
                        <div class="social-row">
                            <asp:LinkButton ID="GoogleRegisterButton" runat="server" CssClass="social-button google" CausesValidation="false" ToolTip="Sign up with Google" OnClick="GoogleRegisterButton_Click">
                                <svg class="social-icon" viewBox="0 0 18 18" aria-hidden="true" focusable="false" xmlns="http://www.w3.org/2000/svg">
                                    <path fill="#4285F4" d="M17.64 9.2c0-.64-.06-1.25-.16-1.84H9v3.48h4.84a4.14 4.14 0 0 1-1.8 2.72v2.26h2.92c1.7-1.57 2.68-3.88 2.68-6.62z"/>
                                    <path fill="#34A853" d="M9 18c2.43 0 4.47-.8 5.96-2.18l-2.92-2.26c-.8.54-1.84.86-3.04.86-2.34 0-4.32-1.58-5.03-3.7H.96v2.33A9 9 0 0 0 9 18z"/>
                                    <path fill="#FBBC05" d="M3.97 10.72A5.41 5.41 0 0 1 3.69 9c0-.6.1-1.18.28-1.72V4.95H.96A9 9 0 0 0 0 9c0 1.45.35 2.82.96 4.05l3.01-2.33z"/>
                                    <path fill="#EA4335" d="M9 3.58c1.32 0 2.5.45 3.43 1.35l2.59-2.59A8.65 8.65 0 0 0 9 0 9 9 0 0 0 .96 4.95l3.01 2.33C4.68 5.16 6.66 3.58 9 3.58z"/>
                                </svg>
                                <span class="sr-only">Sign up with Google</span>
                            </asp:LinkButton>
                            <asp:LinkButton ID="DiscordRegisterButton" runat="server" CssClass="social-button discord" CausesValidation="false" ToolTip="Sign up with Discord" OnClick="DiscordRegisterButton_Click">
                                <svg class="social-icon" viewBox="0 0 127.14 96.36" aria-hidden="true" focusable="false" xmlns="http://www.w3.org/2000/svg">
                                    <path fill="currentColor" d="M107.7 8.07A105.15 105.15 0 0 0 81.47 0a72.06 72.06 0 0 0-3.36 6.83 97.68 97.68 0 0 0-29.11 0A72.37 72.37 0 0 0 45.64 0 105.89 105.89 0 0 0 19.39 8.09C2.79 32.65-1.71 56.6.54 80.21a105.73 105.73 0 0 0 32.17 16.15 77.7 77.7 0 0 0 6.89-11.11 68.42 68.42 0 0 1-10.85-5.18c.91-.66 1.8-1.34 2.66-2.03a75.57 75.57 0 0 0 64.32 0c.87.71 1.76 1.39 2.66 2.03a68.68 68.68 0 0 1-10.87 5.19 77 77 0 0 0 6.89 11.1 105.25 105.25 0 0 0 32.19-16.14c2.64-27.38-4.51-51.11-18.9-72.15ZM42.45 65.69c-6.26 0-11.4-5.75-11.4-12.81s5.04-12.82 11.4-12.82c6.4 0 11.51 5.8 11.4 12.82 0 7.06-5.04 12.81-11.4 12.81Zm42.24 0c-6.26 0-11.4-5.75-11.4-12.81s5.04-12.82 11.4-12.82c6.4 0 11.51 5.8 11.4 12.82 0 7.06-5.01 12.81-11.4 12.81Z"/>
                                </svg>
                                <span class="sr-only">Sign up with Discord</span>
                            </asp:LinkButton>
                            <asp:LinkButton ID="FacebookRegisterButton" runat="server" CssClass="social-button facebook" CausesValidation="false" ToolTip="Sign up with Facebook" OnClick="FacebookRegisterButton_Click">
                                <svg class="social-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false" xmlns="http://www.w3.org/2000/svg">
                                    <path fill="currentColor" d="M14.2 8.4H16V5.1c-.3 0-1.5-.1-2.8-.1-2.8 0-4.7 1.7-4.7 4.9V12H5.4v3.7h3.1V24h3.8v-8.3h3.1l.5-3.7h-3.6V10.2c0-1.1.3-1.8 1.9-1.8Z"/>
                                </svg>
                                <span class="sr-only">Sign up with Facebook</span>
                            </asp:LinkButton>
                        </div>
                        <div class="oauth-divider">or create manually</div>
                    </div>

                    <div class="auth-form-grid">

                        <div class="auth-field">
                            <label>Full Name</label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="auth-input" required="true" placeholder="John Doe" />
                        </div>

                        <div class="auth-field">
                            <label>Username</label>
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="auth-input" required="true" placeholder="johndoe99" />
                        </div>

                        <div class="auth-field">
                            <label>Email Address</label>
                            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="auth-input" required="true" placeholder="name@example.com" />
                        </div>

                        <div class="auth-field">
                            <label>Phone Number</label>
                            <asp:TextBox ID="txtPhone" runat="server" TextMode="Phone" CssClass="auth-input" placeholder="+60 12-345 6789" />
                        </div>

                        <div class="auth-field">
                            <label>Password</label>
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="auth-input" required="true" placeholder="Enter strong password" />
                            <div class="strength-wrapper" id="strengthWrapper">
                                <div class="strength-bars">
                                    <div class="strength-bar" id="sbar1"></div>
                                    <div class="strength-bar" id="sbar2"></div>
                                    <div class="strength-bar" id="sbar3"></div>
                                    <div class="strength-bar" id="sbar4"></div>
                                </div>
                                <span class="strength-text" id="strengthText"></span>
                            </div>
                        </div>

                        <div class="auth-field">
                            <label>Confirm Password</label>
                            <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="auth-input" required="true" placeholder="Confirm password" />
                            <div class="match-indicator" id="matchIndicator"></div>
                        </div>

                        <div class="auth-field">
                            <label>Date of Birth</label>
                            <asp:TextBox ID="txtDob" runat="server" CssClass="auth-input" style="display:none" />
                            <div class="date-seg-wrapper" id="dateSegWrapper">
                                <input type="text" id="segDD"   class="date-seg"      placeholder="DD"   maxlength="2" inputmode="numeric" autocomplete="off" />
                                <span class="date-sep">/</span>
                                <input type="text" id="segMM"   class="date-seg"      placeholder="MM"   maxlength="2" inputmode="numeric" autocomplete="off" />
                                <span class="date-sep">/</span>
                                <input type="text" id="segYYYY" class="date-seg yyyy" placeholder="YYYY" maxlength="4" inputmode="numeric" autocomplete="off" />
                            </div>
                            <div id="dateMsg" class="date-feedback"></div>
                        </div>

                    </div>

                    <asp:LinkButton ID="btnRegister" runat="server" CssClass="cta" OnClick="btnRegister_Click">
                        <span class="hover-underline-animation">REGISTER NOW</span>
                        <svg viewBox="0 0 46 16" height="10" width="30" xmlns="http://www.w3.org/2000/svg" id="arrow-horizontal">
                            <path transform="translate(30)" d="M8,0,6.545,1.455l5.506,5.506H-30V9.039H12.052L6.545,14.545,8,16l8-8Z" data-name="Path 10" id="Path_10"></path>
                        </svg>
                    </asp:LinkButton>
                </div>
                </div><!-- /.auth-scroll-content -->
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/studio-freight/lenis@1.0.19/bundled/lenis.min.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", () => {

            // Lenis smooth scroll � wrapper clips, content is the full scrollable area
            const lenisWrapper  = document.querySelector('.auth-right');
            const lenisContent  = document.querySelector('.auth-scroll-content');
            if (lenisWrapper && lenisContent) {
                const lenis = new Lenis({
                    wrapper:     lenisWrapper,
                    content:     lenisContent,
                    lerp:        0.1,
                    smoothWheel: true,
                    syncTouch:   true
                });
                function raf(time) { lenis.raf(time); requestAnimationFrame(raf); }
                requestAnimationFrame(raf);
            }

            // GSAP entrance
            const tl = gsap.timeline();
            tl.from(".auth-container", { duration: 1.2, scale: 0.96, opacity: 0, ease: "power4.out" })
              .from(".auth-video-bg",   { duration: 2, opacity: 0, ease: "power2.out" }, "-=0.8")
              .from(".auth-brand, .auth-copyright", { duration: 0.8, x: -30, opacity: 0, stagger: 0.2, ease: "power3.out" }, "-=1.5")
              .from(".auth-top-nav, .auth-title",   { duration: 0.8, y: 20,  opacity: 0, stagger: 0.1, ease: "power3.out" }, "-=1.2")
              .from(".oauth-divider", { duration: 0.6, y: 12, opacity: 0, ease: "power3.out" }, "-=0.65")
              .from(".auth-field", { duration: 0.6, y: 20, opacity: 0, stagger: 0.06, ease: "power3.out" }, "-=0.45")
              .from(".cta",        { duration: 1.2, y: 30, opacity: 0, ease: "expo.out", clearProps: "all" }, "-=0.4");

            // ============================================================
            //  SEGMENTED DATE INPUT  (DD / MM / YYYY)
            // ============================================================
            const segDD        = document.getElementById('segDD');
            const segMM        = document.getElementById('segMM');
            const segYYYY      = document.getElementById('segYYYY');
            const dateMsg      = document.getElementById('dateMsg');
            const dateWrapper  = document.getElementById('dateSegWrapper');
            const hiddenDob    = document.getElementById('<%= txtDob.ClientID %>');
            const today        = new Date(); today.setHours(0, 0, 0, 0);

            const MONTH_NAMES = ['January','February','March','April','May','June',
                                 'July','August','September','October','November','December'];

            function daysInMonth(m, y) { return new Date(y, m, 0).getDate(); }
            function pad(n) { return String(n).padStart(2, '0'); }

            function setMsg(text, type) {
                dateMsg.textContent = text;
                dateMsg.className   = 'date-feedback' + (type ? ' ' + type : '');
                dateWrapper.classList.toggle('has-error', type === 'error');
            }

            function validateDate() {
                const dd   = parseInt(segDD.value,   10);
                const mm   = parseInt(segMM.value,   10);
                const yyyy = parseInt(segYYYY.value, 10);
                const full = segDD.value.length === 2 && segMM.value.length === 2 && segYYYY.value.length === 4;

                hiddenDob.value = '';

                if (!segDD.value && !segMM.value && !segYYYY.value) { setMsg('', ''); return; }
                if (!full) { setMsg('', ''); return; }

                // Year range
                if (yyyy < 1900 || yyyy > today.getFullYear()) {
                    setMsg('Year must be between 1900 and ' + today.getFullYear(), 'error'); return;
                }
                // Month-aware day validation
                const maxDays = daysInMonth(mm, yyyy);
                if (dd < 1 || dd > maxDays) {
                    setMsg(MONTH_NAMES[mm - 1] + ' ' + yyyy + ' only has ' + maxDays + ' days', 'error'); return;
                }
                // Not in the future
                const entered = new Date(yyyy, mm - 1, dd);
                if (entered > today) {
                    setMsg('Date of birth cannot be in the future', 'error'); return;
                }
                // Max age 120
                const oldest = new Date(today.getFullYear() - 120, today.getMonth(), today.getDate());
                if (entered < oldest) {
                    setMsg('Please enter a valid year of birth', 'error'); return;
                }
                // Min age 13
                const minAge = new Date(today.getFullYear() - 13, today.getMonth(), today.getDate());
                if (entered > minAge) {
                    setMsg('You must be at least 13 years old to register', 'error'); return;
                }

                hiddenDob.value = yyyy + '-' + pad(mm) + '-' + pad(dd);
                setMsg('Valid date of birth', 'valid');
            }

            // DD handlers
            segDD.addEventListener('input', () => {
                segDD.value = segDD.value.replace(/\D/g, '').slice(0, 2);
                const v = parseInt(segDD.value, 10);
                if (segDD.value.length === 1 && v > 3) {
                    segDD.value = '0' + segDD.value;
                    segMM.focus(); segMM.select();
                } else if (segDD.value.length === 2) {
                    if (v < 1 || v > 31) { setMsg('Day must be 01 - 31', 'error'); segDD.value = ''; return; }
                    segMM.focus(); segMM.select();
                }
                validateDate();
            });
            segDD.addEventListener('keydown', e => {
                if (e.key === 'ArrowRight' && segDD.selectionStart === segDD.value.length) {
                    e.preventDefault(); segMM.focus(); segMM.select();
                }
            });

            // MM handlers
            segMM.addEventListener('input', () => {
                segMM.value = segMM.value.replace(/\D/g, '').slice(0, 2);
                const v = parseInt(segMM.value, 10);
                if (segMM.value.length === 1 && v > 1) {
                    segMM.value = '0' + segMM.value;
                    segYYYY.focus(); segYYYY.select();
                } else if (segMM.value.length === 2) {
                    if (v < 1 || v > 12) { setMsg('Month must be 01 - 12', 'error'); segMM.value = ''; return; }
                    segYYYY.focus(); segYYYY.select();
                }
                validateDate();
            });
            segMM.addEventListener('keydown', e => {
                if (e.key === 'Backspace' && segMM.value === '') {
                    e.preventDefault(); segDD.focus(); segDD.setSelectionRange(segDD.value.length, segDD.value.length);
                }
                if (e.key === 'ArrowLeft'  && segMM.selectionStart === 0)               { e.preventDefault(); segDD.focus(); }
                if (e.key === 'ArrowRight' && segMM.selectionStart === segMM.value.length) { e.preventDefault(); segYYYY.focus(); segYYYY.select(); }
            });

            // YYYY handlers
            segYYYY.addEventListener('input', () => {
                segYYYY.value = segYYYY.value.replace(/\D/g, '').slice(0, 4);
                validateDate();
            });
            segYYYY.addEventListener('keydown', e => {
                if (e.key === 'Backspace' && segYYYY.value === '') {
                    e.preventDefault(); segMM.focus(); segMM.setSelectionRange(segMM.value.length, segMM.value.length);
                }
                if (e.key === 'ArrowLeft' && segYYYY.selectionStart === 0) { e.preventDefault(); segMM.focus(); }
            });

            // ============================================================
            //  PASSWORD STRENGTH
            // ============================================================
            const pwdInput        = document.getElementById('<%= txtPassword.ClientID %>');
            const strengthWrapper = document.getElementById('strengthWrapper');
            const strengthText    = document.getElementById('strengthText');
            const bars = ['sbar1','sbar2','sbar3','sbar4'].map(id => document.getElementById(id));

            const STRENGTH_LEVELS = [
                null,
                { label: 'WEAK',       color: '#ff4444' },
                { label: 'FAIR',       color: '#777777' },
                { label: 'GOOD',       color: '#a8a8a8' },
                { label: 'STRONG',     color: '#d4d4d4' }
            ];

            function getScore(pwd) {
                let s = 0;
                if (pwd.length >= 8)           s++;
                if (pwd.length >= 12)          s++;
                if (/[A-Z]/.test(pwd))         s++;
                if (/[0-9]/.test(pwd))         s++;
                if (/[^A-Za-z0-9]/.test(pwd))  s++;
                return Math.min(4, Math.max(1, Math.round(s / 5 * 4) || 1));
            }

            function updateStrength() {
                const val = pwdInput.value;
                if (!val) { strengthWrapper.style.display = 'none'; return; }
                strengthWrapper.style.display = 'block';
                const score = getScore(val);
                const lvl   = STRENGTH_LEVELS[score];
                bars.forEach((bar, i) => { bar.style.background = i < score ? lvl.color : '#1e1e1e'; });
                strengthText.textContent = lvl.label;
                strengthText.style.color = lvl.color;
                checkMatch();
            }

            pwdInput.addEventListener('input', updateStrength);

            // ============================================================
            //  PASSWORD MATCH
            // ============================================================
            const confirmInput   = document.getElementById('<%= txtConfirmPassword.ClientID %>');
            const matchIndicator = document.getElementById('matchIndicator');

            function checkMatch() {
                const val = confirmInput.value;
                if (!val) {
                    matchIndicator.textContent = '';
                    matchIndicator.className = 'match-indicator';
                    return;
                }
                if (pwdInput.value === val) {
                    matchIndicator.innerHTML = '&#10003;&nbsp; Passwords match';
                    matchIndicator.className = 'match-indicator matched';
                } else {
                    matchIndicator.innerHTML = '&#10007;&nbsp; Passwords do not match';
                    matchIndicator.className = 'match-indicator unmatched';
                }
            }

            confirmInput.addEventListener('input', checkMatch);
        });
    </script>
</asp:Content>
