SHAMLOKO PAYMENT UPDATE

Files:
- index.html: updated main app (Home, Explore, job detail/apply, Profile/Plans)
- admin.html: updated admin dashboard payment queue
- payments_setup.sql: Supabase migration required for payment requests, admin approval, subscription pricing and database enforcement

IMPORTANT SETUP
1. Back up the current Supabase database.
2. Run payments_setup.sql in Supabase SQL Editor.
3. Upload index.html to replace the main app page and admin.html to replace the admin page.
4. Confirm admin_stats() remains restricted to real admin accounts. The dashboard PIN is not backend security.
5. Test with a test account and verify mobile-money receipts manually before approving.

PRICING
- One application: K1.00
- Lite: K9.99 per 30 days, unlimited applications
- Pro: K19.99 per 30 days, unlimited applications

Lite and Pro currently have the same application allowance because no separate Pro benefits were specified.
Payments are manual mobile-money payments; the app does not automatically verify MTN/Airtel transactions.
