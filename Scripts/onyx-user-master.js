tailwind.config = {
    theme: {
        extend: {
            colors: {
                primary: '#050505',
                accent: '#d8dde3',
                secondary: '#9ca3af'
            },
            fontFamily: {
                sans: ['Inter', 'sans-serif'],
                mono: ['JetBrains Mono', 'monospace']
            }
        }
    }
};

document.addEventListener('DOMContentLoaded', function () {
    (function () {
        var mainNav = document.getElementById('onyx-main-nav');
        var mobileMenu = document.getElementById('onyxMobileMenu');
        var mobileMenuButton = document.getElementById('onyxMobileMenuButton');
        var navSearchInputs = [
            document.getElementById('onyx-nav-search-input'),
            document.getElementById('onyx-mobile-search-input')
        ].filter(Boolean);
        var currentSearchTerm = new URL(window.location.href).searchParams.get('q') || '';

        navSearchInputs.forEach(function (input) {
            input.value = currentSearchTerm;
        });

        function openCatalogSearch(searchTerm, preserveCatalogState) {
            var catalogUrl = document.body.getAttribute('data-catalog-url') || '/customer_page/onyx_catalog.aspx';
            var target = new URL(catalogUrl, window.location.origin);

            if (preserveCatalogState && window.location.pathname.toLowerCase().indexOf('onyx_catalog') >= 0) {
                var current = new URL(window.location.href);
                var category = current.searchParams.get('category');
                var sort = current.searchParams.get('sort');
                if (category) target.searchParams.set('category', category);
                if (sort) target.searchParams.set('sort', sort);
            }

            if (searchTerm && searchTerm.trim()) {
                target.searchParams.set('q', searchTerm.trim());
            }

            window.location.href = target.pathname + target.search;
        }

        navSearchInputs.forEach(function (input) {
            input.addEventListener('keydown', function (event) {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    openCatalogSearch(input.value, false);
                }
            });
        });

        window.onyxApplyCatalogFilters = function () {
            var current = new URL(window.location.href);
            var search = document.getElementById('onyx-catalog-search');
            var sort = document.getElementById('onyx-catalog-sort');

            current.searchParams.delete('page');
            if (search && search.value.trim()) {
                current.searchParams.set('q', search.value.trim());
            } else {
                current.searchParams.delete('q');
            }

            if (sort && sort.value && sort.value !== 'newest') {
                current.searchParams.set('sort', sort.value);
            } else {
                current.searchParams.delete('sort');
            }

            window.location.href = current.pathname + current.search;
        };

        var catalogSearch = document.getElementById('onyx-catalog-search');
        if (catalogSearch) {
            catalogSearch.addEventListener('keydown', function (event) {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    window.onyxApplyCatalogFilters();
                }
            });
        }

        var catalogSort = document.getElementById('onyx-catalog-sort');
        if (catalogSort) {
            catalogSort.addEventListener('change', window.onyxApplyCatalogFilters);
        }

        if (mobileMenuButton && mobileMenu) {
            mobileMenuButton.addEventListener('click', function () {
                var isOpen = mobileMenu.classList.toggle('is-open');
                mobileMenuButton.classList.toggle('is-open', isOpen);
                mobileMenuButton.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
                mobileMenu.setAttribute('aria-hidden', isOpen ? 'false' : 'true');
            });
        }

        if (mainNav) {
            function updateNavScrolled() {
                if (window.scrollY > 60) {
                    mainNav.classList.add('is-scrolled');
                } else {
                    mainNav.classList.remove('is-scrolled');
                }
            }

            window.addEventListener('scroll', updateNavScrolled, { passive: true });
            updateNavScrolled();
        }

        var logoutDialog = document.getElementById('onyxLogoutDialog');
        var logoutConfirm = document.getElementById('onyxLogoutConfirm');
        var logoutCancel = document.getElementById('onyxLogoutCancel');
        var pendingLogoutButton = null;

        function closeLogoutDialog() {
            if (!logoutDialog) {
                return;
            }

            logoutDialog.classList.remove('is-visible');
            logoutDialog.setAttribute('aria-hidden', 'true');

            if (pendingLogoutButton) {
                pendingLogoutButton.focus();
            }
        }

        window.onyxRequestLogout = function (source) {
            if (!logoutDialog) {
                return true;
            }

            if (source && source.getAttribute('data-onyx-logout-confirmed') === 'true') {
                source.removeAttribute('data-onyx-logout-confirmed');
                return true;
            }

            pendingLogoutButton = source;
            logoutDialog.classList.add('is-visible');
            logoutDialog.setAttribute('aria-hidden', 'false');

            if (logoutConfirm) {
                logoutConfirm.focus();
            }

            return false;
        };

        if (logoutCancel) {
            logoutCancel.addEventListener('click', closeLogoutDialog);
        }

        if (logoutConfirm) {
            logoutConfirm.addEventListener('click', function () {
                if (!pendingLogoutButton) {
                    closeLogoutDialog();
                    return;
                }

                pendingLogoutButton.setAttribute('data-onyx-logout-confirmed', 'true');
                pendingLogoutButton.click();
            });
        }

        if (logoutDialog) {
            logoutDialog.addEventListener('click', function (event) {
                if (event.target === logoutDialog) {
                    closeLogoutDialog();
                }
            });

            document.addEventListener('keydown', function (event) {
                if (event.key === 'Escape' && logoutDialog.classList.contains('is-visible')) {
                    closeLogoutDialog();
                }
            });
        }
    })();
});
