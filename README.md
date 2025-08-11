# Charter (Capacitor Wrapper)

Wrapper app for iOS & Android that loads `https://chartermarket.app`.

- Deep links: `https://chartermarket.app/*` and custom `charter://` scheme
- External links open in system browser
- Offline fallback page (`www/offline.html`) via basic `sw.js`
- Native Share via Capacitor Share plugin and iOS overlay button
- Handles `window.open` via Capacitor Browser plugin

## Commands

- `npm run cap:sync`
- `npm run cap:open:ios`
- `npm run cap:open:android`

## Notes

- Path contains spaces; consider moving to `~/CharterMobileWrapped` for stable native builds.
- iOS Universal Links require `apple-app-site-association` on your domain.

