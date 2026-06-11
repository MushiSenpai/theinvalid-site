#!/bin/bash
# make-resume-pdf.sh — regenerate public/resume.pdf from src/content/resume.md
# Print-friendly (white) styling, distinct from the dark site theme.
# Run after every resume edit: bash scripts/make-resume-pdf.sh && git add -A && git commit && git push
set -e
cd "$(dirname "$0")/.."

TMP_HTML=$(mktemp /tmp/resume-XXXX.html)

pandoc src/content/resume.md --standalone --metadata title="Madhan Kumar Reddy — Resume" \
  --css /dev/null -o "$TMP_HTML"

# Inject print stylesheet
python3 - "$TMP_HTML" << 'EOF'
import sys
css = """
<style>
  body { font-family: -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
         font-size: 10.5pt; line-height: 1.45; color: #1a1a1a;
         max-width: 7.3in; margin: 0 auto; }
  h1 { font-size: 19pt; margin-bottom: 2pt; }
  h1 + p { margin-top: 2pt; }
  h2 { font-size: 12.5pt; border-bottom: 1.5pt solid #c8901f; padding-bottom: 2pt;
       margin-top: 14pt; margin-bottom: 6pt; }
  h3 { font-size: 11pt; margin-bottom: 3pt; margin-top: 10pt; }
  a { color: #1a5276; text-decoration: none; }
  hr { border: none; border-top: 0.5pt solid #ccc; margin: 8pt 0; }
  ul { margin: 4pt 0; padding-left: 16pt; }
  li { margin-bottom: 3pt; }
  blockquote { margin: 6pt 0; padding-left: 10pt; border-left: 2.5pt solid #c8901f; color: #333; }
  header#title-block-header { display: none; }
  @page { margin: 0.55in 0.6in; }
</style>
"""
p = sys.argv[1]
html = open(p).read().replace("</head>", css + "</head>")
open(p, "w").write(html)
EOF

google-chrome --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf=public/resume.pdf "file://$TMP_HTML" 2>/dev/null

rm -f "$TMP_HTML"
ls -lh public/resume.pdf
