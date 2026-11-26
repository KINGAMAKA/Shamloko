SHAMLOKO — SOCIAL PROFILE PHOTO UPDATE

FILES
- index.html: Updated main SHAMLOKO application.
- admin.html: Current SHAMLOKO admin dashboard with revenue overview, included unchanged.

WHAT CHANGED IN THE MAIN APP
1. Job feed cards show the job poster's circular profile photo beside their name.
2. The job detail page shows the poster's profile photo and name above the job information.
3. Job comments and replies show each commenter's profile photo.
4. Inbox conversation previews show the other member's profile photo.
5. The conversation header and every message bubble show the sender's profile photo.
6. Applicant rows also show applicants' profile photos.
7. If a member has not uploaded a photo, SHAMLOKO shows a circular initial avatar instead.

INSTALLATION
1. Make a backup of the currently deployed index.html.
2. Replace the deployed main index.html with this package's index.html.
3. Keep admin.html as your admin page (this copy retains the current revenue dashboard).
4. Publish/deploy the updated files and refresh the site.

DATABASE REQUIREMENTS
- No SQL migration is required for this visual update.
- The existing profiles.photo_url field and avatars storage bucket are reused.
- Members' existing profile photos are displayed automatically; no one needs to upload again.
- New photos will appear wherever the member is shown after the profile photo is saved.

VALIDATION
- The updated JavaScript passed a syntax check.
- Existing authentication, jobs, applications, comments, messaging and admin flows were retained.
