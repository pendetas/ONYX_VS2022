<%@ Page Title="Terms and Conditions" Language="C#" AutoEventWireup="true" CodeBehind="Terms.aspx.cs" Inherits="ONYX_DDAC.user_page.Terms" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Terms &amp; Conditions — ONYX</title>

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

    <style>
        .onyx-ddac-home {
            background-color: #050505;
            color: #ffffff;
            cursor: none;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            overflow-x: hidden;
            position: relative;
            isolation: isolate;
        }

        .onyx-ddac-home a,
        .onyx-ddac-home button,
        .onyx-ddac-home input,
        .onyx-ddac-home label {
            cursor: none;
        }

        .onyx-ddac-cursor {
            background-color: #ffffff;
            border-radius: 50%;
            height: 12px;
            left: 0;
            mix-blend-mode: difference;
            pointer-events: none;
            position: fixed;
            top: 0;
            transform: translate(-50%, -50%);
            transition: width 0.3s, height 0.3s, background-color 0.3s, opacity 0.3s, border-color 0.3s;
            width: 12px;
            z-index: 9999;
        }

        .onyx-ddac-cursor.hover-state {
            background-color: transparent;
            border: 1px solid #d8dde3;
            height: 60px;
            mix-blend-mode: normal;
            width: 60px;
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

        /* ── Catalog mega-panel ───────────────────── */
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

        .onyx-ddac-nav.is-floating ~ * .onyx-ddac-megapanel,
        .onyx-ddac-nav.is-floating + .onyx-ddac-megapanel {
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
            transition: opacity 0.35s cubic-bezier(0.4, 0, 0.2, 1), transform 0.35s cubic-bezier(0.4, 0, 0.2, 1);
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
            transition: opacity 0.4s cubic-bezier(0.4, 0, 0.2, 1) 0.28s, transform 0.4s cubic-bezier(0.4, 0, 0.2, 1) 0.28s;
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

        /* Floating Nav */
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
            transition: border-radius 0.55s cubic-bezier(0.4, 0, 0.2, 1), top 0.55s cubic-bezier(0.4, 0, 0.2, 1), left 0.55s cubic-bezier(0.4, 0, 0.2, 1), right 0.55s cubic-bezier(0.4, 0, 0.2, 1), padding 0.55s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.55s cubic-bezier(0.4, 0, 0.2, 1), border-color 0.4s ease, background 0.4s ease;
            width: auto;
            z-index: 90;
        }

        .onyx-ddac-nav.is-floating {
            background: rgba(8, 8, 10, 0.97);
            border-bottom-color: transparent;
            border-radius: 999px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5), 0 2px 8px rgba(0, 0, 0, 0.3), 0 0 0 1px rgba(255, 255, 255, 0.10), inset 0 1px 0 rgba(255, 255, 255, 0.06);
            left: 20px;
            padding: 12px 32px;
            right: 20px;
            top: 12px;
        }

        /* Editorial Layout */
        .editorial-container {
            display: grid;
            grid-template-columns: 1fr;
            gap: 4rem;
            max-width: 1200px;
            margin: 0 auto;
            padding: 200px 24px 100px;
        }

        @media (min-width: 1024px) {
            .editorial-container {
                grid-template-columns: 240px 1fr;
                gap: 6rem;
                padding-left: 48px;
                padding-right: 48px;
            }
        }

        .editorial-toc {
            position: sticky;
            top: 120px;
            align-self: start;
        }

        .editorial-toc-link {
            display: block;
            color: #9ca3af;
            text-decoration: none;
            padding: 8px 0;
            font-size: 14px;
            transition: color 0.2s ease, transform 0.2s ease;
        }

        .editorial-toc-link:hover, .editorial-toc-link.active {
            color: #ffffff;
            transform: translateX(4px);
        }

        .editorial-section {
            margin-bottom: 5rem;
            padding-bottom: 5rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.06);
        }

        .editorial-section:last-child {
            border-bottom: none;
        }

        .editorial-section h2 {
            font-family: 'Syne', sans-serif;
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: baseline;
            gap: 1rem;
        }

        .editorial-section h2 span {
            color: #9ca3af;
            font-size: 1.25rem;
            font-weight: 500;
        }

        .editorial-section p {
            color: #d1d5db;
            line-height: 1.8;
            margin-bottom: 1.5rem;
            font-size: 1.125rem;
        }

        .editorial-section ul {
            list-style: none;
            padding: 0;
            margin: 0 0 1.5rem 0;
        }

        .editorial-section li {
            color: #d1d5db;
            line-height: 1.8;
            margin-bottom: 0.75rem;
            padding-left: 1.5rem;
            position: relative;
        }

        .editorial-section li::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0.6rem;
            width: 6px;
            height: 6px;
            background-color: #d8dde3;
            border-radius: 50%;
        }

        .footer {
            border-top: 1px solid rgba(255, 255, 255, 0.06);
            padding: 4rem 24px;
            margin-top: 4rem;
        }

        .footer-inner {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 2rem;
        }

        @media (min-width: 768px) {
            .footer-inner {
                flex-direction: row;
                justify-content: space-between;
                padding: 0 24px;
            }
        }
    </style>
