import { createContext, useContext, useState, useEffect } from 'react';
import { router, useSegments, useRootNavigationState } from 'expo-router';

type User = {
  id: string;
  email: string;
  roles: ('landlord' | 'renter')[];
} | null;

type AuthContextType = {
  user: User;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  isLoading: boolean;
};

const AuthContext = createContext<AuthContextType | null>(null);

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

function useProtectedRoute(user: User) {
  const segments = useSegments();
  const navigationState = useRootNavigationState();

  useEffect(() => {
    console.log('navigationState', navigationState);
    console.log('user', user);
    if (!navigationState?.key) return;

    const section = segments[0] as string;
    const isAuthRoute = segments[0] === '(auth)';

    // Prevent unnecessary redirects
    if (isAuthRoute) {
        if (!user) return
        else {
            if (user.roles.includes('landlord')) router.replace('/(landlord)/dashboard');
            else router.replace('/(renter)/dashboard');
        }
    } else {
        if (!user) router.replace('/(auth)/login');
        else {
            if (user.roles.includes('landlord') && section === '(renter)') router.replace('/(landlord)/dashboard' as any);
            if (user.roles.includes('renter') && section === '(renter)') router.replace('/(landlord)/dashboard' as any);
        }
    }
  }, [user, segments, navigationState?.key]);
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User>(null);
  const [isLoading, setIsLoading] = useState(true);

  useProtectedRoute(user);

  useEffect(() => {
    checkAuthState();
  }, []);

  async function checkAuthState() {
    try {
      // TODO: Implement actual session check with Supabase
      setIsLoading(false);
    } catch (error) {
      console.error('Error checking auth state:', error);
      setIsLoading(false);
    }
  }

  async function signIn(email: string, password: string) {
    try {
      setIsLoading(true);
      // TODO: Implement actual sign in with Supabase
      setUser({
        id: '123',
        email: email,
        roles: ['landlord'],
      });
    } catch (error) {
      console.error('Error signing in:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }

  async function signOut() {
    try {
      setIsLoading(true);
      // TODO: Implement actual sign out with Supabase
      setUser(null);
      router.push('/signup');
    } catch (error) {
      console.error('Error signing out:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <AuthContext.Provider value={{ user, signIn, signOut, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
} 