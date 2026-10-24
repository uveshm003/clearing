# Milestone exit checklist

The code for M0–M4 is done and covered by automated tests (`flutter test`;
`flutter test integration_test` on a device). These checks need real
devices or real people, and gate the beta and its end.

## Before inviting testers

- [ ] **M2: reminder soak test** passes on a Pixel and one OEM phone
      (`soak-test.md`).
- [ ] **M3: weekly review** completed end to end on a device with ~20
      inbox items, including leaving mid-way and resuming.
- [ ] **M4: export → uninstall → reinstall → import** restores all items,
      series, lists and settings on a device.
- [ ] **M4: TalkBack walkthrough** of capture, clarify, Today, review and
      reset; **Accessibility Scanner** on each main screen shows no issues.
- [ ] **M4: Today widget**: tap-to-complete updates within 2 s without
      opening the app; widget rolls over at midnight.
- [ ] `flutter test integration_test` passes on a device.
- [ ] Full regression in **airplane mode** (PRD §11 "Truly offline").
- [ ] **Name clearance** (PRD §13): Play Store, App Store and trademark
      searches for "Clearing"; fallbacks "Kept", "Unload".
- [ ] Privacy policy published at a public URL.
- [ ] Release signed with the upload key; build number bumped.

## Post-beta features (releases 1.2–2.0) on a device

These are built and covered by unit, widget and golden tests, but touch the
phone in ways only a phone can check.

- [ ] **Voice capture** works in **airplane mode** with the language pack
      downloaded, and the microphone button is **absent** on a phone without
      an on-device recogniser (never falls back to the cloud).
- [ ] **Automatic backup** runs overnight into a chosen folder (internal and
      SD card), prunes old copies, and restores; an **encrypted** one asks
      for the passphrase and rejects a wrong one.
- [ ] **Quick Settings tile** and **launcher shortcuts** open capture,
      Today, the review and the reset.
- [ ] **Home-screen widgets**: Next thing ticks in the background; the
      Today widget's Inbox line opens the Inbox; the Grove widget shows the
      clearing after it changes.
- [ ] **App lock** asks after the chosen time away; capture works while
      locked; turning it on needs a working screen lock.
- [ ] **Notifications**: lock-screen privacy hides titles; "Pick a time"
      opens the item; replying to the morning summary captures a thought.
- [ ] **Photos** from camera and gallery attach, show, survive a backup
      round trip, and are removed with their item.
- [ ] Release APK still requests **no INTERNET** (the CI job checks this).

## During the beta (M5: 5–10 testers, 2–4 weeks)

- [ ] Usability sessions with 5 people (`usability-sessions.md`).
- [ ] Triage feedback weekly; ship fixes as new closed-testing builds.
- [ ] Revisit the **must-do cap default** (3) after the sessions.

## Success criteria (PRD §11)

| Goal | Measure | Target | Result |
| --- | --- | --- | --- |
| Fast capture | Widget tap → saved, usability sessions | Median ≤ 5 s | |
| Intuitive sorting | Clarify without help | 4 of 5 | |
| Sustainable review | Review with ~20 inbox items | Median ≤ 15 min | |
| Trustworthy reminders | 7-day soak, Pixel + OEM, incl. reboot | 100%; exact ≤ 1 min, inexact ≤ 15 min | |
| Truly offline | Regression in airplane mode | All pass | |
| Lower mental load | Survey Q1–Q2 | Majority improve | |
| Useful notifications | Survey Q3 | < 1 in 5 disable/dismiss | |

## Decided before public release

- Monetisation (recommended: free beta, one-time unlock for v1.1 extras).
- iOS timing (recommended: after Android beta feedback).
