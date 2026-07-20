<%@ Page Title="Pro Gears" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="proGears.aspx.cs" Inherits="ONYX_DDAC.customer_page.proGears" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-pro-page {
            --pro-bg: #040404;
            --pro-panel: #101112;
            --pro-panel-alt: #151617;
            --pro-line: #292b2d;
            --pro-ink: #f7f7f5;
            --pro-muted: #a7a9ad;
            --pro-faint: #6f7278;
            --pro-glow: #d8dde3;
            background: var(--pro-bg);
            color: var(--pro-ink);
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            min-height: 100vh;
            overflow: hidden;
        }

        .onyx-pro-page *,
        .onyx-pro-page h1,
        .onyx-pro-page h2,
        .onyx-pro-page h3,
        .onyx-pro-page p,
        .onyx-pro-page a,
        .onyx-pro-page span,
        .onyx-pro-page strong {
            box-sizing: border-box;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif !important;
            font-weight: 400 !important;
        }

        .onyx-pro-shell {
            margin: 0 auto;
            max-width: 1400px;
            width: min(100% - 80px, 1400px);
        }

        .onyx-pro-kicker,
        .onyx-pro-label,
        .onyx-pro-button,
        .onyx-pro-spec em {
            font-family: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace !important;
            font-size: 12px;
            letter-spacing: 1.2px !important;
            line-height: 1.4;
            text-transform: uppercase;
        }

        .onyx-pro-hero {
            border-bottom: 1px solid var(--pro-line);
            padding: clamp(126px, 12vw, 172px) 0 74px;
        }

        .onyx-pro-hero-heading {
            align-items: end;
            display: grid;
            gap: clamp(28px, 5vw, 70px);
            grid-template-columns: minmax(0, 1fr) minmax(280px, 380px);
            text-align: left;
        }

        .onyx-pro-kicker {
            color: var(--pro-muted);
            display: inline-flex;
            gap: 14px;
            margin-bottom: 30px;
        }

        .onyx-pro-kicker::before {
            background: #d8dde3;
            content: "";
            height: 1px;
            margin-top: 8px;
            width: 44px;
        }

        .onyx-pro-page h1 {
            color: var(--pro-ink) !important;
            font-size: clamp(54px, 8vw, 122px);
            letter-spacing: -0.055em !important;
            line-height: 0.88;
            margin: 0;
            max-width: 980px;
            text-wrap: balance;
            text-transform: uppercase;
        }

        .onyx-pro-break {
            display: block;
        }

        .onyx-pro-lede {
            color: var(--pro-muted) !important;
            font-size: clamp(18px, 2vw, 24px);
            line-height: 1.58;
            margin: 28px 0 0;
            max-width: 720px;
        }

        .onyx-pro-brief-card {
            background:
                linear-gradient(180deg, rgba(255, 255, 255, 0.055), rgba(255, 255, 255, 0)),
                var(--pro-panel);
            border: 1px solid var(--pro-line);
            border-radius: 8px;
            padding: 22px;
        }

        .onyx-pro-brief-card strong {
            color: var(--pro-ink) !important;
            display: block;
            font-size: 24px;
            letter-spacing: -0.03em !important;
            line-height: 1.1;
            margin-top: 18px;
        }

        .onyx-pro-brief-card p {
            color: var(--pro-muted) !important;
            font-size: 14px;
            line-height: 1.7;
            margin: 18px 0 0;
        }

        .onyx-pro-signal {
            display: grid;
            gap: 7px;
            grid-template-columns: repeat(6, 1fr);
            margin-top: 24px;
        }

        .onyx-pro-signal span {
            background: rgba(216, 221, 227, 0.22);
            border-radius: 999px;
            display: block;
            height: 3px;
        }

        .onyx-pro-signal span:nth-child(-n + 4) {
            background: var(--pro-glow);
        }

        .onyx-pro-stage {
            background: #070707;
            border: 1px solid var(--pro-line);
            border-radius: 8px;
            height: min(72vh, 720px);
            margin-top: clamp(42px, 6vw, 72px);
            min-height: 500px;
            overflow: hidden;
            position: relative;
        }

        .onyx-pro-stage::before {
            background:
                radial-gradient(circle at 74% 24%, rgba(216, 221, 227, 0.18), transparent 20rem),
                linear-gradient(90deg, rgba(4, 4, 4, 0.16), transparent 42%, rgba(4, 4, 4, 0.58));
            content: "";
            inset: 0;
            position: absolute;
            z-index: 1;
        }

        .onyx-pro-stage::after {
            background: linear-gradient(180deg, transparent 46%, rgba(4, 4, 4, 0.66));
            content: "";
            inset: 0;
            pointer-events: none;
            position: absolute;
            z-index: 2;
        }

        .onyx-pro-hero-image {
            display: block;
            height: 112%;
            inset: -6% 0 auto;
            object-fit: cover;
            object-position: center;
            position: absolute;
            transform: scale(1.04);
            width: 100%;
            z-index: 0;
        }

        .onyx-pro-drop-card {
            background: rgba(5, 5, 5, 0.76);
            border: 1px solid rgba(255, 255, 255, 0.16);
            border-radius: 8px;
            bottom: 28px;
            right: 28px;
            padding: 24px;
            position: absolute;
            text-align: left;
            width: min(420px, calc(100% - 56px));
            z-index: 3;
        }

        .onyx-pro-label {
            color: var(--pro-faint);
            display: block;
            margin-bottom: 14px;
        }

        .onyx-pro-drop-card h2 {
            color: var(--pro-ink) !important;
            font-size: clamp(30px, 3.2vw, 46px);
            letter-spacing: -0.04em !important;
            line-height: 1;
            margin: 0 0 14px;
        }

        .onyx-pro-drop-card p,
        .onyx-pro-section-copy,
        .onyx-pro-card p,
        .onyx-pro-spec strong,
        .onyx-pro-cta p {
            color: var(--pro-muted) !important;
            font-size: 16px;
            line-height: 1.68;
            margin: 0;
        }

        .onyx-pro-section {
            border-bottom: 1px solid var(--pro-line);
            padding: clamp(76px, 9vw, 116px) 0;
        }

        .onyx-pro-section-last {
            border-bottom: 0;
        }

        .onyx-pro-grid-layout {
            display: grid;
            gap: 42px;
            grid-template-columns: minmax(160px, 0.24fr) minmax(0, 1fr);
        }

        .onyx-pro-section-title {
            color: var(--pro-ink) !important;
            font-size: clamp(34px, 5vw, 72px);
            letter-spacing: -0.04em !important;
            line-height: 1;
            margin: 0;
            max-width: 960px;
            text-wrap: balance;
        }

        .onyx-pro-section-copy {
            font-size: clamp(17px, 1.7vw, 22px) !important;
            line-height: 1.62 !important;
            margin-top: 24px;
            max-width: 780px;
        }

        .onyx-pro-collab-grid {
            display: grid;
            gap: 14px;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            margin-top: 48px;
        }

        .onyx-pro-card {
            background: var(--pro-panel);
            border: 1px solid var(--pro-line);
            border-radius: 8px;
            min-height: 290px;
            padding: 24px;
            text-decoration: none;
            transition: border-color 160ms ease, transform 160ms ease, background 160ms ease;
        }

        .onyx-pro-card:hover,
        .onyx-pro-card:focus-visible {
            background: #141416;
            border-color: rgba(255, 255, 255, 0.36);
            transform: translateY(-3px);
        }

        .onyx-pro-card .onyx-pro-label {
            margin-bottom: 50px;
        }

        .onyx-pro-card h3 {
            color: var(--pro-ink) !important;
            font-size: clamp(26px, 3vw, 42px);
            letter-spacing: -0.04em !important;
            line-height: 1;
            margin: 0 0 18px;
        }

        .onyx-pro-spec-list {
            list-style: none;
            margin: 44px 0 0;
            padding: 0;
        }

        .onyx-pro-spec {
            align-items: start;
            border-top: 1px solid var(--pro-line);
            display: grid;
            gap: clamp(42px, 5vw, 80px);
            grid-template-columns: minmax(360px, 0.42fr) minmax(0, 1fr) 60px;
            padding: 30px 0;
        }

        .onyx-pro-spec:last-child {
            border-bottom: 1px solid var(--pro-line);
        }

        .onyx-pro-spec h3 {
            color: var(--pro-ink) !important;
            font-size: clamp(36px, 5vw, 72px);
            letter-spacing: -0.04em !important;
            line-height: 0.98;
            margin: 0;
        }

        .onyx-pro-spec strong {
            display: block;
            font-size: clamp(18px, 2vw, 24px) !important;
            line-height: 1.45 !important;
            padding-top: 10px;
        }

        .onyx-pro-spec em {
            color: var(--pro-glow);
            font-style: normal;
            text-align: right;
        }

        .onyx-pro-product-band {
            display: grid;
            gap: 14px;
            grid-template-columns: minmax(0, 1.12fr) minmax(320px, 0.88fr);
        }

        .onyx-pro-product-media,
        .onyx-pro-product-copy {
            background: var(--pro-panel);
            border: 1px solid var(--pro-line);
            border-radius: 8px;
            overflow: hidden;
        }

        .onyx-pro-product-media {
            min-height: 560px;
            position: relative;
        }

        .onyx-pro-product-media::after {
            background: linear-gradient(180deg, transparent 48%, rgba(4, 4, 4, 0.78));
            content: "";
            inset: 0;
            position: absolute;
        }

        .onyx-pro-product-media img {
            background: #050505;
            display: block;
            height: 100%;
            min-height: 560px;
            object-fit: cover;
            object-position: center;
            padding: 0;
            width: 100%;
        }

        .onyx-pro-product-copy {
            align-content: end;
            display: grid;
            padding: clamp(28px, 4vw, 44px);
        }

        .onyx-pro-product-copy h2 {
            color: var(--pro-ink) !important;
            font-size: clamp(34px, 5vw, 68px);
            letter-spacing: -0.04em !important;
            line-height: 1;
            margin: 0 0 22px;
        }

        .onyx-pro-console {
            border-top: 1px solid var(--pro-line);
            margin-top: 28px;
        }

        .onyx-pro-console-row {
            align-items: baseline;
            border-bottom: 1px solid var(--pro-line);
            display: grid;
            gap: 18px;
            grid-template-columns: 112px minmax(0, 1fr);
            padding: 16px 0;
        }

        .onyx-pro-console-row span {
            color: var(--pro-faint);
            font-family: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace !important;
            font-size: 11px;
            letter-spacing: 1.2px !important;
            text-transform: uppercase;
        }

        .onyx-pro-console-row strong {
            color: var(--pro-ink) !important;
            font-size: 17px;
            line-height: 1.45;
        }

        .onyx-pro-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 34px;
        }

        .onyx-pro-button {
            align-items: center;
            border: 1px solid rgba(255, 255, 255, 0.28);
            border-radius: 999px;
            color: var(--pro-ink) !important;
            display: inline-flex;
            min-height: 48px;
            padding: 0 22px;
            text-decoration: none;
            transition: background 160ms ease, border-color 160ms ease, color 160ms ease, transform 160ms ease;
        }

        .onyx-pro-button:hover,
        .onyx-pro-button:focus-visible {
            background: var(--pro-ink);
            border-color: var(--pro-ink);
            color: var(--pro-bg) !important;
            transform: translateY(-2px);
        }

        .onyx-pro-button.is-primary {
            background: var(--pro-ink);
            border-color: var(--pro-ink);
            color: #050505 !important;
        }

        .onyx-pro-button.is-primary:hover,
        .onyx-pro-button.is-primary:focus-visible {
            background: var(--pro-glow);
            border-color: var(--pro-glow);
        }

        .onyx-pro-cta {
            align-items: center;
            display: grid;
            gap: 34px;
            grid-template-columns: minmax(0, 1fr) auto;
        }

        .onyx-pro-cta p {
            font-size: 18px;
            margin-top: 22px;
            max-width: 680px;
        }

        .onyx-pro-reveal {
            opacity: 1;
            transform: none;
        }

        .onyx-pro-page.is-ready .onyx-pro-reveal {
            opacity: 0;
            transform: translateY(28px);
            transition: opacity 700ms cubic-bezier(0.16, 1, 0.3, 1), transform 700ms cubic-bezier(0.16, 1, 0.3, 1);
        }

        .onyx-pro-page.is-ready .onyx-pro-reveal.is-visible {
            opacity: 1;
            transform: translateY(0);
        }

        @media (prefers-reduced-motion: reduce) {
            .onyx-pro-page *,
            .onyx-pro-reveal {
                transition: none !important;
                transform: none !important;
            }
        }

        @media (max-width: 1100px) {
            .onyx-pro-shell {
                width: min(100% - 48px, 1400px);
            }

            .onyx-pro-grid-layout,
            .onyx-pro-product-band,
            .onyx-pro-hero-heading,
            .onyx-pro-cta {
                grid-template-columns: 1fr;
            }

            .onyx-pro-collab-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .onyx-pro-spec {
                grid-template-columns: 1fr;
            }

            .onyx-pro-spec em {
                text-align: left;
            }
        }

        @media (max-width: 760px) {
            .onyx-pro-shell {
                width: min(100% - 32px, 1400px);
            }

            .onyx-pro-hero {
                padding-top: 118px;
            }

            .onyx-pro-page h1 {
                font-size: clamp(44px, 15vw, 72px);
            }

            .onyx-pro-stage {
                height: 520px;
                min-height: 520px;
            }

            .onyx-pro-hero-image {
                height: 100%;
                inset: 0;
                object-position: 52% center;
            }

            .onyx-pro-drop-card {
                bottom: 96px;
                left: 16px;
                right: 84px;
                padding: 18px;
                width: auto;
            }

            .onyx-pro-product-media,
            .onyx-pro-product-media img {
                min-height: 360px;
            }

            .onyx-pro-console-row {
                grid-template-columns: 1fr;
            }

            .onyx-pro-collab-grid {
                grid-template-columns: 1fr;
            }

            .onyx-pro-card {
                min-height: 0;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-pro-page" aria-labelledby="pro-title">
        <section class="onyx-pro-hero">
            <div class="onyx-pro-shell">
                <div class="onyx-pro-hero-heading">
                    <div>
                        <span class="onyx-pro-kicker onyx-pro-reveal">Pro gear</span>
                        <h1 id="pro-title" class="onyx-pro-reveal">Pro collab keyboard.</h1>
                        <p class="onyx-pro-lede onyx-pro-reveal">
                            A TenZ-style pro drop concept: compact keyboard, fast input feel, and more room for aim.
                        </p>
                    </div>
                    <aside class="onyx-pro-brief-card onyx-pro-reveal" aria-label="Pro gear setup signal">
                        <span class="onyx-pro-label">Best for</span>
                        <strong>Keyboard-first players.</strong>
                        <p>Pick this path when movement timing and mouse space matter most.</p>
                        <div class="onyx-pro-signal" aria-hidden="true">
                            <span></span><span></span><span></span><span></span><span></span><span></span>
                        </div>
                    </aside>
                </div>

                <div class="onyx-pro-stage onyx-pro-reveal" aria-label="ONYX pro collab keyboard concept">
                    <img class="onyx-pro-hero-image" src="<%= ONYX_DDAC.Helpers.MediaUrlHelper.Resolve("site-photos/pro-gear/onyx-pro-signature-keyboard.png") %>" alt="Black ONYX compact pro keyboard with signature-style accent lighting" />
                    <div class="onyx-pro-drop-card">
                        <span class="onyx-pro-label">Collab concept</span>
                        <h2>ONYX Pro Signature</h2>
                        <p>Compact layout, fast switches, black shell, and a signature accent.</p>
                    </div>
                </div>
            </div>
        </section>

        <section class="onyx-pro-section">
            <div class="onyx-pro-shell onyx-pro-grid-layout">
                <div class="onyx-pro-label onyx-pro-reveal">Why it matters</div>
                <div>
                    <h2 class="onyx-pro-section-title onyx-pro-reveal">Three reasons to choose the pro keyboard path.</h2>
                    <p class="onyx-pro-section-copy onyx-pro-reveal">
                        No long explanation. This page should help a player decide if the keyboard upgrade is worth opening.
                    </p>

                    <div class="onyx-pro-collab-grid">
                        <article class="onyx-pro-card onyx-pro-reveal">
                            <span class="onyx-pro-label">01</span>
                            <h3>More mouse room.</h3>
                            <p>Compact layout keeps the aim lane open for low-sensitivity players.</p>
                        </article>
                        <article class="onyx-pro-card onyx-pro-reveal">
                            <span class="onyx-pro-label">02</span>
                            <h3>Faster repeats.</h3>
                            <p>Built around quick movement keys, peeks, ability timing, and reset feel.</p>
                        </article>
                        <article class="onyx-pro-card onyx-pro-reveal">
                            <span class="onyx-pro-label">03</span>
                            <h3>Cleaner desk.</h3>
                            <p>One focused board instead of oversized gear fighting for space.</p>
                        </article>
                    </div>
                </div>
            </div>
        </section>

        <section class="onyx-pro-section onyx-pro-section-last">
            <div class="onyx-pro-shell onyx-pro-cta onyx-pro-reveal">
                <div>
                    <span class="onyx-pro-kicker">Ready</span>
                    <h2 class="onyx-pro-section-title">Open the keyboard lineup.</h2>
                    <p>Compare layouts, price, stock, and product details in the catalog.</p>
                </div>
                <div class="onyx-pro-actions">
                    <a class="onyx-pro-button is-primary hover-trigger" href="/customer_page/onyx_catalog.aspx?category=Keyboard">Keyboard gear</a>
                    <a class="onyx-pro-button hover-trigger" href="/customer_page/onyx_catalog.aspx">Full catalog</a>
                </div>
            </div>
        </section>
    </main>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const page = document.querySelector('.onyx-pro-page');
            const revealItems = document.querySelectorAll('.onyx-pro-reveal');
            const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

            if (!page) return;
            page.classList.add('is-ready');

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
        });
    </script>
</asp:Content>
