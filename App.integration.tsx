/**
 * Integration guide for block page server
 * Add this to your App.tsx or root navigation component
 */

import React, { useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { linking } from './navigation/deepLinkingConfig';
import BlockPageServer from './services/blockPageServer';

export default function App() {
  useEffect(() => {
    // Start the block page server when app launches
    const server = BlockPageServer.getInstance();
    server.start().catch(err => console.error('Block server error:', err));

    // Cleanup on app close
    return () => {
      server.stop().catch(err => console.error('Failed to stop server:', err));
    };
  }, []);

  return (
    <NavigationContainer linking={linking} fallback={<LoadingScreen />}>
      {/* Your existing navigation stack here */}
    </NavigationContainer>
  );
}

// Also add this handler to catch deep links from the block page
export function handleBlockedContentDeepLink(url: string) {
  const params = new URLSearchParams(url.split('?')[1]);
  const domain = params.get('domain');

  // Navigate to a "Blocked Content" screen if you want
  console.log('User tried to access blocked domain:', domain);

  // You can show a modal or dedicated screen here
}
