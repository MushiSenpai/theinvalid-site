"""Copy a built Astro dist into public/classic/ so the previous design stays reachable.

Only the generated pages (not files that came from public/) and their /_astro/ CSS are
copied. Internal links to those pages are re-pointed under /classic/, every page gets a
noindex meta (the current site owns search) and a one-line banner linking to the current
version of the same page. Usage: classic_rewrite.py DIST PUBLIC OUT LABEL
"""
import os
import re
import shutil
import sys

dist, public, out, label = sys.argv[1:5]

pages = []
for root, _, files in os.walk(dist):
    for f in files:
        if not f.endswith(".html"):
            continue
        rel = os.path.relpath(os.path.join(root, f), dist)
        if os.path.exists(os.path.join(public, rel)):
            continue  # a standalone page from public/: shared by both designs
        pages.append(rel)

routes = set()
for rel in pages:
    d = os.path.dirname(rel)
    if os.path.basename(rel) == "index.html":
        routes.add("/" if d == "" else f"/{d}/")
    else:
        routes.add("/" + rel)


def is_route(path):
    if path == "/":
        return True
    return path in routes or (path.rstrip("/") + "/") in routes


def remap(path):
    base, sep, rest = re.match(r"([^?#]*)([?#]?)(.*)", path).groups()
    if base.startswith("/_astro/") or (base.startswith("/") and not base.startswith("//") and is_route(base)):
        return "/classic" + base + sep + rest
    return path


attr = re.compile(r'(\s(?:href|src)=")(/[^"]*)(")')
refresh = re.compile(r'(content="\d+;\s*url=)(/[^"]*)(")', re.I)
body = re.compile(r"(<body[^>]*>)", re.I)

if os.path.isdir(out):
    shutil.rmtree(out)
for rel in pages:
    src = os.path.join(dist, rel)
    html = open(src, encoding="utf-8").read()
    html = attr.sub(lambda m: m.group(1) + remap(m.group(2)) + m.group(3), html)
    html = refresh.sub(lambda m: m.group(1) + remap(m.group(2)) + m.group(3), html)
    html = html.replace("<head>", '<head><meta name="robots" content="noindex">', 1)
    d = os.path.dirname(rel)
    here = "/" if d == "" else f"/{d}/"
    banner = (
        '<div style="font-family:var(--mono);font-size:0.78rem;background:var(--bg-raise);'
        'border-bottom:1px solid var(--line);padding:0.55rem 1.25rem;text-align:center;color:var(--muted)">'
        f'Classic design, frozen {label}. <a href="{here}">See this page in the current design →</a></div>'
    )
    html = body.sub(lambda m: m.group(1) + banner, html, count=1)
    dst = os.path.join(out, rel)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    open(dst, "w", encoding="utf-8").write(html)

shutil.copytree(os.path.join(dist, "_astro"), os.path.join(out, "_astro"))
print(f"classic: {len(pages)} pages, {len(routes)} routes -> {out}")
