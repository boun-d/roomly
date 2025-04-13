import { useMemo, useState } from "react";
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  KeyboardAvoidingView,
  TouchableWithoutFeedback,
  Keyboard,
} from "react-native";
import { StatusBar } from "expo-status-bar";
import { BlurView } from "expo-blur";
import { Input } from "components/Input";
import { router } from "expo-router";
import { RoomlyHeader } from "components/RoomlyHeader";
import { BACKGROUND, BLACK, OLIVE, PRIMARY, WHITE } from "constants/palette";
import { useAuth } from "../context/auth";
import { PrimaryButton } from "components/PrimaryButton";

const shouldDisableSignup = (
  signupAs: "renter" | "landlord" | undefined,
  email: string,
  password: string,
  confirmPassword: string
) => {
  return signupAs === undefined || email === "" || password === "" || confirmPassword === "";
};

export default function SignupScreen() {
  const { signIn } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [signupAs, setSignupAs] = useState<"renter" | "landlord" | undefined>(
    undefined
  );

  const disabled = useMemo(
    () => shouldDisableSignup(signupAs, email, password, confirmPassword),
    [signupAs, email, password, confirmPassword]
  );

  const handleSignup = async () => {
    try {
      if (password !== confirmPassword) {
        // TODO: Show error message
        return;
      }
      await signIn(email, password); // Replace with actual signup
    } catch (error) {
      console.error("Signup failed:", error);
      // TODO: Show error message
    }
  };

  return (
    <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
      <View style={styles.container}>
        <KeyboardAvoidingView behavior="padding" style={styles.formContainer}>
          <BlurView intensity={60} style={styles.blurContainer}>
            <RoomlyHeader />
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
            <View style={styles.credentialsContainer}>
              <Input
                type="email"
                value={email}
                placeholder="Email"
                onChange={setEmail}
              />
              <Input
                type="password"
                value={password}
                placeholder="Password"
                onChange={setPassword}
              />
              <Input
                type="password"
                value={confirmPassword}
                placeholder="Confirm Password"
                onChange={setConfirmPassword}
              />
            </View>
            <PrimaryButton label="Sign up" onPress={handleSignup} disabled={disabled} />
            <View style={styles.existingAccountContainer}>
              <Text style={styles.existingAccountText}>
                Already have an account?{" "}
              </Text>
              <TouchableOpacity>
                <Text style={styles.loginLink} onPress={() => router.back()}>
                  Go back
                </Text>
              </TouchableOpacity>
            </View>
          </BlurView>
        </KeyboardAvoidingView>
      </View>
    </TouchableWithoutFeedback>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: BACKGROUND,
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
    backgroundColor: BLACK,
  },
  subtitle: {
    fontSize: 16,
    color: "#A0A0A0",
    marginBottom: 32,
    textAlign: "left",
  },
  credentialsContainer: {
    gap: 16,
    marginBottom: 16,
  },
  switchContainer: {
    flexDirection: "row",
    gap: 16,
    justifyContent: "space-between",
    marginBottom: 16,
  },
  switchButton: {
    padding: 16,
    backgroundColor: OLIVE,
    borderRadius: 12,
    alignItems: "center",
    flex: 1,
  },
  switchButtonActive: {
    backgroundColor: PRIMARY,
  },
  switchButtonText: {
    color: "#fff",
    fontSize: 14,
    fontWeight: "600",
  },
  existingAccountContainer: {
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
    marginTop: 12,
  },
  existingAccountText: {
    color: WHITE,
    fontSize: 14,
  },
  loginLink: {
    color: PRIMARY,
    fontSize: 14,
    fontWeight: "600",
  },
});
