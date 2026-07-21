<%@ Page Title="Checkout" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_checkout.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_checkout" %>
<%@ Import Namespace="ONYX_DDAC.Helpers" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-commerce.css") %>" />
</asp:Content>

<asp:Content ID="CheckoutContent" ContentPlaceHolderID="MainContent" runat="server">


    <section class="onyx-checkout-page">
        <div class="onyx-checkout-shell">
            <h1 class="onyx-checkout-title">Checkout</h1>

            <asp:Panel ID="pnlEmptyCheckout" runat="server" Visible="false" CssClass="onyx-checkout-panel">
                <h2>Your cart is empty</h2>
                <a href="onyx_catalog.aspx" class="onyx-pay-btn" style="display: inline-block; max-width: 240px; text-align: center;">Return to Catalog</a>
            </asp:Panel>

            <asp:Panel ID="pnlCheckout" runat="server" Visible="false" CssClass="onyx-checkout-grid">
                <div class="onyx-checkout-panel">
                    <h2>Selected Products</h2>
                    <asp:Repeater ID="rptCheckoutItems" runat="server">
                        <ItemTemplate>
                            <div class="onyx-checkout-item">
                                <img src='<%# GetSafeImageUrl(Eval("ImageUrl")) %>' alt='<%# EncodeProductName(Eval("ProductName")) %>' />
                                <div>
                                    <div class="onyx-checkout-name"><%# EncodeProductName(Eval("ProductName")) %></div>
                                    <div class="onyx-checkout-meta">Qty <%# Eval("Quantity") %> x <%# CurrencyHelper.FormatMyr((decimal)Eval("Price")) %></div>
                                </div>
                                <strong><%# CurrencyHelper.FormatMyr((decimal)Eval("Subtotal")) %></strong>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="onyx-checkout-panel">
                    <h2>Delivery & Payment</h2>

                    <div class="onyx-checkout-field">
                        <label for="<%= ddlDeliveryMethod.ClientID %>">Delivery Method</label>
                        <asp:DropDownList ID="ddlDeliveryMethod" runat="server" CssClass="onyx-checkout-input">
                            <asp:ListItem Text="Standard Delivery" Value="Standard Delivery" />
                            <asp:ListItem Text="Express Delivery" Value="Express Delivery" />
                            <asp:ListItem Text="Self Pickup" Value="Self Pickup" />
                        </asp:DropDownList>
                    </div>

                    <div class="onyx-checkout-field">
                        <label for="<%= txtShippingAddress.ClientID %>">Shipping Address</label>
                        <asp:TextBox ID="txtShippingAddress" runat="server" TextMode="MultiLine" Rows="4" CssClass="onyx-checkout-input" />
                    </div>

                    <div class="onyx-voucher-entry">
                        <label for="<%= txtVoucherCode.ClientID %>">Voucher Code</label>
                        <div class="onyx-voucher-entry__row">
                            <asp:TextBox ID="txtVoucherCode" runat="server" MaxLength="40" CssClass="onyx-checkout-input onyx-voucher-entry__input" />
                            <asp:Button ID="btnApplyVoucher" runat="server" Text="Apply" OnClick="btnApplyVoucher_Click" CssClass="onyx-voucher-apply" />
                        </div>
                        <asp:Label ID="lblVoucherMessage" runat="server" Visible="false" CssClass="onyx-checkout-message onyx-checkout-message--voucher" />
                    </div>

                    <asp:Panel ID="pnlAppliedVoucher" runat="server" Visible="false" CssClass="onyx-voucher-applied">
                        <div class="onyx-voucher-applied__meta">
                            <strong><asp:Literal ID="litVoucherName" runat="server" /></strong>
                            <span>Code <asp:Literal ID="litVoucherCode" runat="server" /></span>
                        </div>
                        <div class="onyx-voucher-applied__actions">
                            <button type="button" class="onyx-voucher-terms-link" data-voucher-terms-open>T&amp;C apply</button>
                            <asp:LinkButton ID="btnRemoveVoucher" runat="server" Text="Remove" OnClick="btnRemoveVoucher_Click" CssClass="onyx-voucher-remove" />
                        </div>
                    </asp:Panel>

                    <div class="onyx-checkout-totals">
                        <div class="onyx-checkout-totals__row">
                            <span>Subtotal</span>
                            <asp:Literal ID="litCheckoutSubtotal" runat="server" />
                        </div>

                        <asp:Panel ID="pnlVoucherDiscount" runat="server" Visible="false" CssClass="onyx-checkout-totals__row onyx-checkout-totals__row--discount">
                            <span>Voucher Discount</span>
                            <strong>-<asp:Literal ID="litVoucherDiscount" runat="server" /></strong>
                        </asp:Panel>

                        <div class="onyx-checkout-total">
                            <span>Total</span>
                            <asp:Literal ID="litCheckoutTotal" runat="server" />
                        </div>
                    </div>

                    <div id="voucherTermsModal" class="onyx-voucher-modal" hidden role="dialog" aria-modal="true" aria-labelledby="voucherTermsTitle">
                        <div class="onyx-voucher-modal__panel">
                            <button type="button" class="onyx-voucher-modal__close" data-voucher-terms-close aria-label="Close voucher terms">&times;</button>
                            <h2 id="voucherTermsTitle">Voucher Terms</h2>
                            <div class="onyx-voucher-terms">
                                <asp:Literal ID="litVoucherTerms" runat="server" />
                            </div>
                        </div>
                    </div>

                    <div class="onyx-stripe-checkout-note">
                        <strong>Secure Stripe Checkout</strong>
                        <span>Stripe will show the eligible payment methods enabled for ONYX test mode. Delivery is free.</span>
                    </div>

                    <asp:Button
                        ID="btnPayWithStripe"
                        runat="server"
                        Text="Pay With Stripe"
                        CssClass="onyx-pay-btn"
                        OnClientClick="var button=this; button.value='Redirecting...'; setTimeout(function(){ button.disabled=true; }, 0);"
                        OnClick="btnPayWithStripe_Click" />
                    <asp:Label ID="lblCheckoutMessage" runat="server" Visible="false" CssClass="onyx-checkout-message" />
                </div>
            </asp:Panel>
        </div>
    </section>

    <script type="text/javascript">
        (function () {
            var modal = document.getElementById('voucherTermsModal');
            if (!modal) return;

            var opener = document.querySelector('[data-voucher-terms-open]');
            var closer = modal.querySelector('[data-voucher-terms-close]');
            var previousFocus = null;

            function getFocusableElements() {
                return modal.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
            }

            function openTerms() {
                previousFocus = document.activeElement;
                modal.hidden = false;
                document.body.classList.add('voucher-modal-open');
                if (closer) {
                    closer.focus();
                }
            }

            function closeTerms() {
                modal.hidden = true;
                document.body.classList.remove('voucher-modal-open');
                if (previousFocus && previousFocus.focus) {
                    previousFocus.focus();
                }
            }

            if (opener) {
                opener.addEventListener('click', function (event) {
                    event.preventDefault();
                    openTerms();
                });
            }

            if (closer) {
                closer.addEventListener('click', function (event) {
                    event.preventDefault();
                    closeTerms();
                });
            }

            modal.addEventListener('click', function (event) {
                if (event.target === modal) {
                    closeTerms();
                }
            });

            document.addEventListener('keydown', function (event) {
                if (modal.hidden) return;

                if (event.key === 'Escape') {
                    event.preventDefault();
                    closeTerms();
                    return;
                }

                if (event.key !== 'Tab') return;

                var focusable = getFocusableElements();
                if (!focusable.length) return;

                var first = focusable[0];
                var last = focusable[focusable.length - 1];

                if (event.shiftKey && document.activeElement === first) {
                    event.preventDefault();
                    last.focus();
                } else if (!event.shiftKey && document.activeElement === last) {
                    event.preventDefault();
                    first.focus();
                }
            });
        }());
    </script>
</asp:Content>
