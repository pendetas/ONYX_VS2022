<%@ Page Title="Product Details" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_product_details.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_product_details" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .onyx-details-page {
            background: #050505;
            color: #ffffff;
            min-height: 100vh;
            padding: 140px 32px 120px;
        }
        
        .onyx-details-shell {
            margin: 0 auto;
            max-width: 1200px; /* Tighter max-width to prevent massive spreading */
        }

        /* Fixed the image stage to be much more controlled */
        .onyx-image-stage {
            background: radial-gradient(circle at center, rgba(255,255,255,0.05), transparent 70%);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 20px;
            padding: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            aspect-ratio: 4/3; /* Forces a reasonable rectangle instead of stretching */
            max-height: 550px;
            overflow: hidden;
        }

        .onyx-image-stage img {
            max-width: 90%;
            max-height: 90%;
            object-fit: contain;
            filter: drop-shadow(0 20px 40px rgba(0,0,0,0.8));
            transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .onyx-image-stage:hover img {
            transform: scale(1.08);
        }

        .onyx-product-title {
            font-family: Syne, Inter, sans-serif;
            font-size: clamp(32px, 4vw, 48px); /* Slightly smaller so it doesn't wrap awkwardly */
            font-weight: 800;
            letter-spacing: -0.02em;
            line-height: 1;
            text-transform: uppercase;
        }

        .onyx-product-price {
            font-size: 24px;
            font-weight: 700;
            color: #ffffff;
        }

        .onyx-stock-status {
            color: #d8dde3;
            display: inline-block;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.08em;
            margin-bottom: 22px;
            text-transform: uppercase;
        }

        .onyx-stock-status.is-low {
            color: #facc15;
        }

        .onyx-stock-status.is-out {
            color: #ff4444;
        }

        /* Improved Variant Dropdown styling */
        .onyx-variant-select {
            background: #0a0a0a;
            color: white;
            border: 1px solid rgba(255,255,255,0.15);
            border-radius: 12px;
            padding: 14px 18px;
            width: 100%;
            font-size: 14px;
            font-weight: 600;
            appearance: none; /* Removes default browser styling */
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 1rem center;
            background-size: 1em;
            cursor: pointer;
            transition: border-color 0.2s ease;
        }

        .onyx-variant-select:focus {
            outline: none;
            border-color: #39FF14; /* Toxic green accent on focus */
        }

        /* Improved Button & Input Layout */
        .onyx-qty-input {
            background: #0a0a0a;
            color: white;
            border: 1px solid rgba(255,255,255,0.15);
            border-radius: 999px;
            padding: 16px;
            width: 90px;
            text-align: center;
            font-weight: 700;
            font-size: 16px;
        }

        .onyx-qty-input:focus {
            outline: none;
            border-color: #ffffff;
        }

        .onyx-add-to-cart {
            background: #ffffff;
            color: #000000;
            font-family: Syne, sans-serif;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.1em;
            border-radius: 999px;
            padding: 16px 42px;
            border: none;
            transition: all 0.2s ease;
            display: inline-flex;
            justify-content: center;
            align-items: center;
            font-size: 14px;
        }

        .onyx-add-to-cart:hover {
            transform: translateY(-2px);
            background: #e0e0e0;
            box-shadow: 0 10px 20px rgba(255,255,255,0.1);
        }

        .onyx-add-to-cart.disabled,
        .onyx-add-to-cart:disabled {
            background: #444;
            color: #aaa;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .onyx-detail-wishlist {
            align-items: center;
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.18);
            border-radius: 999px;
            color: #ffffff;
            display: inline-flex;
            font-family: Syne, sans-serif;
            font-size: 12px;
            font-weight: 800;
            gap: 10px;
            justify-content: center;
            letter-spacing: 0.08em;
            min-height: 56px;
            padding: 0 22px;
            text-decoration: none;
            text-transform: uppercase;
            transition: background 160ms ease, border-color 160ms ease, color 160ms ease, transform 160ms ease;
            white-space: nowrap;
        }

        .onyx-detail-wishlist svg {
            fill: transparent;
            height: 18px;
            stroke: currentColor;
            stroke-width: 2.2;
            width: 18px;
        }

        .onyx-detail-wishlist:hover,
        .onyx-detail-wishlist.is-active {
            background: #ffffff;
            border-color: #ffffff;
            color: #050505;
            transform: translateY(-1px);
        }

        .onyx-detail-wishlist.is-active svg {
            fill: currentColor;
        }

        /* New Specs Section to fill empty space */
        .onyx-specs-list {
            margin-top: 40px;
            padding-top: 30px;
            border-top: 1px solid rgba(255,255,255,0.1);
        }
        
        .onyx-spec-item {
            display: flex;
            justify-content: space-between;
            padding-bottom: 12px;
            margin-bottom: 12px;
            border-bottom: 1px dashed rgba(255,255,255,0.1);
            font-size: 13px;
        }

         .onyx-qty-input:focus {
            outline: none;
            border-color: #ffffff;
        }

        /* NEW: Color Swatch Styling */
        .onyx-variants-flex {
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
        }

        .onyx-color-swatch {
            display: inline-block;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            border: 2px solid rgba(255,255,255,0.2);
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
        }

        .onyx-color-swatch:hover {
            transform: scale(1.1);
            border-color: rgba(255,255,255,0.6);
        }

        .onyx-color-swatch.is-active {
            border-color: #39FF14;
            transform: scale(1.1);
            box-shadow: 0 0 15px rgba(57, 255, 20, 0.4);
        }

        .onyx-add-to-cart {
            background: #ffffff;
        }
    </style>
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
                        <asp:LinkButton ID="btnWishlist" runat="server" CssClass="onyx-detail-wishlist hover-trigger" OnClick="btnWishlist_Click" ToolTip="Add to wishlist">
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
