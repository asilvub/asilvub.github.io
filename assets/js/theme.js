(function () {
    const themeSelect = document.getElementById('theme-select');
    const themeColors = window.typeThemeColors || {};

    if (!themeSelect) return;

    themeSelect.value = document.documentElement.dataset.theme || 'dragon';
    themeSelect.addEventListener('change', function () {
        const theme = themeSelect.value;
        document.documentElement.dataset.theme = theme;

        const themeColor = document.querySelector('meta[name="theme-color"]');
        if (themeColor && themeColors[theme]) {
            themeColor.setAttribute('content', themeColors[theme]);
        }

        try {
            localStorage.setItem('as-card-palette', theme);
        } catch (error) {
            // The selected palette still applies for this visit.
        }
    });
}());
