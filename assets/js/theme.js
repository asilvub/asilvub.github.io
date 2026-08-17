(function () {
    const themeSelect = document.getElementById('theme-select');
    const themeColors = window.typeThemeColors || {};

    function activeTheme() {
        const theme = document.documentElement.dataset.theme || 'dragon';
        return themeColors[theme] ? theme : 'dragon';
    }

    function syncSiteLinks() {
        const theme = activeTheme();

        document.querySelectorAll('a[href]').forEach(function (link) {
            const rawHref = link.getAttribute('href');
            if (!rawHref || rawHref.startsWith('#')) return;

            let url;
            try {
                url = new URL(rawHref, window.location.href);
            } catch (error) {
                return;
            }

            const isLocal = url.protocol === 'file:' || url.origin === window.location.origin;
            const isSitePage = url.pathname.endsWith('.html');
            if (!isLocal || !isSitePage) return;

            url.searchParams.set('palette', theme);
            link.href = url.href;
        });
    }

    function applyTheme(theme) {
        if (!themeColors[theme]) return;

        document.documentElement.dataset.theme = theme;
        const themeColor = document.querySelector('meta[name="theme-color"]');
        if (themeColor) themeColor.setAttribute('content', themeColors[theme]);

        try {
            localStorage.setItem('as-card-palette', theme);
        } catch (error) {
            // The palette still travels with links between local pages.
        }

        syncSiteLinks();
    }

    if (themeSelect) {
        themeSelect.value = activeTheme();
        themeSelect.addEventListener('change', function () {
            applyTheme(themeSelect.value);
        });
    }

    syncSiteLinks();
}());
