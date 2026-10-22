# Play Console data safety answers

| Question | Answer |
| --- | --- |
| Does your app collect or share any of the required user data types? | **No** |
| Is all of the user data collected by your app encrypted in transit? | Not applicable (nothing is collected) |
| Do you provide a way for users to request that their data is deleted? | Not applicable. All data is on the device; uninstalling or Trash › Empty removes it |

Why "No" is accurate: the release build declares no `INTERNET` permission
(checked in CI), and there are no analytics, crash-reporting or ads SDKs.
Backups are only written to a destination the user picks, which Play does
not count as collection.

**Ads:** No. **App access:** all functionality available without login.
**Target audience:** 18 and over.
