# TeamFlow

A custom team workflow tool that replaces monday.com. No installs, no accounts, no per-seat fees.

## How to open it
Double-click `index.html` — it opens in any browser and works immediately.

## TeamFlow vs monday.com

| Capability | monday.com | TeamFlow |
|---|---|---|
| Table view with groups, statuses, owners, priorities, dates, tags | ✅ | ✅ |
| Kanban with drag & drop | ✅ | ✅ |
| Timeline / Gantt chart | 💰 Standard+ | ✅ Free |
| Calendar view | ✅ | ✅ |
| Dashboards (battery, workload, upcoming widgets) | ✅ (limits by plan) | ✅ |
| No-code automations ("when Done → move it…") | ✅ capped per month by plan | ✅ **Unlimited** |
| Time tracking | 💰 Pro ($30/seat/mo) | ✅ Free |
| Task dependencies (blocked by) | 💰 Pro | ✅ Free |
| Subitems with progress | ✅ | ✅ |
| My Work (cross-board personal agenda) | ✅ | ✅ |
| Intake forms that create tasks | ✅ | ✅ |
| Updates / comment threads on tasks | ✅ | ✅ |
| Board templates | ✅ | ✅ |
| CSV export | ✅ | ✅ |
| Per-task audit history | ✅ | ✅ |
| Automatic versioned backups with one-click restore | managed | ✅ |
| Calendar export (.ics for Apple/Google Calendar) | ✅ | ✅ |
| Slack notifications from automations | ✅ | ✅ (webhook) |
| Installable app with offline support (PWA) | ✅ apps | ✅ |
| Dark mode, undo, activity log | partial | ✅ |
| **Price for the whole team** | **~$6,000 / yr** | **$0** |

## Feature tour
- **7 views on every board:** Table, Kanban, **Timeline (Gantt)**, Calendar, Dashboard, **Form**, and **My Work**
- **⚡ Automations:** click "Automate" on any board and build rules in plain English — *when status changes to Done → move it to a group / set priority / assign someone / post an update*. They run instantly and are unlimited.
- **Task cards:** description, start & due dates, tags, **subitems with progress**, **time tracking with a live timer**, **blocked-by dependencies**, a comment thread, and one-click duplicate
- **Timeline:** bars run start → due, today line, weekend shading, done bars in green — click any bar to open the task
- **My Work:** pick a person and see everything assigned to them across every board, bucketed into Overdue / Today / This week / Later
- **Form:** a request form per board — submissions land straight in the group you choose
- **Dashboards:** status battery, progress per group, open tasks per person, next-7-days list
- Filters, search, sorting, drag-to-reorder, board templates, CSV export, dark mode, undo for deletions, and auto-save throughout

The app opens with a **Getting Started** board that teaches everything, plus a sample project with a working automation you can trigger (set any task to Done and watch it post an update).

## Backups & data safety
- **Automatic snapshots**: the app snapshots itself as you work (and before every import/restore). **Backups** in the sidebar lists them — one click restores any of the last 12.
- **Export/Import** downloads and restores a full backup file; **CSV export** and **calendar (.ics) export** live in the board menu (⋯).
- Every task keeps a **History** log of status, owner, priority, and date changes.

## Install it as an app
Open TeamFlow in Chrome/Edge and click **📲 Install app** in the sidebar (or use the browser's install button). It gets a home-screen icon, opens in its own window, works offline, and the layout adapts to phones.

## The remaining gap (and the plan for it)
Live multi-user sync and 24/7 server-side automations need a real backend. The complete
backend is already written and waiting in [`backend/`](backend/) — a Postgres schema with
in-database automation triggers, server-side audit history, and realtime sync, plus a
10-minute setup guide. Once the Supabase project exists, the app gets rewired to it,
then deployed to a real domain.
