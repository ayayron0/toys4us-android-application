import 'package:flutter/material.dart';
import '../../checkout_primary_button.dart';
import '../../checkout_input.dart';

const Color brandColor = Color(0xFF7B1FA2);

class WebCardPaymentPage extends StatefulWidget {
  final double total;

  const WebCardPaymentPage({super.key, required this.total});

  @override
  State<WebCardPaymentPage> createState() => _WebCardPaymentPageState();
}

class _WebCardPaymentPageState extends State<WebCardPaymentPage> {
  final cardNumber = TextEditingController();
  final cardHolder = TextEditingController();
  final expiry = TextEditingController();
  final cvv = TextEditingController();

  @override
  void dispose() {
    cardNumber.dispose();
    cardHolder.dispose();
    expiry.dispose();
    cvv.dispose();
    super.dispose();
  }

  bool _validate() {
    if (cardNumber.text.trim().length < 16) {
      _showError("Enter a valid 16-digit card number.");
      return false;
    }
    if (cardHolder.text.trim().isEmpty) {
      _showError("Enter the cardholder name.");
      return false;
    }
    if (expiry.text.trim().isEmpty) {
      _showError("Enter the expiry date.");
      return false;
    }
    if (cvv.text.trim().length < 3) {
      _showError("Enter a valid CVV.");
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
        title: const Text("Card Payment"),
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF8F5FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 20),
            const Text(
              "Card Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CheckoutInput(
              controller: cardNumber,
              label: "Card Number",
              icon: Icons.credit_card,
            ),
            CheckoutInput(
              controller: cardHolder,
              label: "Cardholder Name",
              icon: Icons.person_outline,
            ),
            Row(
              children: [
                Expanded(
                  child: CheckoutInput(
                    controller: expiry,
                    label: "MM/YY",
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CheckoutInput(
                    controller: cvv,
                    label: "CVV",
                    icon: Icons.lock_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CheckoutPrimaryButton(
              label: "Pay \$${widget.total.toStringAsFixed(2)}",
              onPressed: () {
                if (_validate()) Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}