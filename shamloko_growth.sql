-- ==========================================
-- SHAMLOKO GROWTH UPDATE (run once, in order, AFTER the other SQL files)
-- Order: social -> update2 -> notifications -> THIS FILE
-- ==========================================

-- 1. FOLLOWS, CATEGORY FOLLOWS, BLOCKS
create table if not exists public.follows (
  follower_id uuid not null references auth.users(id) on delete cascade,
  followee_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, followee_id),
  check (follower_id <> followee_id)
);
create table if not exists public.category_follows (
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, category_id)
);
create table if not exists public.blocks (
  blocker_id uuid not null references auth.users(id) on delete cascade,
  blocked_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);
alter table public.follows enable row level security;
alter table public.category_follows enable row level security;
alter table public.blocks enable row level security;

drop policy if exists follows_read on public.follows;
create policy follows_read on public.follows for select to authenticated using (true);
drop policy if exists follows_insert on public.follows;
create policy follows_insert on public.follows for insert to authenticated with check (auth.uid() = follower_id);
drop policy if exists follows_delete on public.follows;
create policy follows_delete on public.follows for delete to authenticated using (auth.uid() = follower_id);

drop policy if exists catfollows_all on public.category_follows;
create policy catfollows_all on public.category_follows for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists blocks_all on public.blocks;
create policy blocks_all on public.blocks for all to authenticated
  using (auth.uid() = blocker_id) with check (auth.uid() = blocker_id);

-- 2. REPORTING MEMBERS (reports table gets a reported_user_id column)
alter table public.reports add column if not exists reported_user_id uuid;
alter table public.reports alter column job_id drop not null;

-- 3. SEARCH AT SCALE (database-side search with typo tolerance)
create extension if not exists pg_trgm;
create index if not exists jobs_title_trgm on public.jobs using gin (title gin_trgm_ops);
create index if not exists jobs_desc_trgm on public.jobs using gin (description gin_trgm_ops);

create or replace function public.search_job_ids(terms text[], qtext text, lim int default 200)
returns table(id text, score numeric)
language sql stable
as $$
  select j.id::text,
    (coalesce((select sum(
        case when j.title ilike '%'||t||'%' then 6 else 0 end
      + case when coalesce(c.name,'') ilike '%'||t||'%' then 4 else 0 end
      + case when coalesce(j.description,'') ilike '%'||t||'%' then 2.5 else 0 end)
      from unnest(terms) t), 0) + similarity(j.title, qtext) * 5)::numeric as score
  from public.jobs j
  left join public.categories c on c.id = j.category_id
  where j.deleted_at is null
    and j.status in ('published','applications_open')
    and (exists (select 1 from unnest(terms) t
                 where j.title ilike '%'||t||'%'
                    or coalesce(j.description,'') ilike '%'||t||'%'
                    or coalesce(c.name,'') ilike '%'||t||'%')
         or similarity(j.title, qtext) > 0.25)
  order by 2 desc
  limit lim;
$$;

-- 4. NOTIFICATIONS FOR THE WORK ITSELF (uses push_notification from the notifications file)
create or replace function public.notify_application()
returns trigger language plpgsql security definer set search_path = public as $$
declare poster uuid; ttl text; nm text;
begin
  select poster_id, title into poster, ttl from public.jobs where id::text = new.job_id::text;
  if tg_op = 'INSERT' then
    select coalesce(full_name,'Someone') into nm from public.profiles where id = new.applicant_id;
    if poster is not null and poster <> new.applicant_id then
      perform public.push_notification(poster, new.job_id::text, '📩 ' || nm || ' applied to your job “' || coalesce(ttl,'') || '”');
    end if;
  elsif new.status is distinct from old.status then
    if new.status = 'accepted' then
      perform public.push_notification(new.applicant_id, new.job_id::text, '✅ You were accepted for “' || coalesce(ttl,'') || '”. You can start working on it.');
    elsif new.status = 'rejected' then
      perform public.push_notification(new.applicant_id, new.job_id::text, 'Not selected this time for “' || coalesce(ttl,'') || '”. Keep applying!');
    end if;
  end if;
  return new;
exception when others then return new;
end $$;

drop trigger if exists notify_application_ins on public.job_applications;
create trigger notify_application_ins after insert on public.job_applications
  for each row execute function public.notify_application();
drop trigger if exists notify_application_upd on public.job_applications;
create trigger notify_application_upd after update of status on public.job_applications
  for each row execute function public.notify_application();

create or replace function public.notify_payment_status()
returns trigger language plpgsql security definer set search_path = public as $$
declare j jsonb := to_jsonb(new); u text := coalesce(j->>'user_id', j->>'applicant_id', j->>'payer_id', j->>'requester_id');
begin
  if u is null or new.status is not distinct from old.status then return new; end if;
  if new.status = 'approved' then
    perform public.push_notification(u::uuid, j->>'job_id', '✅ Your transaction was approved. You can start working on the job.');
  elsif new.status = 'rejected' then
    perform public.push_notification(u::uuid, j->>'job_id', '❌ Your transaction was not approved. Check the transaction ID and try again.');
  end if;
  return new;
exception when others then return new;
end $$;

drop trigger if exists notify_payment_app on public.application_payment_requests;
create trigger notify_payment_app after update of status on public.application_payment_requests
  for each row execute function public.notify_payment_status();
drop trigger if exists notify_payment_sub on public.subscription_requests;
create trigger notify_payment_sub after update of status on public.subscription_requests
  for each row execute function public.notify_payment_status();

-- 5. TELL FOLLOWERS ABOUT NEW POSTS
create or replace function public.notify_followers()
returns trigger language plpgsql security definer set search_path = public as $$
declare r record; nm text;
begin
  select coalesce(full_name,'Someone you follow') into nm from public.profiles where id = new.poster_id;
  for r in
    select follower_id as uid, 1 as k from public.follows where followee_id = new.poster_id
    union
    select user_id, 2 from public.category_follows where category_id = new.category_id::text
  loop
    if r.uid <> new.poster_id then
      perform public.push_notification(r.uid, new.id::text,
        case r.k when 1 then '🆕 ' || nm || ' posted: ' else '🔔 New in a category you follow: ' end || coalesce(new.title,''));
    end if;
  end loop;
  return new;
exception when others then return new;
end $$;

drop trigger if exists notify_followers_trg on public.jobs;
create trigger notify_followers_trg after insert on public.jobs
  for each row execute function public.notify_followers();
