-- Artifact Appraiser: admin accounts and shared pictures.
-- Run this after setup.sql: paste the whole file into Supabase > SQL Editor > New query, then press Run.
-- It is safe to run more than once.

-- 1) Admin accounts. Only the SQL Editor can add or remove admins; the app can only ask "am I an admin?".
create table if not exists public.appraiser_admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.appraiser_admins enable row level security;
alter table public.appraiser_admins force row level security;
revoke all on public.appraiser_admins from anon, authenticated;

create or replace function public.appraiser_is_admin() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.appraiser_admins where user_id = (select auth.uid()));
$$;
revoke all on function public.appraiser_is_admin() from public;
grant execute on function public.appraiser_is_admin() to anon, authenticated;

-- 2) Shared pictures: element icons, set pictures and character pictures every visitor sees
--    unless they upload their own. Everyone can read them; only admins can change them.
create table if not exists public.appraiser_shared_pics (
  kind       text        not null check (kind in ('el','sets','chars')),
  key        text        not null check (char_length(key) between 1 and 200),
  path       text        not null check (char_length(path) between 1 and 300),
  updated_at timestamptz not null default now(),
  primary key (kind, key)
);
alter table public.appraiser_shared_pics enable row level security;
alter table public.appraiser_shared_pics force row level security;
drop policy if exists "shared pics: read"         on public.appraiser_shared_pics;
drop policy if exists "shared pics: admin insert" on public.appraiser_shared_pics;
drop policy if exists "shared pics: admin update" on public.appraiser_shared_pics;
drop policy if exists "shared pics: admin delete" on public.appraiser_shared_pics;
create policy "shared pics: read"         on public.appraiser_shared_pics for select to anon, authenticated using (true);
create policy "shared pics: admin insert" on public.appraiser_shared_pics for insert to authenticated with check ((select public.appraiser_is_admin()));
create policy "shared pics: admin update" on public.appraiser_shared_pics for update to authenticated using ((select public.appraiser_is_admin())) with check ((select public.appraiser_is_admin()));
create policy "shared pics: admin delete" on public.appraiser_shared_pics for delete to authenticated using ((select public.appraiser_is_admin()));
revoke all on public.appraiser_shared_pics from anon;
grant select on public.appraiser_shared_pics to anon;
grant select, insert, update, delete on public.appraiser_shared_pics to authenticated;

-- 2b) Characters and artifact sets admins add for everyone (released after this version of the app).
create table if not exists public.appraiser_shared_data (
  kind       text        not null check (kind in ('char','set')),
  name       text        not null check (char_length(name) between 1 and 80),
  data       jsonb       not null check (pg_column_size(data) < 20000),
  updated_at timestamptz not null default now(),
  primary key (kind, name)
);
alter table public.appraiser_shared_data enable row level security;
alter table public.appraiser_shared_data force row level security;
drop policy if exists "shared data: read"         on public.appraiser_shared_data;
drop policy if exists "shared data: admin insert" on public.appraiser_shared_data;
drop policy if exists "shared data: admin update" on public.appraiser_shared_data;
drop policy if exists "shared data: admin delete" on public.appraiser_shared_data;
create policy "shared data: read"         on public.appraiser_shared_data for select to anon, authenticated using (true);
create policy "shared data: admin insert" on public.appraiser_shared_data for insert to authenticated with check ((select public.appraiser_is_admin()));
create policy "shared data: admin update" on public.appraiser_shared_data for update to authenticated using ((select public.appraiser_is_admin())) with check ((select public.appraiser_is_admin()));
create policy "shared data: admin delete" on public.appraiser_shared_data for delete to authenticated using ((select public.appraiser_is_admin()));
revoke all on public.appraiser_shared_data from anon;
grant select on public.appraiser_shared_data to anon;
grant select, insert, update, delete on public.appraiser_shared_data to authenticated;

-- 3) Public picture storage for the shared pictures: anyone can view, only admins can upload or delete.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('shared-pictures', 'shared-pictures', true, 5242880, array['image/png','image/jpeg','image/webp','image/gif'])
on conflict (id) do update set public = true, file_size_limit = 5242880,
  allowed_mime_types = array['image/png','image/jpeg','image/webp','image/gif'];

drop policy if exists "shared-pictures: read"         on storage.objects;
drop policy if exists "shared-pictures: admin insert" on storage.objects;
drop policy if exists "shared-pictures: admin update" on storage.objects;
drop policy if exists "shared-pictures: admin delete" on storage.objects;
-- (deleting a file needs read access to it too; the pictures are public anyway)
create policy "shared-pictures: read" on storage.objects for select to anon, authenticated
  using (bucket_id = 'shared-pictures');
create policy "shared-pictures: admin insert" on storage.objects for insert to authenticated
  with check (bucket_id = 'shared-pictures' and (select public.appraiser_is_admin()));
create policy "shared-pictures: admin update" on storage.objects for update to authenticated
  using (bucket_id = 'shared-pictures' and (select public.appraiser_is_admin()));
create policy "shared-pictures: admin delete" on storage.objects for delete to authenticated
  using (bucket_id = 'shared-pictures' and (select public.appraiser_is_admin()));

-- 4) Make your account an admin: put the email you sign in with between the quotes, then run this line.
--    (Sign in to the site once first so the account exists.)
insert into public.appraiser_admins (user_id)
select id from auth.users where lower(email) = lower('YOUR-EMAIL-HERE')
on conflict do nothing;
