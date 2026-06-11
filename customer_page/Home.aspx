<%@ Page Title="Home" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="ONYX_DDAC.customer_page.Home" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Syne:wght@500;700;800&display=swap" rel="stylesheet" />

    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#050505',
                        accent: '#d8dde3',
                        secondary: '#9ca3af',
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                        syne: ['Syne', 'sans-serif'],
                    }
                }
            }
        };
    </script>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/ScrollTrigger.min.js"></script>

    <style>
        .onyx-shell > .onyx-nav,
        .onyx-shell > .onyx-footer {
            display: none;
        }

        .onyx-main {
            margin-top: 0;
        }

        .onyx-ddac-home {
            background-color: #050505;
            color: #ffffff;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            margin-top: -1px;
            overflow-x: hidden;
            position: relative;
            isolation: isolate;
        }

        .onyx-ddac-hero-section {
            background: #050505;
            isolation: isolate;
            overflow: hidden;
        }

        .onyx-ddac-hero-video {
            filter: grayscale(0.3) contrast(1.06) brightness(0.88);
            height: 100%;
            inset: 0;
            object-fit: cover;
            opacity: 0.92;
            pointer-events: none;
            position: absolute;
            width: 100%;
            z-index: 0;
        }

        .onyx-ddac-hero-scrim {
            background:
                radial-gradient(circle at 50% 45%, rgba(255, 255, 255, 0.06), transparent 34%),
                linear-gradient(90deg, rgba(5, 5, 5, 0.52), rgba(5, 5, 5, 0.14) 48%, rgba(5, 5, 5, 0.52)),
                linear-gradient(180deg, rgba(5, 5, 5, 0.28), rgba(5, 5, 5, 0.04) 44%, rgba(5, 5, 5, 0.76));
            inset: 0;
            pointer-events: none;
            position: absolute;
            z-index: 1;
        }

        .onyx-ddac-hero-title {
            color: #ffffff;
            font-family: Syne, sans-serif;
            font-size: clamp(64px, 11vw, 156px);
            font-weight: 800;
            letter-spacing: -0.06em;
            line-height: 0.86;
            margin: 0;
            pointer-events: none;
            position: relative;
            text-align: center;
            text-transform: uppercase;
            z-index: 2;
        }

        .onyx-home-context {
            background: #09090b;
            border-top: 1px solid #27272a;
            color: #ffffff;
            padding: clamp(72px, 9vw, 128px) 6vw;
            position: relative;
            z-index: 10;
        }

        .onyx-home-context-inner {
            display: grid;
            gap: clamp(32px, 6vw, 88px);
            grid-template-columns: minmax(0, 0.92fr) minmax(0, 1.08fr);
            margin: 0 auto;
            max-width: 1240px;
        }

        .onyx-home-kicker {
            align-items: center;
            color: #a1a1aa;
            display: inline-flex;
            font-family: "JetBrains Mono", ui-monospace, monospace;
            font-size: 12px;
            gap: 14px;
            letter-spacing: 1.2px;
            margin-bottom: 26px;
            text-transform: uppercase;
        }

        .onyx-home-kicker::before {
            background: #d8dde3;
            content: "";
            display: inline-block;
            height: 1px;
            width: 44px;
        }

        .onyx-home-context h2 {
            color: #ffffff;
            font-family: Inter, system-ui, sans-serif;
            font-size: clamp(42px, 6vw, 84px);
            font-weight: 400;
            letter-spacing: -2.6px;
            line-height: 0.96;
            margin: 0;
            max-width: 680px;
        }

        .onyx-home-context-copy {
            color: #a1a1aa;
            font-size: clamp(18px, 2vw, 24px);
            line-height: 1.55;
            margin: 0;
            max-width: 620px;
        }

        .onyx-home-context-copy strong {
            color: #ffffff;
            font-weight: 400;
        }

        .onyx-home-standard-grid {
            display: grid;
            gap: 12px;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            margin-top: 34px;
        }

        .onyx-home-standard-card {
            background: #121214;
            border: 1px solid #27272a;
            border-radius: 8px;
            min-height: 170px;
            padding: 24px;
        }

        .onyx-home-standard-card span {
            color: #71717a;
            display: block;
            font-family: "JetBrains Mono", ui-monospace, monospace;
            font-size: 11px;
            letter-spacing: 1.2px;
            margin-bottom: 28px;
            text-transform: uppercase;
        }

        .onyx-home-standard-card h3 {
            color: #ffffff;
            font-family: Inter, system-ui, sans-serif;
            font-size: 22px;
            font-weight: 400;
            letter-spacing: -0.8px;
            line-height: 1.12;
            margin: 0 0 12px;
        }

        .onyx-home-standard-card p {
            color: #a1a1aa;
            font-size: 14px;
            line-height: 1.6;
            margin: 0;
        }

        .onyx-home-trust-row {
            border-top: 1px solid #27272a;
            display: grid;
            gap: 18px;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            margin: clamp(42px, 6vw, 72px) auto 0;
            max-width: 1240px;
            padding-top: 26px;
        }

        .onyx-home-trust-row a {
            border: 1px solid transparent;
            border-radius: 8px;
            display: block;
            padding: 18px;
            text-decoration: none;
            transition: background 160ms ease, border-color 160ms ease, transform 160ms ease;
        }

        .onyx-home-trust-row a:hover {
            background: #121214;
            border-color: #27272a;
            transform: translateY(-2px);
        }

        .onyx-home-trust-row strong {
            color: #ffffff;
            display: block;
            font-family: Inter, system-ui, sans-serif;
            font-size: 28px;
            font-weight: 400;
            letter-spacing: -1px;
            line-height: 1;
            margin-bottom: 8px;
        }

        .onyx-home-trust-row span {
            color: #a1a1aa;
            font-family: "JetBrains Mono", ui-monospace, monospace;
            font-size: 11px;
            letter-spacing: 1.2px;
            text-transform: uppercase;
        }

        .onyx-ddac-nav-register {
            background: #ffffff;
            border-radius: 999px;
            color: #050505 !important;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.06em;
            padding: 9px 20px;
            text-transform: uppercase;
            transition: background 0.22s ease, color 0.22s ease, box-shadow 0.22s ease;
        }

        .onyx-ddac-nav-register:hover {
            background: #d8dde3;
            box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.18);
            color: #050505 !important;
        }

        /* ── Catalog mega-panel (Awwwards style) ───────────────────── */
        .onyx-ddac-dropdown {
            position: static;
        }

        .onyx-ddac-dropdown-trigger {
            align-items: center;
            color: rgba(255,255,255,0.82);
            cursor: pointer;
            display: inline-flex;
            gap: 6px;
            text-decoration: none;
            transition: color 0.2s ease;
            user-select: none;
        }

        /* Pure CSS chevron — no unicode, no encoding issues */
        .onyx-ddac-dropdown-trigger .onyx-chev {
            border-right: 1.5px solid currentColor;
            border-top: 1.5px solid currentColor;
            display: inline-block;
            height: 6px;
            opacity: 0.55;
            transform: rotate(135deg) translateY(-2px);
            transition: transform 0.35s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.2s ease;
            width: 6px;
        }

        .onyx-ddac-dropdown.is-open .onyx-ddac-dropdown-trigger,
        .onyx-ddac-dropdown:hover .onyx-ddac-dropdown-trigger {
            color: #ffffff;
        }

        .onyx-ddac-dropdown.is-open .onyx-chev,
        .onyx-ddac-dropdown:hover .onyx-chev {
            opacity: 1;
            transform: rotate(-45deg) translateY(-2px);
        }

        /* Full-width panel anchored to the nav bottom */
        .onyx-ddac-megapanel {
            background: rgba(7, 7, 9, 0.99);
            backdrop-filter: blur(24px) saturate(160%);
            -webkit-backdrop-filter: blur(24px) saturate(160%);
            border-bottom: 1px solid rgba(255, 255, 255, 0.07);
            clip-path: inset(0 0 100% 0);
            left: 0;
            pointer-events: none;
            position: fixed;
            right: 0;
            top: 0;
            padding-top: 130px;
            padding-bottom: 0;
            transition: clip-path 0.48s cubic-bezier(0.4, 0, 0.2, 1);
            z-index: 80;
        }

        .onyx-ddac-nav.is-scrolled ~ * .onyx-ddac-megapanel,
        .onyx-ddac-nav.is-scrolled + .onyx-ddac-megapanel {
            padding-top: 110px;
        }

        .onyx-ddac-dropdown:hover .onyx-ddac-megapanel {
            clip-path: inset(0 0 0% 0);
            pointer-events: auto;
        }

        .onyx-ddac-megapanel-inner {
            border-top: 1px solid rgba(255, 255, 255, 0.06);
            display: grid;
            grid-template-columns: 1fr auto;
            gap: 0;
            margin: 0 auto;
            max-width: 1400px;
            padding: 0 48px;
        }

        /* Left: category links */
        .onyx-ddac-mega-cats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            padding: 40px 0;
            gap: 0;
        }

        .onyx-ddac-mega-cat {
            border-right: 1px solid rgba(255, 255, 255, 0.06);
            padding: 0 32px 0 0;
            margin-right: 32px;
            text-decoration: none !important;
            display: flex;
            flex-direction: column;
            gap: 10px;
            opacity: 0;
            transform: translateY(16px);
            transition:
                opacity 0.35s cubic-bezier(0.4, 0, 0.2, 1),
                transform 0.35s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .onyx-ddac-mega-cat:last-child {
            border-right: none;
            margin-right: 0;
            padding-right: 0;
        }

        .onyx-ddac-dropdown:hover .onyx-ddac-mega-cat:nth-child(1) { opacity: 1; transform: translateY(0); transition-delay: 0.06s; }
        .onyx-ddac-dropdown:hover .onyx-ddac-mega-cat:nth-child(2) { opacity: 1; transform: translateY(0); transition-delay: 0.12s; }
        .onyx-ddac-dropdown:hover .onyx-ddac-mega-cat:nth-child(3) { opacity: 1; transform: translateY(0); transition-delay: 0.18s; }
        .onyx-ddac-dropdown:hover .onyx-ddac-mega-cat:nth-child(4) { opacity: 1; transform: translateY(0); transition-delay: 0.24s; }

        .onyx-ddac-mega-cat-num {
            color: rgba(255,255,255,0.25);
            font-size: 10px;
            font-weight: 600;
            letter-spacing: 0.18em;
            text-transform: uppercase;
        }

        .onyx-ddac-mega-cat-name {
            color: rgba(255,255,255,0.9);
            font-family: Syne, sans-serif;
            font-size: 28px;
            font-weight: 700;
            letter-spacing: -0.02em;
            line-height: 1;
            transition: color 0.2s ease;
        }

        .onyx-ddac-mega-cat:hover .onyx-ddac-mega-cat-name {
            color: #d8dde3;
        }

        .onyx-ddac-mega-cat-sub {
            color: rgba(255,255,255,0.32);
            font-size: 11px;
            letter-spacing: 0.04em;
        }

        /* Right: CTA */
        .onyx-ddac-mega-cta {
            align-items: flex-start;
            border-left: 1px solid rgba(255, 255, 255, 0.06);
            display: flex;
            flex-direction: column;
            gap: 16px;
            justify-content: center;
            opacity: 0;
            padding: 40px 0 40px 48px;
            transform: translateX(12px);
            transition: opacity 0.4s cubic-bezier(0.4, 0, 0.2, 1) 0.28s,
                        transform 0.4s cubic-bezier(0.4, 0, 0.2, 1) 0.28s;
        }

        .onyx-ddac-dropdown:hover .onyx-ddac-mega-cta {
            opacity: 1;
            transform: translateX(0);
        }

        .onyx-ddac-mega-cta-label {
            color: rgba(255,255,255,0.35);
            font-size: 10px;
            font-weight: 600;
            letter-spacing: 0.2em;
            text-transform: uppercase;
        }

        .onyx-ddac-mega-cta-link {
            align-items: center;
            background: #ffffff;
            border-radius: 999px;
            color: #050505 !important;
            display: inline-flex;
            font-size: 12px;
            font-weight: 800;
            gap: 8px;
            letter-spacing: 0.06em;
            padding: 12px 22px;
            text-decoration: none !important;
            text-transform: uppercase;
            transition: background 0.2s ease, transform 0.2s ease;
            white-space: nowrap;
        }

        .onyx-ddac-mega-cta-link:hover {
            background: #d8dde3;
            transform: scale(1.03);
        }
        .onyx-ddac-mega-cta-link svg {
            flex-shrink: 0;
        }

        /* ── Navbar rectangle → floating pill (scroll only) ─────────── */
        .onyx-ddac-nav {
            background: rgba(5, 5, 5, 0.2);
            backdrop-filter: blur(24px) saturate(180%);
            -webkit-backdrop-filter: blur(24px) saturate(180%);
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 0px;
            left: 0;
            padding: 16px 48px;
            position: fixed;
            right: 0;
            top: 0;
            transition:
                background 0.45s ease,
                border-color 0.45s ease,
                box-shadow 0.45s ease,
                backdrop-filter 0.45s ease,
                -webkit-backdrop-filter 0.45s ease;
            width: auto;
            z-index: 90;
        }

        .onyx-ddac-nav.is-scrolled {
            background: rgba(5, 5, 5, 0.65);
            backdrop-filter: blur(40px) saturate(200%);
            -webkit-backdrop-filter: blur(40px) saturate(200%);
            border-bottom-color: rgba(255, 255, 255, 0.12);
            box-shadow: 0 4px 24px rgba(0, 0, 0, 0.6);
            left: 0;
            right: 0;
            top: 0;
        }

        .onyx-ddac-marquee-container {
            overflow: hidden;
            white-space: nowrap;
            width: 100%;
        }

        .onyx-ddac-trusted-section,
        .onyx-ddac-footer {
            background-color: #050505;
        }

        .onyx-ddac-marquee-content {
            animation: onyx-ddac-marquee 30s linear infinite;
            display: inline-flex;
        }

        .onyx-ddac-logo-track {
            align-items: center;
            gap: clamp(3rem, 6vw, 6rem);
        }

        .onyx-ddac-team-logo {
            align-items: center;
            display: inline-flex;
            height: 78px;
            justify-content: center;
            min-width: 170px;
        }

        .onyx-ddac-team-logo img {
            display: block;
            filter: grayscale(1) brightness(0) invert(1);
            max-height: 54px;
            max-width: 150px;
            object-fit: contain;
            opacity: 0.68;
            transition: filter 220ms ease, opacity 220ms ease, transform 220ms ease;
        }

        .onyx-ddac-team-logo:hover img {
            filter: grayscale(1) brightness(1.18) invert(1);
            opacity: 1;
            transform: translateY(-2px);
        }

        @keyframes onyx-ddac-marquee {
            0% {
                transform: translateX(0);
            }

            100% {
                transform: translateX(-50%);
            }
        }

        .onyx-ddac-text-outline {
            -webkit-text-stroke: 1px rgba(255, 255, 255, 0.24);
            color: transparent;
            transition: color 0.3s ease;
        }

        .onyx-ddac-text-outline:hover {
            color: #ffffff;
        }

        .onyx-ddac-home::-webkit-scrollbar {
            display: none;
        }

        .onyx-ddac-product-grid {
            display: grid;
            gap: 18px;
            grid-template-columns: repeat(4, minmax(0, 1fr));
        }

        .onyx-ddac-product-card {
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 18px;
            overflow: hidden;
            transition: border-color 220ms ease, transform 220ms ease, background 220ms ease;
        }

        .onyx-ddac-product-card:hover {
            background: rgba(255, 255, 255, 0.065);
            border-color: rgba(216, 221, 227, 0.46);
            transform: translateY(-5px);
        }

        .onyx-ddac-product-media {
            align-items: center;
            aspect-ratio: 1.55 / 1;
            background: #050505;
            display: flex;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        .onyx-ddac-product-media::after {
            background: linear-gradient(180deg, transparent 62%, rgba(5, 5, 5, 0.82) 100%);
            box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.04);
            content: "";
            inset: 0;
            pointer-events: none;
            position: absolute;
            z-index: 2;
        }

        .onyx-ddac-product-image {
            display: block;
            filter: saturate(0.96) contrast(1.04);
            height: 100%;
            object-fit: cover;
            object-position: center center;
            position: relative;
            transition: transform 260ms ease, filter 260ms ease;
            width: 100%;
            z-index: 1;
        }

        .onyx-ddac-product-card:hover .onyx-ddac-product-image {
            filter: saturate(1) contrast(1.08) brightness(1.05);
            transform: scale(1.045);
        }

        .onyx-ddac-product-body {
            padding: 22px;
        }

        .onyx-ddac-product-body p {
            color: #9ca3af;
            font-size: 11px;
            margin: 0 0 10px;
        }

        .onyx-ddac-product-body h3 {
            color: #ffffff;
            font-family: Syne, sans-serif;
            font-size: 18px;
            font-weight: 700;
            line-height: 1.18;
            margin: 0;
            min-height: 44px;
        }

        .onyx-ddac-product-meta {
            align-items: center;
            display: flex;
            gap: 12px;
            justify-content: space-between;
            margin-top: 18px;
        }

        .onyx-ddac-product-meta strong {
            color: #d8dde3;
            font-size: 13px;
            white-space: nowrap;
        }

        .onyx-ddac-product-meta a {
            background: #d8dde3;
            border-radius: 999px;
            color: #050505;
            font-size: 12px;
            font-weight: 800;
            padding: 8px 12px;
            text-decoration: none;
        }

        @media (max-width: 1024px) {
            .onyx-home-context-inner,
            .onyx-home-trust-row {
                grid-template-columns: 1fr;
            }

            .onyx-ddac-product-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 640px) {
            .onyx-ddac-home,
            .onyx-ddac-home a,
            .onyx-ddac-home button,
            .onyx-ddac-home input,
            .onyx-ddac-home label {
                cursor: auto;
            }

            .onyx-ddac-nav {
                padding: 14px 20px;
            }

            .onyx-ddac-product-grid {
                grid-template-columns: 1fr;
            }

            .onyx-home-standard-grid {
                grid-template-columns: 1fr;
            }

            .onyx-ddac-team-logo {
                min-width: 132px;
            }

            .onyx-ddac-team-logo img {
                max-height: 44px;
                max-width: 120px;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .onyx-ddac-marquee-content {
                animation: none;
            }

        }

        .onyx-ddac-home.is-ready .onyx-ddac-hero-section .reveal-item {
            opacity: 1;
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="onyx-ddac-home antialiased font-sans selection:bg-accent selection:text-black">
        <main id="top">
            <section class="onyx-ddac-hero-section relative w-full h-screen flex flex-col justify-center items-center px-6 pt-20" aria-label="ONYX hero video">
                <video class="onyx-ddac-hero-video" autoplay muted loop playsinline preload="auto" aria-hidden="true">
                    <source src="https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260319_055001_8e16d972-3b2b-441c-86ad-2901a54682f9.mp4" type="video/mp4" />
                </video>
                <div class="onyx-ddac-hero-scrim" aria-hidden="true"></div>
                <h1 class="onyx-ddac-hero-title reveal-item opacity-0">Dominate<br />the game.</h1>
            </section>

            <section class="onyx-home-context" aria-label="Why ONYX">
                <div class="onyx-home-context-inner">
                    <div class="reveal-item">
                        <span class="onyx-home-kicker">Why ONYX</span>
                        <h2>Built for players who notice every millisecond.</h2>
                    </div>
                    <div class="reveal-item">
                        <p class="onyx-home-context-copy">
                            <strong>ONYX designs black-and-silver gaming peripherals</strong> for competitive players who need precise aim, fast inputs, clean audio, and hardware that holds up under pressure.
                        </p>
                        <div class="onyx-home-standard-grid" aria-label="ONYX product standards">
                            <article class="onyx-home-standard-card">
                                <span>01 / Precision</span>
                                <h3>Controlled movement</h3>
                                <p>Sensors and surfaces are selected for stable tracking, low latency, and confident aim adjustments.</p>
                            </article>
                            <article class="onyx-home-standard-card">
                                <span>02 / Response</span>
                                <h3>Faster inputs</h3>
                                <p>Switches, keyboards, and click systems focus on crisp actuation when timing decides the round.</p>
                            </article>
                            <article class="onyx-home-standard-card">
                                <span>03 / Endurance</span>
                                <h3>Daily-use durability</h3>
                                <p>Reinforced materials, clean finishes, and warranty support keep your setup reliable after long sessions.</p>
                            </article>
                            <article class="onyx-home-standard-card">
                                <span>04 / Setup</span>
                                <h3>One connected store</h3>
                                <p>Browse gear, save wishlist picks, manage orders, and post reviews from the same ONYX account flow.</p>
                            </article>
                        </div>
                    </div>
                </div>
                <div class="onyx-home-trust-row reveal-item">
                    <a class="hover-trigger" href="/customer_page/onyx_catalog.aspx?category=Mouse">
                        <strong>Aim control</strong>
                        <span>Shop gaming mice for tracking, grip, and click timing</span>
                    </a>
                    <a class="hover-trigger" href="/customer_page/onyx_catalog.aspx?category=Keyboard">
                        <strong>Fast inputs</strong>
                        <span>Compare keyboards for response, switch feel, and layout</span>
                    </a>
                    <a class="hover-trigger" href="/customer_page/onyx_catalog.aspx">
                        <strong>Build setup</strong>
                        <span>Browse the full catalog and save gear to your wishlist</span>
                    </a>
                </div>
            </section>

            <section class="w-full py-32 px-6 md:px-12 bg-[#050505] relative z-10 border-t border-white/10">
                <div class="max-w-7xl mx-auto">
                    <div class="flex items-center gap-4 mb-24 reveal-item">
                        <div class="w-12 h-12 rounded-full border border-accent flex items-center justify-center text-accent font-syne text-sm">01</div>
                        <h4 class="text-accent uppercase tracking-widest text-sm font-bold">Hardware</h4>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-20 items-center mb-40">
                        <div class="reveal-item">
                            <h2 class="text-5xl md:text-7xl font-syne font-bold tracking-tighter mb-8 leading-tight">
                                Hardware that<br />keeps pressure<br /><span class="onyx-ddac-text-outline">controlled</span>
                            </h2>
                        </div>
                        <div class="reveal-item md:pl-20">
                            <p class="text-secondary text-lg md:text-xl leading-relaxed">
                                From mice to audio, ONYX gear is built around the moments where one missed click, one late keypress, or one unclear sound cue changes the match.
                            </p>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-32">
                        <div class="flex flex-col gap-8 reveal-item">
                            <div class="w-16 h-16 rounded-full bg-white/10 flex items-center justify-center text-accent font-syne text-xl border border-accent/30">01</div>
                            <h3 class="text-3xl font-syne font-bold">Tournament-Grade Precision</h3>
                            <p class="text-secondary leading-relaxed">
                                Flagship optical sensors track flawless movement with zero smoothing, filtering, or acceleration. Translate every micro-adjustment directly into the game.
                            </p>
                        </div>
                        <div class="flex flex-col gap-8 reveal-item lg:mt-32">
                            <div class="w-16 h-16 rounded-full bg-white/10 flex items-center justify-center text-accent font-syne text-xl border border-accent/30">02</div>
                            <h3 class="text-3xl font-syne font-bold">Tactile Optical Switches</h3>
                            <p class="text-secondary leading-relaxed">
                                Actuation at the speed of light. Custom optical switches reduce debounce delay for rapid-fire inputs and durable daily play.
                            </p>
                        </div>
                    </div>
                </div>
            </section>

            <section class="onyx-ddac-trusted-section w-full py-20 border-y border-white/5 relative z-10 overflow-hidden">
                <div class="text-center mb-10 reveal-item">
                    <span class="border border-accent text-accent px-4 py-1 rounded-full text-xs font-bold uppercase tracking-widest">Competitive setup references</span>
                </div>
                <div class="onyx-ddac-marquee-container opacity-60 hover:opacity-100 transition-opacity duration-500">
                    <div class="onyx-ddac-marquee-content onyx-ddac-logo-track">
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/faze-clan.svg" alt="FaZe Clan logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/cloud9.svg" alt="Cloud9 logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/team-liquid.svg" alt="Team Liquid logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/fnatic.svg" alt="Fnatic logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/100-thieves.svg" alt="100 Thieves logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/g2-esports.svg" alt="G2 Esports logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/sentinels.svg" alt="Sentinels logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/navi.svg" alt="NAVI logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/faze-clan.svg" alt="FaZe Clan logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/cloud9.svg" alt="Cloud9 logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/team-liquid.svg" alt="Team Liquid logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/fnatic.svg" alt="Fnatic logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/100-thieves.svg" alt="100 Thieves logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/g2-esports.svg" alt="G2 Esports logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/sentinels.svg" alt="Sentinels logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="/Content/home/team-logos/navi.svg" alt="NAVI logo" loading="lazy" /></span>
                    </div>
                </div>
            </section>

            <section id="featured-products" class="w-full py-32 px-6 md:px-12 bg-[#0b0b0c] relative z-10 border-t border-white/10">
                <div class="max-w-7xl mx-auto">
                    <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-8 mb-14 reveal-item">
                        <div>
                            <p class="text-accent uppercase tracking-widest text-sm font-bold mb-4">Featured Gear</p>
                            <h2 class="text-5xl md:text-7xl font-syne font-bold tracking-tighter leading-tight">Shop the silver standard.</h2>
                        </div>
                        <a href="../customer_page/onyx_catalog.aspx" class="hover-trigger border border-white/30 px-8 py-4 rounded-full font-bold text-sm tracking-wide uppercase hover:border-white transition-colors no-underline text-white">View All</a>
                    </div>

                    <div class="onyx-ddac-product-grid">
                        <asp:Repeater ID="FeaturedProductsRepeater" runat="server">
                            <ItemTemplate>
                                <article class="onyx-ddac-product-card reveal-item">
                                    <div class="onyx-ddac-product-media">
                                        <img src='<%# GetFeaturedProductImageUrl(Eval("Category"), Container.ItemIndex) %>' alt='<%# GetFeaturedProductAlt(Eval("Category"), Container.ItemIndex) %>' class="onyx-ddac-product-image" loading="lazy" />
                                    </div>
                                    <div class="onyx-ddac-product-body">
                                        <p><%# GetFeaturedProductBrandLine(Eval("Category"), Container.ItemIndex) %></p>
                                        <h3><%# GetFeaturedProductName(Eval("Category"), Container.ItemIndex) %></h3>
                                        <div class="onyx-ddac-product-meta">
                                            <strong><%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("Price")) %></strong>
                                            <a href="../customer_page/onyx_catalog.aspx" class="hover-trigger">View</a>
                                        </div>
                                    </div>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </section>

            <footer class="onyx-ddac-footer w-full py-32 px-6 md:px-12 relative z-10">
                <div class="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-20">
                    <div class="reveal-item">
                        <h2 class="text-4xl md:text-6xl font-syne font-bold tracking-tighter mb-6 leading-tight">
                            Get early access to exclusive hardware drops.
                        </h2>
                        <div class="mt-12 flex flex-col sm:flex-row gap-4 border-b border-white/20 pb-4">
                            <input type="email" placeholder="Email address" class="bg-transparent outline-none flex-grow text-white placeholder:text-white/30 font-inter text-lg" />
                            <button type="button" class="hover-trigger font-syne font-bold uppercase tracking-widest text-sm text-accent hover:text-white transition-colors">Subscribe</button>
                        </div>
                        <label class="flex items-center gap-3 mt-6 text-sm text-secondary hover-trigger">
                            <input type="checkbox" class="accent-slate-200 w-4 h-4" />
                            I agree to receive promotional emails.
                        </label>
                    </div>

                    <div class="flex md:justify-end reveal-item">
                        <div class="flex flex-col gap-4 text-right">
                            <h4 class="text-secondary text-sm font-bold uppercase tracking-widest mb-4">Shop Onyx</h4>
                            <a href="../customer_page/onyx_catalog.aspx?category=Mouse" class="hover-trigger text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Gaming Mice</a>
                            <a href="../customer_page/onyx_catalog.aspx?category=Keyboard" class="hover-trigger text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Mechanical Keyboards</a>
                            <a href="../customer_page/onyx_catalog.aspx?category=Headset" class="hover-trigger text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Headsets</a>
                            <a href="../customer_page/onyx_catalog.aspx?category=Accessory" class="hover-trigger text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Accessories</a>
                            <a href="/customer_page/Support.aspx" class="hover-trigger text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Support & Warranty</a>
                        </div>
                    </div>
                </div>

                <div class="max-w-7xl mx-auto mt-32 flex flex-col md:flex-row justify-between items-center text-xs text-secondary border-t border-white/10 pt-8 reveal-item">
                    <p>Onyx Gaming Technologies, 2026</p>
                    <div class="flex gap-6 mt-4 md:mt-0">
                        <a href="/customer_page/Terms.aspx" class="hover:text-white transition-colors hover-trigger no-underline text-secondary">Terms of Sale</a>
                        <a href="/customer_page/Privacy.aspx" class="hover:text-white transition-colors hover-trigger no-underline text-secondary">Privacy Policy</a>
                    </div>
                    <button type="button" id="onyx-back-to-top" class="mt-4 md:mt-0 hover:text-white transition-colors hover-trigger uppercase tracking-widest font-bold">Back to Top</button>
                </div>
            </footer>
        </main>
    </div>

    <script>
        (function () {
            var root = document.querySelector('.onyx-ddac-home');
            var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

            if (!root) {
                return;
            }

            if (window.gsap && window.ScrollTrigger) {
                gsap.registerPlugin(ScrollTrigger);
            }

            window.addEventListener('load', function () {
                var homeRoot = document.querySelector('.onyx-ddac-home');

                if (window.gsap && !reduceMotion) {
                    var timeline = gsap.timeline({
                        onComplete: function () {
                            if (homeRoot) {
                                homeRoot.classList.add('is-ready');
                            }

                            initScrollAnimations();
                        }
                    });

                    timeline.to('.onyx-ddac-hero-title', {
                        opacity: 1,
                        y: 0,
                        duration: 0.9,
                        ease: 'power3.out'
                    }, 0.15);
                } else {
                    var homeRoot = document.querySelector('.onyx-ddac-home');
                    if (homeRoot) {
                        homeRoot.classList.add('is-ready');
                    }

                    document.querySelectorAll('.onyx-ddac-hero-title').forEach(function (item) {
                        item.style.opacity = '1';
                    });
                    initScrollAnimations();
                }
            });

            function initScrollAnimations() {
                if (!window.gsap || !window.ScrollTrigger || reduceMotion) {
                    return;
                }

                document.querySelectorAll('section:not(:first-of-type) .reveal-item, footer .reveal-item').forEach(function (item) {
                    gsap.set(item, { opacity: 0, y: 50 });

                    ScrollTrigger.create({
                        trigger: item,
                        start: 'top 85%',
                        onEnter: function () {
                            gsap.to(item, {
                                opacity: 1,
                                y: 0,
                                duration: 1,
                                ease: 'power3.out'
                            });
                        },
                        once: true
                    });
                });

                ScrollTrigger.refresh();
            }

            /* Back to top */
            var backToTop = document.getElementById('onyx-back-to-top');

            if (backToTop) {
                backToTop.addEventListener('click', function () {
                    window.scrollTo({ top: 0, behavior: reduceMotion ? 'auto' : 'smooth' });
                });
            }
        })();
    </script>
</asp:Content>
