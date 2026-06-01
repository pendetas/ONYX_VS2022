<%@ Page Title="Register - ONYX" Language="C#" MasterPageFile="~/customer_page/onyx_layout.Master" AutoEventWireup="true" CodeBehind="onyx_register.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_register" %>

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
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Inter', 'Helvetica Neue', Helvetica, Arial, sans-serif;
            color: #ffffff;
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
            flex: 1.2;
            padding: 50px 60px;
            position: relative;
            background: linear-gradient(135deg, #0a0a0a 0%, #111111 100%);
            display: flex;
            flex-direction: column;
            overflow-y: auto; /* Allow scrolling */
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
            color: #00ff87;
        }

        .auth-top-nav a:hover::after {
            width: 50px;
            background-color: #00ff87;
        }

        .auth-form-wrapper {
            max-width: 600px;
            margin-top: 20px;
            /* Crucial: Provides space at the bottom for the absolute submit button and fixes Lenis boundary */
            padding-bottom: 150px; 
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

        /* Circular Submit Button with Absolute Positioning */
        .auth-submit-btn {
            position: absolute;
            bottom: 50px;
            right: 60px;
            width: 90px;
            height: 90px;
            border-radius: 50%;
            background-color: #fff;
            color: #000;
            border: none;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.5px;
            cursor: pointer;
            transition: transform 0.2s, background-color 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 10;
        }

        .auth-submit-btn:hover {
            transform: scale(1.05);
            background-color: #00ff87;
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
                
                <!-- MP4 Video Background with updated ASP.NET path resolving -->
                <video autoplay loop muted playsinline class="auth-video-bg">
                    <source src="<%= ResolveUrl("~/Videos/ONYX_Cinematic_Logo.mp4") %>" type="video/mp4" />
                </video>

                <div class="auth-copyright">&copy; ONYX 2024. All rights reserved.</div>
            </div>

            <!-- Right Side: Registration Form -->
            <div class="auth-right">
                <div class="auth-top-nav">
                    <a href="onyx_login.aspx"><span>Already have an account? Sign In</span></a>
                </div>

                <div class="auth-form-wrapper">
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
                </div>

                <asp:Button ID="btnRegister" runat="server" Text="SIGN UP" CssClass="auth-submit-btn" OnClick="btnRegister_Click" />
            </div>
        </div>
    </div>

    <!-- Animation Libraries -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/studio-freight/lenis@1.0.19/bundled/lenis.min.js"></script>

    <script>
        document.addEventListener("DOMContentLoaded", () => {
            // 1. Initialize Lenis for buttery smooth scrolling in the right panel
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

            // 2. GSAP Entrance Animations
            const tl = gsap.timeline();

            tl.from(".auth-container", { duration: 1.2, scale: 0.96, opacity: 0, ease: "power4.out" })
                .from(".auth-video-bg", { duration: 2, opacity: 0, ease: "power2.out" }, "-=0.8")
                .from(".auth-brand, .auth-copyright", { duration: 0.8, x: -30, opacity: 0, stagger: 0.2, ease: "power3.out" }, "-=1.5")
                .from(".auth-top-nav, .auth-title", { duration: 0.8, y: 20, opacity: 0, stagger: 0.1, ease: "power3.out" }, "-=1.2")
                // Faster stagger for registration since it has more fields
                .from(".auth-field", { duration: 0.6, y: 20, opacity: 0, stagger: 0.06, ease: "power3.out" }, "-=0.8");

            gsap.from(".auth-submit-btn", { duration: 1, scale: 0, opacity: 0, delay: 1.1, ease: "back.out(1.7)" });

            // 3. Magnetic Hover Effect for circular button
            const btn = document.querySelector('.auth-submit-btn');
            if (btn) {
                btn.addEventListener('mousemove', (e) => {
                    const rect = btn.getBoundingClientRect();
                    const x = e.clientX - rect.left - rect.width / 2;
                    const y = e.clientY - rect.top - rect.height / 2;
                    gsap.to(btn, { x: x * 0.35, y: y * 0.35, duration: 0.3, ease: 'power2.out' });
                });

                btn.addEventListener('mouseleave', () => {
                    gsap.to(btn, { x: 0, y: 0, duration: 0.7, ease: 'elastic.out(1, 0.3)' });
                });
            }
        });
    </script>
</asp:Content>