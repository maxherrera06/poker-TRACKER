-- Lucky Odds: Friends, profiles and the leaderboard.
-- Run once in Supabase (SQL Editor → New query → Run), after setup.sql.
--
-- What other people can see:
--   * Anyone signed in: your username, avatar, title and points (so they can find and add you).
--   * Only your accepted friends: your results summary (profit, hands, sessions, biggest pot),
--     and only if "Show my results to friends" is on.
--   * Your sessions and hands stay private to you. Nothing here changes that.

create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  username   text not null unique check (username ~ '^[a-z0-9_.]{2,24}$'),
  avatar     int  not null default 0,
  title      text check (char_length(title) <= 40),
  points     int  not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.friendships (
  requester  uuid not null references auth.users(id) on delete cascade,
  addressee  uuid not null references auth.users(id) on delete cascade,
  status     text not null default 'pending' check (status in ('pending','accepted')),
  created_at timestamptz not null default now(),
  primary key (requester, addressee),
  check (requester <> addressee)
);

create table if not exists public.profile_stats (
  id         uuid primary key references auth.users(id) on delete cascade,
  stats      jsonb not null default '{}',
  updated_at timestamptz not null default now()
);

alter table public.profiles      enable row level security;
alter table public.friendships   enable row level security;
alter table public.profile_stats enable row level security;

-- profiles
drop policy if exists "profiles: signed-in users can look people up" on public.profiles;
create policy "profiles: signed-in users can look people up" on public.profiles
  for select to authenticated using (true);
drop policy if exists "profiles: create your own" on public.profiles;
create policy "profiles: create your own" on public.profiles
  for insert to authenticated with check (id = auth.uid());
drop policy if exists "profiles: edit your own" on public.profiles;
create policy "profiles: edit your own" on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- friendships
drop policy if exists "friendships: see your own" on public.friendships;
create policy "friendships: see your own" on public.friendships
  for select to authenticated using (auth.uid() in (requester, addressee));
drop policy if exists "friendships: send a request" on public.friendships;
create policy "friendships: send a request" on public.friendships
  for insert to authenticated with check (requester = auth.uid() and status = 'pending');
drop policy if exists "friendships: accept a request sent to you" on public.friendships;
create policy "friendships: accept a request sent to you" on public.friendships
  for update to authenticated using (addressee = auth.uid()) with check (addressee = auth.uid() and status = 'accepted');
drop policy if exists "friendships: remove or decline" on public.friendships;
create policy "friendships: remove or decline" on public.friendships
  for delete to authenticated using (auth.uid() in (requester, addressee));

-- results summary: you and your accepted friends only
drop policy if exists "stats: you and your friends" on public.profile_stats;
create policy "stats: you and your friends" on public.profile_stats
  for select to authenticated using (
    id = auth.uid() or exists (
      select 1 from public.friendships f
      where f.status = 'accepted'
        and ((f.requester = auth.uid() and f.addressee = profile_stats.id)
          or (f.addressee = auth.uid() and f.requester = profile_stats.id))
    )
  );
drop policy if exists "stats: write your own" on public.profile_stats;
create policy "stats: write your own" on public.profile_stats
  for insert to authenticated with check (id = auth.uid());
drop policy if exists "stats: update your own" on public.profile_stats;
create policy "stats: update your own" on public.profile_stats
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
