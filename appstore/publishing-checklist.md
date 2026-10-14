# App Store publishing checklist: arrow escape game

Game: **Arrowly** (details in game/README.md).
Rules checked against Apple's [upcoming requirements page](https://developer.apple.com/news/upcoming-requirements/) on Oct 14, 2026.

Legend: **[You]** only Marko can do it (account, money, legal, signing). **[Claude]** already prepared in this folder or by another thread.

---

## Stage 0. Before anything else (start today, these take days)

1. **[You] Enroll in the Apple Developer Program** at developer.apple.com/programs/enroll. $99/year.
   - Enroll as an **Individual** (fastest, no D-U-N-S number needed). Your legal name shows as the seller on the App Store.
     An Organization account shows a company name but needs a registered company and a D-U-N-S number (adds 1 to 2 weeks).
   - Needs an Apple Account with two-factor authentication. Approval usually takes 24 to 48 hours.
2. **[You] Have a Mac with Xcode 26 or later.** Since Apr 28, 2026 every upload must be built with Xcode 26 and the iOS 26 SDK.
   The game is SwiftUI, so there is no way around a Mac (a cloud Mac such as MacinCloud works too).
3. **[You] EU trader status** (App Store Connect > Business). Required to be listed in the EU.
   As a hobbyist making a free game you can declare **non-trader**; if you declare trader, your address, phone and email are shown publicly in the EU.
4. **[You] Agreements.** Accept the Free Apps agreement in App Store Connect > Business. Tax and banking forms are only needed if the game is paid or adds in-app purchases or ads revenue later.

## Stage 1. Inside the Xcode project

5. **Bundle ID**, e.g. `com.<yourname>.arrowly` (game/README.md uses the placeholder `com.yourname.arrowly`). Register it at developer.apple.com > Identifiers (Xcode can do it automatically with "Automatically manage signing").
6. **Version 1.0, build 1.** Bump the build number on every upload.
7. **Deployment target iOS 17 or later** (Apple's floor is iOS 13 since Sep 9, 2026; 17 keeps SwiftUI simple).
8. **Export compliance:** add `ITSAppUsesNonExemptEncryption = NO` to Info.plist (the game uses no encryption beyond Apple's own). This skips the encryption question on every upload.
9. **Privacy manifest** `PrivacyInfo.xcprivacy`: required if the game saves progress with `UserDefaults` (almost certain). Declare
   `NSPrivacyAccessedAPICategoryUserDefaults` with reason `CA92.1`, `NSPrivacyTracking = false`, no collected data types. Without it the upload is flagged.
10. **App icon:** one 1024x1024 PNG in the asset catalog (see [screenshots-and-icon.md](screenshots-and-icon.md)).
11. **Launch screen** set (a plain background color is fine).
12. **Orientation and devices:** portrait, iPhone only (`TARGETED_DEVICE_FAMILY = 1`; it still runs on iPads in iPhone mode). Only iPhone screenshots are needed.
13. **No placeholder content, no debug menus, no "beta" wording, no broken buttons.** These are the most common rejections (Guideline 2.1 and 2.3).
14. **Test on a real iPhone** and through **TestFlight** before submitting.

## Stage 2. App Store Connect setup

15. **[You] Create the app** at appstoreconnect.apple.com > Apps > +: platform iOS, name, primary language English (U.S.), bundle ID, SKU (any string, e.g. `arrowly001`).
    The name must be unique on the App Store; if it is taken, try the alternates in [listing.md](listing.md).
16. Paste the listing copy from [listing.md](listing.md): subtitle, promotional text, description, keywords, support URL, marketing URL, copyright.
17. **Category:** Primary **Games**, subcategories **Puzzle** and **Board**.
18. **Age rating:** answer the questionnaire using [age-rating-and-privacy.md](age-rating-and-privacy.md). Expected result: **4+**.
19. **App Privacy:** paste the privacy policy URL and answer "Data Not Collected" (see the same file).
20. **Pricing and availability:** Free, all countries (or leave out countries you do not want).
21. **Screenshots:** upload the 6.9" iPhone set (3 to 10 images). Optional app preview video.
22. **App Review information:** contact name, phone, email; sign-in not required; paste the review notes from [listing.md](listing.md).
23. **Version release:** choose "Manually release this version" so you control launch day (lines up with the website and blog posts).

## Stage 3. Build, test, submit

24. In Xcode: select "Any iOS Device (arm64)", **Product > Archive**, then **Distribute App > App Store Connect > Upload**.
25. Wait for processing (10 to 60 minutes; you get an email). Fix any warnings it emails you.
26. **TestFlight:** install the build on your phone, play through at least 20 levels, check it works offline and after a restart.
27. On the 1.0 version page, pick the build, then **Add for Review > Submit**.
28. Review takes about 24 to 48 hours. If rejected, read the message in Resolution Center, fix, bump the build number, resubmit.
29. When approved: press **Release**, publish the website and blog posts the same day, and update the website's App Store badge link with the real app URL (`https://apps.apple.com/app/id<APP_ID>`).

## Stage 4. After launch

30. Watch App Store Connect > Analytics and crash reports (Xcode Organizer) for the first week.
31. Use **promotional text** (editable without a new build) for announcements.
32. Plan 1.1: ideas such as themes, ads or a "remove ads" purchase. Adding ads changes the privacy and age-rating answers; the alternate answers are already in [age-rating-and-privacy.md](age-rating-and-privacy.md).

---

## What depends on other threads
- **Game thread:** your own bundle ID, confirming nothing is stored besides UserDefaults, real gameplay for screenshots.
- **Website thread:** privacy policy URL and support URL are `https://markogelo14-source.github.io/arrow-out/privacy.html` and `.../support.html` (website/URLS.md). They go live once GitHub Pages is turned on (repo Settings > Pages > Source: GitHub Actions). Both must be live before you submit; Apple checks them.
