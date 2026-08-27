---
title: "Shipping a domain, site, and offsite backup in one evening"
description: "Five underdocumented setup blockers: DNS parking records, zone-scoped API tokens, Hetzner Storage Box defaults, restic sftp path format, and the Cloudflare Pages-to-Workers migration."
date: 2026-08-27
project: sovereign-ai-stack
tags: ["cloudflare", "hetzner", "restic", "selfhosted", "dns"]
---

I set aside one evening to ship three things: point `theinvalid.me` at Cloudflare Pages, attach a Hetzner Storage Box for offsite backups, and get restic writing encrypted snapshots to it. Six hours later everything was running. The path there hit five blockers in a row, none of them hard, none of them documented together anywhere.

This is the list.

## Gotcha 1: parking DNS records block your custom domain

When you buy a domain at a registrar and don't immediately move the nameservers, the registrar inserts placeholder records in its own zone: an `A` record pointing `@` at a parking page, sometimes a `CNAME` on `www`. Even after you delegate to Cloudflare, those records shadow the delegation long enough to cause the Cloudflare custom-domain verification to fail with a message about the domain already having conflicting records.

**The fix:** before you touch nameservers, delete the registrar's parking records. Then delegate. Cloudflare creates its own records on a clean zone and verification goes through on the first try.

## Gotcha 2: zone-scoped Cloudflare tokens can't touch Pages or Workers

If you generate an API token scoped to your DNS zone and then try to use it with `wrangler` or the Pages API, you get:

```
Error: 10000: Authentication error
```

Pages and Workers are account-level resources, not zone-level. A zone-scoped token has no visibility into them at all.

**The fix:** create a token with account-level permissions (specifically the Pages or Workers permission). Alternatively, skip the API entirely: the dashboard Git-connect sets up a permanent auto-deploy webhook without any token to rotate. For a static site, that is the right answer.

## Gotcha 3: Hetzner Storage Boxes ship with all access disabled

I created a Storage Box, got the credentials from Hetzner Robot, and ran `restic init`. It hung. I tried sftp directly. Connection refused. I assumed a password error, reset the password, tried again:

```
ssh: connect to host u123456.your-storagebox.de port 23: Connection refused
```

The problem is not the password. Hetzner Storage Boxes ship with every external access method turned off. SSH support, SFTP, Samba, WebDAV, everything. You have to enable them explicitly in the Robot panel under the Storage Box settings before the box is reachable over any protocol.

**The fix:** in Hetzner Robot, open the Storage Box, go to Settings, enable SSH support. Wait about a minute for propagation. Then the credentials work.

The "connection refused" message is the misleading part. It reads as a network or firewall problem when it is actually a feature toggle. Do not spend an hour debugging credentials.

## Gotcha 4: restic sftp needs a relative path

Once the Storage Box was reachable, restic init failed with:

```
Fatal: unable to create lock in backend: sftp: "file does not exist"
```

The directory existed. The path was correct in every other sense. The issue is that restic's sftp backend requires a path that starts with `./` relative to the home directory:

```bash
# Wrong - absolute path, fails even when the directory exists:
restic -r sftp:u123456@u123456.your-storagebox.de:/repos/backup init

# Right - relative path from home:
restic -r sftp:u123456@u123456.your-storagebox.de:./repos/backup init
```

The `./` prefix is not optional. Without it, restic tries to construct an absolute path over the sftp session and the storage box rejects it.

## Gotcha 5: new Cloudflare Pages projects use wrangler.jsonc, not wrangler.toml

Cloudflare is migrating Pages to run on the Workers platform. New projects created after the migration started need a `wrangler.jsonc` file with an assets stanza, not the old `wrangler.toml` format:

```jsonc
{
  "name": "theinvalid-site",
  "compatibility_date": "2026-01-01",
  "assets": {
    "directory": "./dist"
  }
}
```

If you copy a `wrangler.toml` from any tutorial written before mid-2025 and run `wrangler deploy`, it either errors on the assets config or deploys nothing visible. The Pages documentation does not clearly flag which path you are on when you create a new project today.

For a static Astro site, the dashboard Git-connect skips this entirely. But if you are scripting the deploy or want local `wrangler` previews, the `wrangler.jsonc` format is what the current tooling expects.

## What I'd tell you to check before you start

1. At the registrar: delete the parking `A` and `CNAME` records before you move nameservers.
2. For Cloudflare API tokens: account-level scope for Pages and Workers, not zone-level.
3. In Hetzner Robot: enable SSH support on the Storage Box before any restic or sftp command.
4. In the restic sftp URL: `./repo` relative path, never `/repo` absolute.
5. For new Cloudflare Pages projects: check whether yours is Workers-backed and use `wrangler.jsonc` accordingly.

All five are fixable in under two minutes each once you know what you are looking at.

---

*The backup scripts, watchdog, and the ops layer that keeps this running are documented at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
