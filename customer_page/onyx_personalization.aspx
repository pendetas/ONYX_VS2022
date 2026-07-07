<%@ Page Title="Personalization" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_personalization.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_personalization" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-personalization.css?v=20260707-stepper-css-1") %>" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .onyx-personalization-shell-page .onyx-ddac-nav,
        .onyx-personalization-shell-page .onyx-ddac-nav.is-scrolled,
        .onyx-personalization-shell-page .onyx-master-footer,
        .onyx-personalization-step[hidden],
        .onyx-personalization-submit[hidden],
        #onyxPersonalizationNext[hidden] {
            display: none !important;
        }

        .onyx-personalization-page .onyx-choice {
            background: #050505 !important;
            border-color: #25262a !important;
            color: #f8f8f8 !important;
            box-shadow: none !important;
        }

        .onyx-personalization-page .onyx-choice:hover,
        .onyx-personalization-page .onyx-choice:focus,
        .onyx-personalization-page .onyx-choice:focus-visible {
            background: #0d0d0e !important;
            border-color: #f8f8f8 !important;
            color: #fff !important;
            outline: none !important;
            box-shadow: none !important;
        }

        .onyx-personalization-page .onyx-choice.is-selected,
        .onyx-personalization-page .onyx-choice[aria-pressed="true"] {
            background: #171717 !important;
            border-color: #f8f8f8 !important;
            color: #fff !important;
        }

        .onyx-personalization-page .onyx-personalization-back,
        .onyx-personalization-page .onyx-personalization-back:hover,
        .onyx-personalization-page .onyx-personalization-back:focus,
        .onyx-personalization-page .onyx-personalization-back:focus-visible,
        .onyx-personalization-page .onyx-personalization-back:active,
        .onyx-personalization-page .onyx-personalization-next,
        .onyx-personalization-page .onyx-personalization-next:hover,
        .onyx-personalization-page .onyx-personalization-next:focus,
        .onyx-personalization-page .onyx-personalization-next:focus-visible,
        .onyx-personalization-page .onyx-personalization-next:active,
        .onyx-personalization-page input.onyx-personalization-submit,
        .onyx-personalization-page .onyx-personalization-submit {
            background: #f8f8f8 !important;
            border-color: #f8f8f8 !important;
            color: #050505 !important;
            box-shadow: none !important;
            outline: none !important;
        }

        .onyx-personalization-page input.onyx-personalization-submit:hover,
        .onyx-personalization-page input.onyx-personalization-submit:focus,
        .onyx-personalization-page input.onyx-personalization-submit:focus-visible,
        .onyx-personalization-page input.onyx-personalization-submit:active,
        .onyx-personalization-page .onyx-personalization-submit:hover,
        .onyx-personalization-page .onyx-personalization-submit:focus,
        .onyx-personalization-page .onyx-personalization-submit:focus-visible,
        .onyx-personalization-page .onyx-personalization-submit:active {
            background: #f8f8f8 !important;
            border-color: #f8f8f8 !important;
            color: #050505 !important;
            outline: none !important;
        }

        .onyx-personalization-page .onyx-personalization-back:disabled,
        .onyx-personalization-page .onyx-personalization-next:disabled {
            background: #f8f8f8 !important;
            border-color: #f8f8f8 !important;
            color: #050505 !important;
            opacity: 0.44 !important;
        }
    </style>

    <script>
        (function () {
            var nav = document.getElementById('onyx-main-nav');
            var footer = document.querySelector('.onyx-master-footer');
            if (nav) {
                nav.style.display = 'none';
            }
            if (footer) {
                footer.style.display = 'none';
            }
        })();
    </script>

    <section class="onyx-personalization-page" aria-labelledby="onyxPersonalizationTitle">
        <div class="onyx-personalization-frame is-intro" id="onyxPersonalizationFrame">
            <span class="onyx-personalization-sr">Build Your ONYX Setup</span>

            <div class="onyx-personalization-intro" id="onyxPersonalizationIntro" aria-live="polite">
                <p class="onyx-personalization-intro-kicker">ONYX setup profile</p>
                <h1 class="onyx-personalization-intro-title" data-split-text>Welcome to ONYX.</h1>
                <p class="onyx-personalization-intro-subtitle">Let us customize your preferences.</p>
            </div>

            <header class="onyx-personalization-progress" aria-label="Personalization progress">
                <div class="onyx-personalization-progress-copy">
                    <span id="onyxPersonalizationStepLabel">STEP 1 OF 8</span>
                    <strong id="onyxPersonalizationPercent">13%</strong>
                </div>
                <div class="onyx-personalization-progress-track" aria-hidden="true">
                    <span id="onyxPersonalizationProgressFill"></span>
                </div>
            </header>

            <asp:HiddenField ID="GamingStyleField" runat="server" />
            <asp:HiddenField ID="PreferredCategoriesField" runat="server" />
            <asp:HiddenField ID="PrioritiesField" runat="server" />
            <asp:HiddenField ID="BudgetRangeField" runat="server" />
            <asp:HiddenField ID="SetupGoalField" runat="server" />
            <asp:HiddenField ID="ComfortPreferencesField" runat="server" />
            <asp:HiddenField ID="PerformancePreferencesField" runat="server" />
            <asp:HiddenField ID="SetupConstraintsField" runat="server" />

            <div class="onyx-personalization-stage" data-step-count="8">
                <article class="onyx-personalization-step is-active" data-step-index="0" data-target="gaming_style" aria-labelledby="onyxPersonalizationTitle">
                    <p class="onyx-personalization-kicker">01 / Play style</p>
                    <h1 id="onyxPersonalizationTitle">What defines your main play style?</h1>
                    <p class="onyx-personalization-prompt">Choose the mode that should guide your first ONYX recommendations.</p>

                    <div class="onyx-personalization-choices">
                        <button type="button" class="onyx-choice" data-target="gaming_style" data-value="FPS" data-multi="true" aria-pressed="false"><span>FPS</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="gaming_style" data-value="MOBA" data-multi="true" aria-pressed="false"><span>MOBA</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="gaming_style" data-value="RPG" data-multi="true" aria-pressed="false"><span>RPG</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="gaming_style" data-value="Racing" data-multi="true" aria-pressed="false"><span>Racing</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="gaming_style" data-value="Casual" data-multi="true" aria-pressed="false"><span>Casual</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="gaming_style" data-value="Creator" data-multi="true" aria-pressed="false"><span>Creator</span><i aria-hidden="true"></i></button>
                    </div>
                </article>

                <article class="onyx-personalization-step" data-step-index="1" data-target="preferred_categories" aria-labelledby="preferred-categories-title" hidden>
                    <p class="onyx-personalization-kicker">02 / Gear focus</p>
                    <h1 id="preferred-categories-title">Which gear should ONYX tune first?</h1>
                    <p class="onyx-personalization-prompt">Pick one or more categories. If you love small mice, start with Mouse.</p>

                    <div class="onyx-personalization-choices">
                        <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Mouse" aria-pressed="false"><span>Mouse</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Keyboard" aria-pressed="false"><span>Keyboard</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Headset" aria-pressed="false"><span>Headset</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Accessory" aria-pressed="false"><span>Accessory</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Monitor" aria-pressed="false"><span>Monitor</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Mic" aria-pressed="false"><span>Mic</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Mousepad" aria-pressed="false"><span>Mousepad</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Cable" aria-pressed="false"><span>Cable</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Monitor Extension" aria-pressed="false"><span>Monitor Extension</span><i aria-hidden="true"></i></button>
                    </div>
                </article>

                <article class="onyx-personalization-step" data-step-index="2" data-target="priorities" aria-labelledby="priorities-title" hidden>
                    <p class="onyx-personalization-kicker">03 / Buying priority</p>
                    <h1 id="priorities-title">What matters most in the next upgrade?</h1>
                    <p class="onyx-personalization-prompt">Select every signal that should affect the product score.</p>

                    <div class="onyx-personalization-choices">
                        <button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="Speed" aria-pressed="false"><span>Speed</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="Comfort" aria-pressed="false"><span>Comfort</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="Wireless" aria-pressed="false"><span>Wireless</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="Budget" aria-pressed="false"><span>Budget</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="RGB" aria-pressed="false"><span>RGB</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="Premium Build" aria-pressed="false"><span>Premium Build</span><i aria-hidden="true"></i></button>
                    </div>
                </article>

                <article class="onyx-personalization-step" data-step-index="3" data-target="budget_range" aria-labelledby="budget-range-title" hidden>
                    <p class="onyx-personalization-kicker">04 / Budget range</p>
                    <h1 id="budget-range-title">Where should recommendations sit?</h1>
                    <p class="onyx-personalization-prompt">This keeps the first product strip realistic for your next purchase.</p>

                    <div class="onyx-personalization-choices onyx-personalization-choices-compact">
                        <button type="button" class="onyx-choice" data-target="budget_range" data-value="Entry" aria-pressed="false"><span>Entry</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="budget_range" data-value="Mid-range" aria-pressed="false"><span>Mid-range</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="budget_range" data-value="Premium" aria-pressed="false"><span>Premium</span><i aria-hidden="true"></i></button>
                    </div>
                </article>

                <article class="onyx-personalization-step" data-step-index="4" data-target="setup_goal" aria-labelledby="setup-goal-title" hidden>
                    <p class="onyx-personalization-kicker">05 / Setup goal</p>
                    <h1 id="setup-goal-title">What kind of setup are you building?</h1>
                    <p class="onyx-personalization-prompt">Your answer shapes how ONYX explains the products on home.</p>

                    <div class="onyx-personalization-choices">
                        <button type="button" class="onyx-choice" data-target="setup_goal" data-value="Competitive" aria-pressed="false"><span>Competitive</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="setup_goal" data-value="Streaming" aria-pressed="false"><span>Streaming</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="setup_goal" data-value="Work and Gaming" aria-pressed="false"><span>Work and Gaming</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="setup_goal" data-value="Everyday Gaming" aria-pressed="false"><span>Everyday Gaming</span><i aria-hidden="true"></i></button>
                    </div>
                </article>

                <article class="onyx-personalization-step" data-step-index="5" data-target="comfort_preferences" aria-labelledby="comfort-preferences-title" hidden>
                    <p class="onyx-personalization-kicker">06 / Comfort</p>
                    <h1 id="comfort-preferences-title">What matters most for your comfort?</h1>
                    <p class="onyx-personalization-prompt">Pick every comfort signal ONYX should respect in your recommendations.</p>
                    <div class="onyx-personalization-choices">
                        <button type="button" class="onyx-choice" data-target="comfort_preferences" data-multi="true" data-value="Lightweight gear" aria-pressed="false"><span>Lightweight gear</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="comfort_preferences" data-multi="true" data-value="Ergonomic shape" aria-pressed="false"><span>Ergonomic shape</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="comfort_preferences" data-multi="true" data-value="Soft ear cushions" aria-pressed="false"><span>Soft ear cushions</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="comfort_preferences" data-multi="true" data-value="Wrist support" aria-pressed="false"><span>Wrist support</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="comfort_preferences" data-multi="true" data-value="Adjustable size" aria-pressed="false"><span>Adjustable size</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="comfort_preferences" data-multi="true" data-value="Low noise" aria-pressed="false"><span>Low noise</span><i aria-hidden="true"></i></button>
                    </div>
                </article>

                <article class="onyx-personalization-step" data-step-index="6" data-target="performance_preferences" aria-labelledby="performance-preferences-title" hidden>
                    <p class="onyx-personalization-kicker">07 / Performance</p>
                    <h1 id="performance-preferences-title">What performance feature do you care about the most?</h1>
                    <p class="onyx-personalization-prompt">Pick the performance signals ONYX should score higher.</p>
                    <div class="onyx-personalization-choices">
                        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="Low latency" aria-pressed="false"><span>Low latency</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="High DPI" aria-pressed="false"><span>High DPI</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="Mechanical switches" aria-pressed="false"><span>Mechanical switches</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="Noise cancellation" aria-pressed="false"><span>Noise cancellation</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="High refresh rate" aria-pressed="false"><span>High refresh rate</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="Long battery life" aria-pressed="false"><span>Long battery life</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="performance_preferences" data-multi="true" data-value="Accurate tracking" aria-pressed="false"><span>Accurate tracking</span><i aria-hidden="true"></i></button>
                    </div>
                </article>

                <article class="onyx-personalization-step" data-step-index="7" data-target="setup_constraints" aria-labelledby="setup-constraints-title" hidden>
                    <p class="onyx-personalization-kicker">08 / Setup constraint</p>
                    <h1 id="setup-constraints-title">What setup constraint should ONYX respect?</h1>
                    <p class="onyx-personalization-prompt">These details help ONYX avoid awkward recommendations.</p>
                    <div class="onyx-personalization-choices">
                        <button type="button" class="onyx-choice" data-target="setup_constraints" data-multi="true" data-value="Small hands" aria-pressed="false"><span>Small hands</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="setup_constraints" data-multi="true" data-value="Compact desk" aria-pressed="false"><span>Compact desk</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="setup_constraints" data-multi="true" data-value="Long sessions" aria-pressed="false"><span>Long sessions</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="setup_constraints" data-multi="true" data-value="Shared room" aria-pressed="false"><span>Shared room</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="setup_constraints" data-multi="true" data-value="Streaming setup" aria-pressed="false"><span>Streaming setup</span><i aria-hidden="true"></i></button>
                        <button type="button" class="onyx-choice" data-target="setup_constraints" data-multi="true" data-value="Minimal desk" aria-pressed="false"><span>Minimal desk</span><i aria-hidden="true"></i></button>
                    </div>
                </article>
            </div>

            <p id="onyxPersonalizationClientFeedback" class="onyx-personalization-client-feedback" role="status" aria-live="polite"></p>

            <footer class="onyx-personalization-actions">
                <button id="onyxPersonalizationBack" type="button" class="onyx-personalization-back" disabled>
                    <span aria-hidden="true"></span>
                    Back
                </button>
                <div class="onyx-personalization-primary-actions">
                    <button id="onyxPersonalizationNext" type="button" class="onyx-personalization-next" disabled>
                        Next
                        <span aria-hidden="true"></span>
                    </button>
                    <asp:Button ID="BuildSetupButton" runat="server" Text="Build My Setup" CssClass="onyx-personalization-submit" OnClientClick="return onyxPersonalizationBeforeSubmit();" OnClick="BuildSetupButton_Click" hidden="hidden" />
                </div>
            </footer>

            <asp:Label ID="FeedbackLabel" runat="server" CssClass="onyx-personalization-feedback" Visible="false" role="status" aria-live="polite" />
        </div>
    </section>

    <script>
        (function () {
            var fields = {
                gaming_style: '<%= GamingStyleField.ClientID %>',
                preferred_categories: '<%= PreferredCategoriesField.ClientID %>',
                priorities: '<%= PrioritiesField.ClientID %>',
                budget_range: '<%= BudgetRangeField.ClientID %>',
                setup_goal: '<%= SetupGoalField.ClientID %>',
                comfort_preferences: '<%= ComfortPreferencesField.ClientID %>',
                performance_preferences: '<%= PerformancePreferencesField.ClientID %>',
                setup_constraints: '<%= SetupConstraintsField.ClientID %>'
            };

            var steps = Array.prototype.slice.call(document.querySelectorAll('.onyx-personalization-step'));
            var currentStep = 0;
            var frame = document.getElementById('onyxPersonalizationFrame');
            var intro = document.getElementById('onyxPersonalizationIntro');
            var backButton = document.getElementById('onyxPersonalizationBack');
            var nextButton = document.getElementById('onyxPersonalizationNext');
            var submitButton = document.getElementById('<%= BuildSetupButton.ClientID %>');
            var stepLabel = document.getElementById('onyxPersonalizationStepLabel');
            var percentLabel = document.getElementById('onyxPersonalizationPercent');
            var progressFill = document.getElementById('onyxPersonalizationProgressFill');
            var clientFeedback = document.getElementById('onyxPersonalizationClientFeedback');
            var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

            function choicesFor(target) {
                return Array.prototype.slice.call(document.querySelectorAll('[data-target="' + target + '"].onyx-choice'));
            }

            function selectedValues(target) {
                return choicesFor(target)
                    .filter(function (button) { return button.classList.contains('is-selected'); })
                    .map(function (button) { return button.getAttribute('data-value'); });
            }

            function sync(target) {
                var field = document.getElementById(fields[target]);
                if (field) {
                    field.value = selectedValues(target).join(',');
                }
            }

            function stepHasAnswer(step) {
                return selectedValues(step.getAttribute('data-target')).length > 0;
            }

            function setFeedback(message) {
                if (clientFeedback) {
                    clientFeedback.textContent = message || '';
                }
            }

            function showStep(index) {
                currentStep = Math.max(0, Math.min(index, steps.length - 1));

                steps.forEach(function (step, stepIndex) {
                    var active = stepIndex === currentStep;
                    step.classList.toggle('is-active', active);
                    step.hidden = !active;
                    step.setAttribute('aria-hidden', active ? 'false' : 'true');
                });

                var progress = Math.round(((currentStep + 1) / steps.length) * 100);
                stepLabel.textContent = 'STEP ' + (currentStep + 1) + ' OF ' + steps.length;
                percentLabel.textContent = progress + '%';
                progressFill.style.width = progress + '%';

                backButton.disabled = currentStep === 0;
                nextButton.hidden = currentStep === steps.length - 1;
                nextButton.disabled = !stepHasAnswer(steps[currentStep]);
                submitButton.hidden = currentStep !== steps.length - 1;
                setFeedback('');
            }

            function splitText(element, baseDelay) {
                if (!element || element.getAttribute('data-split-ready') === 'true') {
                    return 0;
                }

                var text = element.textContent;
                element.textContent = '';
                element.setAttribute('data-split-ready', 'true');

                var visibleIndex = 0;
                var initialDelay = baseDelay || 0;
                Array.prototype.forEach.call(text.split(''), function (character) {
                    var span = document.createElement('span');
                    span.className = 'onyx-split-char';
                    span.textContent = character === ' ' ? '\u00a0' : character;
                    span.style.setProperty('--split-delay', (initialDelay + visibleIndex * 86) + 'ms');
                    element.appendChild(span);

                    if (character !== ' ') {
                        visibleIndex += 1;
                    }
                });

                return visibleIndex;
            }

            function startIntro() {
                var title = document.querySelector('.onyx-personalization-intro-title');
                var subtitle = document.querySelector('.onyx-personalization-intro-subtitle');
                var titleChars = splitText(title, 0);
                var subtitleDelay = titleChars * 86 + 520;
                var totalIntroTime = subtitleDelay + 1850;

                if (reduceMotion) {
                    revealQuestions();
                    return;
                }

                window.setTimeout(function () {
                    if (subtitle) {
                        subtitle.classList.add('is-visible');
                    }
                }, subtitleDelay);

                window.setTimeout(function () {
                    if (intro) {
                        intro.classList.add('is-leaving');
                    }
                }, Math.max(3400, totalIntroTime - 500));

                window.setTimeout(revealQuestions, Math.max(3900, totalIntroTime));
            }

            function revealQuestions() {
                if (frame) {
                    frame.classList.remove('is-intro');
                    frame.classList.add('is-ready');
                }

                if (intro) {
                    intro.hidden = true;
                }

                showStep(0);
            }

            Array.prototype.forEach.call(document.querySelectorAll('.onyx-choice'), function (button) {
                button.addEventListener('click', function () {
                    var target = button.getAttribute('data-target');
                    var multi = button.getAttribute('data-multi') === 'true';

                    if (multi) {
                        button.classList.toggle('is-selected');
                    } else {
                        choicesFor(target).forEach(function (peer) {
                            peer.classList.remove('is-selected');
                            peer.setAttribute('aria-pressed', 'false');
                        });
                        button.classList.add('is-selected');
                    }

                    button.setAttribute('aria-pressed', button.classList.contains('is-selected') ? 'true' : 'false');
                    button.classList.remove('is-pressing');
                    window.setTimeout(function () {
                        button.classList.add('is-pressing');
                    }, 0);
                    window.setTimeout(function () {
                        button.classList.remove('is-pressing');
                    }, 180);

                    sync(target);
                    nextButton.disabled = !stepHasAnswer(steps[currentStep]);
                    setFeedback('');
                });
            });

            backButton.addEventListener('click', function () {
                showStep(currentStep - 1);
            });

            nextButton.addEventListener('click', function () {
                if (!stepHasAnswer(steps[currentStep])) {
                    setFeedback('Choose an answer to continue.');
                    return;
                }

                showStep(currentStep + 1);
            });

            window.onyxPersonalizationBeforeSubmit = function () {
                var firstMissingIndex = -1;

                steps.forEach(function (step, index) {
                    sync(step.getAttribute('data-target'));
                    if (firstMissingIndex === -1 && !stepHasAnswer(step)) {
                        firstMissingIndex = index;
                    }
                });

                if (firstMissingIndex >= 0) {
                    showStep(firstMissingIndex);
                    setFeedback('Complete this answer before building your setup.');
                    return false;
                }

                return true;
            };

            showStep(0);
            startIntro();
        })();
    </script>
</asp:Content>
