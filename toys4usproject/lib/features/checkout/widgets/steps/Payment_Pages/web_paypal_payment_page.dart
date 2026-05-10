import 'package:flutter/material.dart';
import '../../checkout_input.dart';

const Color brandColor = Color(0xFF7B1FA2);
const Color paypalBlue = Color(0xFF003087);

class WebPayPalPaymentPage extends StatefulWidget {
  final double total;

  const WebPayPalPaymentPage({super.key, required this.total});

  @override
  State<WebPayPalPaymentPage> createState() => _WebPayPalPaymentPageState();
}

class _WebPayPalPaymentPageState extends State<WebPayPalPaymentPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  bool _validate() {
    if (!email.text.contains("@")) {
      _showError("Enter a valid PayPal email.");
      return false;
    }
    if (password.text.trim().length < 6) {
      _showError("Enter your PayPal password.");
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PayPal"),
        backgroundColor: paypalBlue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF8F5FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1E5F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, color: brandColor, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Demo mode — no real payment will be processed.",
                      style: TextStyle(color: brandColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Log in to PayPal",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: paypalBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Total: \$${widget.total.toStringAsFixed(2)}",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            CheckoutInput(
              controller: email,
              label: "PayPal Email",
              icon: Icons.email_outlined,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: password,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: paypalBlue, width: 1.5),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: paypalBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (_validate()) Navigator.pop(context, true);
              },
              child: Text(
                "Pay \$${widget.total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
