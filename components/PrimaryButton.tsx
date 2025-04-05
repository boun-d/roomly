import { PRIMARY } from "constants/palette";
import { StyleSheet, Text, TouchableOpacity } from "react-native";

interface Props {
  label: string;
  onPress: () => void;
}

export const PrimaryButton: React.FC<Props> = ({ label, onPress }) => {
  return (
    <TouchableOpacity style={styles.primaryButton} onPress={onPress}>
      <Text style={styles.primaryButtonText}>{label}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  primaryButton: {
    backgroundColor: PRIMARY,
    padding: 16,
    borderRadius: 12,
    alignItems: "center",
  },
  primaryButtonText: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "600",
  },
});
