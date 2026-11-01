-- XFUDSTAR V3 schema for Supabase
-- Run this in Supabase Dashboard -> SQL Editor.
-- RLS is enabled. The browser's anon key is public; policies enforce access.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  content text not null check (char_length(content) between 1 and 3000),
  created_at timestamptz not null default now()
);

create table if not exists public.clip_projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 160),
  format text not null default '9:16',
  notes text not null default '',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.clip_projects enable row level security;

-- API privileges; RLS policies below still decide which rows are accessible.
grant usage on schema public to authenticated;
grant select on public.profiles to authenticated;
grant select, insert, delete on public.posts to authenticated;
grant select, insert, update, delete on public.clip_projects to authenticated;

-- Helper function: role is checked in the database, not trusted from browser input.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- Profile access: users see their own profile; admins can see all profiles.
drop policy if exists "profile select own or admin" on public.profiles;
create policy "profile select own or admin" on public.profiles
for select to authenticated
using (id = auth.uid() or public.is_admin());

-- No client-side insert/update/delete policy for profiles.
-- This prevents users from promoting themselves to admin.

drop policy if exists "posts read signed in" on public.posts;
create policy "posts read signed in" on public.posts
for select to authenticated
using (true);

drop policy if exists "posts insert own" on public.posts;
create policy "posts insert own" on public.posts
for insert to authenticated
with check (user_id = auth.uid());

drop policy if exists "posts delete own or admin" on public.posts;
create policy "posts delete own or admin" on public.posts
for delete to authenticated
using (user_id = auth.uid() or public.is_admin());

drop policy if exists "clips select own or admin" on public.clip_projects;
create policy "clips select own or admin" on public.clip_projects
for select to authenticated
using (user_id = auth.uid() or public.is_admin());

drop policy if exists "clips insert own" on public.clip_projects;
create policy "clips insert own" on public.clip_projects
for insert to authenticated
with check (user_id = auth.uid());

drop policy if exists "clips update own" on public.clip_projects;
create policy "clips update own" on public.clip_projects
for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "clips delete own or admin" on public.clip_projects;
create policy "clips delete own or admin" on public.clip_projects
for delete to authenticated
using (user_id = auth.uid() or public.is_admin());

-- Keep profile rows synchronized with Auth sign-ups.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, role)
  values (new.id, new.email, 'user')
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Allow authenticated users to read profiles needed for public feed author labels.
-- The policy above intentionally limits profile visibility to own/admin.
-- To display public author names instead of email, add a separate public display_name field
-- and a carefully scoped public profile policy before production.

-- IMPORTANT: After creating your owner account through the website and confirming email,
-- replace the email below with that exact address and run this statement ONCE:
-- update public.profiles
-- set role = 'admin'
-- where id = (select id from auth.users where email = 'OWNER_EMAIL_HERE');
--
-- Do not expose your Supabase service_role key or database password.
