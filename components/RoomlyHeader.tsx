import { StyleSheet, Text, View, Image } from "react-native";
import { WHITE } from "constants/palette";

export function RoomlyHeader() {
  return (
    <View style={styles.titleContainer}>
      <Image
        source={require("assets/images/house.png")}
        style={styles.titleIcon}
      />
      <Text style={styles.title}>Roomly</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  titleContainer: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 16,
    gap: 12,
  },
  titleIcon: {
    width: 40,
    height: 40,
    marginBottom: 8,
  },
  title: {
    fontSize: 32,
    fontWeight: "bold",
    color: WHITE,
    textAlign: "left",
  },
}); 