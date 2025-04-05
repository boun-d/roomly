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
import { router } from "expo-router";
import { PrimaryButton } from "components/PrimaryButton";
import { BACKGROUND, BLACK, PRIMARY, WHITE } from "constants/palette";
import { Input } from "components/Input";

export default function LoginScreen() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleLogin = () => {
    // TODO: Implement login logic
    console.log("Login attempted with:", { email, password });
  };

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
              <Text style={styles.title}>Roomly</Text>
            </View>
            <Text style={styles.subtitle}>Sign in to continue</Text>
            <View style={styles.credentialsContainer}>
              <Input type="email" value={email} onChange={setEmail} />
              <Input type="password" value={password} onChange={setPassword} />
            </View>
            <TouchableOpacity style={styles.forgotPassword}>
              <Text style={styles.forgotPasswordText}>Forgot Password?</Text>
            </TouchableOpacity>
            <PrimaryButton label="Sign In" onPress={handleLogin} />
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
    marginBottom: 32,
    textAlign: "left",
  },
  credentialsContainer: {
    gap: 16,
    marginBottom: 16,
  },
  // input: {
  //   backgroundColor: "rgba(255, 255, 255, 0.1)",
  //   padding: 16,
  //   borderRadius: 12,
  //   color: "#FFFFFF",
  //   fontSize: 16,
  // },
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
