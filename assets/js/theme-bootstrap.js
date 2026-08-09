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

try {
    let initialTheme = localStorage.getItem('as-card-palette') || 'dragon';
    if (!window.typeThemeColors[initialTheme]) initialTheme = 'dragon';
    document.documentElement.dataset.theme = initialTheme;
    document.querySelector('meta[name="theme-color"]').setAttribute('content', window.typeThemeColors[initialTheme]);
} catch (error) {
    document.documentElement.dataset.theme = 'dragon';
}
