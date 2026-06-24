// Build-time GitHub repo status. The site is static, so this runs at build:
// each deploy (incl. the scheduled rebuild) refreshes the snapshot.
// Fail-soft by design — any error (rate limit, network, abort) returns null and
// the caller simply omits the "updated" badge. Never breaks the build.
//
// Optional: set GITHUB_TOKEN in the Cloudflare Pages build env for higher rate
// limits. Unauthenticated is fine for a handful of public repos per build.

const cache = new Map();
// Runs in Node at build (Astro SSG / CF Workers build / CI) — prefer process.env;
// fall back to Vite's import.meta.env. Optional: omit it and run unauthenticated.
const TOKEN =
  (typeof process !== 'undefined' && process.env && process.env.GITHUB_TOKEN) ||
  import.meta.env.GITHUB_TOKEN;

function parseRepo(url) {
  try {
    const m = String(url).match(/github\.com\/([^/]+)\/([^/?#]+?)(?:\.git)?\/?$/i);
    return m ? { owner: m[1], repo: m[2] } : null;
  } catch {
    return null;
  }
}

export async function repoStatus(url) {
  if (cache.has(url)) return cache.get(url);
  let status = null;
  const r = parseRepo(url);
  if (r) {
    try {
      const ctrl = new AbortController();
      const timer = setTimeout(() => ctrl.abort(), 5000);
      const headers = { Accept: 'application/vnd.github+json', 'User-Agent': 'theinvalid-site' };
      if (TOKEN) headers.Authorization = `Bearer ${TOKEN}`;
      const res = await fetch(`https://api.github.com/repos/${r.owner}/${r.repo}`, {
        headers,
        signal: ctrl.signal,
      });
      clearTimeout(timer);
      if (res.ok) {
        const d = await res.json();
        status = { pushedAt: d.pushed_at, stars: d.stargazers_count ?? 0, htmlUrl: d.html_url };
      }
    } catch {
      // fail soft — leave status null
    }
  }
  cache.set(url, status);
  return status;
}

// Dedupes URLs and fetches concurrently; returns Map<url, status|null>.
export async function repoStatuses(urls) {
  const unique = [...new Set(urls)];
  const entries = await Promise.all(unique.map(async (u) => [u, await repoStatus(u)]));
  return new Map(entries);
}

export function ago(iso, now = new Date()) {
  if (!iso) return null;
  const days = Math.floor(Math.max(0, (now - new Date(iso)) / 86400000));
  if (days === 0) return 'today';
  if (days === 1) return 'yesterday';
  if (days < 30) return `${days} days ago`;
  const months = Math.floor(days / 30);
  if (months < 12) return `${months} month${months > 1 ? 's' : ''} ago`;
  const years = Math.floor(days / 365);
  return `${years} year${years > 1 ? 's' : ''} ago`;
}
