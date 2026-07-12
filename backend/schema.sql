-- ============================================================
-- TeamFlow backend schema for Supabase (Postgres)
-- Paste this whole file into: Supabase Dashboard → SQL Editor → Run
-- ============================================================

-- ---------- profiles (one row per logged-in team member) ----------
create table if not exists profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  name       text not null,
  color      text not null default '#6161ff',
  created_at timestamptz not null default now()
);

-- auto-create a profile when a user signs up
create or replace function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id, name)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', split_part(new.email,'@',1)))
  on conflict (id) do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users for each row execute function handle_new_user();

-- ---------- boards / groups / tasks ----------
create table if not exists boards (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  created_at timestamptz not null default now()
);

create table if not exists groups (
  id         uuid primary key default gen_random_uuid(),
  board_id   uuid not null references boards(id) on delete cascade,
  name       text not null,
  color      text not null default '#579bfc',
  collapsed  boolean not null default false,
  position   double precision not null default 0
);

create table if not exists tasks (
  id          uuid primary key default gen_random_uuid(),
  group_id    uuid not null references groups(id) on delete cascade,
  title       text not null,
  description text not null default '',
  owner_id    uuid references profiles(id) on delete set null,
  status      text not null default 'not_started'
              check (status in ('not_started','working','stuck','done')),
  priority    text not null default 'medium'
              check (priority in ('low','medium','high','critical')),
  start_date  date,
  due_date    date,
  tags        text[] not null default '{}',
  blocked_by  uuid references tasks(id) on delete set null,
  tt_total_ms bigint not null default 0,
  tt_started  timestamptz,
  position    double precision not null default 0,
  created_at  timestamptz not null default now()
);

create table if not exists subitems (
  id       uuid primary key default gen_random_uuid(),
  task_id  uuid not null references tasks(id) on delete cascade,
  title    text not null,
  done     boolean not null default false,
  position double precision not null default 0
);

create table if not exists comments (
  id            uuid primary key default gen_random_uuid(),
  task_id       uuid not null references tasks(id) on delete cascade,
  author_id     uuid references profiles(id) on delete set null,
  is_automation boolean not null default false,
  body          text not null,
  created_at    timestamptz not null default now()
);

create table if not exists task_history (
  id         bigint generated always as identity primary key,
  task_id    uuid not null references tasks(id) on delete cascade,
  body       text not null,
  created_at timestamptz not null default now()
);

create table if not exists automations (
  id          uuid primary key default gen_random_uuid(),
  board_id    uuid not null references boards(id) on delete cascade,
  when_type   text not null check (when_type in ('status','created')),
  when_status text,
  then_type   text not null check (then_type in ('move','priority','assign','comment')),
  then_param  text,   -- group id / priority id / profile id
  then_text   text,   -- comment body
  created_at  timestamptz not null default now()
);

create table if not exists activity (
  id         bigint generated always as identity primary key,
  board_id   uuid references boards(id) on delete cascade,
  body       text not null,
  created_at timestamptz not null default now()
);

-- ---------- Row Level Security ----------
-- Single-workspace model: every signed-in team member can read/write everything.
-- (Per-board permissions can be layered on later.)
do $$
declare t text;
begin
  foreach t in array array['profiles','boards','groups','tasks','subitems',
                           'comments','task_history','automations','activity'] loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists team_all on %I', t);
    execute format(
      'create policy team_all on %I for all to authenticated using (true) with check (true)', t);
  end loop;
end $$;

-- ---------- SERVER-SIDE AUTOMATIONS ----------
-- These run inside the database, 24/7, no browser required.
create or replace function run_automations() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  r automations%rowtype;
  b uuid;
begin
  -- avoid infinite loops when an automation itself updates a task
  if pg_trigger_depth() > 1 then return new; end if;

  select g.board_id into b from groups g where g.id = new.group_id;

  for r in
    select * from automations a
    where a.board_id = b
      and (
        (tg_op = 'INSERT' and a.when_type = 'created')
        or
        (tg_op = 'UPDATE' and a.when_type = 'status'
         and new.status is distinct from old.status
         and a.when_status = new.status)
      )
  loop
    if r.then_type = 'move' then
      update tasks set group_id = r.then_param::uuid
      where id = new.id
        and exists (select 1 from groups g2 where g2.id = r.then_param::uuid and g2.board_id = b);
    elsif r.then_type = 'priority' then
      update tasks set priority = r.then_param where id = new.id;
    elsif r.then_type = 'assign' then
      update tasks set owner_id = r.then_param::uuid where id = new.id;
    elsif r.then_type = 'comment' then
      insert into comments (task_id, is_automation, body)
      values (new.id, true, coalesce(r.then_text, 'Automation triggered'));
    end if;

    insert into task_history (task_id, body)
    values (new.id, '⚡ Automation ran (' || r.then_type || ')');
  end loop;

  return new;
end $$;

drop trigger if exists trg_automations_update on tasks;
create trigger trg_automations_update
  after update of status on tasks
  for each row execute function run_automations();

drop trigger if exists trg_automations_insert on tasks;
create trigger trg_automations_insert
  after insert on tasks
  for each row execute function run_automations();

-- ---------- audit history for key field changes (server-side) ----------
create or replace function log_task_changes() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.status is distinct from old.status then
    insert into task_history (task_id, body) values (new.id, 'Status → ' || new.status);
  end if;
  if new.owner_id is distinct from old.owner_id then
    insert into task_history (task_id, body)
    values (new.id, 'Owner → ' || coalesce((select name from profiles where id = new.owner_id), 'Unassigned'));
  end if;
  if new.priority is distinct from old.priority then
    insert into task_history (task_id, body) values (new.id, 'Priority → ' || new.priority);
  end if;
  if new.due_date is distinct from old.due_date then
    insert into task_history (task_id, body)
    values (new.id, 'Due date → ' || coalesce(new.due_date::text, 'none'));
  end if;
  return new;
end $$;

drop trigger if exists trg_task_history on tasks;
create trigger trg_task_history
  after update on tasks
  for each row execute function log_task_changes();

-- ---------- realtime: push every change to all connected clients ----------
alter publication supabase_realtime add table boards, groups, tasks, subitems, comments, automations, task_history, activity;