</head>
<body class="onyx-ddac-home antialiased font-sans selection:bg-accent selection:text-black">
    <div id="cursor" class="onyx-ddac-cursor"></div>

    <nav id="onyx-main-nav" class="onyx-ddac-nav flex justify-between items-center">
        <a href="Home.aspx" class="hover-trigger no-underline text-white flex-shrink-0">
            <img src="/Content/home/onyx-logo-horizontal.png" alt="ONYX" class="onyx-ddac-nav-logo" />
        </a>
        <div class="hidden md:flex gap-8 text-sm font-medium tracking-wide items-center">
            <!-- Catalog mega-dropdown -->
            <div class="onyx-ddac-dropdown">
                <a href="../customer_page/onyx_catalog.aspx" class="hover-trigger onyx-ddac-dropdown-trigger text-white">
                    Catalog
                    <span class="onyx-chev"></span>
                </a>
                <div class="onyx-ddac-megapanel">
                    <div class="onyx-ddac-megapanel-inner">
                        <div class="onyx-ddac-mega-cats">
                            <a href="../customer_page/onyx_products.aspx?category=Mouse" class="hover-trigger onyx-ddac-mega-cat">
                                <span class="onyx-ddac-mega-cat-num">01</span>
                                <span class="onyx-ddac-mega-cat-name">Gaming Mice</span>
                                <span class="onyx-ddac-mega-cat-sub">Precision tracking</span>
                            </a>
                            <a href="../customer_page/onyx_products.aspx?category=Keyboard" class="hover-trigger onyx-ddac-mega-cat">
                                <span class="onyx-ddac-mega-cat-num">02</span>
                                <span class="onyx-ddac-mega-cat-name">Keyboards</span>
                                <span class="onyx-ddac-mega-cat-sub">Tactile response</span>
                            </a>
                            <a href="../customer_page/onyx_products.aspx?category=Headset" class="hover-trigger onyx-ddac-mega-cat">
                                <span class="onyx-ddac-mega-cat-num">03</span>
                                <span class="onyx-ddac-mega-cat-name">Audio</span>
                                <span class="onyx-ddac-mega-cat-sub">Spatial surround</span>
                            </a>
                            <a href="../customer_page/onyx_products.aspx" class="hover-trigger onyx-ddac-mega-cat">
                                <span class="onyx-ddac-mega-cat-num">04</span>
                                <span class="onyx-ddac-mega-cat-name">Accessories</span>
                                <span class="onyx-ddac-mega-cat-sub">Desk essentials</span>
                            </a>
                        </div>
                        <div class="onyx-ddac-mega-cta">
                            <span class="onyx-ddac-mega-cta-label">New season</span>
                            <a href="../customer_page/onyx_catalog.aspx" class="hover-trigger onyx-ddac-mega-cta-link">
                                Shop All
                                <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
                                    <path d="M2 6h8M6.5 2.5L10 6l-3.5 3.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <a href="Home.aspx#featured-products" class="hover-trigger hover:text-accent transition-colors no-underline text-white">Pro Gear</a>
            <a href="../About.aspx" class="hover-trigger hover:text-accent transition-colors no-underline text-white">About</a>
            <a href="../Contact.aspx" class="hover-trigger hover:text-accent transition-colors no-underline text-white">Support</a>

            <span class="text-secondary">|</span>

            <a href="../auth_page/onyx_login.aspx" class="hover-trigger hover:text-accent transition-colors no-underline text-white">Login</a>
            <a href="../auth_page/onyx_register.aspx" class="hover-trigger no-underline onyx-ddac-nav-register">Register</a>
        </div>
    </nav>

    <div class="editorial-container">
        <aside class="hidden lg:block">
            <div class="editorial-toc">
                <p class="text-xs uppercase tracking-widest text-secondary mb-6 font-bold">Contents</p>
                <nav class="flex flex-col gap-2">
                    <a href="#acceptance" class="editorial-toc-link hover-trigger">1. Acceptance of Terms</a>
                    <a href="#products" class="editorial-toc-link hover-trigger">2. Products & Pricing</a>
                    <a href="#orders" class="editorial-toc-link hover-trigger">3. Orders & Payment</a>
                    <a href="#shipping" class="editorial-toc-link hover-trigger">4. Shipping & Delivery</a>
                    <a href="#returns" class="editorial-toc-link hover-trigger">5. Returns & Warranty</a>
                    <a href="#intellectual" class="editorial-toc-link hover-trigger">6. Intellectual Property</a>
                    <a href="#liability" class="editorial-toc-link hover-trigger">7. Limitation of Liability</a>
                    <a href="#governing" class="editorial-toc-link hover-trigger">8. Governing Law</a>
                </nav>
            </div>
        </aside>

        <main>
            <div class="mb-24 reveal-item">
                <h1 class="text-5xl md:text-7xl font-syne font-bold mb-6 tracking-tight">Terms & Conditions</h1>
                <p class="text-secondary text-lg">Effective Date: January 2026</p>
                <div class="h-px bg-white/10 w-full mt-12"></div>
            </div>

            <section id="acceptance" class="editorial-section reveal-item">
                <h2><span>01</span> Acceptance of Terms</h2>
                <p>By accessing, browsing, or purchasing products from ONYX Gaming Technologies ("ONYX", "we", "us"), you agree to be bound by these Terms and Conditions. If you do not agree to all the terms and conditions of this agreement, then you may not access the website or use any services.</p>
                <p>We reserve the right to update, change or replace any part of these Terms and Conditions by posting updates and/or changes to our website. It is your responsibility to check this page periodically for changes.</p>
            </section>

            <section id="products" class="editorial-section reveal-item">
                <h2><span>02</span> Products & Pricing</h2>
                <p>We strive to accurately display the colors, features, specifications, and details of the products available on our website. However, we do not guarantee that the colors, features, specifications, and details of the products will be accurate, complete, reliable, current, or free of other errors.</p>
                <p>All pricing is listed in Malaysian Ringgit (MYR) unless otherwise stated. Prices for our products are subject to change without notice. We reserve the right at any time to modify or discontinue any product (or any part or content thereof) without notice at any time.</p>
            </section>

            <section id="orders" class="editorial-section reveal-item">
                <h2><span>03</span> Orders & Payment</h2>
                <p>We reserve the right to refuse any order you place with us. We may, in our sole discretion, limit or cancel quantities purchased per person, per household or per order. These restrictions may include orders placed by or under the same customer account, the same credit card, and/or orders that use the same billing and/or shipping address.</p>
                <p>You agree to provide current, complete and accurate purchase and account information for all purchases made at our store. We accept major credit cards, online banking, and e-wallets as displayed during the checkout process.</p>
            </section>

            <section id="shipping" class="editorial-section reveal-item">
                <h2><span>04</span> Shipping & Delivery</h2>
                <p>Shipping costs and estimated delivery times are calculated at checkout and may vary depending on the delivery address and selected shipping method. While we endeavor to ensure timely delivery, we cannot be held responsible for delays beyond our control, including carrier delays or customs clearance.</p>
                <p>Risk of loss and title for items purchased from ONYX pass to you upon delivery of the items to the carrier. It is your responsibility to provide a secure delivery location.</p>
            </section>

            <section id="returns" class="editorial-section reveal-item">
                <h2><span>05</span> Returns & Warranty</h2>
                <p>We offer a 30-day return policy for unused, unopened items in their original packaging. Return shipping costs are the responsibility of the customer unless the item received was defective or incorrect.</p>
                <p>ONYX esports peripherals come with a standard limited warranty covering manufacturing defects. This warranty does not cover damage resulting from misuse, abuse, accidents, modifications, or normal wear and tear. Please refer to the specific warranty documentation included with your product for detailed terms.</p>
            </section>

            <section id="intellectual" class="editorial-section reveal-item">
                <h2><span>06</span> Intellectual Property</h2>
                <p>The website and its entire contents, features, and functionality (including but not limited to all information, software, text, displays, images, video, and audio, and the design, selection, and arrangement thereof) are owned by ONYX Gaming Technologies, its licensors, or other providers of such material and are protected by international copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws.</p>
                <p>You must not reproduce, distribute, modify, create derivative works of, publicly display, publicly perform, republish, download, store, or transmit any of the material on our website without our prior written consent.</p>
            </section>

            <section id="liability" class="editorial-section reveal-item">
                <h2><span>07</span> Limitation of Liability</h2>
                <p>In no case shall ONYX Gaming Technologies, our directors, officers, employees, affiliates, agents, contractors, interns, suppliers, service providers or licensors be liable for any injury, loss, claim, or any direct, indirect, incidental, punitive, special, or consequential damages of any kind, including, without limitation lost profits, lost revenue, lost savings, loss of data, replacement costs, or any similar damages, whether based in contract, tort (including negligence), strict liability or otherwise, arising from your use of any of the service or any products procured using the service.</p>
            </section>

            <section id="governing" class="editorial-section reveal-item">
                <h2><span>08</span> Governing Law</h2>
                <p>These Terms and Conditions and any separate agreements whereby we provide you services shall be governed by and construed in accordance with the laws of Malaysia, without regard to its conflict of law provisions.</p>
                <p>Any dispute arising out of or in connection with these terms, including any question regarding its existence, validity, or termination, shall be referred to and finally resolved by the courts of Malaysia.</p>
            </section>
        </main>
    </div>

    <footer class="footer">
        <div class="footer-inner">
            <div class="font-syne text-2xl font-bold tracking-widest uppercase hover-trigger">ONYX</div>
            <div class="flex gap-6 text-sm text-secondary">
                <a href="Privacy.aspx" class="hover-trigger hover:text-white transition-colors">Privacy Policy</a>
                <a href="Terms.aspx" class="hover-trigger text-white">Terms</a>
                <a href="../Contact.aspx" class="hover-trigger hover:text-white transition-colors">Support</a>
            </div>
            <div class="text-sm text-secondary">
                &copy; 2026 Onyx Gaming Technologies.
            </div>
        </div>
    </footer>

    <script>
        // Custom Cursor Logic
        const cursor = document.getElementById('cursor');
        const hoverTriggers = document.querySelectorAll('.hover-trigger');

        document.addEventListener('mousemove', (e) => {
            cursor.style.left = e.clientX + 'px';
            cursor.style.top = e.clientY + 'px';
        });

        hoverTriggers.forEach(trigger => {
            trigger.addEventListener('mouseenter', () => {
                cursor.classList.add('hover-state');
            });
            trigger.addEventListener('mouseleave', () => {
                cursor.classList.remove('hover-state');
            });
        });

        // Floating Nav Logic
        const nav = document.getElementById('onyx-main-nav');
        window.addEventListener('scroll', () => {
            if (window.scrollY > 60) {
                nav.classList.add('is-floating');
            } else {
                nav.classList.remove('is-floating');
            }
        });

        // GSAP Animations
        gsap.registerPlugin(ScrollTrigger);

        gsap.utils.toArray('.reveal-item').forEach(item => {
            gsap.fromTo(item, 
                { opacity: 0, y: 30 },
                {
                    opacity: 1, 
                    y: 0, 
                    duration: 0.8,
                    ease: "power3.out",
                    scrollTrigger: {
                        trigger: item,
                        start: "top 85%",
                        toggleActions: "play none none reverse"
                    }
                }
            );
        });

        // Smooth TOC Scrolling
        document.querySelectorAll('.editorial-toc-link').forEach(anchor => {
            anchor.addEventListener('click', function(e) {
                e.preventDefault();
                const targetId = this.getAttribute('href').substring(1);
                const targetElement = document.getElementById(targetId);
                
                if (targetElement) {
                    window.scrollTo({
                        top: targetElement.offsetTop - 120, // offset for fixed nav
                        behavior: 'smooth'
                    });
                }
            });
        });

        // Highlight TOC on scroll
        const sections = document.querySelectorAll('.editorial-section');
        const navLi = document.querySelectorAll('.editorial-toc-link');

        window.addEventListener('scroll', () => {
            let current = '';
            sections.forEach(section => {
                const sectionTop = section.offsetTop;
                if (scrollY >= sectionTop - 150) {
                    current = section.getAttribute('id');
                }
            });

            navLi.forEach(li => {
                li.classList.remove('active');
                if (li.getAttribute('href') === `#${current}`) {
                    li.classList.add('active');
                }
            });
        });
    </script>
</body>
</html>
