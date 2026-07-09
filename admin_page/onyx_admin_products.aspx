<%@ Page Title="Products" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_products.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_products" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* ── Page header ─────────────────────────────── */
    .products-header {
        display: flex;
        align-items: flex-end;
        justify-content: space-between;
        margin-bottom: 36px;
    }

    .products-title {
        font-size: 22px;
        font-weight: 600;
        color: #fff;
        letter-spacing: -0.02em;
    }

    .products-subtitle {
        font-size: 12px;
        color: rgba(255,255,255,0.28);
        margin-top: 5px;
        font-weight: 400;
        letter-spacing: 0.03em;
    }

    /* Add Product button */
    .btn-add {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 9px 18px;
        background: #ffffff;
        color: #000;
        border-radius: 5px;
        font-size: 11px;
        font-weight: 700;
        text-decoration: none;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        transition: background 0.15s;
    }

    .btn-add:hover { background: rgba(255,255,255,0.82); color: #000; text-decoration: none; }
    .btn-add i { width: 13px; height: 13px; }

    /* ── Search ──────────────────────────────────── */
    .search-wrap {
        max-width: 300px;
        margin-bottom: 28px;
    }

    .search-line {
        display: flex;
        align-items: center;
        gap: 10px;
        border-bottom: 1px solid rgba(255,255,255,0.12);
        padding: 8px 0;
        transition: border-color 0.18s;
    }

    .search-line:focus-within {
        border-color: rgba(255,255,255,0.42);
    }

    .search-line i {
        width: 14px;
        height: 14px;
        color: rgba(255,255,255,0.22);
        flex-shrink: 0;
    }

    .search-input {
        flex: 1;
        background: transparent;
        border: none;
        outline: none;
        color: #fff;
        font-size: 13px;
        font-weight: 400;
    }

    .search-input::placeholder { color: rgba(255,255,255,0.18); }

    /* ── Filter tabs ─────────────────────────────── */
    .filter-tabs {
        display: flex;
        align-items: stretch;
        border-bottom: 1px solid rgba(255,255,255,0.07);
        margin-bottom: 28px;
        overflow-x: auto;
        scrollbar-width: none;
        -ms-overflow-style: none;
        gap: 0;
    }

    .filter-tabs::-webkit-scrollbar { display: none; }

    .tab {
        padding: 9px 16px;
        font-size: 11px;
        font-weight: 500;
        letter-spacing: 0.10em;
        text-transform: uppercase;
        color: rgba(255,255,255,0.26);
        cursor: pointer;
        border-bottom: 1.5px solid transparent;
        margin-bottom: -1px;
        transition: color 0.15s, border-color 0.15s;
        white-space: nowrap;
        user-select: none;
    }

    .tab:first-child { padding-left: 0; }
    .tab:hover { color: rgba(255,255,255,0.62); }

    .tab.active {
        color: #fff;
        border-bottom-color: #fff;
    }

    /* ── Results bar ─────────────────────────────── */
    .results-bar {
        font-size: 11px;
        color: rgba(255,255,255,0.20);
        margin-bottom: 20px;
        letter-spacing: 0.06em;
        text-transform: uppercase;
    }

    /* ── Product grid ────────────────────────────── */
    .product-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(215px, 1fr));
        gap: 13px;
    }

    /* ── Product card ────────────────────────────── */
    .product-card {
        background: #111113;
        border: 1px solid rgba(255,255,255,0.05);
        border-radius: 10px;
        overflow: hidden;
        cursor: pointer;
        text-decoration: none;
        display: flex;
        flex-direction: column;
        transition: border-color 0.18s, transform 0.18s, box-shadow 0.18s;
    }

    .product-card:hover {
        border-color: rgba(255,255,255,0.12);
        transform: translateY(-2px);
        box-shadow: 0 10px 38px rgba(0,0,0,0.52);
        text-decoration: none;
    }

    /* Image */
    .card-image {
        aspect-ratio: 1 / 1;
        background: #18181c;
        display: flex;
        align-items: center;
        justify-content: center;
        position: relative;
        overflow: hidden;
        flex-shrink: 0;
    }

    .card-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        opacity: 0.88;
        transition: opacity 0.18s;
    }

    .product-card:hover .card-image img { opacity: 1; }

    .admin-product-gallery {
        width: 100%;
        height: 100%;
        position: relative;
    }

    .admin-product-gallery-slide {
        inset: 0;
        position: absolute;
        opacity: 0;
        pointer-events: none;
    }

    .admin-product-gallery-slide.is-active {
        opacity: 0.88;
        pointer-events: auto;
    }

    .product-card:hover .admin-product-gallery-slide.is-active { opacity: 1; }

    .admin-product-gallery-nav {
        position: absolute;
        top: 50%;
        z-index: 3;
        width: 30px;
        height: 30px;
        border: 1px solid rgba(255,255,255,0.18);
        border-radius: 999px;
        background: rgba(0,0,0,0.58);
        color: #fff;
        transform: translateY(-50%);
        opacity: 0;
        transition: opacity 0.15s, background 0.15s;
    }

    .admin-product-gallery-nav--prev { left: 9px; }
    .admin-product-gallery-nav--next { right: 9px; }

    .card-image:hover .admin-product-gallery-nav,
    .admin-product-gallery-nav:focus {
        opacity: 1;
    }

    .admin-product-gallery-nav:hover,
    .admin-product-gallery-nav:focus {
        background: #fff;
        color: #050505;
    }

    .admin-product-gallery-count {
        position: absolute;
        left: 10px;
        bottom: 10px;
        z-index: 3;
        padding: 3px 7px;
        border-radius: 999px;
        background: rgba(0,0,0,0.56);
        color: rgba(255,255,255,0.76);
        font-size: 9px;
        font-weight: 700;
    }

    .card-placeholder {
        font-size: 54px;
        font-weight: 700;
        color: rgba(255,255,255,0.045);
        letter-spacing: -3px;
        user-select: none;
    }

    .card-category-badge {
        position: absolute;
        top: 10px;
        left: 10px;
        padding: 3px 7px;
        border-radius: 3px;
        font-size: 9px;
        font-weight: 600;
        letter-spacing: 0.10em;
        text-transform: uppercase;
        background: rgba(255,255,255,0.07);
        color: rgba(255,255,255,0.45);
    }

    /* Info */
    .card-body {
        padding: 14px 15px 15px;
        display: flex;
        flex-direction: column;
        gap: 4px;
        flex: 1;
        border-top: 1px solid rgba(255,255,255,0.04);
    }

    .card-name {
        font-size: 13px;
        font-weight: 600;
        color: #fff;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        letter-spacing: -0.01em;
    }

    .card-brand {
        font-size: 11px;
        color: rgba(255,255,255,0.26);
        font-weight: 400;
    }

    .card-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-top: 10px;
    }

    .card-price {
        font-size: 14px;
        font-weight: 700;
        color: #fff;
        letter-spacing: -0.01em;
    }

    .stock-badge {
        font-size: 10px;
        font-weight: 500;
        padding: 3px 8px;
        border-radius: 3px;
        letter-spacing: 0.03em;
    }

    .stock-ok  { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.38); }
    .stock-low { background: rgba(251,191,36,0.10);  color: #fbbf24; }
    .stock-out { background: rgba(255,68,68,0.10);   color: #ff5555; }

    /* ── Empty state ─────────────────────────────── */
    .empty-state {
        text-align: center;
        padding: 80px 20px;
        color: rgba(255,255,255,0.16);
        font-size: 12px;
        display: none;
        letter-spacing: 0.06em;
        text-transform: uppercase;
    }

    .empty-state i { width: 30px; height: 30px; margin-bottom: 14px; opacity: 0.15; }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Header --%>
    <div class="products-header">
        <div>
            <div class="products-title">Products</div>
            <div class="products-subtitle">
                <asp:Label ID="lblCount" runat="server" />
            </div>
        </div>
        <a href="onyx_admin_products_form.aspx" class="btn-add">
            <i data-lucide="plus"></i> Add Product
        </a>
    </div>

    <%-- Search --%>
    <div class="search-wrap">
        <div class="search-line">
            <i data-lucide="search"></i>
            <input type="text" id="searchInput" class="search-input"
                   placeholder="Search products..." oninput="applyFilters()" />
        </div>
    </div>

    <%-- Filter tabs --%>
    <div class="filter-tabs" id="filterTabs">
        <span class="tab active" data-cat="all" onclick="setCategory(this)">All</span>
        <asp:Repeater ID="CategoryRepeater" runat="server">
            <ItemTemplate>
                <span class="tab"
                      data-cat="<%# Container.DataItem.ToString().ToLower() %>"
                      onclick="setCategory(this)"><%# Container.DataItem %></span>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <div class="results-bar" id="resultsBar"></div>

    <%-- Product grid --%>
    <div class="product-grid" id="productGrid">
        <asp:Repeater ID="ProductsRepeater" runat="server">
            <ItemTemplate>
                <a class="product-card"
                   href="onyx_admin_product_detail.aspx?id=<%# Eval("Id") %>"
                   data-name="<%# Eval("Name").ToString().ToLower() %> <%# (Eval("Brand") ?? "").ToString().ToLower() %>"
                   data-category="<%# Eval("Category").ToString().ToLower() %>">

                    <div class="card-image">
                        <%# GetProductGalleryHtml(Container.DataItem) %>
                        <div class="card-placeholder"<%# !string.IsNullOrEmpty(Eval("ImageUrl") as string) ? " style=\"display:none\"" : "" %>><%# Eval("Name").ToString().Substring(0, 1).ToUpper() %></div>
                        <span class="card-category-badge"><%# Eval("Category") %></span>
                    </div>

                    <div class="card-body">
                        <div class="card-name" title="<%# Eval("Name") %>"><%# Eval("Name") %></div>
                        <div class="card-brand"><%# Eval("Brand") ?? "—" %></div>
                        <div class="card-footer">
                            <div class="card-price">RM <%# string.Format("{0:N2}", Eval("Price")) %></div>
                            <%# GetStockBadge((int)Eval("StockQty")) %>
                        </div>
                    </div>
                </a>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <div class="empty-state" id="emptyState">
        <div><i data-lucide="package-x"></i></div>
        No products match your search.
    </div>

    <script>
        var activeCategory = 'all';

        function setCategory(el) {
            document.querySelectorAll('.tab').forEach(function (t) { t.classList.remove('active'); });
            el.classList.add('active');
            activeCategory = el.getAttribute('data-cat');
            applyFilters();
        }

        function applyFilters() {
            var query = document.getElementById('searchInput').value.toLowerCase().trim();
            var cards = document.querySelectorAll('#productGrid .product-card');
            var visible = 0;

            cards.forEach(function (card) {
                var name = card.getAttribute('data-name') || '';
                var cat  = card.getAttribute('data-category') || '';

                var matchSearch = query === '' || name.indexOf(query) !== -1;
                var matchCat   = activeCategory === 'all' || cat === activeCategory;

                if (matchSearch && matchCat) {
                    card.style.display = '';
                    visible++;
                } else {
                    card.style.display = 'none';
                }
            });

            document.getElementById('resultsBar').textContent =
                visible + (visible === 1 ? ' product' : ' products') + ' shown';
            document.getElementById('emptyState').style.display = visible === 0 ? 'block' : 'none';
        }

        applyFilters();

        document.addEventListener('click', function (event) {
            var control = event.target.closest('[data-gallery-prev],[data-gallery-next]');
            if (!control) return;
            event.preventDefault();
            event.stopPropagation();

            var gallery = control.closest('[data-product-gallery]');
            if (!gallery) return;

            var slides = gallery.querySelectorAll('[data-gallery-slide]');
            if (!slides.length) return;

            var current = parseInt(gallery.getAttribute('data-gallery-index') || '0', 10);
            var next = current + (control.hasAttribute('data-gallery-next') ? 1 : -1);
            var index = (next + slides.length) % slides.length;

            gallery.setAttribute('data-gallery-index', String(index));
            slides.forEach(function (slide, slideIndex) {
                slide.classList.toggle('is-active', slideIndex === index);
            });

            var count = gallery.querySelector('.admin-product-gallery-count');
            if (count) count.textContent = (index + 1) + '/' + slides.length;
        });
    </script>

</asp:Content>
