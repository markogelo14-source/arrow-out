# Monetization: how games make money on the App Store, and a plan for Arrowly

Research date: Oct 14, 2026. Game: **Arrowly** (repo `arrow-out`; details in [game/README.md](../game/README.md)).
Sister note: `what-makes-puzzle-games-popular.md` (broad overview, written separately). This note goes deep on money only.

How to read the sources:
- **Primary** = the rule owner or data owner (Apple, Google, AppLovin, Unity, FTC, Sensor Tower's own blog, Liftoff's own report).
- **Secondary** = someone summarizing a primary source (newsletters, law-firm notes, vendor blogs). Labelled as such.
- **[Uncertain]** = could not confirm against the owner's page, or sources conflict. Check before relying on it.

---

## TL;DR

- Arrowly v1 ships free with no ads, no purchases, no data collected. That is a clean, honest launch and needs only the Free Apps agreement.
- Arrow puzzles are the breakout subgenre of 2026, and the charting ones make money mainly from **rewarded ads tied to helpers** (hints, erasers, extra lives), with a "remove ads" purchase on top. Sensor Tower even calls out that the current leader unlocks rewarded ads at level 1 to 2.
- The best fit for a solo dev who does not want to break the "calm, no data" brand is a **ranked, staged plan**:
  1. v1.0: free, no monetization (as planned). Optional tip jar is cheap to add.
  2. v1.1: **StoreKit only**: "Arrowly Plus" one-time unlock (cosmetic themes + unlimited hints + supports the dev), plus a hint pack consumable and tip jar. Keeps "Data Not Collected" and the 4+ rating unchanged.
  3. v1.2 (only if downloads justify it): **rewarded ads only** (extra heart after a loss, extra hint, streak repair), served by AdMob with non-personalized ads by default, and "Plus" removes them. No interstitials unless data says otherwise.
- Apple keeps **15%** of purchases once you join the Small Business Program (free, needs the Paid Apps Agreement). Ad money skips Apple entirely and comes from the ad network.

---

## 1. Where Arrowly stands today (from the repo)

