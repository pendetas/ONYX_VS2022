<%@ Page Title="Login" Language="C#" MasterPageFile="~/customer_page/onyx_layout.Master" AutoEventWireup="true" CodeBehind="onyx_login.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_login" %>

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
            background-color: #050505;
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Inter', 'Helvetica Neue', Helvetica, Arial, sans-serif;
            color: #ffffff;
            overflow: hidden;
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

        /* Left Panel - Video BG */
        .auth-left {
            flex: 1;
            position: relative;
            border-right: 1px solid #1f1f1f;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #030303;
            overflow: hidden; 
        }

        .auth-brand {
            position: absolute;
            top: 30px;
            left: 40px;
            font-size: 20px;
            font-weight: 600;
            letter-spacing: -0.5px;
            z-index: 2;
        }

        .auth-copyright {
            position: absolute;
            bottom: 30px;
            left: 40px;
            font-size: 11px;
            color: #555;
            z-index: 2;
        }

        .auth-video-bg {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.5;
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
            color: #c0c0c0;
        }

        .auth-top-nav a:hover::after {
            width: 50px;
            background-color: #c0c0c0;
        }

        /* Fixed missing button by preventing squishing */
        .auth-form-wrapper {
            margin: auto 0; /* Centers it vertically */
            max-width: 480px;
            width: 100%;
            flex-shrink: 0; /* Forces scrolling if screen is too small */
            padding-top: 40px;
            padding-bottom: 40px;
            display: flex;
            flex-direction: column;
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
            gap: 40px;
        }

        .auth-field {
            display: flex;
            flex-direction: column;
        }

        .auth-field label {
            font-size: 11px;
            color: #888;
            margin-bottom: 8px;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .auth-input {
            background: transparent;
            border: none;
            border-bottom: 1px solid #333;
            color: #fff;
            font-size: 16px;
            padding: 8px 0;
            outline: none;
            transition: border-color 0.3s, box-shadow 0.3s;
        }

        .auth-input:focus {
            border-bottom-color: #fff;
            box-shadow: 0 1px 0 #fff;
        }

        /* UIverse Button "empty-moose-12" */
        .cta {
            border: none;
            background: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            text-decoration: none;
            margin-top: 50px;
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

                    <div class="auth-form-grid">
                        <div class="auth-field">
                            <label>Email / Username</label>
                            <asp:TextBox ID="EmailTextBox" runat="server" CssClass="auth-input" placeholder="Enter email or username" />
                        </div>

                        <div class="auth-field">
                            <label>Password</label>
                            <asp:TextBox ID="PasswordTextBox" runat="server" CssClass="auth-input" TextMode="Password" placeholder="Enter password" />
                        </div>
                    </div>

                    <!-- Uiverse "empty-moose-12" LinkButton -->
                    <asp:LinkButton ID="LoginButton" runat="server" CssClass="cta" OnClick="LoginButton_Click">
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

    <script>
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
                .from(".auth-field", { duration: 0.6, y: 20, opacity: 0, stagger: 0.1, ease: "power3.out" }, "-=0.8")
                // Uiverse button elegantly slides in. clearProps ensures hover CSS works smoothly afterwards!
                .from(".cta", { duration: 1.2, y: 30, opacity: 0, ease: "expo.out", clearProps: "all" }, "-=0.4");
        });
    </script>
</asp:Content>
