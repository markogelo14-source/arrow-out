# Age rating and App Privacy answers

Assumes version 1.0 as planned: single-player, offline, no ads, no analytics, no accounts, no purchases, progress saved only on the device.
If any of that changes, use the "If you add ads later" section.

## Age rating questionnaire (App Store Connect > App Information > Age Rating)

Apple's ratings are now 4+, 9+, 13+, 16+, 18+. The questionnaire was expanded in 2025 and again in 2026 (social media questions, required for new apps since Sep 2026).

| Section | Question (short form) | Answer |
|---|---|---|
| In-app controls | Parental controls | No |
| In-app controls | Age assurance / age verification | No |
| Capabilities | Unrestricted web access | No |
| Capabilities | User-generated content | No |
| Capabilities | Messaging and chat | No |
| Capabilities | Social media features (feed, sharing, discovery of user content) | No |
| Capabilities | Advertising | No |
| Mature themes | Profanity or crude humor | None |
| Mature themes | Horror / fear themes | None |
| Mature themes | Alcohol, tobacco, drug use or references | None |
| Mature themes | Mature or suggestive themes | None |
| Medical or wellness | Medical or treatment information | None |
| Medical or wellness | Health or wellness topics | None |
| Sexuality or nudity | Sexual content, graphic sexual content, nudity | None |
| Violence | Cartoon or fantasy violence | None |
| Violence | Realistic violence, prolonged graphic violence | None |
| Violence | Guns or other weapons | None |
| Chance-based activities | Simulated gambling | None |
| Chance-based activities | Contests | None |
| Chance-based activities | Gambling (real money) | No |
| Chance-based activities | Loot boxes | No |
| Other | Made for Kids | No (leave unchecked, see note) |

**Expected rating: 4+.**

Note on "Made for Kids": do not opt into the Kids category. It brings stricter rules (no third-party analytics or ads, parental gates on links) and makes adding ads later much harder. A 4+ game is still visible to everyone.

## App Privacy ("nutrition label", App Store Connect > App Privacy)

1. Privacy Policy URL: `https://markogelo14-source.github.io/arrow-out/privacy.html` (from the website thread).
2. "Do you or your third-party partners collect data from this app?" **No, we do not collect data from this app.**
3. Result shown on the store: **Data Not Collected**.

Why this is true: progress lives in UserDefaults on the device and never leaves it. Apple only counts data as "collected" when it is sent off the device.
Keep it true: no analytics SDK, no crash SDK other than Apple's own (Apple's built-in crash reports do not need declaring), no network calls.

## In the build (matches the answers above)
- `PrivacyInfo.xcprivacy`: `NSPrivacyTracking` = false, `NSPrivacyTrackingDomains` empty, `NSPrivacyCollectedDataTypes` empty, `NSPrivacyAccessedAPITypes` = UserDefaults with reason `CA92.1`.
- No App Tracking Transparency prompt (not needed without tracking).
- Info.plist `ITSAppUsesNonExemptEncryption` = NO.

## Privacy policy: what it must say (for the website thread)
- The app collects no personal data and has no accounts.
- Game progress and settings are stored only on the user's device and are deleted when the app is deleted.
- No ads, no analytics, no tracking, no data shared with third parties.
- Not directed at children under 13 specifically, but suitable for all ages and collects nothing from anyone.
- Contact email for privacy questions; date of last update.

---

## If you add ads later (e.g. Google AdMob in version 1.1)

Changes you must make at the same time:
- **Age rating:** Capabilities > Advertising: **Yes**. Rating stays 4+ as long as ad content filters are set to G / general audiences in AdMob.
- **App Privacy:** switch to "Yes, we collect data". Typical AdMob declarations: Identifiers (Device ID), Usage Data (Product Interaction, Advertising Data), Diagnostics (Crash Data, Performance Data), Location (Coarse Location). Mark Device ID and Advertising Data as **used for tracking** if you serve personalized ads; purposes: Third-Party Advertising, Analytics.
- **App Tracking Transparency:** add `NSUserTrackingUsageDescription` and show the ATT prompt before personalized ads; serve non-personalized ads if the user declines.
- **Privacy manifest:** the AdMob SDK ships its own; keep the SDK updated.
- **Agreements:** tax and banking are not needed for ad revenue from Apple (AdMob pays you directly), but you need an AdMob account and its own tax forms.
- **EU/UK users:** a consent dialog (Google UMP SDK) is required for personalized ads.
- **Privacy policy:** rewrite it to name the ad network and link to its policy.