| Thing | State | Why it matters for money |
|---|---|---|
| Tech | SwiftUI, iOS 17+, no third-party code ([BUILDING.md](../game/BUILDING.md)) | StoreKit 2 and its SwiftUI views (`StoreView`, `ProductView`) are available on iOS 17, so a store is cheap to build |
| Backend / accounts | None. Progress in `UserDefaults` only (`Support/PlayerProgress.swift`) | Consumables (hint balance) must be stored locally; no server receipt checks; no cross-device sync of consumables |
| Hearts | 3 per board; out of hearts = "Try again" (`Game/GameModel.swift`, `Views/GameView.swift`) | Natural spot for a rewarded "+1 heart, keep going" |
| Hints | 3 free per board, highlight an arrow that can escape | Natural spot for "extra hint" (ad or purchase) and for "unlimited hints" in a paid unlock |
| Levels | Endless, generated, chapters of 8 on a map | Lots of sessions = lots of natural break points; no content to sell as "level packs" (levels are infinite and free) |
| Daily Puzzle + streak | One per day, streak shown on home, share card | Streak repair / freeze is a proven retention-plus-monetization hook |
| Privacy | `PrivacyInfo.xcprivacy`: no tracking, no collected data; App Store label "Data Not Collected" | Any ad SDK changes this. StoreKit purchases do not (Apple's data, see §5) |
| Store copy | Listing and in-app Settings both promise "No ads, no account, no data collected" ([listing.md](../appstore/listing.md), `Views/SettingsView.swift`) | Adding ads means rewriting listing, privacy policy, Terms, Settings text |
| Website | GitHub Pages at `markogelo14-source.github.io/arrow-out/` | AdMob's `app-ads.txt` must sit at the **root** of the domain (§4.6), which a project-page subfolder cannot do |

---

## 2. How the money flows

### 2.1 Purchases through Apple (paid app or In-App Purchase)
1. Player pays Apple. Apple handles payment, refunds, fraud and (in most countries) sales tax/VAT.
2. Apple keeps its commission and pays you the rest ("proceeds").
3. Payout: "within 45 days of the last day of the fiscal month in which the transaction was completed", one payment per currency, only above a per-country minimum threshold ([Apple: Overview of receiving payments](https://developer.apple.com/help/app-store-connect/getting-paid/overview-of-receiving-payments), accessed Oct 14 2026).

Requirements before any purchase can be sold (same page and [Small Business Program](https://developer.apple.com/app-store/small-business-program/)):
- **Paid Apps Agreement** accepted in App Store Connect > Business (the Free Apps agreement is not enough).
- **Bank account** (one primary account; split accounts not supported).
- **Tax forms**: "All developers must complete a US tax form to comply with the Paid Apps Agreement." US residents get a W-9; non-US developers are walked to a W-8BEN (individual), W-8BEN-E or W-8ECI, plus some country-specific IDs ([Apple: Provide tax information](https://developer.apple.com/help/app-store-connect/manage-tax-information/provide-tax-information)). A W-8BEN can claim a treaty rate on US withholding if your country has a tax treaty with the US. **[Uncertain]** exact withholding depends on Marko's country of residence; not determined here.
- Taxes on the sale: Apple collects and remits in many places under Schedule 2 of the Paid Apps Agreement (stated explicitly for Taiwan and some Mexico cases on the tax page above). **[Uncertain]** the page lists country rules piecemeal and was truncated; Apple's "Understanding taxes" article is the place to confirm for your country. Your own income tax on proceeds is always yours.
- Apple updated the Developer Program License Agreement on **Oct 13, 2026**, including: Apple "will report legally required tax, sales, and contact information to tax authorities" (Schedules 2 and 3, §3.3(a)) ([Apple Developer News, Oct 13 2026](https://developer.apple.com/news/)). Accept it in your account.

### 2.2 Commission rates (as of Oct 2026)

| Case | Apple keeps | Source |
|---|---|---|
| Standard paid app / IAP | 30% | Long-standing standard; the subscriptions page states "you receive 70% ... during a subscriber's first year" ([Apple: Auto-renewable subscriptions](https://developer.apple.com/app-store/subscriptions/)) |
| **Small Business Program** (≤ $1M proceeds prior calendar year, or new developer) | **15%** on paid apps and IAP | [Apple: Small Business Program](https://developer.apple.com/app-store/small-business-program/) |
| Auto-renewable subscription after the subscriber's first paid year | 15% ("your net revenue increases to 85%") | [Apple: Subscriptions](https://developer.apple.com/app-store/subscriptions/) |
| EU storefronts, IAP (new single EU terms from **Oct 1, 2026**) | 26% standard; **15%** for Small Business Program members and subs after year one | [Apple: Update on apps distributed in the EU](https://developer.apple.com/support/dma-and-apps-in-the-eu/) |
| Ads, sold by an ad network | 0% to Apple | Ads are not an Apple transaction; the network pays you (§4) |

Small Business Program details ([Apple](https://developer.apple.com/app-store/small-business-program/)):
- You must enroll (it is not automatic): be Account Holder, accept the latest Paid Apps Agreement, list any associated accounts.
- The reduced rate starts 15 days after the end of the fiscal month in which enrollment is approved. Enroll **before** the first paid product goes live.
- Passing $1M in a year moves future sales to the standard rate; dropping back re-qualifies you the following year.
- Side note from the same page: enrollees under two million first-time downloads can use Apple Foundation Models on Private Cloud Compute without cloud cost (not needed for Arrowly).

### 2.3 EU (DMA) in one paragraph
Since **Oct 1, 2026** EU apps run under one set of terms (Attachment 14 of the License Agreement; the old Alternative Terms Addendum and EU link-out addendum are superseded). In-app IAP commission is 26% (15% for small business), alternative in-app payment processing 20% (10%), link-out "store services commission" 15% (10%) on sales within 7 days of a link tap, and a 5% **Core Technology Commission** on digital sales for apps distributed outside the App Store ([Apple](https://developer.apple.com/support/dma-and-apps-in-the-eu/)). **[Uncertain]** whether the 5% CTC also stacks on App Store IAP: the page scopes it to alternative distribution, which reads as "no", but does not say so outright. For Arrowly this whole area is irrelevant: plain StoreKit IAP, App Store only, = 15% in the EU as elsewhere.

### 2.4 US link-outs (Epic v. Apple) in one paragraph
- Guideline 3.1.1(a) now says link-out entitlements "are not required for developers to include buttons, external links, or other calls to action in their United States storefront apps" ([App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), accessed Oct 14 2026).
- Ninth Circuit (Dec 2025) upheld the contempt finding but said Apple may charge a commission on linked-out purchases limited to costs "genuinely and reasonably necessary", and may stop developers making links more prominent than Apple's own buttons; remanded to set the details (secondary: [Fenwick, Dec 22 2025](https://www.fenwick.com/insights/publications/ninth-circuit-largely-upholds-ruling-in-epic-v-apple)).
- Apple petitioned the Supreme Court (No. 25-1311; petition May 26 2026, merits brief filed Sep 14 2026, per the [Supreme Court docket](https://www.supremecourt.gov/DocketPDF/25/25-1311/424150/20260914154510009_2026-09-14%20No.%2025-1311%20Apple-Epic%20Merits%20Opening%20Brief.pdf)). **[Uncertain]** no decision yet, and secondary reports conflict on what (if any) commission Apple currently charges on US link-outs.
- For Arrowly: ignore. Web checkout needs a website store, payment processor, tax handling and account linking (Arrowly has no accounts). At 15% via IAP the saving is small and the work is large.

---

## 3. The monetization models

### 3.1 Premium (paid upfront)
- How: set a price in App Store Connect; Apple offers hundreds of price points from $0.29 (expanded to ~900 points in Dec 2022 / Mar 2023; secondary: [AppleInsider, Dec 2022](https://appleinsider.com/articles/22/12/06/apple-adding-hundreds-of-app-store-price-points-as-low-as-029)).
- Needs: Paid Apps Agreement, banking, tax. No code.
- Trade-offs: simplest and most privacy-friendly; but a paywall before the first tap kills downloads in a genre where every competitor is free. The arrow-puzzle chart leaders are all free (Arrows Puzzle Escape, Arrows GO!, Amaze GO!, Arrow Puzzle; see §6). **Poor fit.**

### 3.2 Freemium with In-App Purchase
Apple's product types ([Apple: In-App Purchase](https://developer.apple.com/in-app-purchase/)): consumable, non-consumable, auto-renewable subscription, non-renewing subscription.

| Type | What it is | Arrowly example | Notes |
|---|---|---|---|
| Consumable | Used up, can be bought again | "10 hints" pack, tip | Purchased credits/currencies "may not expire" (Guideline 3.1.1). Not restored by Apple, so the balance lives on the device; deleting the app loses it unless you sync (e.g. iCloud key-value store) |
| Non-consumable | Bought once, owned forever | "Arrowly Plus", a theme | Must offer **Restore Purchases** (3.1.1). Family Sharing optional (non-consumables and auto-renewables only) |
| Auto-renewable sub | Recurring | "Plus" monthly | Must "provide ongoing value", min. 7-day period, work on all user devices (3.1.2(a)). Weak fit for a game with no ongoing content service |
| Non-renewing sub | Time-boxed pass | "Season pass" | You track expiry yourself |

Rules that matter (all from the [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), accessed Oct 14 2026):
- Unlocking features, levels, currencies or "full version" **must** use IAP; no license keys or QR codes (3.1.1).
- Tipping via IAP is explicitly allowed: "Apps may use in-app purchase currencies to enable customers to 'tip' the developer" (3.1.1).
- Loot boxes / random items for money: odds must be disclosed before purchase (3.1.1). Arrowly should avoid randomness in paid items altogether; it also keeps the age-rating "Loot boxes" answer at No.
- Subscriptions: describe clearly what the user gets before asking (3.1.2(c)); bait-and-switch gets you removed.

Promotions available ([Apple: Subscriptions](https://developer.apple.com/app-store/subscriptions/); [Apple docs: Supporting offer codes](https://developer.apple.com/documentation/storekit/supporting-offer-codes-in-your-app)):
- Subscriptions: introductory offers (free trial, pay as you go, pay up front; one per subscription group), promotional offers (up to 10 per subscription), win-back offers, offer codes.
- **Offer codes now cover consumables, non-consumables and non-renewing subscriptions too**, not just subscriptions (expanded 2025; redeem via App Store, URL, or in-app sheet). Secondary press says IAP **promo codes** can no longer be created since Mar 26 2026 (offer codes replace them) ([MacTrast, Oct 2025](https://www.mactrast.com/2025/10/apple-announces-new-features-for-app-store-developers/amp/)). Useful for giving "Plus" to reviewers and friends.

Data point on how many players pay: Unity says "only 1-3% of daily active users engage in IAPs" (citing its 2024 Mobile Growth and Monetization Report) ([Unity blog, May 7 2025](https://unity.com/blog/iap-to-hybrid-monetization)). Plan on most players never paying.

### 3.3 Ads (in-app advertising, IAA)
Formats (Google's definitions; AppLovin and Unity use the same three):
- **Rewarded**: player opts in to watch an ad for a reward. "Rewarded ads are served after a user explicitly chooses to view a rewarded ad"; close-button countdown 5 to 30 s ([AdMob: About rewarded ads](https://support.google.com/admob/answer/7372450)).
- **Interstitial**: full-screen ad at a break. "Best placed at natural app transition points" ([AdMob: Interstitial guidance](https://support.google.com/admob/answer/6066980)).
- **Banner**: small strip, always on screen. Lowest value (see eCPM below), and clutters a one-thumb board.

How the money works:
- You earn per 1,000 impressions (eCPM). Revenue ≈ impressions × eCPM / 1000. ARPDAU from ads ≈ (ads shown per daily user) × eCPM / 1000.
- **Mediation** runs an auction across several networks for each impression to raise eCPM: AppLovin MAX, Unity LevelPlay ("a unified auction across multiple ad networks and bidders", [Unity LevelPlay docs](https://docs.unity.com/en-us/grow/levelplay/sdk/ios/rewarded-ads-integration)), or AdMob's own mediation. AppLovin and AdMob together held ~65% of mobile game ad revenue in May 2026 (AppLovin 35.6%, AdMob 29.2%) (secondary summary of Sensor Tower's H1'26 index: [GameDev Reports, Aug 17 2026](https://gamedevreports.substack.com/p/sensor-tower-the-gaming-market-in)).
- eCPM benchmarks (all **secondary vendor blogs**, directional only): US iOS rewarded roughly $14 to $22, interstitial ~$9 to $14, banner well under $1.50 ([Business of Apps, rewarded video, updated Oct 2026](https://www.businessofapps.com/ads/rewarded-video/); [RevenueLab, AdMob eCPM benchmarks 2026](https://www.revenuelab.fyi/blog/admob-ecpm-benchmarks-2026)). Same ad can be worth 4 to 5x more in North America than Latin America. No primary, puzzle-specific iOS eCPM data was found. **[Uncertain]**
- Illustrative math (not a forecast): 1,000 daily players × 0.6 rewarded views each × $15 eCPM = **~$9/day** (ARPDAU $0.009). Adding 1.5 interstitials per player at $10 eCPM adds ~$15/day. Ads need volume: at a few hundred daily players, ads earn pocket change.
- Who pays you: the ad network directly (no Apple cut). AdMob pays monthly once the balance passes the threshold (default $100), "on or around the 21st" of the following month; needs its own tax info and payee profile ([AdMob Help: payment timeline](https://support.google.com/admob/answer/2998394), via search snippet; **[Uncertain]** page not opened directly).

Ad policy limits that shape the design:
- Apple 2.5.18: ads must fit the age rating; interstitials must be clearly ads with an easily visible close button; users must be able to report inappropriate ads; no behavioural ads to kids ([Guidelines](https://developer.apple.com/app-store/review/guidelines/)).
- Apple 3.2.2(iii): no apps "designed predominantly for the display of ads"; 3.2.2(x): you **may** incentivize "watching an ad".
- Apple 5.1.2(i) and the ATT FAQ: you may **not** reward or gate anything on accepting tracking ([Apple: User privacy and data use](https://developer.apple.com/app-store/user-privacy-and-data-use/)).
- AdMob rewarded policy: clear disclosure of the reward before each ad, opt-in only, declining must not hurt normal play, deliver the reward, no cash/gift-card rewards, no extra text beyond describing the reward ([AdMob: Policies for ad units that offer rewards](https://support.google.com/admob/answer/7313578)).
- AdMob disallowed interstitials: on app load or exit, after every user action, back-to-back, "suddenly appear when a user is focused on a task", blocking core content ([AdMob: Disallowed interstitial implementations](https://support.google.com/admob/answer/6201362)). So: never mid-board.

### 3.4 Hybrid (ads + IAP)
- The dominant model for puzzle hits. Liftoff: hybrid and hypercasual puzzle titles "combine IAA and IAP through session-length restriction bypasses and purchasable boosters"; it also notes timed "remove ads" offers bought with in-game currency ([Liftoff 2025 Casual Gaming Apps Report](https://liftoff.ai/2025-casual-gaming-apps-report/), data Feb 2024 to Feb 2025).
- Unity's consultancy: implement **rewarded ads first**, add system-initiated ads (interstitials) only after testing; for non-spenders, rewarded comes before interstitials or banners ([Unity, May 2025](https://unity.com/blog/iap-to-hybrid-monetization)).
- Classic indie hybrid = rewarded ads + "Remove Ads" non-consumable + small consumable packs.

### 3.5 Subscriptions
- Allowed in any category (3.1.2) and 85% after year one. But Apple requires "ongoing value", and Arrowly's levels are already endless and free. A sub would have to be "Plus" (no ads, unlimited hints, themes) billed monthly, which players of a calm tap puzzle rarely want. **Not recommended at launch;** reconsider only if a content stream appears (e.g. hand-made weekly packs).

### 3.6 "Remove ads" purchase
- A non-consumable. Only makes sense once there are ads to remove. Note: if the only ads are opt-in rewarded ones, "remove ads" means "grant the reward without the ad", which is a good framing for "Plus".

### 3.7 Tip jar
- Consumable IAPs ("Small tip", "Big tip") with a thank-you message. Explicitly allowed (3.1.1). Zero privacy impact, an afternoon of work with `StoreView`. Earns little, but fits an ad-free indie game with an honest voice.

### 3.8 Apple Arcade
- Apple Arcade games are played "without ads or In-App Purchases" ([Apple: Apple Arcade for developers](https://developer.apple.com/apple-arcade/)). Entry is by pitch: the only route on the page is a contact form for "a fun, unreleased game". Revenue terms, exclusivity and requirements are not public. **[Uncertain]** how Apple pays (reported as upfront funding plus engagement-based pool; not confirmed on any Apple page).
- For Arrowly: the page asks for **unreleased** games; the page also mentions "App Store Greats" (existing hits). A small, already-released generated-level puzzle is a long shot. Worth one email only if v1 is not yet public. **Low priority.**

---

## 4. What ads require, technically and legally

### 4.1 SDK choice for a solo dev
| | Google AdMob | AppLovin MAX | Unity LevelPlay |
|---|---|---|---|
| Setup | One SDK, one dashboard; built-in consent tool (UMP) | SDK key, SKAdNetwork IDs in Info.plist, consent APIs, terms/privacy flow ([AppLovin MAX iOS integration](https://support.applovin.com/en/max/ios/overview/integration/)) | App key + ad unit IDs, LevelPlay SDK 8.1+ ([Unity docs](https://docs.unity.com/en-us/grow/levelplay/sdk/ios/rewarded-ads-integration)) |
| Strength | Simplest; strong fill; G-rated content filter | Biggest share of game ad revenue (35.6%, May 2026, secondary) | Unity Ads demand |
| For Arrowly | **Start here** | Switch if ad revenue becomes meaningful | Alternative to MAX |

Mediation is worth it only at scale; a single network is fine below a few thousand daily players. **[Uncertain]** no primary source gives a threshold; this is judgement.

### 4.2 App Tracking Transparency (ATT)
- Tracking = linking your app's user/device data with other companies' data for targeted ads or ad measurement, or sharing it with a data broker. You need the ATT prompt "to track them or access their device's advertising identifier" ([Apple: User privacy and data use](https://developer.apple.com/app-store/user-privacy-and-data-use/)).
- Ads can run **without** ATT; they are just non-personalized and earn less. You may explain the prompt beforehand but may not incentivize it.
- Opt-in reality: gaming iOS ATT opt-in **39%** in Q1 2026, North America 33%, Europe 36% ([Adjust Gaming App Insights Report 2026](https://a.storyblok.com/f/47007/x/20551740ee/gaming-app-insights-report-2026.pdf), via search summary).
- Attribution without tracking: SKAdNetwork and its successor **AdAttributionKit** (Apple's privacy-preserving install attribution, iOS 17.4+). These matter if Arrowly **buys** ads (user acquisition) or for the ad network's measurement (the SKAdNetwork IDs in Info.plist). **[Uncertain]** Apple's AdAttributionKit page did not render for the fetcher; iOS version from general knowledge.

### 4.3 Consent (GDPR / UK / Switzerland / US states)
- Google requires a **Google-certified CMP integrated with the IAB TCF** to serve personalized ads in the EEA and UK (since Jan 16 2024) and Switzerland (since Jul 31 2024); otherwise no personalized ads there ([AdMob Help: certified CMP requirement](https://support.google.com/admob/answer/13554020), via search snippets).
- Google's **UMP SDK** is such a tool: request consent info every launch, show the form if required, gate ad requests on `canRequestAds`, and provide a "Privacy options" entry point in Settings when required ([AdMob iOS: Get started with UMP](https://developers.google.com/admob/ios/privacy), updated Oct 14 2026). It also has US-state privacy messages and an IDFA explainer message.
- Apple 5.1.1(ii): collecting data needs consent and an easy way to withdraw; paid features must not depend on granting data access.

### 4.4 Privacy label, manifest and policy
- Apple: you must declare data collected by **third-party SDKs** in your app, not just your own code ([Apple: App privacy details](https://developer.apple.com/app-store/app-privacy-details/)). "Collect" = sent off device and kept longer than needed to answer the request.
- Google Mobile Ads SDK may collect: IP address (coarse location), crash logs, performance data, **Device ID** (advertising identifier), **Advertising Data**, other product interactions ([AdMob iOS: data disclosure](https://developers.google.com/admob/ios/privacy/data-disclosure)). So the label moves from "Data Not Collected" to "Data Used to Track You" (if personalized) and "Data Linked/Not Linked to You". The alternate answers are already drafted in [age-rating-and-privacy.md](../appstore/age-rating-and-privacy.md).
- Privacy manifests: Google Mobile Ads SDK 11.2.0+ ships one; with mediation, every adapter must too (same Google page). Apple's list of "commonly used SDKs" that **must** include a manifest and signature did not list GoogleMobileAds, AppLovin or UMP when checked ([Apple: Third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements/)); you are still responsible for all SDK code. Arrowly's own manifest keeps its `UserDefaults` entry.
- StoreKit: Apple says "You are not responsible for disclosing data collected by Apple", and payment info entered outside your app is not "collected" ([Apple: App privacy details](https://developer.apple.com/app-store/app-privacy-details/)). **So IAP alone keeps "Data Not Collected"**, as long as you do not send purchase events to your own analytics.
- Privacy policy, Terms of Use (just added in commit `85369c8`), listing description, Settings text and website all say "no ads"; each needs editing the day ads ship.

### 4.5 Kids and COPPA
- Do not enter the Kids Category: it forbids purchases and links outside a parental gate and mostly forbids third-party ads and analytics (Guideline 1.3).
- A 4+ rating is not "directed to children", but an abstract arrow puzzle may still appeal to kids. The FTC's amended COPPA Rule (published Apr 22 2025, effective Jun 23 2025, **compliance date Apr 22 2026**) tightens rules for child-directed and mixed-audience services, including naming third parties that receive children's data ([Federal Register, Apr 22 2025](https://www.federalregister.gov/documents/2025/04/22/2025-05904/childrens-online-privacy-protection-rule)). **[Uncertain]** whether Arrowly would be judged mixed-audience; it has no kid-themed art or characters, which helps.
- Safe defaults in AdMob: set `maxAdContentRating` to General (SDK setting overrides the dashboard) and use `ageRestrictedTreatment` if ever treating users as children (`tagForChildDirectedTreatment` is deprecated) ([AdMob iOS: Targeting](https://developers.google.com/admob/ios/targeting)).

### 4.6 app-ads.txt (a concrete blocker for Arrowly)
- AdMob verifies app ownership through the **developer website in the App Store "Marketing URL"** and crawls `app-ads.txt` at the **root of that domain** ([AdMob Help: app-ads.txt](https://support.google.com/admob/answer/9363762)). Unverified apps can lose demand.
- Arrowly's site is a GitHub **project** page (`markogelo14-source.github.io/arrow-out/`), so `/arrow-out/app-ads.txt` does not count. Fix: create a user-site repo `markogelo14-source.github.io` with `app-ads.txt` at its root, or move the site to a custom domain.

### 4.7 Age rating
- Ads add "Advertising: Yes" in the questionnaire; the repo's draft says the rating stays 4+ with G-rated ad filters ([age-rating-and-privacy.md](../appstore/age-rating-and-privacy.md)). **[Uncertain]** the exact 2026 questionnaire wording was not re-checked against App Store Connect here.
- IAP alone does not change the age rating (no loot boxes, no gambling).

---

## 5. Requirements by model (cheat sheet)

| Model | Agreements | Code | Privacy label | Rating | Effort (solo) |
|---|---|---|---|---|---|
| Free, nothing | Free Apps | none | Data Not Collected | 4+ | done |
| Tip jar / Plus / hint packs (IAP) | **Paid Apps** + tax + bank + Small Business enrollment | StoreKit 2, restore button, local balance | **unchanged** | unchanged | 1 to 3 days |
| Rewarded ads | AdMob account, AdMob tax/payee | AdMob SDK + UMP, ATT prompt (optional), SKAdNetwork IDs, `app-ads.txt` at domain root | Changes (Device ID, Advertising Data, etc.) | Advertising: Yes | 3 to 5 days + policy rewrite |
| Interstitials | same | frequency caps, break-point logic | same | same | +1 day |
| Subscription | Paid Apps | `SubscriptionStoreView`, entitlement checks, terms/privacy links in paywall | unchanged | unchanged | 2 to 4 days, plus ongoing value obligation |
| Premium | Paid Apps | none | unchanged | unchanged | trivial, hurts downloads |
| Apple Arcade | by invitation | remove all ads/IAP | n/a | n/a | pitch only |

---

## 6. What works in puzzle games (market evidence)

- **Puzzle is the biggest ad genre**: 53% of mobile game ad revenue ($2.65B), Feb to Apr 2026; Block Blast! top ad earner ($127M Jan to May 2026) (secondary summary of Sensor Tower H1'26 index: [GameDev Reports, Aug 17 2026](https://gamedevreports.substack.com/p/sensor-tower-the-gaming-market-in)). Sensor Tower's own deep dive: "Puzzle titles account for more than half of all ad earnings across most of the largest ad networks" ([Sensor Tower, Jun 2026](https://sensortower.com/blog/gaming-deep-dive-ad-monetization-report)).
- **Puzzle IAP is also huge and growing**: #2 genre by IAP, ~$8.07B in H1 2026, up ~20% while overall downloads fell ~12% (secondary, same GameDev Reports summary). Q2 2026: puzzle IAP +17% YoY to >$4B, and puzzle was the only major genre with positive download growth (+1%) ([Sensor Tower Q2 2026 Digital Market Index, Aug 2026](https://sensortower.com/blog/q2-2026-digital-market-index-report)).
- **Arrow puzzles are the 2026 breakout**: Arrows Puzzle Escape became the #1 most-downloaded mobile game worldwide in Q2 2026, Arrows GO! #5, and arrow titles took the top three breakout spots ([Sensor Tower Q2 2026](https://sensortower.com/blog/q2-2026-digital-market-index-report)). This is both good (demand) and bad (crowded, funded competitors).
- **How the arrow leaders monetize**: per Sensor Tower's H1'26 report (secondary summary), Arrow Puzzle overtook Arrows and Amaze GO! by early July; the difference called out is monetization: it unlocks rewarded ads at **level 1 to 2** (vs level 4 in Arrows, level 15 in Amaze GO!) and has more rewarded placements on iOS: **coins, eraser, Grid Guide, Magic Wand, double rewards**. Arrows Puzzle Escape bought ~4.99B ad impressions Jan to May 2026, i.e. it grows by paid UA ([GameDev Reports, Aug 17 2026](https://gamedevreports.substack.com/p/sensor-tower-the-gaming-market-in)).
- **Hybrid is the norm in puzzle**: AppMagic found puzzle = 48% of top-10 hybrid-casual IAP revenue in Q1 2025 (secondary: [GameDev Reports on AppMagic](https://gamedevreports.substack.com/p/appmagic-top-10-hybridcasual-games)); Liftoff: hybrid puzzle revenues up 240% in 12 months (2025 report, via secondary summary; Liftoff's page confirms the IAA+IAP blend) ([Liftoff](https://liftoff.ai/2025-casual-gaming-apps-report/)).
- **Ads matter less in the US than in emerging markets**: ads were 70.3% of game revenue in India vs ~22.1% in the US (Jan to May 2026) (secondary; **[Uncertain]**, not visible on Sensor Tower's public page). Arrowly's English-first, iOS audience skews to IAP-friendly markets.
- **Retention context**: median D1 ~22%, D7 just under 4%, D30 ~0.7 to 0.8% across 11,600 games (2025 data) ([GameAnalytics 2026 Benchmarks](https://www.gameanalytics.com/reports/2026-mobile-pc-gaming-benchmarks), via search summary; genre data not published this year). Most monetization has to happen in the first sessions, which is why leaders surface rewarded ads at level 1 to 2.
- **Not found from a primary source**: puzzle-specific ARPDAU, IAP conversion rate, and iOS puzzle eCPM. The only primary conversion figure is Unity's 1 to 3% of DAU (§3.2).

What this means for a solo indie: the big arrow games win on paid user acquisition (billions of ad impressions) funded by aggressive ad monetization. Arrowly will not out-spend them. Its edge is the opposite: calm, offline, no data, no interruptions. Monetization should earn from fans without breaking that promise, and keep the option of adding rewarded ads if organic downloads turn out large.

---

## 7. Recommendation for Arrowly

### Ranked plan

**#1. Ship v1.0 as planned (free, nothing to buy, no ads).**
- Evidence: the brand promise ("No ads, no account, no data collected") is a differentiator against the ad-heavy leaders (§6), and changing it later is cheap while launching with ads forces the privacy label, ATT, consent and `app-ads.txt` work up front (§4).
- Do now anyway: accept the **Paid Apps Agreement**, tax and banking, and **enroll in the Small Business Program**, because the 15% starts only 15 days after the fiscal month of approval (§2.2). Optional: a 2-tier **tip jar** in Settings (allowed by 3.1.1; privacy unchanged).

**#2. v1.1: StoreKit-only monetization (keeps "Data Not Collected" and 4+).**

| Product | Type | Suggested US price | Why it fits Arrowly |
|---|---|---|---|
| **Arrowly Plus** | Non-consumable | $3.99 (test $2.99 to $4.99) | Unlimited hints, all themes, "supports an indie dev". Hints are Arrowly's only helper today (3 per board), so "unlimited" is a real, clear benefit (3.1.2(c)-style clarity). Later, also "no ads" |
| Theme packs (arrow skins / board colours, e.g. fish, cars, ants from the [shortlist](game-idea-shortlist.md)) | Non-consumable | $0.99 to $1.99 each | Cosmetic, never pay-to-win; restorable; Family Sharing optional |
| Hint pack (e.g. 15 hints) | Consumable | $0.99 | For players who want more than 3 per board but not Plus. Balance must never expire (3.1.1) |
| Tip jar (Small / Big) | Consumable | $0.99 / $4.99 | Explicitly allowed; zero friction |

- Do **not** sell: levels (they are free and endless), hearts with timers (energy systems contradict "no timers, play at your own pace" in the listing), random rewards (loot-box odds disclosure and age-rating answer).
- Placement: a "Store" row in Settings and a soft offer on the **out-of-hints** state and the win card every ~10 levels. Never mid-board.
- Use offer codes for press, friends and support cases (now available for non-consumables and consumables, §3.2).

**#3. v1.2 (only if daily players reach a few thousand): rewarded ads, opt-in only.**
Placements, in order of naturalness (mirrors the arrow leaders' "eraser / magic wand / extra" placements, §6):
1. **"+1 heart, keep going"** on the out-of-hearts card, next to "Try again". Today losing restarts the board; a continue is the highest-intent moment.
2. **"+1 hint"** when the 3 free hints are used.
3. **Daily streak repair**: watch one ad to save a streak missed yesterday (the streak lapses after one missed day, `PlayerProgress.currentStreak`).
4. Optional: "double the confetti / unlock today's theme preview" on the win card.
- Plus owners get every reward without the ad.
- Start rewarded ads early (around level 2 to 4, when the first loss is likely), as the leading arrow game does; Unity also recommends rewarded first (§3.4).
- Serve **non-personalized** ads by default and skip the ATT prompt at first: simpler label, no prompt friction, and only ~33 to 39% would opt in anyway (§4.2). Revisit if eCPM data says personalized is worth it.

**#4. Interstitials: hold back.** Only consider them after rewarded ads are live and only at chapter boundaries (every 8 levels on the map), never on launch, never back-to-back, with Plus removing them (AdMob disallowed list, §3.3). They earn more per player but are the format most likely to hurt a "calm" game's reviews; Unity advises adding them only after testing (§3.4).

**#5. Not recommended:** premium price (all arrow competitors are free), subscriptions (no ongoing content; Apple requires ongoing value), banners (lowest eCPM, clutters a one-thumb board), web checkout / link-outs (no accounts, tiny saving at 15%), Apple Arcade (pitch-only, wants unreleased or established hits; send one email only if v1 is not out yet).

### Implementation and compliance checklist

**Business (Marko, App Store Connect)**
- [ ] Accept the updated License Agreement (Oct 13 2026) and the **Paid Apps Agreement**.
- [ ] Bank account and tax form (W-9 or W-8BEN with treaty claim if applicable).
- [ ] Enroll in the **Small Business Program** before the first product goes live.
- [ ] Create IAP products (IDs like `arrowly.plus`, `arrowly.hints15`, `arrowly.tip.small`), localized names, review screenshot for each. First IAPs are submitted together with an app version.

**StoreKit work (v1.1)**
- [ ] `Store` model: load products with `Product.products(for:)`, buy with `purchase()`, accept only `.verified` transactions, then `finish()`.
- [ ] Listen to `Transaction.updates` at launch; derive Plus/themes from `Transaction.currentEntitlements` (no server needed).
- [ ] "Restore Purchases" button (`AppStore.sync()`), required by 3.1.1.
- [ ] Hint balance in `UserDefaults` (already declared with reason CA92.1); optionally mirror to iCloud key-value store so it survives reinstall (new capability, still Apple data).
- [ ] Plus effects in `GameModel`: unlimited hints (`maxHints`), themes in `Theme.swift`.
- [ ] `.storekit` configuration file for local testing; TestFlight sandbox purchase test.
- [ ] Update `SettingsView` text ("How to play" mentions 3 hints), listing description ("No ads..." stays true), What's New, review notes (mention purchases and where to find them).
- [ ] Privacy label: still **Data Not Collected** as long as no analytics SDK is added.

**Ads work (v1.2, only if pursued)**
- [ ] AdMob account, app registered, ad units (rewarded only), payee and tax info in AdMob.
- [ ] Google Mobile Ads SDK ≥ 11.2.0 (privacy manifest) via SPM; set `maxAdContentRating = General`.
- [ ] UMP: consent request every launch, gate ads on `canRequestAds`, "Privacy options" row in Settings; set up EEA/UK and US-state messages in AdMob's Privacy & messaging.
- [ ] SKAdNetwork IDs in Info.plist; ATT prompt and `NSUserTrackingUsageDescription` only if personalized ads are enabled; never reward accepting tracking.
- [ ] Rewarded UX: clear reward text before the ad, decline leaves play unchanged, reward always delivered (AdMob rewarded policy).
- [ ] "Report this ad" path (Apple 2.5.18).
- [ ] **`app-ads.txt` at a domain root** (user-site repo or custom domain) and that domain as the App Store Marketing URL.
- [ ] Update `PrivacyInfo.xcprivacy` (tracking flag/domains if personalized), App Privacy label (Device ID, Advertising Data, Product Interaction, Crash/Performance, Coarse Location per Google's list), age rating "Advertising: Yes".
- [ ] Rewrite privacy policy, Terms, website, listing copy, Settings privacy text; name Google as an ad partner.

### What to watch after each step
- v1.1: Plus conversion as % of active players (Unity's 1 to 3% of DAU is the realistic ceiling for any IAP; §3.2). If Plus sells well, raise the price test before adding ads.
- v1.2: rewarded views per daily player, eCPM by country (in AdMob), D1/D7 retention before vs after (benchmarks: median D1 ~22%, §6), and App Store review sentiment about ads.

### Open questions
- Marko's tax residency (affects W-8BEN treaty rate and local income tax).
- Whether the 5% EU CTC ever applies to App Store IAP (reads as no).
- Current US link-out commission while Apple v. Epic is at the Supreme Court (irrelevant unless a web store is built).
- Puzzle-specific ARPDAU and iOS eCPM from a primary source: best obtained from Arrowly's own AdMob dashboard after a small test.
