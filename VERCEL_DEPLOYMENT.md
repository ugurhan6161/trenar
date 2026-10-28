# Vercel deployment

The website and admin dashboard are separate Flutter web applications. Create
two Vercel projects from the same Git repository:

| Vercel project | Root Directory | Framework preset |
|---|---|---|
| `trenar-web` | `apps/hotelyn_app` | Other |
| `trenar-admin` | `apps/hotelyn_dashboard` | Other |

For each project, enable **Include source files outside of the Root Directory**
in its Root Directory settings. Both apps use workspace packages in the
repository-level `packages/` directory. Keep the checked-in install, build, and
output settings in each app's `vercel.json`; do not override them in the project
settings.

If the install step reports
`bash: ../../scripts/vercel_flutter_install.sh: No such file or directory`,
the Vercel project is not including files outside its app root. Open
**Project Settings → Build and Deployment → Root Directory**, keep the app
directory selected, enable **Include source files outside of the Root
Directory**, save the setting, and redeploy. The shared installer and workspace
packages must both be present in the build checkout.

The installer marks only its downloaded Flutter SDK directory as a Git safe
directory before invoking Flutter. This prevents Git's dubious-ownership check
from stopping Flutter's version detection on Vercel build machines.

The install command installs the pinned Flutter 3.47.2 Linux SDK, resolves the
workspace dependencies, and the build command produces the static site in
`build/web`. A fresh Vercel build downloads the Flutter SDK archive
(approximately 1.57 GB), so the first build can take several minutes.

## Vercel environment variables

Add these values to **Settings → Environment Variables** in **both** Vercel
projects. Select Production, Preview, and Development for each variable if all
deployment types should connect to the same Firebase project.

| Name | Value |
|---|---|
| `FIREBASE_API_KEY` | `AIzaSyAsglemJ-_hi8XjK0DPfniYjDO-fjJX2qA` |
| `FIREBASE_AUTH_DOMAIN` | `bektassigorta-5c167.firebaseapp.com` |
| `FIREBASE_PROJECT_ID` | `bektassigorta-5c167` |
| `FIREBASE_STORAGE_BUCKET` | `bektassigorta-5c167.firebasestorage.app` |
| `FIREBASE_MESSAGING_SENDER_ID` | `256844008742` |
| `FIREBASE_APP_ID` | `1:256844008742:web:422d7e825fd5b3d4f605e7` |
| `FIREBASE_MEASUREMENT_ID` | `G-77MVZHV5FJ` |

These are Firebase Web app configuration values and are embedded in the
downloadable browser application at build time. They are **not secrets** and
must not be treated as credentials or used to grant admin access. Never add
Firebase service-account JSON, private keys, or admin passwords to Vercel
environment variables for these frontend projects.

After adding or changing variables, redeploy so Flutter rebuilds with the new
values.

The current TRENAR storefront and admin flows use Firebase directly, so
`API_BASE_URL` is not required for these two deployments. API-dependent legacy
features are not part of this Firebase-only setup; configure a real HTTPS
backend URL separately if those features are enabled later.

## Firebase Console follow-up

For production admin sign-in, add the deployed admin hostname (for example
`trenar-admin.vercel.app`) under **Authentication → Settings → Authorized
domains** in Firebase Console. Add any custom admin domain there as well.

In **Authentication → Sign-in method**, enable Email/Password and create the
admin account. Then create `admin_users/{auth-uid}` in Firestore with
`{ "enabled": true }`; use the account's actual Firebase Authentication UID as
the document ID. A previously supplied UID was not present in the project's
Authentication export, so verify it or use the UID of the account you create.
The website and admin deployment both use the same Firebase project; enforce
admin access with the `admin_users/{uid}` allowlist and the deployed
`firestore.rules`.

## Deploy

1. Import the repository twice in Vercel, using the root directories above.
2. Set the seven Firebase variables in both projects.
3. Configure the admin Firebase Authentication account and UID allowlist.
4. Add the admin deployment hostname to Firebase Authentication's authorized
   domains.
5. Deploy each project. Subsequent Git pushes deploy both projects
   independently.

Both apps use Flutter hash-based navigation, so static hosting does not need
server-side route handling. Their root-level `vercel.json` files provide the
build and static-output configuration.
