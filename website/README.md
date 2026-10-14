# Arrowly website

Plain static site (HTML + CSS + a little JS). No build step: upload the folder as is to any static host.

## Pages
- `index.html`: landing page with a playable demo board (`assets/demo.js`)
- `privacy.html`: privacy policy. Its URL goes in App Store Connect > App Privacy > Privacy Policy URL.
- `support.html`: support page with FAQ. Its URL goes in App Store Connect > Support URL.
- `blog/`: index plus 3 posts

## Before going live
1. **Game name.** The game is Arrowly (from game/README.md). To rename: `grep -rl "Arrowly" . | xargs sed -i "s/Arrowly/NEW NAME/g"`.
2. **Contact email.** Replace `support@example.com` everywhere with a real address you check.
3. **Privacy policy must match the app.** It says: no accounts, no analytics, no ads, no tracking, no in-app purchases, progress stored on device. If the app adds ads or analytics, update `privacy.html` and the App Store privacy answers together.
4. **App Store button.** In `index.html`, replace the `href="#"` on the "Coming soon on the App Store" button with the real App Store link after launch, and change the label to "Download on the App Store".

## Hosting (free option)
GitHub Pages: create a public repo, push this folder's contents, then Settings > Pages > Deploy from branch `main` / root. The site appears at `https://<username>.github.io/<repo>/`. A custom domain can be added later.
