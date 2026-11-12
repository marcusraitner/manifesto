#!/bin/sh
# Builds the KDP interior PDF (5.5x8.5in) from chapters/*.md -> build/interior.pdf
# Needs: pandoc, xelatex, Linux Libertine + Open Sans fonts.
set -eu
cd "$(dirname "$0")/.."
mkdir -p build
# drop the square (1080x1080) quote images; keep diagrams and charts
for img in assets/images/chapters/*/*; do
  file "$img" | grep -Eq '1080 ?x ?1080' && echo "\#^!\[.*\]\($img\)\$#d"
done > build/drop.sed || true
{
  for f in chapters/*.md; do
    title=$(sed -n 's/^title: *//p' "$f" | head -1)
    printf '\n\n# %s {.unnumbered}\n\n' "$title"
    # drop front matter, turn Jekyll image links into plain paths
    awk '/^---$/ && n<2 {n++; next} n>=2' "$f" |
      sed -E "s#\{\{ *'([^']+)' *\| *relative_url *\}\}#\1#; s#\]\(/assets#](assets#"
  done
} | sed -E -f build/drop.sed > build/book.md
cat > build/dedication.tex <<'TEX'
\clearpage\thispagestyle{empty}\vspace*{\fill}
\noindent\textbf{Manifesto for Humane Leadership}\\
Six Theses and 14 Principles for New Leadership in the Age of Digitalization\\[1em]
Marcus Raitner\\
ISBN 9798310667907\\[1em]
\copyright{} 2025 Marcus Raitner
\clearpage
\cleardoublepage\thispagestyle{empty}\vspace*{0.3\textheight}
\begin{center}\itshape For Marie, Ella, and Valentin\end{center}
\cleardoublepage
TEX
pandoc build/book.md -B build/dedication.tex -o build/interior.pdf --pdf-engine=xelatex --toc --top-level-division=chapter \
  --resource-path=. -V documentclass=book -V classoption=openright \
  -V geometry:paperwidth=5.5in -V geometry:paperheight=8.5in \
  -V geometry:inner=0.85in -V geometry:outer=0.65in -V geometry:top=0.85in -V geometry:bottom=0.85in \
  -V mainfont="Linux Libertine O" -V sansfont="Open Sans" -V fontsize=11pt -V linestretch=1.2 \
  -V title="Manifesto for Humane Leadership" \
  -V subtitle="Six Theses and 14 Principles for New Leadership in the Age of AI and Digitalization" \
  -V author="Marcus Raitner" -V links-as-notes=true
pdfinfo build/interior.pdf | grep Pages
