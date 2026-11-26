SHAMLOKO PHASE 2 UPDATE PACKAGE

FILES
1. SHAMLOKO-index-payments.html - updated main website file.
2. SHAMLOKO-admin-payments.html - updated admin dashboard file.
3. SHAMLOKO-phase2-upgrade.sql - database migration for the new membership limits, payment approval flow, applicant counts and messaging rules.

CONFIRMED MEMBERSHIP SETTINGS
- Single application: K1.00 per job.
- Light: K9.00 for 30 days, up to 20 applications.
- Pro: K19.99 for 30 days, unlimited applications.

INSTALLATION ORDER
1. Back up the current website files and Supabase database.
2. Confirm that the earlier SHAMLOKO-payments-setup.sql migration has already been run. If it has not, run that migration first.
3. Run SHAMLOKO-phase2-upgrade.sql in Supabase SQL Editor.
4. Replace the currently hosted main website HTML with SHAMLOKO-index-payments.html.
5. Replace the currently hosted admin HTML with SHAMLOKO-admin-payments.html.
6. Sign in as a normal applicant and test the K1 request flow. Approve a test transaction in Admin; return to the job and complete the application.
7. Test Light with 20 applications and verify that the 21st is blocked; test Pro and verify applications remain unlimited during the 30-day membership.
8. Test messaging: the poster should start a conversation from the job's applicant list; the applicant should only be able to reply after that first poster message.

IMPORTANT
- These are updated source files and a database migration; they have not been deployed to your hosting or run against your live Supabase project from this chat.
- The SQL assumes the existing SHAMLOKO tables/columns and admin RPCs described in the earlier payment setup: jobs, profiles, job_applications, subscriptions, application_payment_requests, messages, platform_settings and admin_stats().
- The existing admin_review_sub RPC must continue to create a subscriptions row with plan='lite' or plan='pro' and expires_at 30 days after approval. The migration intentionally does not replace your existing membership approval routine.
- Test in a backup/staging environment before applying to live data.
