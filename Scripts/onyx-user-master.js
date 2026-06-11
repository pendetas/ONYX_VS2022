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
