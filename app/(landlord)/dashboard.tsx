import { useEffect, useState } from "react";
import {
  StyleSheet,
  Text,
  View,
  ScrollView,
  TouchableOpacity,
  Image,
  FlatList,
} from "react-native";
import { useAuth } from "../context/auth";
import { router } from "expo-router";
import { BACKGROUND, BLACK, PRIMARY, OLIVE, WHITE } from "constants/palette";
import { RoomlyHeader } from "components/RoomlyHeader";
import { PrimaryButton } from "components/PrimaryButton";
import { BlurView } from "expo-blur";

// Mock data for dashboard
const mockMaintenanceRequests = [
  { id: '1', property: 'Sunset Apartments, Unit 3B', issue: 'Leaking faucet', urgency: 'medium', date: '2023-06-15' },
  { id: '2', property: 'Riverdale House', issue: 'Broken AC', urgency: 'high', date: '2023-06-12' },
  { id: '3', property: 'Sunset Apartments, Unit 7A', issue: 'Light fixture', urgency: 'low', date: '2023-06-18' },
];

const mockRentPayments = [
  { id: '1', property: 'Sunset Apartments, Unit 3B', tenant: 'John Doe', amount: 1200, dueDate: '2023-06-30', status: 'pending' },
  { id: '2', property: 'Riverdale House', tenant: 'Jane Smith', amount: 1800, dueDate: '2023-06-30', status: 'overdue' },
  { id: '3', property: 'Sunset Apartments, Unit 7A', tenant: 'Robert Johnson', amount: 950, dueDate: '2023-07-05', status: 'paid' },
];

const mockProperties = [
  { id: '1', name: 'Sunset Apartments', units: 12, occupiedUnits: 10, image: require('assets/images/house.png') },
  { id: '2', name: 'Riverdale House', units: 1, occupiedUnits: 1, image: require('assets/images/house.png') },
  { id: '3', name: 'Oak Residence', units: 8, occupiedUnits: 5, image: require('assets/images/house.png') },
];

