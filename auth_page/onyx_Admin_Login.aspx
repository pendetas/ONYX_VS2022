<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="onyx_Admin_Login.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_Admin_Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Admin &mdash; ONYX</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <style>
        :root {
            --bg:    #0c0c0c;
            --white: #f0ede8;
            --silver:#c0c0c0;
            --font:  'Plus Jakarta Sans', -apple-system, 'Helvetica Neue', sans-serif;
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html, body { height: 100%; }

        body {
            background: var(--bg);
            font-family: var(--font);
            color: var(--white);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        .bg-glow {
            position: fixed; inset: 0; z-index: 0; pointer-events: none;
            background:
                radial-gradient(ellipse 70% 60% at 50% 50%,
                    rgba(220,220,220,0.055) 0%, transparent 65%),
                radial-gradient(ellipse 40% 40% at 50% 50%,
                    rgba(180,180,180,0.03) 0%, transparent 50%);
        }

        /* the single ONYX wordmark — clearly visible, nothing else */
        .bg-word {
            position: fixed;
            top: 50%; left: 50%;
            transform: translate(-50%, -50%);
            z-index: 1; pointer-events: none; user-select: none;
            font-family: var(--font);
            font-size: clamp(160px, 26vw, 340px);
            font-weight: 800;
            letter-spacing: 0.15em;
            white-space: nowrap;
            /* filled at low opacity — much more readable than stroke-only */
            color: rgba(255, 255, 255, 0.065);
            line-height: 1;
        }

        /* very fine film grain — texture only, not noise */
        .bg-grain {
            position: fixed; inset: 0; z-index: 2; pointer-events: none;
            background-image: url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='4' stitchTiles='stitch'/%3E%3CfeColorMatrix type='saturate' values='0'/%3E%3C/filter%3E%3Crect width='200' height='200' filter='url(%23n)' opacity='0.08'/%3E%3C/svg%3E");
            opacity: 0.22;
        }

        /* ══════════════════════════════════════
           LIQUID GLASS CARD
        ══════════════════════════════════════ */

        .admin-wrap {
            position: relative;
            z-index: 10;
            width: 100%;
            padding: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .glass-card {
            width: 100%;
            max-width: 430px;
            padding: 52px 48px 48px;
            border-radius: 30px;
            position: relative;
            overflow: hidden;

            /* ── the actual glass: nearly air-clear ── */
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(80px) saturate(220%) brightness(1.08);
            -webkit-backdrop-filter: blur(80px) saturate(220%) brightness(1.08);

            /* ── edges: this is what makes it look solid ── */
            border: 1px solid rgba(255, 255, 255, 0.16);

            /* ── depth stack ──
               1. inset top: bright rim  — light catching the glass edge
               2. inset bottom: dark rim — underside of the glass
               3. outer ring: subtle dark outline separating glass from bg
               4. main shadow: floats the card above the surface           */
            box-shadow:
                inset 0  1px 0   rgba(255, 255, 255, 0.28),
                inset 0 -1px 0   rgba(0,   0,   0,   0.20),
                inset 1px 0  0   rgba(255, 255, 255, 0.07),
                inset -1px 0 0   rgba(255, 255, 255, 0.04),
                0 0  0 1px       rgba(0,   0,   0,   0.45),
                0 40px 100px     rgba(0,   0,   0,   0.80),
                0 12px 32px      rgba(0,   0,   0,   0.40);
        }

        /* surface light — the sheen you see on physical glass */
        .glass-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 52%;
            border-radius: 30px 30px 0 0;
            background: linear-gradient(
                180deg,
                rgba(255, 255, 255, 0.07)  0%,
                rgba(255, 255, 255, 0.025) 35%,
                transparent                100%
            );
            pointer-events: none;
            z-index: 0;
        }

        /* bright top-rim specular — the clearest "this is glass" signal */
        .glass-card::after {
            content: '';
            position: absolute;
            top: 0; left: 12%; right: 12%;
            height: 1px;
            background: linear-gradient(
                90deg,
                transparent,
                rgba(255, 255, 255, 0.55) 25%,
                rgba(255, 255, 255, 0.55) 75%,
                transparent
            );
            z-index: 1;
            pointer-events: none;
        }

        .card-inner { position: relative; z-index: 2; }

        /* logo */
        .card-logo-wrap { text-align: center; margin-bottom: 10px; }

        .card-logo {
            height: 72px;
            width: auto;
            display: inline-block;
            filter: drop-shadow(0 2px 20px rgba(255,255,255,0.10));
        }

        /* admin badge */
        .card-badge {
            text-align: center;
            font-size: 9px;
            font-weight: 600;
            letter-spacing: 5px;
            color: rgba(255,255,255,0.20);
            text-transform: uppercase;
            margin-bottom: 44px;
        }

        /* error */
        .admin-error {
            display: block;
            font-size: 11px;
            font-weight: 500;
            color: #ff6060;
            line-height: 1.6;
            margin-bottom: 22px;
            padding: 11px 15px;
            background: rgba(255, 70, 70, 0.07);
            border: 1px solid rgba(255, 70, 70, 0.18);
            border-radius: 12px;
        }

        /* fields */
        .field { position: relative; margin-bottom: 22px; }

        .field-lbl {
            display: block;
            font-size: 10px;
            font-weight: 600;
            letter-spacing: 2.5px;
            text-transform: uppercase;
            color: rgba(255,255,255,0.30);
            margin-bottom: 10px;
        }

        .field-input {
            width: 100%;
            /* glass input: slightly more visible than card */
            background: rgba(255, 255, 255, 0.055);
            border: 1px solid rgba(255, 255, 255, 0.10);
            border-radius: 14px;
            color: var(--white);
            font-family: var(--font);
            font-size: 15px;
            font-weight: 400;
            padding: 14px 18px;
            outline: none;
            -webkit-appearance: none;
            transition: border-color 0.25s, background 0.25s, box-shadow 0.25s;
        }

        .field-input::placeholder { color: rgba(255,255,255,0.18); }

        .field-input:focus {
            background: rgba(255, 255, 255, 0.09);
            border-color: rgba(255, 255, 255, 0.24);
            box-shadow:
                0 0 0 3px rgba(255, 255, 255, 0.05),
                inset 0 1px 0 rgba(255, 255, 255, 0.09);
        }

        /* submit */
        .submit-wrap { margin-top: 34px; }

        .submit-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            width: 100%;
            padding: 16px 28px;
            background: rgba(242, 240, 232, 0.92);
            color: #0a0a0a;
            border: none;
            border-radius: 16px;
            cursor: pointer;
            font-family: var(--font);
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 3px;
            text-transform: uppercase;
            text-decoration: none;
            position: relative;
            overflow: hidden;
            transition: transform 0.15s, box-shadow 0.25s;
            box-shadow:
                inset 0 1px 0 rgba(255,255,255,0.85),
                0 8px 30px rgba(0,0,0,0.35);
        }

        .submit-btn::before {
            content: '';
            position: absolute; inset: 0;
            background: var(--silver);
            opacity: 0;
            transition: opacity 0.28s;
            border-radius: 16px;
        }

        .submit-btn:hover::before { opacity: 1; }
        .submit-btn:hover { transform: translateY(-1px); box-shadow: 0 14px 40px rgba(0,0,0,0.45); }
        .submit-btn:active { transform: translateY(0px); }

        .btn-text, .btn-arrow { position: relative; z-index: 1; }
        .btn-arrow { fill: #0a0a0a; transition: transform 0.24s ease; }
        .submit-btn:hover .btn-arrow { transform: translateX(5px); }

        /* footer */
        .card-footer {
            text-align: center;
            margin-top: 26px;
            font-size: 10px;
            font-weight: 500;
            color: rgba(255,255,255,0.13);
            letter-spacing: 1.5px;
            text-transform: uppercase;
        }

    </style>
</head>
<body>

    <!-- background: glow + single wordmark + grain. nothing else. -->
    <div class="bg-glow"></div>
    <span class="bg-word">ONYX</span>
    <div class="bg-grain"></div>

    <form id="form1" runat="server">
        <div class="admin-wrap">
            <div class="glass-card" id="glassCard">
                <div class="card-inner">

                    <div class="card-logo-wrap">
                        <img class="card-logo"
                             src='<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("site-photos/admin-auth/onyx-black.png") %>'
                             alt="ONYX" />
                    </div>

                    <p class="card-badge">Admin Portal</p>

                    <asp:Label ID="lblError" runat="server" CssClass="admin-error" Visible="false" />

                    <div class="field">
                        <label class="field-lbl" for="<%= txtUser.ClientID %>">Username</label>
                        <asp:TextBox ID="txtUser" runat="server" CssClass="field-input" placeholder="Enter username" />
                    </div>

                    <div class="field">
                        <label class="field-lbl" for="<%= txtPass.ClientID %>">Password</label>
                        <asp:TextBox ID="txtPass" runat="server" TextMode="Password" CssClass="field-input" placeholder="Enter password" />
                    </div>

                    <div class="submit-wrap">
                        <asp:LinkButton ID="btnLogin" runat="server" CssClass="submit-btn" OnClick="btnLogin_Click">
                            <span class="btn-text">Sign In</span>
                            <svg class="btn-arrow" viewBox="0 0 46 16" height="11" width="34" xmlns="http://www.w3.org/2000/svg">
                                <path transform="translate(30)" d="M8,0,6.545,1.455l5.506,5.506H-30V9.039H12.052L6.545,14.545,8,16l8-8Z"></path>
                            </svg>
                        </asp:LinkButton>
                    </div>

                    <p class="card-footer">Admin access is invitation-only</p>

                </div>
            </div>
        </div>
    </form>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            gsap.set('#glassCard', { opacity: 0, y: 20, scale: 0.98 });
            gsap.set('.bg-word',   { opacity: 0 });

            var tl = gsap.timeline({ defaults: { ease: 'expo.out' } });

            tl.to('.bg-word',    { opacity: 1, duration: 2.2, ease: 'power2.out' }, 0)
              .to('#glassCard',  { opacity: 1, y: 0, scale: 1, duration: 1.1 }, 0.2)
              .from('.card-logo-wrap', { y: -8, opacity: 0, duration: 0.8 }, 0.5)
              .from('.card-badge',     { opacity: 0, duration: 0.7 }, 0.62)
              .from('.field',          { y: 12, opacity: 0, stagger: 0.1, duration: 0.7 }, 0.68)
              .from('.submit-wrap',    { y: 10, opacity: 0, duration: 0.7, clearProps: 'all' }, 0.84)
              .from('.card-footer',    { opacity: 0, duration: 0.5 }, 0.96);
        });
    </script>
</body>
</html>
