# Firebase setup

The Flutter website and admin dashboard use the same Firebase project:

- Website content: `site_content/public`
- Public booking submissions: `reservation_requests/{generated-id}`
- Admin allowlist: `admin_users/{firebase-auth-uid}`

The Firebase web configuration in `packages/hotelyn_firebase` identifies the
project; it is not an authorization mechanism. Firestore rules enforce access.
Do not add service-account keys or admin credentials to either Flutter app.

## One-time Firebase Console setup

1. Open project `bektassigorta-5c167` in Firebase Console.
2. In **Build → Firestore Database**, create a database in production mode.
3. In **Build → Authentication → Sign-in method**, enable **Email/Password**.
4. In **Authentication → Settings → Authorized domains**, add the production
   website and admin-dashboard domains, along with `localhost` for local tests.
5. Create the administrator account under **Authentication → Users**. Copy its
   UID.
6. In Firestore, create `admin_users/{UID}` (replace `{UID}` with the copied
   value) with this document:

   ```json
   { "enabled": true }
   ```

   This document must be created or changed by a trusted Console user. Client
   writes to `admin_users` are denied.
7. From the project root, publish the included rules:

   ```powershell
   firebase login
   firebase deploy --only firestore:rules
   ```

8. Run the admin dashboard, sign in, and save the initial site content. If no
   `site_content/public` document exists yet, the editor loads the current
   built-in catalogue as the starting content.

## Run locally

Install the Firebase CLI if needed (`npm.cmd install -g firebase-tools`), then run
each web app from its directory:

```powershell
Set-Location apps\hotelyn_app
flutter run -d chrome --target lib\main_development.dart
```

```powershell
Set-Location apps\hotelyn_dashboard
flutter run -d chrome --target lib\main_development.dart
```

Both apps must use the same Firebase project. The admin editor requires an
authenticated account whose UID has an enabled `admin_users` document. The
website reads the public content document and writes unauthenticated booking
requests; customers cannot read or modify submitted requests.

## Mobile Firebase setup

The web configuration is already wired. The Firebase data provided so far is
for the web app only. For Android/iOS builds, register each mobile application
ID in Firebase Console and install its native configuration (`google-services.json`
for Android and `GoogleService-Info.plist` for iOS) with the required platform
build setup. This project initializes native Firebase from those platform
defaults; a generated Dart options file alone is not used by the current
initializer. The web app ID must not be reused as an Android or iOS app ID.

## Security notes

- The included rules intentionally grant public read access only to the single
  published content document and allow public booking creation only with
  bounded, validated fields.
- Only an enabled admin can change published content or read booking requests.
- App Check is recommended before production traffic. Register each web app
  with an App Check provider before enabling enforcement.
- Booking requests contain personal data. Restrict Firebase Console access and
  define a retention/deletion policy before production use.
- If Firebase Storage is added later for editable images, configure separate
  Storage rules; no Storage access is granted by this setup.
