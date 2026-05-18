import * as Linking from 'expo-linking';

const prefix = Linking.createURL('/');

export const linking = {
  prefixes: [prefix, 'shield://'],
  config: {
    screens: {
      Home: '/',
      Blocked: '/blocked',
      Settings: '/settings',
      Stats: '/stats',
      NotFound: '*',
    },
  },
};

export type RootStackParamList = {
  Home: undefined;
  Blocked: { domain?: string } | undefined;
  Settings: undefined;
  Stats: undefined;
  NotFound: undefined;
};

export const handleDeepLink = (url: string) => {
  const route = Linking.parse(url);

  if (route.path === 'blocked') {
    const domain = route.params?.domain as string | undefined;
    return {
      screen: 'Blocked',
      params: { domain },
    };
  }

  if (route.path === 'settings') {
    return { screen: 'Settings' };
  }

  if (route.path === 'stats') {
    return { screen: 'Stats' };
  }

  return { screen: 'Home' };
};
