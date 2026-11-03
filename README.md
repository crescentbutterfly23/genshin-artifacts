# Artifact Appraiser

Grade Genshin Impact artifacts, plan swaps between characters, and track your roster.
It runs as a static site on GitHub Pages. Sign-in and cloud backups are handled by Supabase.

- **With an account:** your artifacts, characters and pictures are saved to your account and sync to every device you sign in on.
- **Without an account:** everything is saved in that browser only. You can copy it into an account later from **Settings → Account**.
- **Backups:** **Settings → Export & backup** downloads a single file that includes every picture. You can restore it into any account.

## Files

| File | What it is |
| --- | --- |
| `index.html` | The whole app |
| `config.js` | Your Supabase project URL and public key, which you fill in once |
| `supabase/setup.sql` | Creates the database table, storage and privacy rules |
| `build.py` | Rebuilds `index.html` from the single-file version of the app |

---

## One-time setup

### 1. Supabase project
1. Create a free project at <https://supabase.com>.
2. Open **SQL Editor → New query**. Paste the whole of `supabase/setup.sql` and click **Run**.
3. Open **Project Settings → API**. Copy the **Project URL** and the **anon public** key into `config.js`.
   **Never** put the `service_role` key in this repository.

### 2. Sign-in settings (Supabase → Authentication)
- **URL Configuration**
  - **Site URL:** `https://<your-github-username>.github.io/<repo-name>/`
  - **Redirect URLs:** add the same address. If you test locally, also add `http://localhost:8765/`.
- **Providers → Email:** turn it on, and keep **Confirm email** on.
- **Policies / Passwords:** set the minimum length to 8 or more, and require letters and digits.
- **Rate limits / Attack protection:** keep the defaults. Turning on CAPTCHA is a good idea if the site becomes public.

### 3. Google sign-in (optional)
1. In <https://console.cloud.google.com>, go to **APIs & Services → Credentials → Create credentials → OAuth client ID**, then choose **Web application**.
2. Under **Authorized redirect URIs**, add `https://<project-ref>.supabase.co/auth/v1/callback`. The exact address is shown on Supabase's Google provider page.
3. Paste the Client ID and Client Secret into **Supabase → Authentication → Providers → Google**, then turn it on.

### 4. Discord sign-in (optional)
1. In <https://discord.com/developers/applications>, click **New Application**, then go to **OAuth2**.
2. Add the redirect `https://<project-ref>.supabase.co/auth/v1/callback`.
3. Paste the Client ID and Client Secret into **Supabase → Authentication → Providers → Discord**, then turn it on.

### 5. GitHub Pages
In the repository, go to **Settings → Pages**. Set **Source** to *Deploy from a branch*, choose `main` and `/ (root)`, then save.
The site will be live at `https://<your-github-username>.github.io/<repo-name>/` within a minute or two.

---

## How privacy works

- Every saved item is a row tagged with its owner's account id. Row Level Security lets a signed-in account read and write **only its own rows**, and visitors who aren't signed in get nothing.
- Pictures are stored in a **private** bucket, in a folder named after the account id. Each account can only read or write its own folder. The app shows pictures through links that expire after six days.
- The `anon` key in `config.js` is public by design. On its own, it can't read anyone's data.

## Moving to your own server later

The app talks to Supabase through a small storage layer (`makeCloudDb` and `makeCloudAssets` in `index.html`). There are two ways to move:

1. **Self-host Supabase.** Supabase is open source and runs on a home server with Docker. Run `supabase/setup.sql` there, then change `config.js` to the new URL and key. Nothing else in the app changes.
2. **Your own API.** Replace those two functions with calls to your server. Each user can then move over with **Export & backup** in the old version and **Restore** in the new one.

## Updating the app

Edit `appraiser.html`, then run `python3 build.py path/to/appraiser.html` to regenerate `index.html`, and commit.
