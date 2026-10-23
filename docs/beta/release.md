# Releasing a beta build

Clearing ships to testers through a **closed testing** track on Google Play
(PRD §10, M5). These steps need your Play Console account and your signing
key, so they are done by hand.

## 1. Create the upload key (once)

Keep the keystore and its passwords out of the repository and backed up
somewhere safe. If it is lost, Play App Signing can reset the upload key, but
that takes a support request.

```sh
keytool -genkey -v -keystore ~/keys/clearing-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties` (already in `.gitignore`):

```properties
storeFile=/Users/<you>/keys/clearing-upload.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

`android/app/build.gradle.kts` signs release builds with it. Without the file,
release builds fall back to the debug key, which Play rejects.

## 2. Build

Bump the build number for every upload. Play refuses a repeated one.

```sh
# pubspec.yaml: version: 0.9.0+2  (name+build)
flutter test
flutter build appbundle --release
```

The bundle is `build/app/outputs/bundle/release/app-release.aab`.

Check that the release build still requests no internet access (PRD §9).
CI checks this too:

```sh
flutter build apk --release
"$ANDROID_HOME"/build-tools/*/aapt2 dump permissions \
  build/app/outputs/flutter-apk/app-release.apk | grep -c INTERNET   # → 0
```

Expected permissions: notifications, exact alarms, boot completed, vibrate,
and the wake lock, network state and foreground service that WorkManager
(used by the home-screen widget) declares. None of them reach the network.

## 3. Play Console (first time)

1. Create the app: name **Clearing**, free, app (not game).
   (Run the name-clearance searches first; see `exit-checklist.md`.)
2. **App content:** privacy policy URL (publish `privacy-policy.md`, e.g. via
   GitHub Pages), ads: none, app access: no login, content rating
   questionnaire, target audience 18+, data safety (`data-safety.md`).
3. **Store listing:** text from `store-listing.md`, the icon
   `play-icon-512.png`, a 1024×500 feature graphic and 4–8 phone screenshots.
4. **Exact alarms:** Play asks why the app declares `SCHEDULE_EXACT_ALARM`.
   Answer: user-set reminders at a chosen time, and the user is asked before
   it's used (falls back to inexact alarms without it).
5. **Testing › Closed testing:** create a track, add testers by email list or
   Google Group, upload the `.aab`, add release notes, roll out.
6. Share the opt-in link with testers, along with `tester-guide.md`.

## 4. Releasing to everyone: staged rollout

Once the beta is done, move to the Production track and release in stages,
watching Android vitals (Play Console › Quality › Android vitals) at each:

| Stage | Share of users | Wait | Go on if |
| --- | --- | --- | --- |
| 1 | 5% | 2–3 days | No new crash cluster; crash and ANR rates flat |
| 2 | 20% | 2–3 days | Same, and no reminder or data-loss reports |
| 3 | 50% | 2–3 days | Same |
| 4 | 100% | — | |

If a stage goes wrong, **halt the rollout** (it stops new installs of the
release; people who have it keep it) and ship a fix as the next build.
Keep user-perceived crash and ANR rates well under Play's bad-behaviour
thresholds (confirm the current numbers in Play Console). Errors also reach
you when people choose "Send feedback with the error log" in About.

## 5. Each later build

1. Bump `version` in `pubspec.yaml` (build number always; name when it
   matters to testers).
2. `flutter test && flutter build appbundle --release`.
3. Closed testing › Create release › upload › release notes › roll out.
