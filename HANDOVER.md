# TeamFlow — Handover

A custom team workflow tool, built as a replacement for monday.com.

**Live app: https://samnoah10.github.io/teamflow/**
(This address changes once ownership is transferred — see "Taking ownership" below.)

---

## 1. What it is

A working web app that does what monday.com does for day-to-day work management:

| | |
|---|---|
| **Boards & groups** | Organize work into boards, split into colored groups |
| **7 views** | Table · Kanban · Timeline (Gantt) · Calendar · Dashboard · Form · My Work |
| **Task cards** | Owner, status, priority, start/due dates, tags, subitems, time tracking, dependencies, comment threads, and a full change history |
| **Automations** | No-code rules — *"when status changes to Done → move it / reassign it / post an update / notify Slack"* |
| **Dashboards** | Status breakdown, progress per group, workload per person, what's due next |
| **Exports** | Full backup (JSON), spreadsheet (CSV), calendar (.ics for Apple/Google Calendar) |
| **Extras** | Dark mode, search, filters, automatic backups with one-click restore, installs as an app on desktop & phone |

**Cost: $0.** No subscription, no per-seat fees, no accounts to buy.

---

## 2. Start using it in 2 minutes

1. Open **https://samnoah10.github.io/teamflow/**
2. It opens on a **Getting Started** board that walks you through the features, plus a sample project you can poke at or delete.
3. Replace the sample team with your real people: sidebar → **Team** → **＋**
4. Make your first real board: sidebar → **Boards** → **＋** → pick a template.
5. Optional — click **📲 Install app** in the sidebar to put it on your desktop or phone home screen. It works offline.

---

## 3. Read this before rolling it out to the team

**Right now, each person's data lives only in their own browser.** There is no shared server yet.

That means: if two people open the link, they each get their own private copy. Your boards do not appear on their screen, and their changes do not appear on yours. Nothing is broken — that piece simply hasn't been built.

**What works today:** one person (or one shared computer) tracking work. Moving boards between people via **Export** → send the file → **Import**. Demoing the tool.

**What does not work today:** the whole team live on the same boards at once, which is the main thing monday.com is paid for.

---

## 4. What it would take to finish it

The remaining work is a real backend — a hosted database so everyone shares the same live data, real logins, and automations that run on a server around the clock instead of only while someone has the page open.

**That backend is already written**, sitting in the `backend/` folder: the complete database structure, server-side automation rules, audit logging, and permissions, plus a step-by-step setup guide. It has not been switched on, because doing so requires:

| Step | What's needed | Cost |
|---|---|---|
| Turn on the shared database | A Supabase account + ~10 min of setup (guide in `backend/README.md`), then a developer wires the app to it | $0–25/month |
| Custom domain | Buy a domain (e.g. `teamflow.app`) and point it at the app | ~$10–40/year |
| iPhone/Android store apps | Apple Developer account + Google Play account | $99/year + $25 once |

Estimated developer time to connect the backend, add logins, and get live sync working: **roughly 1–2 focused days.**

---

## 5. An honest assessment

This is a genuinely complete, working prototype — the full feature surface of monday.com, built from scratch, at zero cost. As a single-user tool or a demo, it's ready now.

It is **not** yet the equal of monday.com as a *product*, and it's worth being clear about why before anyone bets the team's work on it:

- **No live multi-user sync yet** (section 3) — the single biggest gap.
- **No integrations** beyond Slack notifications and calendar export — no Gmail, no automatic calendar sync, no API.
- **No support contract.** monday.com has a support team and uptime guarantees. This has whoever agrees to maintain it. If the team runs on this, someone has to own bug fixes and requests — that's a real, ongoing job, not a one-time build.
- **Data safety.** The app auto-backs-up inside the browser and can export files, but until the shared database is on, the data has no off-machine home. Clearing browser data would erase it.

**The realistic options:**
1. **Use it as-is** for personal/small-scale tracking and demos — free, ready today.
2. **Invest the 1–2 days** to switch on the backend and make it a true team tool. Cheapest long-term if someone owns it.
3. **Move to an existing free tool** (ClickUp, GoodDay, Trello, and Wrike all have free tiers) — saves the same subscription cost with zero maintenance burden and full vendor support.

Option 2 is the best outcome *if* someone is assigned to own it going forward. Option 3 is the lower-risk path if nobody is.

---

## 6. Taking ownership

The app currently lives in a GitHub account belonging to the person who built it. To make it fully yours:

**Path A — take over the hosted version (keeps the live link working):**
1. Create a free account at [github.com](https://github.com).
2. Send your GitHub username to the builder.
3. They go to the project → **Settings → General → Danger Zone → Transfer ownership** and transfer it to you.
4. Your live address becomes `https://<your-username>.github.io/teamflow/`.
5. Anyone you give the link to can use it; only you can change it.

**Path B — just take the files (no accounts, nothing to maintain):**
The entire app is one self-contained file. Unzip the folder anywhere and double-click `index.html` — it runs in any browser with no installation, no internet, and no accounts. Keep the folder on a shared drive and it's yours forever.

**What's in the folder:**
```
index.html          The entire app — this one file IS the product
manifest.json       Lets it install as an app
sw.js               Makes it work offline
icons/              App icon
README.md           Feature list & monday.com comparison
HANDOVER.md         This document
backend/            The unfinished backend: database schema + setup guide
```

**Moving existing data:** if there's already work tracked in the app, open it, click **Export** in the sidebar to download a backup file, and send that file along. The recipient clicks **Import** to load it.
