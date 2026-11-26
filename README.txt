SHAMLOKO — APPLICANT MANAGEMENT UPDATE

FILES
- index.html: updated main application frontend.
- admin.html: matching admin page, unchanged.
- applicant_management.sql: Supabase migration required for secure applicant selection and qualification access.

INSTALLATION
1. Back up the current deployed index.html and admin.html.
2. In Supabase SQL Editor, run applicant_management.sql.
3. Confirm the SQL finishes successfully.
4. Replace the deployed index.html with this package's index.html.
5. Keep admin.html as supplied (it is included for a matched package; it does not need functional changes for this feature).
6. Publish/deploy and hard-refresh the website.

WHAT CHANGES
- Profile > Posted lists each job separately with its application count and a View applicants and job action.
- Job owners can review applicants' introduction, skills, bio, verification status, portfolio and uploaded qualifications.
- Qualification files are opened through short-lived signed URLs; the SQL adds a Storage SELECT policy scoped to posters whose jobs the applicant applied to.
- Selecting a candidate invokes the new select_job_applicant RPC. It calls the existing accept_application RPC first (to preserve the existing assignment workflow), closes the job by setting status to assigned, and rejects all other pending applications.
- Assigned jobs disappear from the home feed because the existing feed only displays published and applications_open jobs.
- Profile > Applications shows pending and selected applications. Rejected applications are intentionally excluded.

IMPORTANT COMPATIBILITY NOTES
- The migration intentionally reuses the existing public.accept_application(uuid) function used by the current app. If that function is missing or has a different signature in your Supabase project, the migration will fail when the new RPC is called; send the exact error before changing anything else.
- The qualification document policy assumes the existing private Storage bucket is named 'qualifications' and uploads use the existing path format user_uuid/filename, as in the current frontend.
- This package does not alter admin authentication, payment logic, existing users, or existing application records.
