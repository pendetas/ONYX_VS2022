<%@ Page Title="ONYX Related" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_about.aspx.cs" Inherits="ONYX_DDAC.customer_page.About" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital@1&display=swap" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-content.css") %>?v=20260708-onyx-related-fix" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-about" aria-labelledby="about-title">
        <section class="onyx-about-hero">
            <div class="onyx-about-shell">
                <span class="onyx-about-kicker onyx-about-reveal">ONYX Related</span>
                <h1 id="about-title" class="onyx-about-hero-title onyx-about-parallax-text">Gear for <em>focused play</em>.</h1>

                <div class="onyx-about-hero-stage onyx-about-reveal" aria-label="ONYX gaming gear collection">
                    <img class="onyx-about-hero-image onyx-about-parallax-img" src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("site-photos/about/onyx-related-hero.png") %>" alt="Dark ONYX gaming setup with monitor, headset, keyboard, and mouse" />
                    <div class="onyx-about-hero-note">
                        <span class="onyx-about-label">What ONYX is</span>
                        <p>Black-and-silver gaming gear with one connected account for catalog, wishlist, orders, reviews, and support.</p>
                    </div>
                </div>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-shell onyx-about-grid-layout">
                <div class="onyx-about-section-label onyx-about-reveal">Quick facts</div>
                <div class="onyx-about-section-content">
                    <p class="onyx-about-mission onyx-about-reveal">
                        ONYX sells <em>performance peripherals</em> for players who care about control, fast inputs, clear audio, and clean ownership after checkout.
                    </p>

                    <div class="onyx-about-stats" aria-label="ONYX company facts">
                        <div class="onyx-about-stat onyx-about-reveal">
                            <strong>8</strong>
                            <span>Current products in the ONYX catalog</span>
                        </div>
                        <div class="onyx-about-stat onyx-about-reveal">
                            <strong>5</strong>
                            <span>Gear categories for complete setups</span>
                        </div>
                        <div class="onyx-about-stat onyx-about-reveal">
                            <strong>1</strong>
                            <span>Account for cart, wishlist, orders, reviews, and support</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="onyx-about-section onyx-about-section-last">
            <div class="onyx-about-shell onyx-about-footer-cta onyx-about-reveal">
                <div>
                    <h2>Find the gear that fits.</h2>
                    <p>Start with mice, keyboards, audio, accessories, or your saved wishlist.</p>
                </div>
                <a class="onyx-about-button" href="/customer_page/onyx_catalog.aspx">Shop ONYX</a>
            </div>
        </section>
    </main>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const about = document.querySelector('.onyx-about');
            const revealItems = document.querySelectorAll('.onyx-about-reveal');
            const heroImage = document.querySelector('.onyx-about-parallax-img');
            const heroText = document.querySelector('.onyx-about-parallax-text');
            const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

            if (!about) return;
            about.classList.add('is-ready');

            if ('IntersectionObserver' in window && !reduceMotion) {
                const observer = new IntersectionObserver(function (entries) {
                    entries.forEach(function (entry) {
                        if (!entry.isIntersecting) return;
                        entry.target.classList.add('is-visible');
                        observer.unobserve(entry.target);
                    });
                }, { threshold: 0.15, rootMargin: '0px 0px -60px 0px' });

                revealItems.forEach(function (item) { observer.observe(item); });
            } else {
                revealItems.forEach(function (item) { item.classList.add('is-visible'); });
            }

            if (!reduceMotion && (heroImage || heroText)) {
                let ticking = false;

                function updateHero() {
                    const y = window.scrollY || 0;
                    if (heroImage) heroImage.style.transform = 'translate3d(0,' + (y * 0.035) + 'px,0) scale(1.04)';
                    if (heroText) {
                        heroText.style.transform = 'translate3d(0,' + (y * 0.03) + 'px,0)';
                        heroText.style.opacity = Math.max(0.18, 1 - y / 760);
                    }
                    ticking = false;
                }

                window.addEventListener('scroll', function () {
                    if (ticking) return;
                    ticking = true;
                    window.requestAnimationFrame(updateHero);
                }, { passive: true });
            }
        });
    </script>
</asp:Content>
