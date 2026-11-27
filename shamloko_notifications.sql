-- ==========================================
-- SHAMLOKO ENGAGEMENT NOTIFICATIONS
-- ==========================================
-- Run once in Supabase SQL Editor, AFTER shamloko_profile_update2.sql
-- (it needs the shared_jobs table).
-- Sends the job poster a notification when someone likes, comments on,
-- shares or saves their post. Never notifies you about your own actions.
-- If you ALREADY get comment notifications, delete the job_comments
-- trigger block at the bottom to avoid duplicates.

create or replace function public.push_notification(p_user uuid, p_job text, p_body text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  c text[] := array['user_id','body'];
  v text[] := array[quote_literal(p_user::text), quote_literal(p_body)];
  t text;
begin
  if p_job is not null and exists (select 1 from information_schema.columns
     where table_schema='public' and table_name='notifications' and column_name='job_id') then
    c := c || 'job_id'; v := v || quote_literal(p_job);
  end if;
  if exists (select 1 from information_schema.columns
     where table_schema='public' and table_name='notifications' and column_name='type') then
    execute 'select type::text from public.notifications where type is not null limit 1' into t;
    c := c || 'type'; v := v || quote_literal(coalesce(t,'activity'));
  end if;
  if exists (select 1 from information_schema.columns
     where table_schema='public' and table_name='notifications' and column_name='title') then
    c := c || 'title'; v := v || quote_literal('Activity on your post');
  end if;
  execute format('insert into public.notifications(%s) values (%s)',
                 array_to_string(c, ','), array_to_string(v, ','));
exception when others then
  null; -- never block a like/comment/share because a notification failed
end;
$$;

create or replace function public.notify_engagement()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  j jsonb := to_jsonb(new);
  actor text := coalesce(j->>'user_id', j->>'author_id', j->>'commenter_id');
  jid text := j->>'job_id';
  poster uuid;
  ttl text;
  nm text;
  verb text;
begin
  select poster_id, title into poster, ttl from public.jobs where id::text = jid;
  if poster is null or actor is null or poster::text = actor then
    return new;
  end if;
  select coalesce(full_name,'Someone') into nm from public.profiles where id::text = actor;
  verb := case tg_table_name
    when 'job_likes'    then '👍 ' || coalesce(nm,'Someone') || ' liked your post'
    when 'job_comments' then '💬 ' || coalesce(nm,'Someone') || ' commented on your post'
    when 'shared_jobs'  then '🔁 ' || coalesce(nm,'Someone') || ' shared your post'
    when 'saved_jobs'   then '⭐ ' || coalesce(nm,'Someone') || ' saved your post'
    else 'New activity on your post' end;
  perform public.push_notification(poster, jid, verb || ' “' || coalesce(ttl,'') || '”');
  return new;
exception when others then
  return new;
end;
$$;

drop trigger if exists notify_like on public.job_likes;
create trigger notify_like after insert on public.job_likes
  for each row execute function public.notify_engagement();

drop trigger if exists notify_share on public.shared_jobs;
create trigger notify_share after insert on public.shared_jobs
  for each row execute function public.notify_engagement();

drop trigger if exists notify_save on public.saved_jobs;
create trigger notify_save after insert on public.saved_jobs
  for each row execute function public.notify_engagement();

-- Delete this block if comment notifications already exist:
drop trigger if exists notify_comment on public.job_comments;
create trigger notify_comment after insert on public.job_comments
  for each row execute function public.notify_engagement();
