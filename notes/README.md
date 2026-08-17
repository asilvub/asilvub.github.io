# Adding a note

The public title of this section is **Things I Learn and Forget**. Editable source files and published web pages live separately:

```text
notes/
├── src/       # Editable .qmd, .md, or other source files
├── entries/   # Published standalone HTML pages
├── index.html
└── entry-template.html
```

The website serves the files in `entries/` directly, so it does not require a build step when someone visits it. Keep the source used to generate an entry in `src/` whenever that source is available.

## Source-based notes

1. Save the editable source as `src/descriptive-kebab-case-title.qmd` or `.md`.
2. Render or export it to `entries/descriptive-kebab-case-title.html`.
3. Make sure the HTML has the notebook navigation, shared styles, description metadata, and a working link back to the index.
4. Add one `.paper-entry.note-library-entry` article to `index.html`.
5. Include an ISO date in the `<time>` element and a short summary and reading time.

For a Quarto source, run the render command from `notes/src/` so relative styles and includes resolve correctly:

```sh
quarto render descriptive-kebab-case-title.qmd --output-dir ../entries
```

## HTML-only notes

If HTML is the only source, place a copy directly in `entries/`. The reusable `entry-template.html` provides the notebook shell and MathJax configuration. After copying the template into `entries/`, add one extra `../` to each local asset and navigation path because the entry is one directory deeper. The existing `entries/about-this-notebook.html` is a path reference.

MathJax is already configured in the template. Use `\( ... \)` for inline mathematics and `\[ ... \]` for displayed mathematics.

For a durable entry, try to include:

- the question in plain language;
- notation and assumptions;
- the result;
- a derivation, proof, or worked example;
- intuition and, when useful, a counterexample;
- sources and a last-updated date;
- a suggested citation with a direct link to the published note.
