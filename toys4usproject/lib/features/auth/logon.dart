import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../navigation/mainproductnavigation.dart';
import '../../core/notification_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toys 4 Us',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AuthStyle.brandColor,
          primary: AuthStyle.brandColor,
        ),
        scaffoldBackgroundColor: AuthStyle.softBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AuthStyle.brandColor,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AuthStyle.brandColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class AuthStyle {
  static const Color brandColor = Color(0xFF7B1FA2);
  static const Color softBackground = Color(0xFFF8F5FA);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController splashController;
  late final Animation<double> floatAnimation;
  late final Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: splashController, curve: Curves.easeInOut),
    );

    fadeAnimation = Tween<double>(begin: 0.55, end: 1).animate(
      CurvedAnimation(parent: splashController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AuthStyle.softBackground,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: splashController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 190,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 8,
                          top: 28 + floatAnimation.value,
                          child: splashBubble(Icons.star, 34, 0.75),
                        ),
                        Positioned(
                          right: 10,
                          top: 18 - floatAnimation.value,
                          child: splashBubble(Icons.favorite, 30, 0.65),
                        ),
                        Positioned(
                          right: 28,
                          bottom: 8 + floatAnimation.value,
                          child: splashBubble(Icons.celebration, 36, 0.7),
                        ),
                        Transform.translate(
                          offset: Offset(0, floatAnimation.value),
                          child: Transform.scale(
                            scale: 1 + (splashController.value * 0.04),
                            child: Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 18,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.toys,
                                size: 58,
                                color: AuthStyle.brandColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Toys 4 Us",
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Build, shop, and track your favorite toys",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 22),
                  Opacity(
                    opacity: fadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFEADCF0)),
                      ),
                      child: const Text(
                        "Getting your toy box ready...",
                        style: TextStyle(
                          color: AuthStyle.brandColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget splashBubble(IconData icon, double size, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(color: const Color(0xFFEADCF0)),
        ),
        child: Icon(icon, size: size * 0.55, color: AuthStyle.brandColor),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnack("Fill all fields");
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) {
        return;
      }

      showSnack("Login successful");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainProductNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      showSnack(e.message ?? "Invalid credentials");
    }
  }

  void showSnack(String msg) {
    NotificationManager.info(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Welcome Back",
      subtitle: "Sign in to keep shopping and building custom toys.",
      child: Column(
        children: [
          AuthTextField(
            hint: "Email",
            icon: Icons.email_outlined,
            controller: emailController,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            hint: "Password",
            icon: Icons.lock_outline,
            controller: passwordController,
            obscureText: obscure,
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  obscure = !obscure;
                });
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotScreen()),
                );
              },
              child: const Text("Forgot password?"),
            ),
          ),
          AuthPrimaryButton(label: "Login", onPressed: loginUser),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              );
            },
            child: const Text("Create a new account"),
          ),
        ],
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void signupUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      showSnack("Fill all fields");
      return;
    }

    if (password != confirm) {
      showSnack("Passwords do not match");
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'email': email, 'createdAt': FieldValue.serverTimestamp()});

      if (!mounted) {
        return;
      }

      showSnack("Account created");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      showSnack(e.message ?? "Could not create account");
    }
  }

  void showSnack(String msg) {
    NotificationManager.info(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      title: "Create Account",
      subtitle: "Join Toys 4 Us and save carts, orders, and custom toys.",
      child: Column(
        children: [
          AuthTextField(
            hint: "Email",
            icon: Icons.email_outlined,
            controller: emailController,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            hint: "Password",
            icon: Icons.lock_outline,
            controller: passwordController,
            obscureText: obscure,
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  obscure = !obscure;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          AuthTextField(
            hint: "Confirm Password",
            icon: Icons.lock_outline,
            controller: confirmController,
            obscureText: obscure,
          ),
          const SizedBox(height: 18),
          AuthPrimaryButton(label: "Create Account", onPressed: signupUser),
        ],
      ),
    );
  }
}

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void checkEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showSnack("Enter your email");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) {
        return;
      }
      showSnack("Password reset email sent");
    } on FirebaseAuthException catch (e) {
      showSnack(e.message ?? "Could not send reset email");
    }
  }

  void showSnack(String msg) {
    NotificationManager.info(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      title: "Reset Password",
      subtitle: "Enter your email and Firebase will send a reset link.",
      child: Column(
        children: [
          AuthTextField(
            hint: "Email",
            icon: Icons.email_outlined,
            controller: emailController,
          ),
          const SizedBox(height: 18),
          AuthPrimaryButton(label: "Send Reset Link", onPressed: checkEmail),
        ],
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool showBackButton;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AuthStyle.softBackground,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBackButton)
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x10000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.toys,
                              color: AuthStyle.brandColor,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Toys 4 Us",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 18),
                            child,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;

  const AuthTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AuthStyle.brandColor, width: 1.5),
        ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AuthStyle.brandColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Welcome to Toys 4 Us")));
  }
}
