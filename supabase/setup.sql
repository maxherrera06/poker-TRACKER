-- Lucky Odds: run this once in your Supabase project (SQL Editor → New query → Run).
-- Each user can only ever see and change their own sessions and hands.

create table if not exists public.sessions (
  id         text primary key,
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  data       jsonb not null,
  created_at timestamptz not null default now()
);

create table if not exists public.hands (
  id         text primary key,
  session_id text not null references public.sessions(id) on delete cascade,
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  data       jsonb not null,
  created_at timestamptz not null default now()
);

create index if not exists hands_session_idx on public.hands(session_id);
create index if not exists sessions_user_idx on public.sessions(user_id);
create index if not exists hands_user_idx    on public.hands(user_id);

alter table public.sessions enable row level security;
alter table public.hands    enable row level security;

drop policy if exists "own sessions" on public.sessions;
create policy "own sessions" on public.sessions
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "own hands" on public.hands;
create policy "own hands" on public.hands
  for all to authenticated
  using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    and exists (select 1 from public.sessions s where s.id = session_id and s.user_id = auth.uid())
  );
