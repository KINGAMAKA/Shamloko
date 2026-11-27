SHAMLOKO — SOCIAL PROFILE + INBOX UPDATE

PACKAGE FILES
- shamloko_index_updated.html — updated member-facing app
- shamloko_profile_social.sql — Supabase migration for the profile photo catalogue
- shamloko_admin_unchanged.html — supplied admin page, included unchanged
- README.txt — installation notes

WHAT CHANGED
1. Profile is redesigned as a social-style member page with a cover area, profile photo, name, username, bio, skills, location and verification/member details.
2. Profile tabs are now Overview, Posted, Saved, Reviews and Photos.
3. The Photos tab lets a member upload an image with a caption to their profile photo catalogue.
4. The account dropdown now includes Edit profile, Free / Light / Pro plans and Settings.
5. Applications, incoming applicants, payment requests, job payments, qualifications and assigned/completed work are presented in Inbox sections, alongside direct conversations.
6. Sharing a job from the feed now adds it to the member's Saved collection on their profile instead of invoking external sharing.
7. Existing job, application, payment approval, membership and direct-message workflows are retained.

INSTALLATION
1. Back up the currently deployed index.html and admin.html.
2. Open Supabase SQL Editor and run shamloko_profile_social.sql.
3. Confirm the migration completes successfully.
4. Deploy shamloko_index_updated.html as index.html (rename it to index.html on your hosting service).
5. Keep the existing admin.html unchanged. The included shamloko_admin_unchanged.html is provided for reference.
6. Hard-refresh the site and test using a normal member account.

IMPORTANT
- The SQL migration creates the profile_posts table and the public profile-photos Storage bucket with owner-scoped upload/delete policies.
- The Inbox reuses the existing messages, job_applications, application_payment_requests, subscription_requests, job_transactions, qualifications and job_assignments tables.
- Existing Supabase RLS policies and RPC permissions still govern payment actions and other protected operations.
- Sharing a job is treated as saving/bookmarking it. It appears in Profile > Saved; this update does not create a separate repost table or a public activity-feed post.
- This package updates the frontend and adds the profile photo catalogue schema. It does not change admin authentication or admin reporting.
