SHAMLOKO — WARM FOREST THEME (Option A)

Files:
- index.html: main app (Home, Explore Opportunities, Post a Job, Profile, and related screens)
- admin.html: admin dashboard visual theme
- job_shares_setup.sql: existing database migration, included unchanged for convenience

Design palette:
Forest #164E3B · Sage #78977D · Ivory #F5F1E8 · Sand #E8D2A8 · Charcoal #252A28
Typography: Poppins for headings/brand, Inter for body and controls, with system fallbacks.

Implementation notes:
This package applies a CSS-only theme layer. Existing page structure, JavaScript, navigation,
Supabase configuration, forms, and workflows are retained. Google Fonts are loaded when online;
system fonts are used as fallbacks.

Admin access note:
The included admin page retains the temporary development PIN flow from the supplied source.
A front-end PIN is not secure authentication and does not bypass Supabase RPC/RLS admin checks.
Do not deploy the development PIN as production security.
