# TeamFlow backend — setup guide

This folder contains everything needed to turn TeamFlow into a real multi-user product:
live sync between teammates, real logins, and automations that run on the server 24/7
(inside the database itself — see `schema.sql`, section "SERVER-SIDE AUTOMATIONS").

## What you (Sam) need to do — about 10 minutes

1. **Create the project**
   - Go to [supabase.com](https://supabase.com) → sign up → **New project**
   - Name: `teamflow` · Region: pick the closest US region · Set a strong database password (save it)
   - Plan: **Pro ($25/mo)** recommended — the free tier pauses projects after a week of
     inactivity, which is wrong for an always-on team tool. Still ~99.5% cheaper than monday.com.

2. **Install the schema**
   - In the project dashboard: **SQL Editor** → New query
   - Paste the entire contents of `schema.sql` → **Run**
   - You should see "Success. No rows returned."

3. **Turn on logins**
   - **Authentication → Providers**: make sure **Email** is enabled
   - **Authentication → Users → Invite user**: invite each teammate's email

4. **Send me two strings**
   - **Settings → API** → copy:
     - `Project URL` (looks like `https://xxxx.supabase.co`)
     - `anon` `public` key (the long one labeled *anon / public*)
   - ⚠️ Do **NOT** send the `service_role` key. That one is a master key — it never
     leaves the Supabase dashboard.

## What happens after that (my job)

- Rewire the app's data layer from localStorage to this database
- Add the login screen (teammates sign in with the emails you invited)
- Subscribe every open browser to realtime changes — edits appear for everyone instantly
- Verify the in-database automations end-to-end
- Then: deploy to a real domain (Vercel/Netlify + the domain you buy), and after that,
  optionally wrap iOS/Android builds with Capacitor for the app stores

## Architecture notes

- **Sync**: Supabase Realtime (Postgres logical replication → websockets). Every table
  is in the realtime publication, so all connected clients converge automatically.
- **Automations**: Postgres triggers (`run_automations()`), not client code. They fire
  on status changes and task creation even if zero browsers are open.
- **Audit trail**: `log_task_changes()` writes to `task_history` server-side, so history
  can't be forged or lost by a client.
- **Permissions**: v1 is single-workspace (all signed-in members see everything) via RLS
  policies. Per-board/private-board permissions are a straightforward later layer.
