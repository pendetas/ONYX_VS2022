<%@ Page Title="About" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="ONYX_DDAC.customer_page.About" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-about {
            background: #050505;
            color: #f8fafc;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            overflow: hidden;
        }

        .onyx-about h1,
        .onyx-about h2,
        .onyx-about h3 {
            font-family: Syne, Inter, sans-serif;
            letter-spacing: -0.04em;
        }

        .onyx-about-hero {
            align-items: flex-end;
            background:
                radial-gradient(circle at 78% 20%, rgba(216, 221, 227, 0.18), transparent 18rem),
                linear-gradient(180deg, rgba(255, 255, 255, 0.04), transparent 34%),
                #050505;
            display: grid;
            min-height: 100vh;
            padding: 150px 6vw 72px;
            position: relative;
        }

        .onyx-about-hero::before {
            background-image:
                linear-gradient(rgba(255, 255, 255, 0.045) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.045) 1px, transparent 1px);
            background-size: 64px 64px;
            content: "";
            inset: 0;
            mask-image: linear-gradient(180deg, #000, transparent 80%);
            opacity: 0.28;
            position: absolute;
        }

        .onyx-about-hero-inner {
            display: grid;
            gap: 56px;
            grid-template-columns: minmax(0, 1.15fr) minmax(320px, 0.85fr);
            margin: 0 auto;
            max-width: 1500px;
            position: relative;
            width: 100%;
            z-index: 1;
        }

        .onyx-about-eyebrow {
            color: #d8dde3;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.22em;
            margin-bottom: 24px;
            text-transform: uppercase;
        }

        .onyx-about h1 {
            font-size: clamp(64px, 10vw, 168px);
            font-weight: 800;
            line-height: 0.86;
            margin: 0;
            max-width: 980px;
            text-transform: uppercase;
        }

        .onyx-about-lede {
            color: #a8b0ba;
            font-size: clamp(17px, 1.5vw, 23px);
            line-height: 1.7;
            margin: 34px 0 0;
            max-width: 720px;
        }

        .onyx-about-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
            margin-top: 40px;
        }

        .onyx-about-pill {
            align-items: center;
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 999px;
            color: #ffffff;
            display: inline-flex;
            font-size: 12px;
            font-weight: 800;
            gap: 10px;
            letter-spacing: 0.1em;
            min-height: 52px;
            padding: 0 24px;
            text-transform: uppercase;
            transition: background 180ms ease, border-color 180ms ease, color 180ms ease, transform 180ms ease;
        }

        .onyx-about-pill:hover {
            background: #ffffff;
            border-color: #ffffff;
            color: #050505;
            transform: translateY(-2px);
        }

        .onyx-about-visual {
            align-self: stretch;
            border: 1px solid rgba(255, 255, 255, 0.14);
            min-height: 560px;
            overflow: hidden;
            position: relative;
        }

        .onyx-about-visual img {
            height: 100%;
            inset: 0;
            object-fit: cover;
            position: absolute;
            width: 100%;
        }

        .onyx-about-visual::after {
            background:
                linear-gradient(180deg, transparent 46%, rgba(5, 5, 5, 0.82)),
                linear-gradient(90deg, rgba(5, 5, 5, 0.35), transparent 42%);
            content: "";
            inset: 0;
            position: absolute;
        }

        .onyx-about-award {
            border: 1px solid rgba(255, 255, 255, 0.18);
            bottom: 24px;
            left: 24px;
            padding: 18px 20px;
            position: absolute;
            right: 24px;
            z-index: 1;
        }

        .onyx-about-award span {
            color: #9ca3af;
            display: block;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.18em;
            text-transform: uppercase;
        }

        .onyx-about-award strong {
            display: block;
            font-family: Syne, Inter, sans-serif;
            font-size: 26px;
            letter-spacing: -0.04em;
            margin-top: 8px;
        }

        .onyx-about-section {
            padding: 120px 6vw;
            position: relative;
        }

        .onyx-about-wrap {
            margin: 0 auto;
            max-width: 1500px;
        }

        .onyx-about-manifesto {
            border-bottom: 1px solid rgba(255, 255, 255, 0.12);
            border-top: 1px solid rgba(255, 255, 255, 0.12);
        }

        .onyx-about-manifesto h2 {
            font-size: clamp(44px, 7vw, 112px);
            font-weight: 800;
            line-height: 0.95;
            margin: 0;
            max-width: 1200px;
            text-transform: uppercase;
        }

        .onyx-about-manifesto p {
            color: #a8b0ba;
            font-size: clamp(18px, 1.8vw, 28px);
            line-height: 1.55;
            margin: 42px 0 0 auto;
            max-width: 760px;
        }

        .onyx-about-craft {
            display: grid;
            gap: 28px;
            grid-template-columns: repeat(4, minmax(0, 1fr));
        }

        .onyx-about-craft article {
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.055), rgba(255, 255, 255, 0.025));
            border: 1px solid rgba(255, 255, 255, 0.12);
            min-height: 330px;
            padding: 28px;
            position: relative;
        }

        .onyx-about-craft article::before {
            color: rgba(216, 221, 227, 0.34);
            content: attr(data-index);
            font-family: Syne, Inter, sans-serif;
            font-size: 52px;
            font-weight: 800;
            letter-spacing: -0.06em;
        }

        .onyx-about-craft h3 {
            font-size: 24px;
            margin: 72px 0 16px;
        }

        .onyx-about-craft p {
            color: #a8b0ba;
            line-height: 1.65;
            margin: 0;
        }

        .onyx-about-wide-shot {
            border: 1px solid rgba(255, 255, 255, 0.12);
            display: grid;
            grid-template-columns: 1fr 1fr;
            margin-top: 36px;
            min-height: 520px;
            overflow: hidden;
        }

        .onyx-about-wide-shot img {
            height: 100%;
            object-fit: cover;
            width: 100%;
        }

        .onyx-about-wide-copy {
            align-content: end;
            background:
                radial-gradient(circle at 12% 8%, rgba(216, 221, 227, 0.16), transparent 14rem),
                #090909;
            display: grid;
            padding: clamp(32px, 5vw, 70px);
        }

        .onyx-about-wide-copy h2 {
            font-size: clamp(38px, 5vw, 76px);
            line-height: 0.96;
            margin: 0;
            text-transform: uppercase;
        }

        .onyx-about-wide-copy p {
            color: #a8b0ba;
            font-size: 18px;
            line-height: 1.65;
            margin: 26px 0 0;
            max-width: 560px;
        }

        .onyx-about-stats {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            margin-top: 36px;
        }

        .onyx-about-stat {
            border-top: 1px solid rgba(255, 255, 255, 0.14);
            padding: 28px 24px 0 0;
        }

        .onyx-about-stat strong {
            display: block;
            font-family: Syne, Inter, sans-serif;
            font-size: clamp(42px, 5vw, 76px);
            letter-spacing: -0.06em;
            line-height: 0.9;
        }

        .onyx-about-stat span {
            color: #9ca3af;
            display: block;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.12em;
            margin-top: 14px;
            text-transform: uppercase;
        }

        .onyx-about-timeline {
            display: grid;
        }

        .onyx-about-timeline-row {
            align-items: center;
            border-top: 1px solid rgba(255, 255, 255, 0.12);
            display: grid;
            gap: 32px;
            grid-template-columns: 160px 1fr 1.2fr;
            padding: 34px 0;
        }

        .onyx-about-timeline-row:last-child {
            border-bottom: 1px solid rgba(255, 255, 255, 0.12);
        }

        .onyx-about-timeline-row span {
            color: #d8dde3;
            font-family: Syne, Inter, sans-serif;
            font-size: 28px;
            font-weight: 800;
            letter-spacing: -0.04em;
        }

        .onyx-about-timeline-row strong {
            font-family: Syne, Inter, sans-serif;
            font-size: clamp(24px, 3vw, 44px);
            letter-spacing: -0.04em;
        }

        .onyx-about-timeline-row p {
            color: #a8b0ba;
            line-height: 1.65;
            margin: 0;
        }

        .onyx-about-cta {
            align-items: center;
            background:
                radial-gradient(circle at 72% 30%, rgba(216, 221, 227, 0.18), transparent 18rem),
                linear-gradient(135deg, #0c0c0d, #050505);
            border: 1px solid rgba(255, 255, 255, 0.14);
            display: grid;
            gap: 36px;
            grid-template-columns: 1fr auto;
            padding: clamp(34px, 6vw, 78px);
        }

        .onyx-about-cta h2 {
            font-size: clamp(44px, 7vw, 104px);
            line-height: 0.92;
            margin: 0;
            text-transform: uppercase;
        }

        .onyx-about-cta p {
            color: #a8b0ba;
            font-size: 18px;
            line-height: 1.6;
            margin: 26px 0 0;
            max-width: 720px;
        }

        @media (max-width: 1100px) {
            .onyx-about-hero-inner,
            .onyx-about-wide-shot,
            .onyx-about-cta {
                grid-template-columns: 1fr;
            }

            .onyx-about-visual {
                min-height: 520px;
            }

            .onyx-about-craft,
            .onyx-about-stats {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 720px) {
            .onyx-about-hero,
            .onyx-about-section {
                padding-left: 24px;
                padding-right: 24px;
            }

            .onyx-about-hero {
                padding-top: 118px;
            }

            .onyx-about-craft,
            .onyx-about-stats {
                grid-template-columns: 1fr;
            }

            .onyx-about-timeline-row {
                gap: 14px;
                grid-template-columns: 1fr;
            }

            .onyx-about-visual {
                min-height: 420px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="onyx-about" aria-labelledby="about-title">
        <section class="onyx-about-hero">
            <div class="onyx-about-hero-inner">
                <div>
                    <p class="onyx-about-eyebrow">ONYX Performance Studio / Malaysia</p>
                    <h1 id="about-title">Built for the last round.</h1>
                    <p class="onyx-about-lede">
                        ONYX creates black-silver esports hardware for players who care about feel, response, and confidence under pressure. Every surface, click, and gram is tuned for the moment where hesitation loses.
                    </p>
                    <div class="onyx-about-actions">
                        <a class="onyx-about-pill hover-trigger" href="/customer_page/onyx_products.aspx">Explore gear <span>+</span></a>
                        <a class="onyx-about-pill hover-trigger" href="/customer_page/Support.aspx">Talk to ONYX <span>+</span></a>
                    </div>
                </div>

                <aside class="onyx-about-visual" aria-label="ONYX product studio photograph">
                    <img src="/Content/home/products/onyx-mouse.png?v=20260603-studio" alt="ONYX black and silver gaming mouse studio photograph" />
                    <div class="onyx-about-award">
                        <span>Design direction</span>
                        <strong>Competition-grade hardware with a studio finish.</strong>
                    </div>
                </aside>
            </div>
        </section>

        <section class="onyx-about-section onyx-about-manifesto">
            <div class="onyx-about-wrap">
                <p class="onyx-about-eyebrow">Manifesto</p>
                <h2>Precision should feel inevitable.</h2>
                <p>
                    We design peripherals like instruments: quiet in the hand, exact in motion, and durable enough for daily training. ONYX is minimal by sight, aggressive by engineering, and obsessed with the details that disappear when you are locked in.
                </p>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-wrap">
                <p class="onyx-about-eyebrow">What we obsess over</p>
                <div class="onyx-about-craft">
                    <article data-index="01">
                        <h3>Latency feel</h3>
                        <p>Clicks, scrolls, and keypresses are tuned around response confidence, not spec-sheet noise.</p>
                    </article>
                    <article data-index="02">
                        <h3>Surface control</h3>
                        <p>Matte shells, brushed rails, and shaped contact zones keep grip predictable through long sessions.</p>
                    </article>
                    <article data-index="03">
                        <h3>Weight balance</h3>
                        <p>We trim mass where it distracts and keep structure where it protects aim, typing, and audio comfort.</p>
                    </article>
                    <article data-index="04">
                        <h3>Visual restraint</h3>
                        <p>ONYX hardware uses black, silver, and white light because focus should belong to the match.</p>
                    </article>
                </div>

                <div class="onyx-about-wide-shot">
                    <img src="/Content/home/products/onyx-keyboard.png?v=20260603-studio" alt="ONYX mechanical keyboard studio photograph" />
                    <div class="onyx-about-wide-copy">
                        <p class="onyx-about-eyebrow">Studio standard</p>
                        <h2>Made to look calm. Built to play fast.</h2>
                        <p>
                            The design language is deliberately reduced: fewer colors, sharper silhouettes, and materials that catch light like a blade. The result is gear that belongs on a championship desk without shouting over the player.
                        </p>
                    </div>
                </div>

                <div class="onyx-about-stats" aria-label="ONYX performance statistics">
                    <div class="onyx-about-stat">
                        <strong>1ms</strong>
                        <span>Response target</span>
                    </div>
                    <div class="onyx-about-stat">
                        <strong>49g</strong>
                        <span>Mouse concept weight</span>
                    </div>
                    <div class="onyx-about-stat">
                        <strong>30K</strong>
                        <span>Sensor class</span>
                    </div>
                    <div class="onyx-about-stat">
                        <strong>50h</strong>
                        <span>Battery ambition</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-wrap">
                <p class="onyx-about-eyebrow">How ONYX moves</p>
                <div class="onyx-about-timeline">
                    <div class="onyx-about-timeline-row">
                        <span>01</span>
                        <strong>Prototype in silence</strong>
                        <p>We start with hand feel, balance, switch force, and material contrast before visual polish enters the room.</p>
                    </div>
                    <div class="onyx-about-timeline-row">
                        <span>02</span>
                        <strong>Pressure test the details</strong>
                        <p>Every shape is judged against repeated flicks, rapid strafes, late-night typing, and hours of voice comms.</p>
                    </div>
                    <div class="onyx-about-timeline-row">
                        <span>03</span>
                        <strong>Finish like a campaign</strong>
                        <p>The final hardware needs to survive the desk, the travel bag, and the close-up shot.</p>
                    </div>
                </div>
            </div>
        </section>

        <section class="onyx-about-section">
            <div class="onyx-about-wrap">
                <div class="onyx-about-cta">
                    <div>
                        <p class="onyx-about-eyebrow">Next drop</p>
                        <h2>Step into the silver standard.</h2>
                        <p>Explore the current ONYX lineup and build a setup that feels quiet, exact, and ready for the last round.</p>
                    </div>
                    <a class="onyx-about-pill hover-trigger" href="/customer_page/Home.aspx">Shop ONYX <span>+</span></a>
                </div>
            </div>
        </section>
    </main>
</asp:Content>
