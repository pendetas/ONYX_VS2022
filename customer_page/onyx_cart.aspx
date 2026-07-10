<%@ Page Title="Your Cart" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_cart.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_cart" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-commerce.css") %>" />

</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-cart-page">
        <div class="onyx-cart-shell">
            <h1 class="onyx-cart-title">Your Cart</h1>

            <!-- Empty Cart State -->
            <asp:Panel ID="pnlEmptyCart" runat="server" Visible="false" CssClass="empty-cart-box">
                <h3 class="text-secondary font-syne text-2xl mb-4">Your cart is currently empty.</h3>
                <a href="onyx_catalog.aspx" class="onyx-checkout-btn" style="background: #ffffff;">Return to Catalog</a>
            </asp:Panel>

            <!-- Populated Cart State -->
            <asp:Panel ID="pnlCart" runat="server">
                <table class="w-full text-left border-collapse onyx-cart-table">
                    <thead>
                        <tr>
                            <th class="w-1/2">Product</th>
                            <th class="hidden md:table-cell">Price</th>
                            <th>Quantity</th>
                            <th class="text-right">Subtotal</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptCartItems" runat="server" OnItemCommand="rptCartItems_ItemCommand">
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center flex-row flex">
                                            <div class="onyx-cart-image flex-shrink-0">
                                                <!-- Updated to use the new C# fallback method -->
                                                <img src='<%# GetImageUrl(Eval("ImageUrl")) %>' alt='<%# Eval("ProductName") %>' />
                                            </div>
                                            <div>
                                                <div class="font-syne font-bold text-lg uppercase"><%# Eval("ProductName") %></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="hidden md:table-cell text-secondary">
                                        <%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("Price")) %>
                                    </td>
                                    <td class="font-bold">
                                        x<%# Eval("Quantity") %>
                                    </td>
                                    <td class="text-right font-bold text-lg">
                                        <%# ONYX_DDAC.Helpers.CurrencyHelper.FormatMyr((decimal)Eval("Subtotal")) %>
                                    </td>
                                    <td class="text-right pl-4">
                                        <!-- Combines ProductId and VariantId so the backend knows exactly what to delete -->
                                        <asp:LinkButton ID="btnRemove" runat="server" 
                                            CommandName="Remove" 
                                            CommandArgument='<%# Eval("ProductId") + "|" + Eval("VariantId") %>' 
                                            CssClass="onyx-remove-btn">
                                            Remove
                                        </asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>

                <!-- Cart Footer / Summary -->
                <div class="mt-12 flex flex-col md:flex-row justify-between items-end border-t border-white/10 pt-8">
                    <div class="text-secondary text-sm mb-6 md:mb-0">
                        Shipping and taxes calculated at checkout.
                    </div>
                    <div class="text-right">
                        <p class="text-secondary uppercase tracking-widest text-xs font-bold mb-2">Estimated Total</p>
                        <h2 class="font-syne font-bold text-4xl md:text-5xl mb-6">
                            <asp:Literal ID="litGrandTotal" runat="server"></asp:Literal>
                        </h2>
                        <asp:Button ID="btnCheckout" runat="server" Text="Proceed to Checkout" CssClass="onyx-checkout-btn" OnClick="btnCheckout_Click" />
                    </div>
                </div>
            </asp:Panel>

        </div>
    </section>
</asp:Content>
