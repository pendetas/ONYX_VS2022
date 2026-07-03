<%@ Page Title="Login" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" Async="true" CodeBehind="onyx_login.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_login" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Force scrollbar removal across all browsers */
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

        /* Fullscreen takeover to override MasterPage formatting */
        .auth-takeover {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
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

        /* Left Panel - Video BG */
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
            position: absolute;
            top: 30px;
            left: 40px;
            font-size: 19px;
            font-weight: 700;
            letter-spacing: -0.04em;
            z-index: 2;
        }

        .auth-copyright {
            position: absolute;
            bottom: 30px;
            left: 40px;
            font-size: 11px;
            color: rgba(255,255,255,0.28);
            letter-spacing: 0.16em;
            text-transform: uppercase;
            z-index: 2;
        }

        .auth-video-bg {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
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
                linear-gradient(90deg, rgba(0,0,0,0.25), rgba(0,0,0,0.72)),
                linear-gradient(180deg, rgba(0,0,0,0.18), rgba(0,0,0,0.72));
            pointer-events: none;
        }

        /* Right Panel - Form Area */
        .auth-right {
            flex: 1;
            padding: clamp(34px, 4.5vw, 70px) clamp(42px, 5vw, 78px);
            position: relative;
            background: #000000 !important;
            display: flex;
            flex-direction: column;
            overflow-y: auto !important; 
        }

        .auth-top-nav {
            text-align: right;
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

        .auth-top-nav a:hover {
            color: #c0c0c0;
        }

        .auth-top-nav a:hover::after {
            width: 50px;
            background-color: #c0c0c0;
        }

        /* Fixed missing button by preventing squishing */
        .auth-form-wrapper {
            margin: auto 0;
            max-width: 520px;
            width: 100%;
            flex-shrink: 0; /* Forces scrolling if screen is too small */
            padding-top: 28px;
            padding-bottom: 28px;
            display: flex;
            flex-direction: column;
        }

        .auth-title {
            font-size: clamp(46px, 5vw, 72px);
            line-height: 0.92;
            font-weight: 300;
            margin: 0 0 34px;
            letter-spacing: -0.035em;
        }

        .auth-form-grid {
            display: grid;
            grid-template-columns: 1fr; 
            gap: 30px;
        }

        .auth-field {
            display: flex;
            flex-direction: column;
        }

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
            font-size: 16px;
            padding: 10px 0 13px;
            outline: none;
            min-height: 52px;
            transition: border-color 0.3s, box-shadow 0.3s, background 0.3s;
        }

        .auth-input:focus {
            background: transparent !important;
            border-bottom-color: rgba(255,255,255,0.86);
            box-shadow: 0 1px 0 rgba(255,255,255,0.86);
        }

        /* UIverse Button "empty-moose-12" */
        .cta {
            border: none;
            background: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            text-decoration: none;
            margin-top: 42px;
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

        .cta svg {
            transform: translateX(-8px);
            transition: all 0.3s ease;
            fill: #ffffff;
        }

        .cta:hover svg {
            transform: translateX(0);
            fill: #c0c0c0;
        }

        .cta:active svg {
            transform: scale(0.9);
        }

        .hover-underline-animation {
            position: relative;
        }

        .hover-underline-animation:after {
            content: "";
            position: absolute;
            width: 100%;
            transform: scaleX(0);
            height: 2px;
            bottom: 0;
            left: 0;
            background-color: #c0c0c0;
            transform-origin: bottom right;
            transition: transform 0.25s ease-out;
        }

        .cta:hover .hover-underline-animation {
            color: #c0c0c0;
        }

        .cta:hover .hover-underline-animation:after {
            transform: scaleX(1);
            transform-origin: bottom left;
        }

        .auth-alert {
            color: #ff4444;
            font-size: 13px;
            margin-bottom: 20px;
            display: block;
        }

        .oauth-entry {
            display: flex;
            flex-direction: column;
            gap: 20px;
            margin-top: -10px;
            margin-bottom: 32px;
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

        .captcha-wrapper {
            margin-top: 28px;
            min-height: 65px;
            display: flex;
            justify-content: flex-start;
        }

        .cta.captcha-pending {
            opacity: 0.45;
            cursor: not-allowed;
        }

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

            .auth-right {
                padding: 34px 24px;
            }

            .auth-form-wrapper {
                max-width: none;
            }
        }

        .auth-takeover input.auth-input,
        .auth-takeover textarea.auth-input,
        .auth-takeover select.auth-input {
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
        .auth-takeover textarea.auth-input::placeholder {
            color: rgba(255,255,255,0.42) !important;
            opacity: 1 !important;
        }

        .auth-takeover input.auth-input:hover,
        .auth-takeover textarea.auth-input:hover,
        .auth-takeover select.auth-input:hover {
            border-bottom-color: rgba(255,255,255,0.34) !important;
        }

        .auth-takeover input.auth-input:focus,
        .auth-takeover textarea.auth-input:focus,
        .auth-takeover select.auth-input:focus {
            border-bottom-color: rgba(255,255,255,0.82) !important;
            box-shadow: 0 1px 0 rgba(255,255,255,0.82) !important;
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
            
            <!-- Left Side: Video Background -->
            <div class="auth-left">
                <div class="auth-brand">ONYX&deg;</div>
                
                <video autoplay loop muted playsinline class="auth-video-bg">
                    <source src="<%= ResolveUrl("~/Videos/ONYX_Cinematic_Logo.mp4") %>" type="video/mp4" />
                </video>

                <div class="auth-copyright">&copy; ONYX 2025. All rights reserved.</div>
            </div>

            <div class="auth-right">
                <div class="auth-top-nav">
                    <a href="onyx_register.aspx"><span>Create an account</span></a>
                </div>

                <div class="auth-form-wrapper">
                    <h1 class="auth-title">Login</h1>
                    
                    <asp:Panel ID="MessagePanel" runat="server" Visible="false">
                        <asp:Literal ID="MessageLiteral" runat="server" />
                    </asp:Panel>

                    <div class="oauth-entry">
                        <div class="social-row">
                            <asp:LinkButton ID="GoogleLoginButton" runat="server" CssClass="social-button google" CausesValidation="false" ToolTip="Continue with Google" OnClick="GoogleLoginButton_Click">
                                <svg class="social-icon" viewBox="0 0 18 18" aria-hidden="true" focusable="false" xmlns="http://www.w3.org/2000/svg">
                                    <path fill="#4285F4" d="M17.64 9.2c0-.64-.06-1.25-.16-1.84H9v3.48h4.84a4.14 4.14 0 0 1-1.8 2.72v2.26h2.92c1.7-1.57 2.68-3.88 2.68-6.62z"/>
                                    <path fill="#34A853" d="M9 18c2.43 0 4.47-.8 5.96-2.18l-2.92-2.26c-.8.54-1.84.86-3.04.86-2.34 0-4.32-1.58-5.03-3.7H.96v2.33A9 9 0 0 0 9 18z"/>
                                    <path fill="#FBBC05" d="M3.97 10.72A5.41 5.41 0 0 1 3.69 9c0-.6.1-1.18.28-1.72V4.95H.96A9 9 0 0 0 0 9c0 1.45.35 2.82.96 4.05l3.01-2.33z"/>
                                    <path fill="#EA4335" d="M9 3.58c1.32 0 2.5.45 3.43 1.35l2.59-2.59A8.65 8.65 0 0 0 9 0 9 9 0 0 0 .96 4.95l3.01 2.33C4.68 5.16 6.66 3.58 9 3.58z"/>
                                </svg>
                                <span class="sr-only">Continue with Google</span>
                            </asp:LinkButton>
                            <asp:LinkButton ID="DiscordLoginButton" runat="server" CssClass="social-button discord" CausesValidation="false" ToolTip="Continue with Discord" OnClick="DiscordLoginButton_Click">
                                <svg class="social-icon" viewBox="0 0 127.14 96.36" aria-hidden="true" focusable="false" xmlns="http://www.w3.org/2000/svg">
                                    <path fill="currentColor" d="M107.7 8.07A105.15 105.15 0 0 0 81.47 0a72.06 72.06 0 0 0-3.36 6.83 97.68 97.68 0 0 0-29.11 0A72.37 72.37 0 0 0 45.64 0 105.89 105.89 0 0 0 19.39 8.09C2.79 32.65-1.71 56.6.54 80.21a105.73 105.73 0 0 0 32.17 16.15 77.7 77.7 0 0 0 6.89-11.11 68.42 68.42 0 0 1-10.85-5.18c.91-.66 1.8-1.34 2.66-2.03a75.57 75.57 0 0 0 64.32 0c.87.71 1.76 1.39 2.66 2.03a68.68 68.68 0 0 1-10.87 5.19 77 77 0 0 0 6.89 11.1 105.25 105.25 0 0 0 32.19-16.14c2.64-27.38-4.51-51.11-18.9-72.15ZM42.45 65.69c-6.26 0-11.4-5.75-11.4-12.81s5.04-12.82 11.4-12.82c6.4 0 11.51 5.8 11.4 12.82 0 7.06-5.04 12.81-11.4 12.81Zm42.24 0c-6.26 0-11.4-5.75-11.4-12.81s5.04-12.82 11.4-12.82c6.4 0 11.51 5.8 11.4 12.82 0 7.06-5.01 12.81-11.4 12.81Z"/>
                                </svg>
                                <span class="sr-only">Continue with Discord</span>
                            </asp:LinkButton>
                            <asp:LinkButton ID="FacebookLoginButton" runat="server" CssClass="social-button facebook" CausesValidation="false" ToolTip="Continue with Facebook" OnClick="FacebookLoginButton_Click">
                                <svg class="social-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false" xmlns="http://www.w3.org/2000/svg">
                                    <path fill="currentColor" d="M14.2 8.4H16V5.1c-.3 0-1.5-.1-2.8-.1-2.8 0-4.7 1.7-4.7 4.9V12H5.4v3.7h3.1V24h3.8v-8.3h3.1l.5-3.7h-3.6V10.2c0-1.1.3-1.8 1.9-1.8Z"/>
                                </svg>
                                <span class="sr-only">Continue with Facebook</span>
                            </asp:LinkButton>
                        </div>
                        <div class="oauth-divider">or sign in manually</div>
                    </div>

                    <div class="auth-form-grid">
                        <div class="auth-field">
                            <label>Email / Username</label>
                            <asp:TextBox ID="EmailTextBox" runat="server" CssClass="auth-input" placeholder="Enter email or 'admin'" />
                        </div>

                        <div class="auth-field">
                            <label>Password</label>
                            <asp:TextBox ID="PasswordTextBox" runat="server" CssClass="auth-input" TextMode="Password" placeholder="Enter password" />
                        </div>
                    </div>

                    <div class="captcha-wrapper">
                        <div class="cf-turnstile"
                             data-sitekey="<%= Server.HtmlEncode(TurnstileSiteKey) %>"
                             data-theme="dark"
                             data-callback="onTurnstileSuccess"
                             data-expired-callback="onTurnstileExpired"
                             data-error-callback="onTurnstileExpired"></div>
                    </div>

                    <!-- Uiverse "empty-moose-12" LinkButton -->
                    <asp:LinkButton ID="LoginButton" runat="server" CssClass="cta captcha-pending" OnClientClick="return ensureCaptchaCompleted();" OnClick="LoginButton_Click">
                        <span class="hover-underline-animation">LOG IN</span>
                        <svg viewBox="0 0 46 16" height="10" width="30" xmlns="http://www.w3.org/2000/svg" id="arrow-horizontal">
                            <path transform="translate(30)" d="M8,0,6.545,1.455l5.506,5.506H-30V9.039H12.052L6.545,14.545,8,16l8-8Z" data-name="Path 10" id="Path_10"></path>
                        </svg>
                    </asp:LinkButton>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/studio-freight/lenis@1.0.19/bundled/lenis.min.js"></script>
    <script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>

    <script>
        let captchaCompleted = false;

        function onTurnstileSuccess() {
            captchaCompleted = true;
            const button = document.getElementById('<%= LoginButton.ClientID %>');
            if (button) button.classList.remove('captcha-pending');
        }

        function onTurnstileExpired() {
            captchaCompleted = false;
            const button = document.getElementById('<%= LoginButton.ClientID %>');
            if (button) button.classList.add('captcha-pending');
        }

        function ensureCaptchaCompleted() {
            return captchaCompleted;
        }

        document.addEventListener("DOMContentLoaded", () => {

            // 1. Lenis Smooth Scroll Initialization on Right Panel
            const scrollContainer = document.querySelector('.auth-right');
            const scrollContent = document.querySelector('.auth-form-wrapper');

            if (scrollContainer && scrollContent) {
                const lenis = new Lenis({
                    wrapper: scrollContainer,
                    content: scrollContent,
                    lerp: 0.08,
                    smoothWheel: true
                });
                function raf(time) {
                    lenis.raf(time);
                    requestAnimationFrame(raf);
                }
                requestAnimationFrame(raf);
            }

            // 2. Cinematic GSAP Timeline Sequence
            const tl = gsap.timeline();

            tl.from(".auth-container", { duration: 1.2, scale: 0.96, opacity: 0, ease: "power4.out" })
                .from(".auth-video-bg", { duration: 2, opacity: 0, ease: "power2.out" }, "-=0.8")
                .from(".auth-brand, .auth-copyright", { duration: 0.8, x: -30, opacity: 0, stagger: 0.2, ease: "power3.out" }, "-=1.5")
              .from(".auth-top-nav, .auth-title", { duration: 0.8, y: 20, opacity: 0, stagger: 0.1, ease: "power3.out" }, "-=1.2")
                .from(".oauth-divider", { duration: 0.6, y: 12, opacity: 0, ease: "power3.out" }, "-=0.65")
                .from(".auth-field", { duration: 0.6, y: 20, opacity: 0, stagger: 0.1, ease: "power3.out" }, "-=0.45")
                // Uiverse button elegantly slides in. clearProps ensures hover CSS works smoothly afterwards!
                .from(".cta", { duration: 1.2, y: 30, opacity: 0, ease: "expo.out", clearProps: "all" }, "-=0.4");
        });
    </script>
</asp:Content>
