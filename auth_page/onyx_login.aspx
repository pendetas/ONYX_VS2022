<%@ Page Title="Login" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_login.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_login" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Fullscreen takeover to override MasterPage formatting */
        .auth-takeover {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background-color: #050505;
            z-index: 12000;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Inter', 'Helvetica Neue', Helvetica, Arial, sans-serif;
            color: #ffffff;
            pointer-events: auto;
            overflow: hidden;
            overscroll-behavior: none;
        }

        body.auth-lock-scroll {
            height: 100vh;
            overflow: hidden !important;
        }

        .auth-container {
            width: 95vw;
            max-width: 1400px;
            height: 90vh;
            background-color: #0a0a0a;
            border-radius: 24px;
            display: flex;
            overflow: hidden;
            box-shadow: 0 0 50px rgba(0,0,0,0.8);
            border: 1px solid #1f1f1f;
        }

        /* Left Panel - Video Placeholder */
        .auth-left {
            flex: 1;
            position: relative;
            border-right: 1px solid #1f1f1f;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #030303;
            overflow: hidden; /* Added to keep video within bounds */
        }

        .auth-brand {
            position: absolute;
            top: 30px;
            left: 40px;
            font-size: 20px;
            font-weight: 600;
            letter-spacing: -0.5px;
            z-index: 2; /* Brought above video */
        }

        .auth-copyright {
            position: absolute;
            bottom: 30px;
            left: 40px;
            font-size: 11px;
            color: #555;
            z-index: 2; /* Brought above video */
        }

        .auth-video-bg {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.5; /* Dimmed slightly for elegance */
            z-index: 1;
        }

        /* Right Panel - Form Area */
        .auth-right {
            flex: 1;
            padding: 50px 60px;
            position: relative;
            background: linear-gradient(135deg, #0a0a0a 0%, #111111 100%);
            display: flex;
            flex-direction: column;
            overflow: hidden;
            z-index: 2;
            pointer-events: auto;
        }

        .auth-top-nav {
            text-align: right;
            display: flex;
            justify-content: flex-end;
            z-index: 10;
        }
        
        .auth-top-nav a {
            color: #666;
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
            color: #d8dde3;
        }

        .auth-top-nav a:hover::after {
            width: 50px;
            background-color: #d8dde3;
        }

        .auth-form-wrapper {
            margin: auto 0;
            max-width: 520px;
            width: 100%;
            padding-bottom: 0;
            position: relative;
            z-index: 20;
            pointer-events: auto;
        }

        .auth-title {
            font-size: 48px;
            font-weight: 300;
            margin-bottom: 50px;
            letter-spacing: -1px;
        }

        .auth-form-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 26px;
            margin-bottom: 0;
        }

        .auth-field {
            display: flex;
            flex-direction: column;
            position: relative;
            z-index: 21;
            pointer-events: auto;
        }

        .auth-field label {
            font-size: 11px;
            color: #888;
            margin-bottom: 8px;
            font-weight: 500;
            text-transform: uppercase;
        }

        .auth-input {
            background: transparent;
            border: none;
            border-bottom: 1px solid #333;
            color: #fff;
            font-size: 16px;
            padding: 8px 0;
            outline: none;
            transition: border-color 0.3s;
            position: relative;
            z-index: 22;
            pointer-events: auto;
        }

        .auth-input:focus {
            border-bottom-color: #fff;
        }

        .auth-action-row {
            align-items: center;
            display: flex;
            gap: 18px;
            justify-content: space-between;
            margin-top: 38px;
            position: static;
        }

        .auth-forgot-link {
            color: #9ca3af;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.12em;
            text-decoration: none;
            text-transform: uppercase;
            transition: color 0.2s ease;
        }

        .auth-forgot-link:hover {
            color: #ffffff;
        }

        .auth-submit-btn {
            appearance: none;
            -webkit-appearance: none;
            opacity: 1 !important;
            visibility: visible !important;
            flex-shrink: 0;
            position: static;
            width: auto;
            min-width: 150px;
            height: 52px;
            border-radius: 999px;
            padding: 0 30px;
            background-color: #fff;
            color: #000;
            border: none;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.08em;
            transition: transform 0.2s ease, background-color 0.2s ease, box-shadow 0.2s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            z-index: 10;
        }

        .auth-submit-btn:hover {
            transform: translateY(-2px);
            background-color: #d8dde3;
            box-shadow: 0 16px 40px rgba(216, 221, 227, 0.18);
        }

        .auth-alert {
            color: #ff4444;
            font-size: 13px;
            margin-bottom: 20px;
            display: block;
        }

        @media (max-width: 720px) {
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
            
            <!-- Left Side: Video Background -->
            <div class="auth-left">
                <div class="auth-brand">ONYX&deg;</div>
                
                <!-- MP4 Video Background with ASP.NET path resolving -->
                <video autoplay loop muted playsinline class="auth-video-bg">
                    <source src="<%= ResolveUrl("~/Videos/ONYX_Cinematic_Logo.mp4") %>" type="video/mp4" />
                </video>

                <div class="auth-copyright">&copy; ONYX 2026. All rights reserved.</div>
            </div>

            <!-- Right Side: Login Form -->
            <div class="auth-right">
                <div class="auth-top-nav">
                    <a href="onyx_register.aspx"><span>Create an account</span></a>
                </div>

                <div class="auth-form-wrapper">
                    <h1 class="auth-title">Login</h1>
                    
                    <asp:Panel ID="MessagePanel" runat="server" Visible="false">
                        <asp:Literal ID="MessageLiteral" runat="server" />
                    </asp:Panel>

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

                    <div class="auth-action-row">
                        <a href="mailto:support@onyxgaming.com?subject=ONYX%20Password%20Reset" class="auth-forgot-link hover-trigger">Forgot password?</a>
                        <asp:Button ID="LoginButton" runat="server" CssClass="auth-submit-btn hover-trigger" Text="LOGIN" OnClick="LoginButton_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Animation Libraries -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>

    <script>
        document.addEventListener("DOMContentLoaded", () => {
            document.body.classList.add("auth-lock-scroll");

            // 1. GSAP Entrance Animations
            const tl = gsap.timeline();

            // Base container scaling in smoothly
            tl.from(".auth-container", { duration: 1.2, scale: 0.96, opacity: 0, ease: "power4.out" })
                // Fade in video background
                .from(".auth-video-bg", { duration: 2, opacity: 0, ease: "power2.out" }, "-=0.8")
                // Reveal left branding
                .from(".auth-brand, .auth-copyright", { duration: 0.8, x: -30, opacity: 0, stagger: 0.2, ease: "power3.out" }, "-=1.5")
                // Reveal right form headers
                .from(".auth-top-nav, .auth-title", { duration: 0.8, y: 20, opacity: 0, stagger: 0.1, ease: "power3.out" }, "-=1.2")
                // Staggered reveal of form fields
                .from(".auth-field", { duration: 0.6, y: 20, opacity: 0, stagger: 0.1, ease: "power3.out" }, "-=0.8");

            gsap.from(".auth-action-row", { duration: 0.6, y: 12, opacity: 0, delay: 0.4, ease: "power3.out" });
        });
    </script>
</asp:Content>
