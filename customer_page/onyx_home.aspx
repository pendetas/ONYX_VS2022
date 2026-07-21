<%@ Page Title="Home" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_home.aspx.cs" Inherits="ONYX_DDAC.customer_page.Home" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-home.css") %>?v=20260709-product-drop" />
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

</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="onyx-ddac-home antialiased font-sans selection:bg-accent selection:text-black">
        <main id="top">
            <section class="onyx-ddac-hero-section relative w-full h-screen flex flex-col justify-center items-center px-6 pt-20" aria-label="ONYX hero video">
                <video class="onyx-ddac-hero-video" autoplay muted loop playsinline preload="auto" aria-hidden="true">
                    <source src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-videos/Dragon.mp4") %>" type="video/mp4" />
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
                    <a  href="/customer_page/onyx_catalog.aspx?category=Mouse">
                        <strong>Aim control</strong>
                        <span>Shop gaming mice for tracking, grip, and click timing</span>
                    </a>
                    <a  href="/customer_page/onyx_catalog.aspx?category=Keyboard">
                        <strong>Fast inputs</strong>
                        <span>Compare keyboards for response, switch feel, and layout</span>
                    </a>
                    <a  href="/customer_page/onyx_catalog.aspx">
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
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/faze-clan.svg") %>" alt="FaZe Clan logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/cloud9.svg") %>" alt="Cloud9 logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/team-liquid.svg") %>" alt="Team Liquid logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/fnatic.svg") %>" alt="Fnatic logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/100-thieves.svg") %>" alt="100 Thieves logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/g2-esports.svg") %>" alt="G2 Esports logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/sentinels.svg") %>" alt="Sentinels logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/navi.svg") %>" alt="NAVI logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/faze-clan.svg") %>" alt="FaZe Clan logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/cloud9.svg") %>" alt="Cloud9 logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/team-liquid.svg") %>" alt="Team Liquid logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/fnatic.svg") %>" alt="Fnatic logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/100-thieves.svg") %>" alt="100 Thieves logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/g2-esports.svg") %>" alt="G2 Esports logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/sentinels.svg") %>" alt="Sentinels logo" loading="lazy" /></span>
                        <span class="onyx-ddac-team-logo"><img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/team-logos/navi.svg") %>" alt="NAVI logo" loading="lazy" /></span>
                    </div>
                </div>
            </section>

            <section class="onyx-home-product-drop" aria-labelledby="onyx-home-drop-title">
                <div class="onyx-home-drop-shell">
                    <div class="onyx-home-drop-header reveal-item">
                        <span>Catalog drop</span>
                        <h2 id="onyx-home-drop-title">New gear, one click to catalog.</h2>
                        <p>Jump straight into the matching catalog section for the newest ONYX mouse and keyboard lineup.</p>
                    </div>

                    <div class="onyx-home-drop-grid" aria-label="Featured ONYX catalog products">
                        <a class="onyx-home-drop-card reveal-item" href="<%= ResolveUrl("~/customer_page/onyx_catalog.aspx?category=Mouse") %>">
                            <img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/drop-cards/onyx-gm1-se-plus.png") %>" alt="ONYX GM1 SE+ gaming mouse" loading="lazy" />
                            <span class="onyx-home-drop-label">Mouse / SE+</span>
                            <div>
                                <h3>ONYX GM1 SE+</h3>
                                <p>Light control for aim-heavy setups.</p>
                                <strong>Shop gaming mice</strong>
                            </div>
                        </a>

                        <a class="onyx-home-drop-card reveal-item" href="<%= ResolveUrl("~/customer_page/onyx_catalog.aspx?category=Keyboard") %>">
                            <img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/drop-cards/onyx-60he-v2.jpeg") %>" alt="ONYX 60HE v2 compact keyboard" loading="lazy" />
                            <span class="onyx-home-drop-label">Keyboard / 60%</span>
                            <div>
                                <h3>ONYX 60HE v2</h3>
                                <p>Compact rapid input for clean desk space.</p>
                                <strong>Shop keyboards</strong>
                            </div>
                        </a>

                        <a class="onyx-home-drop-card reveal-item" href="<%= ResolveUrl("~/customer_page/onyx_catalog.aspx?category=Keyboard") %>">
                            <img src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/drop-cards/onyx-80he.png") %>" alt="ONYX 80HE gaming keyboard" loading="lazy" />
                            <span class="onyx-home-drop-label">Keyboard / 80%</span>
                            <div>
                                <h3>ONYX 80HE</h3>
                                <p>Fuller control layout with a focused footprint.</p>
                                <strong>Shop keyboards</strong>
                            </div>
                        </a>
                    </div>
                </div>
            </section>

            <asp:Panel ID="PersonalizedProductsPanel" runat="server" Visible="false" CssClass="onyx-personalized-strip w-full py-32 px-6 md:px-12 bg-[#050505] relative z-10 border-t border-white/10">
                <div class="max-w-7xl mx-auto">
                    <div class="mb-14 reveal-item">
                        <p class="text-accent uppercase tracking-widest text-sm font-bold mb-4">For your setup</p>
                        <h2 class="text-4xl md:text-6xl font-syne font-bold tracking-tighter leading-tight"><%: PersonalizedSetupHeadline %></h2>
                        <p class="onyx-personalized-copy"><%: PersonalizedSetupSubheadline %></p>
                    </div>

                    <div class="onyx-ddac-product-grid">
                        <asp:Repeater ID="PersonalizedProductsRepeater" runat="server">
                            <ItemTemplate>
                                <article class="onyx-ddac-product-card reveal-item">
                                    <div class="onyx-ddac-product-media">
                                        <img src='<%# GetPersonalizedProductImageUrl(Container.DataItem, Container.ItemIndex) %>' alt='<%# GetPersonalizedProductAlt(Container.DataItem) %>' class="onyx-ddac-product-image" loading="lazy" />
                                    </div>
                                    <div class="onyx-ddac-product-body">
                                        <p><%# GetPersonalizedProductReason(Container.DataItem) %></p>
                                        <h3><%# GetPersonalizedProductName(Container.DataItem) %></h3>
                                        <div class="onyx-ddac-product-meta">
                                            <strong><%# GetPersonalizedProductPrice(Container.DataItem) %></strong>
                                            <a href='<%# GetPersonalizedProductUrl(Container.DataItem) %>'>View</a>
                                        </div>
                                    </div>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </asp:Panel>

            <section id="featured-products" class="w-full py-32 px-6 md:px-12 bg-[#0b0b0c] relative z-10 border-t border-white/10">
                <div class="max-w-7xl mx-auto">
                    <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-8 mb-14 reveal-item">
                        <div>
                            <p class="text-accent uppercase tracking-widest text-sm font-bold mb-4">Featured Gear</p>
                            <h2 class="text-5xl md:text-7xl font-syne font-bold tracking-tighter leading-tight">Shop the silver standard.</h2>
                        </div>
                        <a href="../customer_page/onyx_catalog.aspx" class="border border-white/30 px-8 py-4 rounded-full font-bold text-sm tracking-wide uppercase hover:border-white transition-colors no-underline text-white">View All</a>
                    </div>

                    <div class="onyx-ddac-product-grid">
                        <asp:Repeater ID="FeaturedProductsRepeater" runat="server">
                            <ItemTemplate>
                                <article class="onyx-ddac-product-card reveal-item">
                                    <div class="onyx-ddac-product-media">
                                        <img src='<%# GetFeaturedProductImageUrl(Container.DataItem, Container.ItemIndex) %>' alt='<%# GetFeaturedProductAlt(Container.DataItem) %>' class="onyx-ddac-product-image" loading="lazy" />
                                    </div>
                                    <div class="onyx-ddac-product-body">
                                        <p><%# Eval("Brand") %></p>
                                        <h3><%# Eval("Name") %></h3>
                                        <div class="onyx-ddac-product-meta">
                                            <strong><%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("Price")) %></strong>
                                            <a href="../customer_page/onyx_catalog.aspx">View</a>
                                        </div>
                                    </div>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </section>

            <footer class="onyx-ddac-footer w-full py-32 px-6 md:px-12 relative z-10">
            <video class="onyx-ddac-footer-video" autoplay muted loop playsinline preload="auto" poster="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-photos/dragonink-poster.png") %>" aria-hidden="true">
                    <source src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("home-videos/DragonInk.mp4") %>" type="video/mp4" />
                </video>
                <div class="onyx-ddac-footer-main max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-20">
                    <div class="onyx-ddac-footer-signup reveal-item">
                        <h2 class="onyx-ddac-footer-title text-4xl md:text-6xl font-syne font-bold tracking-tighter mb-6 leading-tight">
                            Get early access to exclusive hardware drops.
                        </h2>
                        <div class="onyx-ddac-footer-form mt-12 flex flex-col sm:flex-row gap-4 border-b border-white/20 pb-4">
                            <input type="email" placeholder="Email address" class="onyx-ddac-footer-input bg-transparent outline-none flex-grow text-white placeholder:text-white/30 font-inter text-lg" />
                            <button type="button" class="onyx-ddac-footer-submit font-syne font-bold uppercase tracking-widest text-sm text-accent hover:text-white transition-colors">Subscribe</button>
                        </div>
                        <label class="onyx-ddac-footer-consent flex items-center gap-3 mt-6 text-sm text-secondary">
                            <input type="checkbox" class="accent-slate-200 w-4 h-4" />
                            I agree to receive promotional emails.
                        </label>
                    </div>

                    <div class="onyx-ddac-footer-nav flex md:justify-end reveal-item">
                        <div class="onyx-ddac-footer-links flex flex-col gap-4 text-right">
                            <h4 class="text-secondary text-sm font-bold uppercase tracking-widest mb-4">Shop Onyx</h4>
                            <a href="../customer_page/onyx_catalog.aspx?category=Mouse" class="text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Gaming Mice</a>
                            <a href="../customer_page/onyx_catalog.aspx?category=Keyboard" class="text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Mechanical Keyboards</a>
                            <a href="../customer_page/onyx_catalog.aspx?category=Headset" class="text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Headsets</a>
                            <a href="../customer_page/onyx_catalog.aspx?category=Accessory" class="text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Accessories</a>
                            <a href="onyx_support.aspx" class="text-2xl font-syne font-medium hover:text-accent transition-colors no-underline text-white">Support & Warranty</a>
                        </div>
                    </div>
                </div>

                <div class="onyx-ddac-footer-bottom max-w-7xl mx-auto mt-32 flex flex-col md:flex-row justify-between items-center text-xs text-secondary border-t border-white/10 pt-8 reveal-item">
                    <p>Onyx Gaming Technologies, 2026</p>
                    <div class="flex gap-6 mt-4 md:mt-0">
                        <a href="onyx_terms.aspx" class="hover:text-white transition-colors no-underline text-secondary">Terms of Sale</a>
                        <a href="onyx_privacy.aspx" class="hover:text-white transition-colors no-underline text-secondary">Privacy Policy</a>
                    </div>
                    <button type="button" id="onyx-back-to-top" class="mt-4 md:mt-0 hover:text-white transition-colors uppercase tracking-widest font-bold">Back to Top</button>
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
