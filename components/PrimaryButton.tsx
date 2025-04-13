import { PRIMARY } from "constants/palette";
import { StyleSheet, Text, TouchableOpacity } from "react-native";

interface Props {
  label: string;
  disabled?: boolean;
  onPress: () => void;
}

export const PrimaryButton: React.FC<Props> = ({ label, disabled = false, onPress }) => {
  return (
    <TouchableOpacity 
      style={[styles.primaryButton, disabled && styles.disabledButton]} 
      onPress={onPress}
      disabled={disabled}
    >
      <Text style={[styles.primaryButtonText, disabled && styles.disabledButtonText]}>
        {label}
      </Text>
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
  disabledButton: {
    opacity: 0.6,
  },
  primaryButtonText: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "600",
  },
  disabledButtonText: {
    color: "#E0E0E0",
  },
});
