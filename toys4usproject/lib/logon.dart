import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mainproductnavigation.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toys 4 Us',
      home: SplashScreen(),
    );
  }
}

//splashing screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "toys 4 us",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

//logging in
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  bool obscure = true;

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

      showSnack("Login successful");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainProductNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      showSnack(e.message ?? "Invalid credentials");
    }
  }


  void showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget buildField(String hint, IconData icon,
      TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
              obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() => obscure = !obscure);
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("WELCOME BACK",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            buildField("Email", Icons.person, emailController),
            SizedBox(height: 10),

            buildField("Password", Icons.lock, passwordController,
                isPassword: true),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ForgotScreen()),
                  );
                },
                child: Text("Forgot password?",
                    style: TextStyle(color: Colors.purple)),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: loginUser,
              child:
              Text("Login", style: TextStyle(color: Colors.white)),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupScreen()),
                );
              },
              child: Text("Sign up to create account"),
            )
          ],
        ),
      ),
    );
  }
}

//signup
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();


  bool obscure = true;

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
      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      showSnack("Account created");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      showSnack(e.message ?? "Could not create account");
    }
  }


  void showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget buildField(String hint, IconData icon,
      TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
              obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() => obscure = !obscure);
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("CREATE AN ACCOUNT",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            buildField("Email", Icons.person, emailController),
            SizedBox(height: 10),

            buildField("Password", Icons.lock, passwordController,
                isPassword: true),
            SizedBox(height: 10),

            buildField("Confirm Password", Icons.lock, confirmController,
                isPassword: true),

            SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: signupUser,
              child: Text("Create Account",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

//forgor pass
class ForgotScreen extends StatefulWidget {
  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final emailController = TextEditingController();

  void checkEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showSnack("Enter your email");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showSnack("Password reset email sent");
    } on FirebaseAuthException catch (e) {
      showSnack(e.message ?? "Could not send reset email");
    }
  }


  void showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("FORGOT PASSWORD?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                hintText: "Enter email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: checkEmail,
              child:
              Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

//home place holder
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Toys 4 Us"),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Text("Welcome  to toys 4 us come view our coool prods"),
      ),
    );
  }
}