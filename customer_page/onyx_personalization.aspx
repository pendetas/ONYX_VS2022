<%@ Page Title="Personalization" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_personalization.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_personalization" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-personalization.css") %>" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-personalization-page" aria-labelledby="onyxPersonalizationTitle">
        <div class="onyx-personalization-shell">
            <header class="onyx-personalization-hero">
                <p class="onyx-personalization-kicker">Mandatory Setup Profile</p>
                <h1 id="onyxPersonalizationTitle">Build Your ONYX Setup</h1>
                <p class="onyx-personalization-lede">
                    Answer a few setup questions before you enter ONYX. This profile helps tailor your first customer experience without changing your account details.
                </p>
            </header>

            <div class="onyx-personalization-layout">
                <aside class="onyx-personalization-summary" aria-label="Setup profile guidance">
                    <div class="onyx-personalization-summary-block">
                        <span>01</span>
                        <h2>Focused onboarding</h2>
                        <p>Choose the gaming style, gear interests, priorities, budget, and setup goal you want ONYX to remember.</p>
                    </div>
                    <div class="onyx-personalization-summary-block">
                        <span>02</span>
                        <h2>Monochrome by design</h2>
                        <p>Everything here stays aligned with the ONYX black, charcoal, graphite, and silver visual system.</p>
                    </div>
                </aside>

                <div class="onyx-personalization-main">
                    <asp:HiddenField ID="GamingStyleField" runat="server" />
                    <asp:HiddenField ID="PreferredCategoriesField" runat="server" />
                    <asp:HiddenField ID="PrioritiesField" runat="server" />
                    <asp:HiddenField ID="BudgetRangeField" runat="server" />
                    <asp:HiddenField ID="SetupGoalField" runat="server" />

                    <section class="onyx-personalization-group" aria-labelledby="gaming-style-title">
                        <div class="onyx-personalization-group-head">
                            <p>01 / Gaming Style</p>
                            <h2 id="gaming-style-title">What defines your main play style?</h2>
                        </div>
                        <div class="onyx-personalization-choices">
                            <button type="button" class="onyx-choice" data-target="gaming_style" data-value="FPS">FPS</button>
                            <button type="button" class="onyx-choice" data-target="gaming_style" data-value="MOBA">MOBA</button>
                            <button type="button" class="onyx-choice" data-target="gaming_style" data-value="RPG">RPG</button>
                            <button type="button" class="onyx-choice" data-target="gaming_style" data-value="Racing">Racing</button>
                            <button type="button" class="onyx-choice" data-target="gaming_style" data-value="Casual">Casual</button>
                            <button type="button" class="onyx-choice" data-target="gaming_style" data-value="Creator">Creator</button>
                        </div>
                    </section>

                    <section class="onyx-personalization-group" aria-labelledby="preferred-categories-title">
                        <div class="onyx-personalization-group-head">
                            <p>02 / Preferred Categories</p>
                            <h2 id="preferred-categories-title">Which gear categories matter most right now?</h2>
                        </div>
                        <div class="onyx-personalization-choices">
                            <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Mouse">Mouse</button>
                            <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Keyboard">Keyboard</button>
                            <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Headset">Headset</button>
                            <button type="button" class="onyx-choice" data-target="preferred_categories" data-multi="true" data-value="Accessory">Accessory</button>
                        </div>
                    </section>

                    <section class="onyx-personalization-group" aria-labelledby="priorities-title">
                        <div class="onyx-personalization-group-head">
                            <p>03 / Priorities</p>
                            <h2 id="priorities-title">What do you care about most in your next setup?</h2>
                        </div>
                        <div class="onyx-personalization-choices">
                            <button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="Speed">Speed</button>
                            <button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="Comfort">Comfort</button>
                            <button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="Wireless">Wireless</button>
                            <button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="Budget">Budget</button>
                            <button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="RGB">RGB</button>
                            <button type="button" class="onyx-choice" data-target="priorities" data-multi="true" data-value="Premium Build">Premium Build</button>
                        </div>
                    </section>

                    <section class="onyx-personalization-group" aria-labelledby="budget-range-title">
                        <div class="onyx-personalization-group-head">
                            <p>04 / Budget Range</p>
                            <h2 id="budget-range-title">Where does your purchase range sit?</h2>
                        </div>
                        <div class="onyx-personalization-choices">
                            <button type="button" class="onyx-choice" data-target="budget_range" data-value="Entry">Entry</button>
                            <button type="button" class="onyx-choice" data-target="budget_range" data-value="Mid-range">Mid-range</button>
                            <button type="button" class="onyx-choice" data-target="budget_range" data-value="Premium">Premium</button>
                        </div>
                    </section>

                    <section class="onyx-personalization-group" aria-labelledby="setup-goal-title">
                        <div class="onyx-personalization-group-head">
                            <p>05 / Setup Goal</p>
                            <h2 id="setup-goal-title">What kind of setup are you building?</h2>
                        </div>
                        <div class="onyx-personalization-choices">
                            <button type="button" class="onyx-choice" data-target="setup_goal" data-value="Competitive">Competitive</button>
                            <button type="button" class="onyx-choice" data-target="setup_goal" data-value="Streaming">Streaming</button>
                            <button type="button" class="onyx-choice" data-target="setup_goal" data-value="Work and Gaming">Work and Gaming</button>
                            <button type="button" class="onyx-choice" data-target="setup_goal" data-value="Everyday Gaming">Everyday Gaming</button>
                        </div>
                    </section>

                    <div class="onyx-personalization-actions">
                        <asp:Button ID="BuildSetupButton" runat="server" Text="Build My Setup" CssClass="onyx-personalization-submit" OnClick="BuildSetupButton_Click" />
                        <asp:Label ID="FeedbackLabel" runat="server" CssClass="onyx-personalization-feedback" Visible="false" role="status" aria-live="polite" />
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        (function () {
            var fields = {
                gaming_style: '<%= GamingStyleField.ClientID %>',
                preferred_categories: '<%= PreferredCategoriesField.ClientID %>',
                priorities: '<%= PrioritiesField.ClientID %>',
                budget_range: '<%= BudgetRangeField.ClientID %>',
                setup_goal: '<%= SetupGoalField.ClientID %>'
            };

            function sync(target) {
                var selected = Array.prototype.slice.call(document.querySelectorAll('[data-target="' + target + '"].is-selected'))
                    .map(function (button) { return button.getAttribute('data-value'); });
                document.getElementById(fields[target]).value = selected.join(',');
            }

            Array.prototype.forEach.call(document.querySelectorAll('.onyx-choice'), function (button) {
                button.addEventListener('click', function () {
                    var target = button.getAttribute('data-target');
                    var multi = button.getAttribute('data-multi') === 'true';
                    if (!multi) {
                        Array.prototype.forEach.call(document.querySelectorAll('[data-target="' + target + '"]'), function (peer) {
                            peer.classList.remove('is-selected');
                        });
                    }
                    button.classList.toggle('is-selected');
                    sync(target);
                });
            });
        })();
    </script>
</asp:Content>
