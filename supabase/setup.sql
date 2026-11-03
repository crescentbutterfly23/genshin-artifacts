-- Artifact Appraiser: one-time database setup.
-- Paste this whole file into Supabase > SQL Editor > New query, then press Run.
-- It is safe to run more than once.

-- 1) One table holds every saved item (artifacts, characters, picture settings).
create table if not exists public.appraiser_docs (
  user_id    uuid        not null references auth.users(id) on delete cascade,
  coll       text        not null check (coll in ('arts','chars','settings')),
  id         text        not null check (char_length(id) between 1 and 200),
  data       jsonb       not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, coll, id)
);
-- Keep any single item to a sane size (pictures live in Storage, not here).
alter table public.appraiser_docs drop constraint if exists appraiser_docs_size;
alter table public.appraiser_docs add constraint appraiser_docs_size check (pg_column_size(data) < 200000);

-- 2) Row Level Security: each signed-in account can only see and change its own rows.
alter table public.appraiser_docs enable row level security;
alter table public.appraiser_docs force row level security;
drop policy if exists "own rows: read"   on public.appraiser_docs;
drop policy if exists "own rows: insert" on public.appraiser_docs;
drop policy if exists "own rows: update" on public.appraiser_docs;
drop policy if exists "own rows: delete" on public.appraiser_docs;
create policy "own rows: read"   on public.appraiser_docs for select to authenticated using ((select auth.uid()) = user_id);
create policy "own rows: insert" on public.appraiser_docs for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own rows: update" on public.appraiser_docs for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own rows: delete" on public.appraiser_docs for delete to authenticated using ((select auth.uid()) = user_id);
-- Visitors who are not signed in get nothing.
revoke all on public.appraiser_docs from anon;
grant select, insert, update, delete on public.appraiser_docs to authenticated;

-- 3) Private picture storage: files live under <account id>/..., images only, 5 MB max each.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('pictures', 'pictures', false, 5242880, array['image/png','image/jpeg','image/webp','image/gif'])
on conflict (id) do update set public = false, file_size_limit = 5242880,
  allowed_mime_types = array['image/png','image/jpeg','image/webp','image/gif'];

drop policy if exists "pictures: own read"   on storage.objects;
drop policy if exists "pictures: own insert" on storage.objects;
drop policy if exists "pictures: own update" on storage.objects;
drop policy if exists "pictures: own delete" on storage.objects;
create policy "pictures: own read"   on storage.objects for select to authenticated
  using (bucket_id = 'pictures' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "pictures: own insert" on storage.objects for insert to authenticated
  with check (bucket_id = 'pictures' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "pictures: own update" on storage.objects for update to authenticated
  using (bucket_id = 'pictures' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "pictures: own delete" on storage.objects for delete to authenticated
  using (bucket_id = 'pictures' and (storage.foldername(name))[1] = (select auth.uid())::text);
