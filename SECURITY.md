# Security

## Reporting a problem
If you find a way to see or change another person's data, please don't open a public issue.
Contact the repository owner privately through GitHub instead.

## How the app is built to stay safe
- No secret keys are in this repository. `config.js` holds only the public Supabase URL and anon key.
- Database access is enforced on the server with Row Level Security (`supabase/setup.sql`), so a modified copy of the page still can't reach other people's data.
- Pictures are stored in a private bucket, with each account limited to its own folder. Files are limited to images, 5 MB each.
- The page sets a Content Security Policy that only allows scripts from this site and jsDelivr (for the pinned Supabase library).
- Passwords are handled entirely by Supabase Auth and never touch this site's code or storage.

## If a key leaks
- **anon key:** this is expected to be public. Nothing needs to be done.
- **service_role key:** rotate it right away in Supabase under **Project Settings → API**. It must never be committed here.
