import { Stack } from 'expo-router';
import { AuthProvider } from './context/auth';
import '../unistyles'

export default function RootLayout() {
  return (
    <AuthProvider>
      <Stack screenOptions={{ headerShown: true }}>
        {/* Auth Group - Unprotected Routes */}
        <Stack.Screen
          name="(auth)/login"
          options={{
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="(auth)/signup"
          options={{
            headerShown: false,
          }}
        />

        {/* Protected Routes */}
        <Stack.Screen
          name="(landlord)/dashboard"
          options={{
            headerBackVisible: false,
          }}
        />
        <Stack.Screen
          name="(renter)/dashboard"
          options={{
            headerBackVisible: false,
          }}
        />

        {/* Shared Protected Routes */}
        <Stack.Screen
          name="profile"
          options={{
            title: 'Profile',
          }}
        />
        <Stack.Screen
          name="messages"
          options={{
            title: 'Messages',
          }}
        />
        <Stack.Screen
          name="chat/[id]"
          options={{
            title: 'Chat',
          }}
        />

        {/* Landlord Routes */}
        <Stack.Screen
          name="(landlord)/properties"
          options={{
            title: 'My Properties',
          }}
        />
        <Stack.Screen
          name="(landlord)/property/[id]"
          options={{
            title: 'Property Details',
          }}
        />
        <Stack.Screen
          name="(landlord)/property/add"
          options={{
            title: 'Add Property',
          }}
        />
        <Stack.Screen
          name="(landlord)/finances"
          options={{
            title: 'Financial Overview',
          }}
        />
        <Stack.Screen
          name="(landlord)/maintenance"
          options={{
            title: 'Maintenance Requests',
          }}
        />
        <Stack.Screen
          name="(landlord)/announcements"
          options={{
            title: 'Announcements',
          }}
        />

        {/* Renter Routes */}
        <Stack.Screen
          name="(renter)/payments"
          options={{
            title: 'Rent Payments',
          }}
        />
        <Stack.Screen
          name="(renter)/maintenance"
          options={{
            title: 'Maintenance',
          }}
        />
        <Stack.Screen
          name="(renter)/documents"
          options={{
            title: 'Documents',
          }}
        />
        <Stack.Screen
          name="(renter)/property-info"
          options={{
            title: 'Property Information',
          }}
        />
      </Stack>
    </AuthProvider>
  );
}