export default function LandlordDashboard() {
  const { user, signOut } = useAuth();
  const [selectedProperty, setSelectedProperty] = useState<string | null>(null);

  // Filter maintenance by selected property
  const filteredMaintenance = selectedProperty 
    ? mockMaintenanceRequests.filter(req => req.property.includes(selectedProperty))
    : mockMaintenanceRequests;

  // Filter rent by selected property
  const filteredRent = selectedProperty 
    ? mockRentPayments.filter(payment => payment.property.includes(selectedProperty))
    : mockRentPayments;

  return (
    <ScrollView style={styles.container}>
      <View style={styles.headerContainer}>
        <View style={styles.headerContent}>
          <RoomlyHeader />
          <TouchableOpacity style={styles.profileButton} onPress={() => {}}>
            <View style={styles.profileCircle}>
              <Text style={styles.profileInitial}>{user?.email.charAt(0).toUpperCase()}</Text>
            </View>
          </TouchableOpacity>
        </View>
        <Text style={styles.welcomeText}>Welcome back, Landlord</Text>
      </View>

      {/* Summary Cards */}
      <View style={styles.summaryContainer}>
        <View style={styles.summaryCard}>
          <Text style={styles.summaryTitle}>Maintenance Requests</Text>
          <Text style={styles.summaryNumber}>{filteredMaintenance.length}</Text>
          <View style={styles.urgencyContainer}>
            <View style={styles.urgencyIndicator}>
              <View style={[styles.urgencyDot, styles.urgencyHigh]} />
              <Text style={styles.urgencyText}>High: {filteredMaintenance.filter(m => m.urgency === 'high').length}</Text>
            </View>
            <View style={styles.urgencyIndicator}>
              <View style={[styles.urgencyDot, styles.urgencyMedium]} />
              <Text style={styles.urgencyText}>Medium: {filteredMaintenance.filter(m => m.urgency === 'medium').length}</Text>
            </View>
          </View>
          <TouchableOpacity 
            style={styles.viewAllButton}
            onPress={() => {}}
          >
            <Text style={styles.viewAllText}>View all requests</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.summaryCard}>
          <Text style={styles.summaryTitle}>Rent Payments</Text>
          <Text style={styles.summaryNumber}>
            ${filteredRent.filter(r => r.status === 'pending' || r.status === 'overdue').reduce((sum, item) => sum + item.amount, 0)}
          </Text>
          <Text style={styles.summarySubtext}>due this month</Text>
          <View style={styles.statusContainer}>
            <View style={styles.statusIndicator}>
              <View style={[styles.statusDot, styles.statusOverdue]} />
              <Text style={styles.statusText}>Overdue: {filteredRent.filter(r => r.status === 'overdue').length}</Text>
            </View>
            <View style={styles.statusIndicator}>
              <View style={[styles.statusDot, styles.statusPending]} />
              <Text style={styles.statusText}>Pending: {filteredRent.filter(r => r.status === 'pending').length}</Text>
            </View>
          </View>
          <TouchableOpacity 
            style={styles.viewAllButton}
            onPress={() => {}}
          >
            <Text style={styles.viewAllText}>View all payments</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Property Selection */}
      <View style={styles.sectionContainer}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>My Properties</Text>
          <TouchableOpacity onPress={() => {}}>
            <Text style={styles.addPropertyText}>+ Add Property</Text>
          </TouchableOpacity>
        </View>
        
        <View style={styles.propertiesContainer}>
          <TouchableOpacity
            style={[styles.propertyFilterButton, selectedProperty === null && styles.propertyFilterActive]}
            onPress={() => setSelectedProperty(null)}
          >
            <Text style={styles.propertyFilterText}>All</Text>
          </TouchableOpacity>
          
          {mockProperties.map(property => (
            <TouchableOpacity
              key={property.id}
              style={[
                styles.propertyFilterButton,
                selectedProperty === property.name && styles.propertyFilterActive
              ]}
              onPress={() => setSelectedProperty(
                selectedProperty === property.name ? null : property.name
              )}
            >
              <Text style={styles.propertyFilterText}>{property.name}</Text>
            </TouchableOpacity>
          ))}
        </View>

        <FlatList
          horizontal
          showsHorizontalScrollIndicator={false}
          data={mockProperties}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <TouchableOpacity 
              style={styles.propertyCard}
              onPress={() => {}}
            >
              <BlurView intensity={60} style={styles.propertyCardInner}>
                <Image source={item.image} style={styles.propertyImage} />
                <Text style={styles.propertyName}>{item.name}</Text>
                <Text style={styles.propertyUnits}>
                  {item.occupiedUnits}/{item.units} units occupied
                </Text>
                <View style={styles.propertyStatRow}>
                  <View style={styles.propertyStat}>
                    <Text style={styles.propertyStatNumber}>
                      {mockMaintenanceRequests.filter(req => req.property.includes(item.name)).length}
                    </Text>
                    <Text style={styles.propertyStatLabel}>Issues</Text>
                  </View>
                  <View style={styles.propertyStat}>
                    <Text style={styles.propertyStatNumber}>
                      ${mockRentPayments.filter(payment => 
                          payment.property.includes(item.name) && 
                          (payment.status === 'pending' || payment.status === 'overdue')
                        ).reduce((sum, item) => sum + item.amount, 0)}
                    </Text>
                    <Text style={styles.propertyStatLabel}>Due</Text>
                  </View>
                </View>
              </BlurView>
            </TouchableOpacity>
          )}
          style={styles.propertiesList}
        />
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: BACKGROUND,
  },
  headerContainer: {
    padding: 20,
    paddingTop: 60,
    backgroundColor: BLACK,
  },
  headerContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  welcomeText: {
    fontSize: 18,
    color: '#A0A0A0',
    marginTop: 8,
  },
  profileButton: {
    padding: 4,
  },
  profileCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: PRIMARY,
    alignItems: 'center',
    justifyContent: 'center',
  },
  profileInitial: {
    color: WHITE,
    fontSize: 18,
    fontWeight: 'bold',
  },
  summaryContainer: {
    flexDirection: 'row',
    padding: 20,
    gap: 16,
  },
  summaryCard: {
    flex: 1,
    backgroundColor: BLACK,
    borderRadius: 15,
    padding: 16,
  },
  summaryTitle: {
    fontSize: 14,
    color: '#A0A0A0',
    marginBottom: 8,
  },
  summaryNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: WHITE,
    marginBottom: 4,
  },
  summarySubtext: {
    fontSize: 12,
    color: '#A0A0A0',
    marginBottom: 8,
  },
  urgencyContainer: {
    marginTop: 8,
  },
  urgencyIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 6,
  },
  urgencyDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginRight: 8,
  },
  urgencyHigh: {
    backgroundColor: '#E53E3E',
  },
  urgencyMedium: {
    backgroundColor: '#F6AD55',
  },
  urgencyLow: {
    backgroundColor: '#68D391',
  },
  urgencyText: {
    fontSize: 12,
    color: '#A0A0A0',
  },
  statusContainer: {
    marginTop: 8,
  },
  statusIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 6,
  },
  statusDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginRight: 8,
  },
  statusOverdue: {
    backgroundColor: '#E53E3E',
  },
  statusPending: {
    backgroundColor: '#F6AD55',
  },
  statusPaid: {
    backgroundColor: '#68D391',
  },
  statusText: {
    fontSize: 12,
    color: '#A0A0A0',
  },
  viewAllButton: {
    marginTop: 16,
    padding: 8,
    alignItems: 'center',
  },
  viewAllText: {
    color: PRIMARY,
    fontSize: 14,
    fontWeight: '600',
  },
  sectionContainer: {
    padding: 20,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: WHITE,
  },
  addPropertyText: {
    color: PRIMARY,
    fontSize: 14,
    fontWeight: '600',
  },
  propertiesContainer: {
    flexDirection: 'row',
    marginBottom: 16,
    flexWrap: 'wrap',
    gap: 8,
  },
  propertyFilterButton: {
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 20,
    backgroundColor: OLIVE,
    marginRight: 8,
  },
  propertyFilterActive: {
    backgroundColor: PRIMARY,
  },
  propertyFilterText: {
    color: WHITE,
    fontSize: 13,
  },
  propertiesList: {
    marginLeft: -20,
    paddingLeft: 20,
  },
  propertyCard: {
    width: 220,
    height: 220,
    marginRight: 16,
  },
  propertyCardInner: {
    borderRadius: 15,
    overflow: 'hidden',
    backgroundColor: BLACK,
    padding: 16,
    height: '100%',
  },
  propertyImage: {
    width: 40,
    height: 40,
    marginBottom: 12,
  },
  propertyName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: WHITE,
    marginBottom: 4,
  },
  propertyUnits: {
    fontSize: 14,
    color: '#A0A0A0',
    marginBottom: 16,
  },
  propertyStatRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  propertyStat: {
    alignItems: 'center',
  },
  propertyStatNumber: {
    fontSize: 20,
    fontWeight: 'bold',
    color: WHITE,
  },
  propertyStatLabel: {
    fontSize: 12,
    color: '#A0A0A0',
  },
});