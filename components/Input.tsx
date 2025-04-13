import { StyleSheet, TextInput } from "react-native";

interface Props {
  type: "email" | "password";
  value: string;
  placeholder: string;
  onChange: (text: string) => void;
}

export const Input: React.FC<Props> = ({ type, value, placeholder, onChange }) => {
  const keyboardType = type === "email" ? "email-address" : "default";
  return (
    <TextInput
      style={styles.input}
      placeholder={placeholder}
      placeholderTextColor="#A0A0A0"
      value={value}
      onChangeText={onChange}
      keyboardType={keyboardType}
      autoCapitalize="none"
      autoComplete="email"
      {...type === 'password' && { secureTextEntry: true }}
    />
  );
};

const styles = StyleSheet.create({
  input: {
    backgroundColor: "#FFFFFF1A",
    padding: 16,
    borderRadius: 12,
    color: "#FFFFFF",
    fontSize: 16,
  },
});
