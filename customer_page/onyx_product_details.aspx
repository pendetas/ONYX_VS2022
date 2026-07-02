<%@ Page Title="Product Details" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_product_details.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_product_details" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-commerce.css") %>" />

</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="onyx-details-page">
        <div class="onyx-details-shell">
            <div class="row align-items-center">
                
                <!-- Left Side: Product Image Stage -->
                <div class="col-lg-6 mb-5 mb-lg-0">
                    <div class="onyx-image-stage">
                        <asp:Image ID="imgProduct" runat="server" />
                    </div>
                </div>

                <!-- Right Side: Details & Purchasing -->
                <div class="col-lg-5 offset-lg-1">
                    <p class="text-secondary text-uppercase fw-bold mb-2" style="font-size: 10px; letter-spacing: 0.2em;">
                        <asp:Literal ID="litBrandCategory" runat="server" />
                    </p>
                    
                    <h1 class="onyx-product-title mb-3"><asp:Literal ID="litName" runat="server" /></h1>
                    
                    <div class="onyx-product-price mb-4">
                        <asp:Literal ID="litPrice" runat="server" />
                    </div>

                    <asp:Literal ID="litStockStatus" runat="server" />

                    <p class="text-secondary mb-5" style="font-size: 16px; line-height: 1.6;">
                        <asp:Literal ID="litDescription" runat="server" />
                    </p>
                    
                    
                    <!-- Variants Dropdown (Hidden if no variants exist) -->
                    <asp:Panel ID="pnlVariants" runat="server" Visible="false" CssClass="mb-4">
                                                    <label class="text-secondary fw-bold text-uppercase mb-3 d-block" style="font-size: 11px; letter-spacing: 0.1em;">
                                                        <asp:Literal ID="litVariantType" runat="server" Text="Color" />: 
                                                        <asp:Label ID="lblSelectedVariantName" runat="server" CssClass="text-white ms-2"></asp:Label>
                                                    </label>
                                
                                                    <div class="onyx-variants-flex">
                                                        <asp:Repeater ID="rptVariants" runat="server" OnItemCommand="rptVariants_ItemCommand">
                                                            <ItemTemplate>
                                                                <asp:LinkButton ID="btnSwatch" runat="server" 
                                                                    CommandName="SelectVariant" 
                                                                    CommandArgument='<%# Eval("ProductVariantId") %>'
                                                                    CssClass='<%# GetSwatchClass(Eval("ProductVariantId")) %>'
                                                                    ToolTip='<%# Eval("VariantValue") %>'
                                                                    Style='<%# "background-color: " + GetColorHex(Eval("VariantValue").ToString()) + ";" %>'>
                                                                </asp:LinkButton>
                                                            </ItemTemplate>
                                                        </asp:Repeater>
                                                    </div>
                                                </asp:Panel>

                    <!-- Add to Cart Actions -->
                    <div class="d-flex gap-3 mt-5">
                        <asp:TextBox ID="txtQty" runat="server" TextMode="Number" Text="1" min="1" CssClass="onyx-qty-input"></asp:TextBox>
                        <asp:Button ID="btnAddToCart" runat="server" Text="Add to Cart" CssClass="onyx-add-to-cart flex-grow-1" OnClick="btnAddToCart_Click" />
                        <asp:LinkButton ID="btnWishlist" runat="server" CssClass="onyx-detail-wishlist" OnClick="btnWishlist_Click" ToolTip="Add to wishlist">
                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M20.8 4.6c-1.8-1.7-4.7-1.7-6.5 0L12 6.8 9.7 4.6c-1.8-1.7-4.7-1.7-6.5 0-1.9 1.8-1.9 4.7 0 6.5l8.8 8.4 8.8-8.4c1.9-1.8 1.9-4.7 0-6.5z" />
                            </svg>
                            <span>Save</span>
                        </asp:LinkButton>
                    </div>
                    
                    <!-- Success/Error Message -->
                    <asp:Label ID="lblMessage" runat="server" CssClass="d-block mt-3 fw-bold" Visible="false"></asp:Label>

                    <!-- NEW: Tech Specs section to fill the empty space and look professional -->
                    <div class="onyx-specs-list">
                        <h4 class="text-uppercase fw-bold text-white mb-4" style="font-size: 12px; letter-spacing: 0.1em;">Technical Highlights</h4>
                        <div class="onyx-spec-item">
                            <span class="text-secondary">Build Quality</span>
                            <span class="text-white fw-bold">Premium Grade</span>
                        </div>
                        <div class="onyx-spec-item">
                            <span class="text-secondary">Warranty</span>
                            <span class="text-white fw-bold">2-Year Limited</span>
                        </div>
                        <div class="onyx-spec-item">
                            <span class="text-secondary">Shipping</span>
                            <span class="text-white fw-bold">Free over RM 200</span>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </section>
</asp:Content>
