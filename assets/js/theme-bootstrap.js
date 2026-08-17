(function () {
    window.typeThemeColors = {
        normal: '#3f3c38',
        fire: '#3c1511',
        water: '#0d3557',
        electric: '#242039',
        grass: '#153725',
        ice: '#174a57',
        fighting: '#3a1915',
        poison: '#35153f',
        ground: '#493017',
        flying: '#303653',
        psychic: '#29133a',
        bug: '#303b14',
        rock: '#493b26',
        ghost: '#0e0b1c',
        dragon: '#082a38',
        dark: '#080a0e',
        steel: '#293844',
        fairy: '#4a213c'
    };

    const themeColors = window.typeThemeColors;
    let requestedTheme = '';

    try {
        requestedTheme = new URLSearchParams(window.location.search).get('palette') || '';
    } catch (error) {
        requestedTheme = '';
    }

    let initialTheme = requestedTheme;
    if (!themeColors[initialTheme]) {
        try {
            initialTheme = localStorage.getItem('as-card-palette') || 'dragon';
        } catch (error) {
            initialTheme = 'dragon';
        }
    }

    if (!themeColors[initialTheme]) initialTheme = 'dragon';
    document.documentElement.dataset.theme = initialTheme;

    const themeColor = document.querySelector('meta[name="theme-color"]');
    if (themeColor) themeColor.setAttribute('content', themeColors[initialTheme]);
}());
