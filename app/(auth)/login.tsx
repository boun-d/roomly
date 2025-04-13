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
import { BlurView } from "expo-blur";
import { router } from "expo-router";
import { PrimaryButton } from "components/PrimaryButton";
import { RoomlyHeader } from "components/RoomlyHeader";
import { BACKGROUND, BLACK, PRIMARY, WHITE } from "constants/palette";
import { Input } from "components/Input";
import { useAuth } from "../context/auth";

const shouldDisableLogin = (email: string, password: string) => {
  return email === "" || password === "";
};

export default function LoginScreen() {
  const { signIn } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const disabled = useMemo(() => shouldDisableLogin(email, password), [email, password]);

  const handleLogin = async () => {
    try {
      await signIn(email, password);
    } catch (error) {
      console.error("Login failed:", error);
      // TODO: Show error message to user
    }
  };

  return (
    <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
      <View style={styles.container}>
        <KeyboardAvoidingView behavior="padding" style={styles.formContainer}>
          <BlurView intensity={60} style={styles.blurContainer}>
            <RoomlyHeader />
            <Text style={styles.subtitle}>Sign in to continue</Text>
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
            </View>
            <TouchableOpacity style={styles.forgotPassword}>
              <Text style={styles.forgotPasswordText}>Forgot Password?</Text>
            </TouchableOpacity>
            <PrimaryButton label="Sign In" onPress={handleLogin} disabled={disabled} />
            <View style={styles.signupContainer}>
              <Text style={styles.signupText}>Don't have an account? </Text>
              <TouchableOpacity>
                <Text
                  style={styles.signupLink}
                  onPress={() => router.push("/signup")}
                >
                  Sign Up
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
  forgotPassword: {
    alignSelf: "flex-end",
    marginBottom: 24,
  },
  forgotPasswordText: {
    color: "#A0A0A0",
    fontSize: 14,
  },
  signupContainer: {
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
    marginTop: 12,
  },
  signupText: {
    color: WHITE,
    fontSize: 14,
  },
  signupLink: {
    color: PRIMARY,
    fontSize: 14,
    fontWeight: "600",
  },
}); 