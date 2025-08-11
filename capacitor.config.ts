import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'app.chartermarket',
  appName: 'Charter',
  webDir: 'www',
  server: {
    // Load the test web app directly
    url: 'https://charter-market.vercel.app',
    cleartext: false,
    allowNavigation: [
      'chartermarket.app',
      '*.chartermarket.app',
      'charter-market.vercel.app'
    ],
  },
  ios: {
    allowsLinkPreview: false,
    contentInset: 'automatic',
    scheme: 'charter',
  },
  android: {
    allowMixedContent: false,
  },
};

export default config;


