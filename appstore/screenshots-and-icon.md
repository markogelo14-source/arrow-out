# Screenshots, app preview and icon specs

Checked Oct 14, 2026. Apple's reference: App Store Connect Help > Screenshot specifications.

## App icon
- **One 1024 x 1024 px PNG**, sRGB, **no transparency (no alpha channel)**, no rounded corners (iOS masks it), no text smaller than you can read on a phone.
- Xcode 26 uses a single-size icon; optionally build it in **Icon Composer** for the iOS 26 Liquid Glass look (light, dark and tinted variants). A flat PNG is still accepted.
- Design brief: one bold arrow (or 2 to 3 interlocking arrows) using the game colors (indigo `#4F46E5`, coral `#F97362`, cream `#FFF8EE`), readable at 60 px. No screenshots, no words, no Apple hardware.
- Keep the key shape inside the center ~80%; corners get clipped by the mask.

## Screenshots: required set (Arrowly is iPhone only)
- **6.9" iPhone display, portrait: 1320 x 2868 px** (also accepted: 1290 x 2796 or 1260 x 2736). Apple scales this set down to all smaller iPhones.
- **3 to 10 images** (Apple's minimum is 1; 3 to 5 is the sweet spot). The first 3 show in search results, so they do most of the work.
- PNG or JPEG, sRGB, **no alpha channel**, exact pixel size, each file under ~8 MB.
- If iPad support is added later: a **13" iPad set at 2064 x 2752 px** (or 2048 x 2732) becomes required.

## How to capture
1. Run the game in the **iPhone 17 Pro Max** simulator in Xcode 26 (its native resolution is 1320 x 2868).
2. Turn on clean status bar first: `xcrun simctl status_bar booted override --time 9:41 --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3`
3. Press **Cmd+S** in the Simulator to save a full-resolution screenshot.
4. Add a caption band on top in Figma/Canva/Keynote at the same 1320 x 2868 canvas. Captions must reflect what the game really does (Guideline 2.3.7: no misleading images).

## Shot list and captions (in this order)
| # | Shows | Caption (big, 2 to 5 words) |
|---|---|---|
| 1 | A mid-size board with one arrow mid-slide (motion trail) | Tap. Slide. Clear. |
| 2 | A blocked arrow bouncing back, hearts visible at the top | Find the right order |
| 3 | A big 8x10 late-game board with long arrows | Endless brain teasers |
| 4 | The Daily Puzzle screen | A new puzzle every day |
| 5 | A hint highlighting a free arrow, or the level-complete screen | Stuck? Get a hint |

Style: same background color family as the icon, caption text in the top 20% of the canvas, game screen below it (optionally inside a device frame). Keep text clear of the bottom home-indicator area.
Every caption matches a real feature in game/README.md (endless generated levels, Daily Puzzle, hints, hearts).

## App preview video (optional, can come in an update)
- 15 to 30 seconds, H.264 or HEVC, .mov/.m4v/.mp4, up to 500 MB, 30 fps.
- 6.9" iPhone portrait: **886 x 1920 px**.
- Must be footage captured from the app itself (screen recording from the Simulator: `xcrun simctl io booted recordVideo preview.mov`), no hands, no device frames, no external footage.
- Autoplays muted, so make the first 3 seconds show an arrow sliding off.

## Website and marketing reuse
- Export the icon also at 512 px and 180 px for the website (favicon / apple-touch-icon).
- Reuse screenshots 1 to 3 on the landing page.
- Use Apple's official "Download on the App Store" badge from developer.apple.com/app-store/marketing/guidelines; do not redraw it.
