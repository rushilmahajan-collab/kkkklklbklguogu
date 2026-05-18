# DNS Redirect to App Setup Guide

## What This Does
When users try to access blocked websites (pornhub.com, etc), they're redirected to `localhost` which displays a scripture block page inside your app, then can open the Shield app with a button tap.

## Files Created

### 1. **PacketTunnelProvider.swift** (MODIFIED)
- Returns `127.0.0.1` (localhost) instead of `0.0.0.0` for blocked domains
- Location: `plugins/vpn-content-blocker/PacketTunnelProvider.swift`
- Key line: `[0x7F, 0x00, 0x00, 0x01]` = 127.0.0.1

### 2. **blockPageServer.ts** (NEW)
- Runs a local HTTP server on `localhost:80`
- Serves an HTML block page with random scripture
- Location: `services/blockPageServer.ts`
- Include 5 bible verses for encouragement

### 3. **deepLinkingConfig.ts** (NEW)
- Configures `shield://` deep linking scheme
- Handles redirects back to your app
- Location: `navigation/deepLinkingConfig.ts`

### 4. **App.integration.tsx** (REFERENCE)
- Shows how to initialize the block page server
- Add to your main `App.tsx`

## Quick Integration Steps

1. **Install dependency:**
   ```bash
   npm install react-native-gcd-web-server
   # or
   yarn add react-native-gcd-web-server
   ```

2. **In your App.tsx or root component:**
   ```javascript
   import BlockPageServer from './services/blockPageServer';

   useEffect(() => {
     BlockPageServer.getInstance().start();
     return () => BlockPageServer.getInstance().stop();
   }, []);
   ```

3. **Setup deep linking in your NavigationContainer:**
   ```javascript
   import { linking } from './navigation/deepLinkingConfig';

   <NavigationContainer linking={linking}>
     {/* your stack */}
   </NavigationContainer>
   ```

4. **Update app.json for URL scheme:**
   ```json
   {
     "expo": {
       "scheme": "shield",
       "plugins": ["./plugins/withVPNContentBlocker"]
     }
   }
   ```

## How It Works

1. User tries to access `pornhub.com`
2. DNS query resolves to `127.0.0.1` (localhost)
3. Browser tries to load `http://pornhub.com`
4. Localhost server intercepts and serves block page HTML
5. Block page shows:
   - Shield icon
   - Random scripture passage
   - "Open Shield App" button
6. User taps button → Opens app via `shield://` deep link
7. App can log/track the blocked access

## Customization

### Change Scripture Passages
Edit `services/blockPageServer.ts` - modify the `SCRIPTURES` array

### Change Block Page Styling
Edit the `<style>` section in `generateBlockPageHTML()` method

### Change App Deep Link
Update `navigation/deepLinkingConfig.ts` with your custom scheme

## What Happens Without This Setup

- Old behavior: Returns `0.0.0.0` → browser shows "cannot connect" error
- New behavior: Returns `127.0.0.1` → users see your branded block page with scripture

## Testing

1. Start the app (block page server auto-starts)
2. Enable VPN profile on iOS
3. Try accessing a blocked domain in Safari
4. Should see your block page instead of error
5. Tap "Open Shield App" button → Should open your app
