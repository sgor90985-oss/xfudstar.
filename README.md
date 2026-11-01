# XFUDSTAR V3 — backend-ready starter

## What is included
- Responsive XFUDSTAR interface: AI Studio, World, Clip, City.
- Supabase Auth sign-up/sign-in UI.
- Supabase database schema with Row Level Security (RLS).
- Admin navigation appears only after the database confirms `profiles.role = 'admin'`.
- Admin panel reads user profiles and community posts.
- Clip project storage per signed-in user.

## Honest status
This is a deployable starter, not a fully launched production service. It becomes connected only after you create/configure a Supabase project and deploy the static files. AI generation, real video editing, multiplayer City, payments, and full moderation are not implemented. No real payments are accepted.

## Free deployment plan (adult account owner should handle account setup where required)
1. Create a Supabase project. Choose a strong unique database password and keep it private.
2. In Supabase Dashboard -> SQL Editor, run `supabase-schema.sql`.
3. In Supabase Authentication settings, enable email sign-up and email confirmation. Configure the site's URL and redirect URLs for the eventual GitHub Pages address.
4. In `config.js`, replace `YOUR_SUPABASE_PROJECT_URL` and `YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY` with the project's public URL and anon/publishable key. These are intended for browser use. NEVER put a `service_role` key in the site.
5. Create the first account through the website, confirm the email, then run the final admin SQL statement from `supabase-schema.sql` with that exact email. This is a privileged one-time action in the Supabase SQL Editor. Do not share passwords or secret keys.
6. Create a GitHub repository and upload `index.html`, `config.js`, and optionally this README and SQL file. Enable Settings -> Pages -> Deploy from branch -> `main` / root. GitHub Pages will provide a free `https://USERNAME.github.io/REPOSITORY/` address. Allow time for publishing.
7. In Supabase Auth URL configuration, add that exact GitHub Pages URL to Site URL / Redirect URLs.
8. Test: create a normal user and verify it cannot see Admin; sign in as the admin and verify Admin appears. Test on mobile too.

## Security notes
- RLS is the security boundary. Hiding the Admin link is only presentation.
- `profiles.role` has no user-facing update policy, so users cannot promote themselves using the browser client.
- Never expose service_role keys, database passwords, SMTP credentials, or AI provider secrets.
- Before public launch, get a security review; add rate limits, reporting/moderation, account deletion/export, backups, privacy/terms, abuse prevention, and robust logging.
- This project has not been penetration-tested. Do not store sensitive personal data.
- Static hosting is free but does not provide backend compute. Supabase free-plan quotas and terms can change; review current plan details before relying on it.
- A parent/guardian or other responsible adult should handle hosting/backend accounts and any legal, financial, or payment-provider arrangements where required.

## Limitations in this version
- AI Studio produces a demo template only; no AI model is connected.
- World supports reading and publishing posts after backend setup; full moderation and richer profiles are not implemented.
- Clip saves project briefs, not video files or edits.
- City is a visual local preview, not a shared multiplayer world.
- Card, crypto, and Telegram Stars payments are not integrated.
