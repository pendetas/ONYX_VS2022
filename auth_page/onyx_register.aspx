<%@ Page Title="Register - ONYX" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_register.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_register" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
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
            color: #ffffff;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            font-size: 28px;
            font-weight: 400;
            letter-spacing: -0.08em;
            line-height: 1;
            text-decoration: none;
            text-transform: lowercase;
            z-index: 2; /* Brought above video */
        }

        .auth-brand:hover {
            color: #d8dde3;
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
            flex: 1.2;
            padding: 50px 60px;
            position: relative;
            background: linear-gradient(135deg, #0a0a0a 0%, #111111 100%);
            display: flex;
            flex-direction: column;
            overflow-y: auto; /* Allow scrolling */
            overscroll-behavior: contain;
            -ms-overflow-style: none;  /* IE and Edge */
            scrollbar-width: none;  /* Firefox */
        }

        /* Hide scrollbar completely to maintain elegant look */
        .auth-right::-webkit-scrollbar {
            display: none;
        }

        /* Premium Top Nav Navigation Link */
        .auth-top-nav {
            text-align: right;
            margin-bottom: 20px;
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
            max-width: 600px;
            width: 100%;
            min-height: auto;
            margin-top: 20px;
            padding-bottom: 28px;
        }

        .auth-register-panel {
            display: flex;
            flex-direction: column;
        }

        .auth-title {
            font-size: 48px;
            font-weight: 300;
            margin-bottom: 40px;
            letter-spacing: -1px;
        }

        /* Form Grid styling */
        .auth-form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px 30px;
        }

        .auth-field {
            display: flex;
            flex-direction: column;
        }

        .auth-field.full-width {
            grid-column: 1 / -1;
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
            font-size: 15px;
            padding: 8px 0;
            outline: none;
            transition: border-color 0.3s;
        }

        .auth-input:focus {
            border-bottom-color: #fff;
        }

        .auth-action-row {
            position: static;
            align-self: flex-end;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            margin-top: 34px;
            padding: 0;
            background: transparent;
            z-index: 30;
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
            height: 48px;
            border-radius: 999px;
            padding: 0 26px;
            background-color: #fff;
            color: #000;
            border: none;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.08em;
            transition: transform 0.2s ease, background-color 0.2s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            z-index: 31;
        }

        .auth-submit-btn:hover {
            transform: scale(1.05);
            background-color: #d8dde3;
        }

        .auth-alert {
            color: #ff4444;
            font-size: 13px;
            margin-bottom: 20px;
            display: block;
        }

        @media (max-width: 720px) {
            .auth-form-grid {
                grid-template-columns: 1fr;
            }

            .auth-action-row {
                align-self: stretch;
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
                <a href="<%= ResolveUrl("~/customer_page/onyx_home.aspx") %>" class="auth-brand" aria-label="Back to ONYX home">onyx</a>
                
                <!-- MP4 Video Background with updated ASP.NET path resolving -->
                <video autoplay loop muted playsinline class="auth-video-bg">
                    <source src="<%= ResolveUrl("~/Videos/ONYX_Cinematic_Logo.mp4") %>" type="video/mp4" />
                </video>

                <div class="auth-copyright">&copy; ONYX 2026. All rights reserved.</div>
            </div>

            <!-- Right Side: Registration Form -->
            <div class="auth-right">
                <div class="auth-top-nav">
                    <a href="onyx_login.aspx"><span>Already have an account? Sign In</span></a>
                </div>

                <div class="auth-form-wrapper">
                    <asp:Panel ID="RegisterPanel" runat="server" CssClass="auth-register-panel" DefaultButton="btnRegister">
                        <h1 class="auth-title">Register</h1>
                        
                        <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

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
                            </div>

                            <div class="auth-field">
                                <label>Confirm Password</label>
                                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="auth-input" required="true" placeholder="Confirm password" />
                            </div>

                            <div class="auth-field">
                                <label>Date of Birth</label>
                                <asp:TextBox ID="txtDob" runat="server" TextMode="Date" CssClass="auth-input" required="true" />
                            </div>

                            <div class="auth-field full-width">
                                <label>Shipping Address</label>
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="auth-input" placeholder="Your default delivery address" />
                            </div>
                        </div>

                        <div class="auth-action-row">
                            <asp:Button ID="btnRegister" runat="server" Text="SIGN UP" CssClass="auth-submit-btn" OnClick="btnRegister_Click" />
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <!-- Animation Libraries -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>

    <script>
        document.addEventListener("DOMContentLoaded", () => {
            document.body.classList.add("auth-lock-scroll");

            // 2. GSAP Entrance Animations
            const tl = gsap.timeline();

            tl.from(".auth-container", { duration: 1.2, scale: 0.96, opacity: 0, ease: "power4.out" })
                .from(".auth-video-bg", { duration: 2, opacity: 0, ease: "power2.out" }, "-=0.8")
                .from(".auth-brand, .auth-copyright", { duration: 0.8, x: -30, opacity: 0, stagger: 0.2, ease: "power3.out" }, "-=1.5")
                .from(".auth-top-nav, .auth-title", { duration: 0.8, y: 20, opacity: 0, stagger: 0.1, ease: "power3.out" }, "-=1.2")
                // Faster stagger for registration since it has more fields
                .from(".auth-field", { duration: 0.6, y: 20, opacity: 0, stagger: 0.06, ease: "power3.out" }, "-=0.8");

            // Keep the submit button in normal layout so registration is always reachable.
        });
    </script>
</asp:Content>
