# Reminder soak test (M2 exit)

**Goal (PRD §11):** over 7 days, on a Pixel and one OEM phone (Samsung,
Xiaomi or similar), **100% of reminders arrive**: exact ones within 1 minute,
inexact ones within 15 minutes, including after a reboot.

## Setup (both phones)

1. Install the release build. Allow notifications. On one phone allow exact
   timing (Settings › Exact timing); leave it off on the other, to cover the
   inexact path.
2. Leave battery settings at their defaults on the OEM phone. That's the
   point of testing it.
3. Settings › Reminders: **Standard**, quiet hours 22:00–07:00.
4. Create these, all starting tomorrow, and note each expected time in the log
   below:

| # | Item | Set up as | Checks |
| --- | --- | --- | --- |
| 1 | Morning meds | Daily 08:00, reminder at the time, skip if missed | exact daily, series advance |
| 2 | Stand-up | Weekdays 09:30, 10 min before | weekly rule |
| 3 | Water plants | Every 2 days, no time, 1 h before | 9:00 default, offsets |
| 4 | Late call | Day 3 at 22:30, reminder at the time | inside quiet hours but timed exactly: arrives **22:30** |
| 5 | Early train | Day 4 at 06:30, reminder 1 h before | 05:30 is in quiet hours: arrives **07:00** |
| 6 | Pay rent | Monthly on day 1 (if within 7 days) or day +5, at the time | monthly |
| 7 | Custom | Day 2, "at a time I choose" 13:13 | absolute reminder |
| 8 | Snoozes | Any reminder: press **Snooze 1 h** once, **Tomorrow** once | snooze |
| 9 | Done from shade | Any reminder: press **Done** with the app closed | background action, next occurrence |

## Events to include

- **Day 2:** reboot the phone at least 30 min before a reminder; don't open
  the app afterwards.
- **Day 4:** change the time zone by +3 h, then back after the next reminder
  (Settings › System › Date & time). "08:00" should stay 08:00 local.
- **Day 5:** force-stop the app from Settings › Apps, don't reopen it.
  (Force-stop cancels alarms on Android by design; note what happens, but it
  doesn't count against the target.)
- **Day 6:** leave the phone untouched overnight (Doze).

## Log

| Day | Item | Expected | Arrived | Late by | Notes |
| --- | --- | --- | --- | --- | --- |
| | | | | | |

Also check each morning that today's occurrence of series 1–3 exists
without opening the app: the midnight run should have created it, so its
reminder fires.

**Pass:** every row arrived, exact ones ≤ 1 min late, inexact ≤ 15 min.
Anything missed: note the phone, Android version, battery setting and
whether the app had been opened since boot.
