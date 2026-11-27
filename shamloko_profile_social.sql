-- ==========================================
-- SHAMLOKO SOCIAL PROFILE PHOTO CATALOGUE
-- ==========================================
-- Run once in Supabase SQL Editor.

create table if not exists public.profile_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  caption text,
  image_url text not null,
  created_at timestamptz not null default now()
);

create index if not exists profile_posts_user_created_idx
  on public.profile_posts(user_id, created_at desc);

alter table public.profile_posts enable row level security;

drop policy if exists profile_posts_public_read on public.profile_posts;
create policy profile_posts_public_read
  on public.profile_posts
  for select
  using (true);

drop policy if exists profile_posts_owner_insert on public.profile_posts;
create policy profile_posts_owner_insert
  on public.profile_posts
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists profile_posts_owner_delete on public.profile_posts;
create policy profile_posts_owner_delete
  on public.profile_posts
  for delete
  to authenticated
  using (auth.uid() = user_id);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'profile-photos',
  'profile-photos',
  true,
  5242880,
  array['image/jpeg','image/png','image/webp','image/gif']
)
on conflict (id)
do update set
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg','image/png','image/webp','image/gif'];

drop policy if exists profile_photos_public_read on storage.objects;
create policy profile_photos_public_read
  on storage.objects
  for select
  using (bucket_id = 'profile-photos');

drop policy if exists profile_photos_owner_upload on storage.objects;
create policy profile_photos_owner_upload
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'profile-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists profile_photos_owner_delete on storage.objects;
create policy profile_photos_owner_delete
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'profile-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
