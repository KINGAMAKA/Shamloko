-- ==========================================
-- SHAMLOKO ACCESS-RULES AUDIT (READ-ONLY: changes nothing)
-- Run each query separately in Supabase SQL Editor and send me the results.
-- ==========================================

-- A. Tables with Row Level Security OFF (anyone with the public key could read/write these)
select tablename from pg_tables
where schemaname = 'public' and not rowsecurity
order by tablename;

-- B. Every policy on your tables
select tablename, policyname, cmd, roles, qual as using_rule, with_check
from pg_policies where schemaname = 'public'
order by tablename, cmd;

-- C. Risky ones: write rules that allow anything (true) or the public/anon role
select tablename, policyname, cmd, roles, qual, with_check
from pg_policies
where schemaname = 'public'
  and cmd in ('INSERT','UPDATE','DELETE','ALL')
  and (qual = 'true' or with_check = 'true' or roles::text ilike '%anon%' or roles::text ilike '%public%');

-- D. Is the notifications table private to each user?
select policyname, cmd, qual from pg_policies
where schemaname = 'public' and tablename = 'notifications';
