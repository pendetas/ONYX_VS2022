<%@ Page Title="Register - ONYX" Language="C#" MasterPageFile="~/customer_page/onyx_layout.Master" AutoEventWireup="true" CodeBehind="onyx_register.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_register" %>

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
            top: 30px; left: 40px;
            font-size: 20px;
            font-weight: 600;
            letter-spacing: -0.5px;
            z-index: 2;
        }

        .auth-copyright {
            position: absolute;
            bottom: 30px; left: 40px;
            font-size: 11px;
            color: #555;
            z-index: 2;
        }

        .auth-video-bg {
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 100%;
            object-fit: cover;
            opacity: 0.5;
            z-index: 1;
        }

        .auth-right {
            flex: 1.2;
            padding: 50px 60px;
            position: relative;
            background: linear-gradient(135deg, #0a0a0a 0%, #111111 100%);
            display: flex;
            flex-direction: column;
            overflow-y: auto !important;
        }

        .auth-top-nav {
            text-align: right;
            margin-bottom: 20px;
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

        .auth-top-nav a:hover { color: #c0c0c0; }
        .auth-top-nav a:hover::after { width: 50px; background-color: #c0c0c0; }

        .auth-form-wrapper {
            max-width: 600px;
            margin-top: 20px;
            width: 100%;
            padding-bottom: 120px;
            flex-shrink: 0;
            display: flex;
            flex-direction: column;
        }

        .auth-title {
            font-size: 48px;
            font-weight: 300;
            margin-bottom: 40px;
            letter-spacing: -1px;
        }

        .auth-form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px 30px;
            overflow: visible;
        }

        .auth-field {
            display: flex;
            flex-direction: column;
        }

        .auth-field.full-width { grid-column: 1 / -1; }

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
            font-size: 15px;
            padding: 8px 0;
            outline: none;
            transition: border-color 0.3s, box-shadow 0.3s;
        }

        .auth-input:focus {
            border-bottom-color: #fff;
            box-shadow: 0 1px 0 #fff;
        }

        .cta {
            border: none;
            background: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            text-decoration: none;
            margin-top: 60px;
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

        /* ============================
           SEGMENTED DATE INPUT
        ============================ */
        .date-seg-wrapper {
            display: flex;
            align-items: center;
            border-bottom: 1px solid #333;
            padding: 8px 0;
            gap: 0;
            transition: border-color 0.3s, box-shadow 0.3s;
        }

        .date-seg-wrapper:focus-within {
            border-bottom-color: #fff;
            box-shadow: 0 1px 0 #fff;
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
    </style>

    <div class="auth-takeover">
        <div class="auth-container">

            <div class="auth-left">
                <div class="auth-brand">ONYX&deg;</div>
                <video autoplay loop muted playsinline class="auth-video-bg">
                    <source src="<%= ResolveUrl("~/Videos/ONYX_Cinematic_Logo.mp4") %>" type="video/mp4" />
                </video>
                <div class="auth-copyright">&copy; ONYX 2024. All rights reserved.</div>
            </div>

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

                        <div class="auth-field full-width">
                            <label>Shipping Address</label>
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="auth-input" placeholder="Your default delivery address" />
                        </div>

                    </div>

                    <asp:LinkButton ID="btnRegister" runat="server" CssClass="cta" OnClick="btnRegister_Click">
                        <span class="hover-underline-animation">REGISTER NOW</span>
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

            // Lenis smooth scroll
            const scrollContainer = document.querySelector('.auth-right');
            const scrollContent   = document.querySelector('.auth-form-wrapper');
            if (scrollContainer && scrollContent) {
                const lenis = new Lenis({ wrapper: scrollContainer, content: scrollContent, lerp: 0.08, smoothWheel: true });
                function raf(time) { lenis.raf(time); requestAnimationFrame(raf); }
                requestAnimationFrame(raf);
            }

            // GSAP entrance
            const tl = gsap.timeline();
            tl.from(".auth-container", { duration: 1.2, scale: 0.96, opacity: 0, ease: "power4.out" })
              .from(".auth-video-bg",   { duration: 2, opacity: 0, ease: "power2.out" }, "-=0.8")
              .from(".auth-brand, .auth-copyright", { duration: 0.8, x: -30, opacity: 0, stagger: 0.2, ease: "power3.out" }, "-=1.5")
              .from(".auth-top-nav, .auth-title",   { duration: 0.8, y: 20,  opacity: 0, stagger: 0.1, ease: "power3.out" }, "-=1.2")
              .from(".auth-field", { duration: 0.6, y: 20, opacity: 0, stagger: 0.06, ease: "power3.out" }, "-=0.8")
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
