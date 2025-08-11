import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'app.chartermarket',
  appName: 'Charter',
  webDir: 'www',
  server: {
    // Load the production web app directly
    url: 'https://chartermarket.app',
    cleartext: false,
    allowNavigation: ['chartermarket.app', '*.chartermarket.app'],
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


