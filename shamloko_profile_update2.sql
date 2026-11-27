-- ==========================================
-- SHAMLOKO PROFILE UPDATE 2
-- ==========================================
-- Run once in Supabase SQL Editor, AFTER shamloko_profile_social.sql.

-- 1. COVER PHOTO COLUMN (replaces the green banner on a profile)
alter table public.profiles add column if not exists cover_url text;

-- 2. SHARED JOBS (separate from Saved jobs)
-- Copies the column layout of saved_jobs so the job_id type always matches.
create table if not exists public.shared_jobs (like public.saved_jobs including all);

alter table public.shared_jobs enable row level security;

drop policy if exists shared_jobs_read on public.shared_jobs;
create policy shared_jobs_read
  on public.shared_jobs
  for select
  to authenticated
  using (true);

drop policy if exists shared_jobs_owner_insert on public.shared_jobs;
create policy shared_jobs_owner_insert
  on public.shared_jobs
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists shared_jobs_owner_delete on public.shared_jobs;
create policy shared_jobs_owner_delete
  on public.shared_jobs
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- Prevent sharing the same job twice
create unique index if not exists shared_jobs_user_job_uidx
  on public.shared_jobs(user_id, job_id);
