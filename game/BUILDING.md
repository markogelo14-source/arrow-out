# Building Arrowly on your Mac

You need a Mac with **Xcode 16 or newer** (free from the Mac App Store). Nothing else to install.

## 1. Run it in the simulator
1. Copy the whole `game` folder to your Mac.
2. Double-click `Arrowly.xcodeproj`.
3. At the top of Xcode, pick an iPhone simulator (for example "iPhone 16 Pro") and press **Run** (▶ or ⌘R).

If Xcode refuses to open the project, run `brew install xcodegen && xcodegen generate` in the `game` folder; it rebuilds the project from `project.yml`.

## 2. Run it on your own iPhone
1. In Xcode, click the blue **Arrowly** project in the left sidebar, then the **Arrowly** target, then **Signing & Capabilities**.
2. Under **Team**, choose your Apple ID (add it in Xcode › Settings › Accounts if it is not listed).
3. Change **Bundle Identifier** from `com.yourname.arrowly` to something unique you own, such as `com.markogelo.arrowly`. Write it down: App Store Connect needs the same one.
4. Plug in your iPhone, pick it at the top of Xcode, press Run. The first time, approve the developer on the phone in Settings › General › VPN & Device Management.

## 3. Upload to the App Store
This needs a paid Apple Developer Program membership ($99/year, developer.apple.com/programs).
1. In App Store Connect (appstoreconnect.apple.com) › Apps › **+** › New App: platform iOS, name "Arrowly", your bundle ID, SKU `arrowly-001`.
2. In Xcode, set the run destination to **Any iOS Device (arm64)**, then **Product › Archive**.
3. When the Organizer window opens, click **Distribute App › App Store Connect › Upload**. Keep the defaults.
4. After processing (usually under an hour), the build appears in App Store Connect under TestFlight and can be attached to the version for review.
5. For every later upload, bump the **Build** number (target › General › Identity) by 1.

Export compliance is already answered in the project (the app uses no non-exempt encryption), so Apple will not ask about it.

## 4. Screenshots
App Store Connect needs iPhone screenshots at 6.9" size. Run the app on the **iPhone 16 Pro Max** simulator (or newer Pro Max) and press **⌘S** in the Simulator to save a screenshot to your Desktop. Good shots: the home screen, an early level, a big later level, the Daily Puzzle, the "Board cleared!" card.

## What is in the project
| Path | What it is |
| --- | --- |
| `Arrowly/ArrowlyApp.swift` | App entry and navigation |
| `Arrowly/Model/` | Game rules, level generator, seeded random numbers (no UI code) |
| `Arrowly/Game/GameModel.swift` | Runs a board: taps, animations, hearts, hints, win/lose |
| `Arrowly/Views/` | Home, game, board, settings screens |
| `Arrowly/Support/` | Colors, haptics, saved progress, links |
| `Arrowly/Assets.xcassets` | App icon (1024px) and accent color |
| `Arrowly/PrivacyInfo.xcprivacy` | Apple privacy manifest (no tracking, no data collected) |
| `ArrowlyCoreTests/` | Tests for the rules and generator: `sh run-tests.sh` in that folder |

## Settings to change before release
- `Arrowly/Support/Theme.swift`, `AppLinks`: replace the example.com privacy policy and support links with the website's real pages.
- Bundle identifier and Team (step 2 above).

## Tuning difficulty
`LevelGenerator.spec(forLevel:)` in `Arrowly/Model/LevelGenerator.swift` sets the board size, how full it is, and the longest arrow for each level. `dailySpec(for:)` sets the Daily Puzzle.
