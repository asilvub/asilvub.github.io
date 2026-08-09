# Note sources

Keep the editable source for public notebook entries in this directory. Use the same kebab-case basename for the source and its rendered page:

```text
src/dimensional_analysis_macroeconomics.qmd
entries/dimensional_analysis_macroeconomics.html
```

The rendered HTML in `../entries/` is the version published by GitHub Pages. Do not edit generated HTML when the corresponding source file is available; update the source and render it again instead.

Render this note from the current directory with:

```sh
quarto render dimensional_analysis_macroeconomics.qmd --output-dir ../entries
```
