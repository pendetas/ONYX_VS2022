<%@ Page Title="Home" Language="C#" MasterPageFile="~/user_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="ONYX_DDAC.user_page.Home" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
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
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>

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

        .onyx-ddac-home.has-custom-cursor,
        .onyx-ddac-home.has-custom-cursor a,
        .onyx-ddac-home.has-custom-cursor button,
        .onyx-ddac-home.has-custom-cursor input,
        .onyx-ddac-home.has-custom-cursor label {
            cursor: none;
        }

        .onyx-ddac-cursor {
            background-color: #ffffff;
            border-radius: 50%;
            height: 12px;
            left: 0;
            mix-blend-mode: difference;
            opacity: 0;
            pointer-events: none;
            position: fixed;
            top: 0;
            transform: translate3d(-100px, -100px, 0) translate(-50%, -50%);
            transition: width 0.3s, height 0.3s, background-color 0.3s, opacity 0.18s ease, border-color 0.3s;
            visibility: hidden;
            will-change: transform, width, height;
            width: 12px;
            z-index: 9999;
        }

        .onyx-ddac-cursor.is-visible {
            opacity: 1;
            visibility: visible;
        }

        .onyx-ddac-cursor.hover-state {
            background-color: transparent;
            border: 1px solid #d8dde3;
            height: 60px;
            mix-blend-mode: normal;
            width: 60px;
        }

        .onyx-ddac-preloader {
            align-items: center;
            background-color: #050505;
            display: flex;
            font-family: Syne, sans-serif;
            height: 100vh;
            justify-content: center;
            left: 0;
            position: fixed;
            top: 0;
            width: 100vw;
            z-index: 9998;
        }

        .onyx-ddac-canvas {
            height: 100vh;
            left: 0;
            pointer-events: none;
            position: fixed;
            top: 0;
            width: 100vw;
            z-index: -1;
        }

        .onyx-ddac-hero-section {
            overflow: hidden;
        }

        .onyx-ddac-hero-copy {
            position: relative;
            z-index: 3;
        }

        .onyx-ddac-nav-logo {
            display: block;
            height: 100px;
            max-width: 300px;
            object-fit: contain;
            width: auto;
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
            background: rgba(5, 5, 5, 0.85);
            backdrop-filter: blur(16px) saturate(180%);
            -webkit-backdrop-filter: blur(16px) saturate(180%);
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 0px;
            left: 0;
            padding: 16px 48px;
            position: fixed;
            right: 0;
            top: 0;
            transition:
                box-shadow 0.55s cubic-bezier(0.4, 0, 0.2, 1),
                border-color 0.4s ease,
                background 0.4s ease;
            width: auto;
            z-index: 90;
        }

        .onyx-ddac-nav.is-scrolled {
            background: rgba(8, 8, 10, 0.97);
            border-bottom-color: rgba(255, 255, 255, 0.12);
            box-shadow:
                0 10px 30px rgba(0, 0, 0, 0.36),
                inset 0 1px 0 rgba(255, 255, 255, 0.06);
            left: 0;
            right: 0;
            top: 0;
        }

        .onyx-ddac-hero-mouse {
            bottom: clamp(1.5rem, 5vh, 4.5rem);
            left: 50%;
            opacity: 0.66;
            pointer-events: none;
            position: absolute;
            transform: translateX(-50%);
            width: min(72vw, 820px);
            z-index: 1;
        }

        .onyx-ddac-hero-mouse img {
            border-radius: 32px;
            display: block;
            filter: drop-shadow(0 34px 60px rgba(216, 221, 227, 0.14));
            height: auto;
            -webkit-mask-image: radial-gradient(ellipse at center, #000 58%, rgba(0, 0, 0, 0.82) 76%, transparent 100%);
            mask-image: radial-gradient(ellipse at center, #000 58%, rgba(0, 0, 0, 0.82) 76%, transparent 100%);
            width: 100%;
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

        .onyx-ddac-split-char {
            display: inline-block;
            opacity: 0;
            transform: translateY(50px);
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
            .onyx-ddac-hero-mouse {
                bottom: 4rem;
                opacity: 0.42;
                width: min(110vw, 620px);
            }

            .onyx-ddac-product-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-height: 760px) {
            .onyx-ddac-hero-mouse {
                opacity: 0.38;
                width: min(56vw, 640px);
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

            .onyx-ddac-cursor {
                display: none;
            }

            .onyx-ddac-nav-logo {
                height: 70px;
                max-width: 210px;
                width: auto;
            }

            .onyx-ddac-nav {
                padding: 14px 20px;
            }

            .onyx-ddac-home.has-custom-cursor,
            .onyx-ddac-home.has-custom-cursor a,
            .onyx-ddac-home.has-custom-cursor button,
            .onyx-ddac-home.has-custom-cursor input,
            .onyx-ddac-home.has-custom-cursor label {
                cursor: auto;
            }

            .onyx-ddac-product-grid {
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

            .onyx-ddac-split-char {
                opacity: 1;
                transform: none;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="onyx-ddac-home antialiased font-sans selection:bg-accent selection:text-black">
        <div id="preloader" class="onyx-ddac-preloader">
            <h1 id="loader-text" class="text-6xl md:text-8xl font-syne font-bold text-white tracking-tighter">0%</h1>
        </div>

        <canvas id="webgl-canvas" class="onyx-ddac-canvas"></canvas>

        <main id="top">
            <section class="onyx-ddac-hero-section relative w-full h-screen flex flex-col justify-center items-center px-6 pt-20">
                <div class="onyx-ddac-hero-copy text-center w-full max-w-6xl mx-auto">
                    <p class="text-secondary font-syne uppercase tracking-widest text-sm mb-6 reveal-item opacity-0">Premium Esports Peripherals</p>
                    <h1 id="hero-title" class="text-6xl md:text-8xl lg:text-[8rem] leading-[0.9] font-syne font-bold tracking-tighter mb-12 uppercase">
                        Dominate<br />the game.
                    </h1>

                    <div class="flex flex-col sm:flex-row gap-6 justify-center items-center reveal-item opacity-0">
                        <a href="../customer_page/onyx_products.aspx" class="hover-trigger bg-accent text-black px-8 py-4 rounded-full font-bold text-sm tracking-wide uppercase hover:bg-white transition-colors no-underline">
                            Shop Collection
                        </a>
                        <a href="#featured-products" class="hover-trigger border border-white/30 px-8 py-4 rounded-full font-bold text-sm tracking-wide uppercase hover:border-white transition-colors no-underline text-white">
                            View Pro Gear
                        </a>
                    </div>
                </div>

                <div class="onyx-ddac-hero-mouse reveal-item opacity-0">
                    <img src="/Content/home/onyx-pro-mouse.png" alt="Black and silver wireless esports gaming mouse" width="1536" height="1024" />
                </div>

                <div class="absolute left-6 md:left-12 top-1/2 -translate-y-1/2 hidden lg:flex flex-col gap-12 reveal-item opacity-0">
                    <div>
                        <h3 class="font-syne text-4xl font-bold text-white">1<span class="text-accent text-2xl">ms</span></h3>
                        <p class="text-secondary text-sm">Ultra-Low Latency</p>
                    </div>
                    <div>
                        <h3 class="font-syne text-4xl font-bold text-white">50<span class="text-accent text-2xl">h</span></h3>
                        <p class="text-secondary text-sm">Competitive Battery Life</p>
                    </div>
                </div>

                <div class="absolute right-6 md:right-12 top-1/2 -translate-y-1/2 hidden lg:flex flex-col gap-12 text-right reveal-item opacity-0">
                    <div>
                        <h3 class="font-syne text-4xl font-bold text-white">49<span class="text-accent text-2xl">g</span></h3>
                        <p class="text-secondary text-sm">Featherweight Chassis</p>
                    </div>
                    <div>
                        <h3 class="font-syne text-4xl font-bold text-white">30<span class="text-accent text-2xl">K</span></h3>
                        <p class="text-secondary text-sm">DPI Optical Sensor</p>
                    </div>
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
                                The foundation<br />of your next<br /><span class="onyx-ddac-text-outline">Victory</span>
                            </h2>
                        </div>
                        <div class="reveal-item md:pl-20">
                            <p class="text-secondary text-lg md:text-xl leading-relaxed">
                                Equip yourself with elite-grade hardware designed for esports players. Experience uncompromised precision, speed, and black-silver build quality.
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
                    <span class="border border-accent text-accent px-4 py-1 rounded-full text-xs font-bold uppercase tracking-widest">Trusted By Pro Teams</span>
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
                        <a href="../customer_page/onyx_products.aspx" class="hover-trigger border border-white/30 px-8 py-4 rounded-full font-bold text-sm tracking-wide uppercase hover:border-white transition-colors no-underline text-white">View All</a>
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
                                            <a href="../customer_page/onyx_products.aspx" class="hover-trigger">View</a>
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
                            <a href="../customer_page/onyx_products.aspx?category=Mouse" class="hover-trigger text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Gaming Mice</a>
                            <a href="../customer_page/onyx_products.aspx?category=Keyboard" class="hover-trigger text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Mechanical Keyboards</a>
                            <a href="../customer_page/onyx_products.aspx?category=Headset" class="hover-trigger text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Headsets</a>
                            <a href="../customer_page/onyx_products.aspx" class="hover-trigger text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Accessories</a>
                            <a href="/user_page/Support.aspx" class="hover-trigger text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Support & Warranty</a>
                        </div>
                    </div>
                </div>

                <div class="max-w-7xl mx-auto mt-32 flex flex-col md:flex-row justify-between items-center text-xs text-secondary border-t border-white/10 pt-8 reveal-item">
                    <p>Onyx Gaming Technologies, 2026</p>
                    <div class="flex gap-6 mt-4 md:mt-0">
                        <a href="/user_page/Terms.aspx" class="hover:text-white transition-colors hover-trigger no-underline text-secondary">Terms of Sale</a>
                        <a href="/user_page/Privacy.aspx" class="hover:text-white transition-colors hover-trigger no-underline text-secondary">Privacy Policy</a>
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

            var canvas = document.getElementById('webgl-canvas');

            if (canvas && window.THREE && !reduceMotion) {
                var scene = new THREE.Scene();
                var camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
                camera.position.z = 30;

                var renderer = new THREE.WebGLRenderer({ canvas: canvas, alpha: true, antialias: true });
                renderer.setSize(window.innerWidth, window.innerHeight);
                renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

                scene.add(new THREE.AmbientLight(0xffffff, 0.15));

                var pointLight = new THREE.PointLight(0xffffff, 1.5);
                pointLight.position.set(15, 15, 15);
                scene.add(pointLight);

                var silverLight = new THREE.PointLight(0xd8dde3, 1.25);
                silverLight.position.set(-15, -15, 15);
                scene.add(silverLight);

                var geometry = new THREE.OctahedronGeometry(14, 0);
                var material = new THREE.MeshStandardMaterial({
                    color: 0x111111,
                    roughness: 0.2,
                    metalness: 0.9,
                    flatShading: true
                });
                var crystal = new THREE.Mesh(geometry, material);

                var wireGeom = new THREE.OctahedronGeometry(14.5, 0);
                var wireMat = new THREE.MeshBasicMaterial({
                    color: 0xd8dde3,
                    wireframe: true,
                    transparent: true,
                    opacity: 0.18
                });
                var wireframe = new THREE.Mesh(wireGeom, wireMat);

                var crystalGroup = new THREE.Group();
                crystalGroup.add(crystal);
                crystalGroup.add(wireframe);
                scene.add(crystalGroup);

                var mouseX = 0;
                var mouseY = 0;
                var targetX = 0;
                var targetY = 0;

                document.addEventListener('mousemove', function (event) {
                    mouseX = (event.clientX - window.innerWidth / 2) * 0.005;
                    mouseY = (event.clientY - window.innerHeight / 2) * 0.005;
                });

                var clock = new THREE.Clock();

                function animateThreeJS() {
                    requestAnimationFrame(animateThreeJS);
                    var time = clock.getElapsedTime();

                    crystalGroup.rotation.x += 0.002;
                    crystalGroup.rotation.y += 0.003;
                    crystalGroup.position.y = Math.sin(time) * 1.5;

                    targetX = mouseX * 3;
                    targetY = mouseY * 3;
                    crystalGroup.position.x += (targetX - crystalGroup.position.x) * 0.05;
                    crystalGroup.position.y += (-targetY - (crystalGroup.position.y - Math.sin(time) * 1.5)) * 0.05;

                    renderer.render(scene, camera);
                }

                animateThreeJS();

                window.addEventListener('resize', function () {
                    camera.aspect = window.innerWidth / window.innerHeight;
                    camera.updateProjectionMatrix();
                    renderer.setSize(window.innerWidth, window.innerHeight);
                });
            }

            window.addEventListener('load', function () {
                var loaderText = document.getElementById('loader-text');

                if (window.gsap && !reduceMotion) {
                    var counter = { value: 0 };
                    var timeline = gsap.timeline({
                        onComplete: function () {
                            initScrollAnimations();
                        }
                    });

                    timeline.to(counter, {
                        value: 100,
                        duration: 1.6,
                        ease: 'power2.inOut',
                        onUpdate: function () {
                            if (loaderText) {
                                loaderText.innerText = Math.round(counter.value) + '%';
                            }
                        }
                    })
                    .to('#preloader', {
                        yPercent: -100,
                        duration: 1.0,
                        ease: 'power4.inOut',
                        delay: 0.1
                    })
                    .to('.reveal-item', {
                        opacity: 1,
                        y: 0,
                        duration: 0.9,
                        stagger: 0.08,
                        ease: 'power3.out',
                        clearProps: 'all'
                    }, '-=0.45');
                } else {
                    var preloader = document.getElementById('preloader');

                    if (preloader) {
                        preloader.style.display = 'none';
                    }

                    document.querySelectorAll('.reveal-item').forEach(function (item) {
                        item.style.opacity = '1';
                    });
                    initScrollAnimations();
                }
            });

            function initScrollAnimations() {
                var heroTitle = document.getElementById('hero-title');

                if (heroTitle && window.gsap && !heroTitle.dataset.split) {
                    var chars = heroTitle.innerText.split('');
                    heroTitle.innerHTML = '';
                    heroTitle.dataset.split = 'true';

                    chars.forEach(function (char) {
                        if (char === ' ') {
                            heroTitle.innerHTML += '&nbsp;';
                        } else if (char === '\n') {
                            heroTitle.innerHTML += '<br />';
                        } else {
                            heroTitle.innerHTML += '<span class="onyx-ddac-split-char">' + char + '</span>';
                        }
                    });

                    gsap.to('.onyx-ddac-split-char', {
                        opacity: 1,
                        y: 0,
                        duration: 0.8,
                        stagger: 0.02,
                        ease: 'back.out(1.5)',
                        delay: 0.2
                    });
                }

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

            /* ── Floating nav on scroll ─────────────────────────── */
            var backToTop = document.getElementById('onyx-back-to-top');

            if (backToTop) {
                backToTop.addEventListener('click', function () {
                    window.scrollTo({ top: 0, behavior: reduceMotion ? 'auto' : 'smooth' });
                });
            }
        })();
    </script>
</asp:Content>
