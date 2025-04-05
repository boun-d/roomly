import { useState } from "react";
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  TouchableWithoutFeedback,
  Keyboard,
  Image,
} from "react-native";
import { StatusBar } from "expo-status-bar";
import { BlurView } from "expo-blur";
import { Input } from "components/Input";

export default function LoginScreen() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [signupAs, setSignupAs] = useState<"renter" | "landlord" | undefined>(
    undefined
  );
  const handleLogin = () => {
    // TODO: Implement login logic
    console.log("Login attempted with:", { email, password });
  };
  console.log(signupAs);

  return (
    <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
      <View style={styles.container}>
        <StatusBar style="light" />
        <KeyboardAvoidingView behavior="padding" style={styles.formContainer}>
          <BlurView intensity={60} style={styles.blurContainer}>
            <View style={styles.titleContainer}>
              <Image
                source={require("assets/images/house.png")}
                style={styles.titleIcon}
              />
              <Text style={styles.title}>roomly</Text>
            </View>
            <Text style={styles.subtitle}>I am a...</Text>
            <View style={styles.switchContainer}>
              <TouchableOpacity
                style={[
                  styles.switchButton,
                  signupAs === "renter" && styles.switchButtonActive,
                ]}
                onPress={() => setSignupAs("renter")}
              >
                <Text style={styles.switchButtonText}>Renter</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[
                  styles.switchButton,
                  signupAs === "landlord" && styles.switchButtonActive,
                ]}
                onPress={() => setSignupAs("landlord")}
              >
                <Text style={styles.switchButtonText}>Landlord</Text>
              </TouchableOpacity>
            </View>
            {signupAs !== undefined && (
              <View style={styles.inputContainer}>
              <Input type="email" value={email} onChange={setEmail} />
              <Input type="password" value={password} onChange={setPassword} />
              <Input type="password" value={password} onChange={setPassword} />
            </View>
            )}
          </BlurView>
        </KeyboardAvoidingView>
      </View>
    </TouchableWithoutFeedback>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#1a1a1a",
  },
  formContainer: {
    flex: 1,
    justifyContent: "center",
    paddingHorizontal: 20,
  },
  blurContainer: {
    padding: 30,
    borderRadius: 15,
    overflow: "hidden",
    backgroundColor: "#FFFFFF1A",
  },
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
    color: "#FFFFFF",
    textAlign: "left",
  },
  subtitle: {
    fontSize: 16,
    color: "#A0A0A0",
    marginBottom: 16,
    textAlign: "left",
  },
  inputContainer: {
    gap: 16,
    marginBottom: 16,
  },
  input: {
    backgroundColor: "#FFFFFF1A",
    padding: 16,
    borderRadius: 12,
    color: "#FFFFFF",
    fontSize: 16,
  },
  forgotPassword: {
    alignSelf: "flex-end",
    marginBottom: 24,
  },
  forgotPasswordText: {
    color: "#A0A0A0",
    fontSize: 14,
  },
  switchContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 16,
    gap: 16,
  },
  switchButton: {
    backgroundColor: "#FFFFFF1A",
    padding: 16,
    borderRadius: 12,
    alignItems: "center",
    marginBottom: 24,
    flex: 1,
  },
  switchButtonActive: {
    backgroundColor: "#007AFF",
  },
  switchButtonText: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "600",
  },
  loginButton: {
    backgroundColor: "#834333",
    padding: 16,
    borderRadius: 12,
    alignItems: "center",
    marginBottom: 24,
  },
  loginButtonText: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "600",
  },
  signupContainer: {
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
  },
  signupText: {
    color: "#A0A0A0",
    fontSize: 14,
  },
  signupLink: {
    color: "#007AFF",
    fontSize: 14,
    fontWeight: "600",
  },
});
