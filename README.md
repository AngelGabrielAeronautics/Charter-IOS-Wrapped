# Charter iOS/Android Wrapper (Capacitor)

Wrapper app that loads the Charter web experience inside a Capacitor WebView with native integrations.

- Target platforms: iOS and Android
- Current server URL: `https://charter-market.vercel.app` (test)
- Deep links: `https://charter-market.vercel.app/*`, `https://chartermarket.app/*`, and custom scheme `charter://`
- Features: external link handling, offline fallback page, native share, file uploads

## Prerequisites
- Node 18+
- Xcode (iOS), CocoaPods
- Android Studio + SDK

## Install and open
```bash
npm install
npm run cap:sync

# iOS
npm run cap:open:ios  # opens Xcode → Run on a simulator/device

# Android
npm run cap:open:android  # opens Android Studio → Run
```

## Useful scripts
```bash
npm run cap:sync         # sync www/ + config to native
npm run cap:open:ios     # open iOS project in Xcode
npm run cap:open:android # open Android project in Android Studio
npm run assets:generate  # generate app icons & splash once assets are provided
```

## Switch environments
Edit `capacitor.config.ts`:
- Test: `server.url = 'https://charter-market.vercel.app'`
- Prod: `server.url = 'https://chartermarket.app'`

Also keep `allowNavigation` hosts in sync, then:
```bash
npm run cap:sync
```

## Deep links
### iOS (Universal Links)
- `ios/App/App/Info.plist` already includes Associated Domains entries.
- In Xcode, enable the Associated Domains capability for the app target.
- Host an `apple-app-site-association` (no extension, JSON) at the web root of each domain you want to support. Example:
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.app.chartermarket",
        "paths": ["*"]
      }
    ]
  }
}
```
Replace TEAMID with your Apple Developer Team ID.

### Android (App Links)
- `AndroidManifest.xml` includes intent-filters for Charter hosts.
- Optional verification: host `/.well-known/assetlinks.json` on each domain. Example:
```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "app.chartermarket",
      "sha256_cert_fingerprints": [
        "YOUR:APP:SIGNING:CERT:FINGERPRINT"
      ]
    }
  }
]
```

## Features in this wrapper
- External links open in the system browser/Safari view controller
- `window.open` routed to Capacitor Browser plugin
- Offline fallback page: `www/offline.html` via a very basic `www/sw.js`
- Native Share overlay button on iOS and Android
- File uploads: iOS camera/photo usage descriptions added in `Info.plist`

## Icons & splash
Provide source assets and run:
```bash
npm run assets:generate
npm run cap:sync
```
Then open the native projects to review the results.

## Path note
For stable native builds, avoid spaces/special characters in the project path. If needed, move the folder to `~/CharterMobileWrapped` and re-open the native projects.

## License
Private, all rights reserved.

