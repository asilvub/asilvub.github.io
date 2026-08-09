(function () {
    const tools = document.querySelector('[data-note-tools]');
    const search = document.getElementById('note-search');
    const filterList = document.getElementById('note-filters');
    const cards = Array.from(document.querySelectorAll('[data-note-card]'));
    const resultCount = document.getElementById('note-result-count');
    const emptyState = document.getElementById('note-empty-state');

    if (!tools || !search || !filterList || cards.length === 0) return;

    let activeTopic = 'All';
    const topics = Array.from(new Set(
        cards.flatMap(function (card) {
            return (card.dataset.topics || '').split(',').map(function (topic) {
                return topic.trim();
            }).filter(Boolean);
        })
    )).sort();

    ['All'].concat(topics).forEach(function (topic) {
        const button = document.createElement('button');
        button.type = 'button';
        button.textContent = topic;
        button.dataset.topic = topic;
        button.setAttribute('aria-pressed', topic === 'All' ? 'true' : 'false');
        filterList.appendChild(button);
    });

    function updateResults() {
        const query = search.value.trim().toLowerCase();
        let visible = 0;

        cards.forEach(function (card) {
            const cardTopics = (card.dataset.topics || '').split(',').map(function (topic) {
                return topic.trim();
            });
            const matchesTopic = activeTopic === 'All' || cardTopics.includes(activeTopic);
            const matchesQuery = !query || card.textContent.toLowerCase().includes(query);
            const matches = matchesTopic && matchesQuery;
            card.hidden = !matches;
            if (matches) visible += 1;
        });

        resultCount.textContent = visible + (visible === 1 ? ' note' : ' notes');
        emptyState.hidden = visible !== 0;
    }

    filterList.addEventListener('click', function (event) {
        const button = event.target.closest('button[data-topic]');
        if (!button) return;

        activeTopic = button.dataset.topic;
        filterList.querySelectorAll('button').forEach(function (filterButton) {
            filterButton.setAttribute('aria-pressed', String(filterButton === button));
        });
        updateResults();
    });

    search.addEventListener('input', updateResults);
    tools.hidden = false;
    updateResults();
}());
