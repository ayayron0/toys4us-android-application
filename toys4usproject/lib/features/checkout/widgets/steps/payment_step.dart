import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../checkout_primary_button.dart';
import '../checkout_summary_row.dart';
import 'Payment_Pages/web_card_payment_page.dart';
import 'Payment_Pages/web_paypal_payment_page.dart';

const Color brandColor = Color(0xFF7B1FA2);

class PaymentStep extends StatefulWidget {
  final double total;
  final VoidCallback onPay;
  final VoidCallback onGooglePay;
  final VoidCallback onApplePay;

  const PaymentStep({
    super.key,
    required this.total,
    required this.onPay,
    required this.onGooglePay,
    required this.onApplePay,
  });

  @override
  State<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<PaymentStep> {
  String selectedMethod = "Credit/Debit Card";

  @override
  Widget build(BuildContext context) {
    final bool useStripe = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Order Summary",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CheckoutSummaryRow(
                        label: "Subtotal",
                        value: "\$${widget.total.toStringAsFixed(2)}",
                      ),
                      const CheckoutSummaryRow(
                        label: "Shipping",
                        value: "\$30.00",
                      ),
                      const Divider(height: 24),
                      CheckoutSummaryRow(
                        label: "Total",
                        value: "\$${(widget.total + 30).toStringAsFixed(2)}",
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1E5F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: brandColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          useStripe
                              ? "Your payment is encrypted and secure via Stripe."
                              : "Demo mode — no real payment will be processed.",
                          style: const TextStyle(color: brandColor, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white),
            child: useStripe ? _stripeButtons() : _webButtons(context),
          ),
        ),
      ],
    );
  }

  Widget _stripeButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: widget.onGooglePay,
          icon: const Icon(Icons.g_mobiledata, size: 24),
          label: const Text("Pay with Google Pay"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (Platform.isIOS) ...[
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: widget.onApplePay,
            icon: const Icon(Icons.apple, size: 24),
            label: const Text("Pay with Apple Pay"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text("or pay with card"),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 10),
        CheckoutPrimaryButton(
          label: "Pay \$${(widget.total + 30).toStringAsFixed(2)}",
          onPressed: widget.onPay,
        ),
      ],
    );
  }

  Widget _webButtons(BuildContext context) {
    return Column(
      children: [
        _webPaymentOption("Credit/Debit Card", Icons.credit_card),
        _webPaymentOption("PayPal", Icons.account_balance_wallet_outlined),
        const SizedBox(height: 10),
        CheckoutPrimaryButton(
          label: "Continue to Payment",
          onPressed: () async {
            if (selectedMethod == "Credit/Debit Card") {
              final confirmed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => WebCardPaymentPage(
                    total: widget.total + 30,
                  ),
                ),
              );
              if (confirmed == true) widget.onPay();
            } else if (selectedMethod == "PayPal") {
              final confirmed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => WebPayPalPaymentPage(
                    total: widget.total + 30,
                  ),
                ),
              );
              if (confirmed == true) widget.onPay();
            }
          },
        ),
      ],
    );
  }

  Widget _webPaymentOption(String value, IconData icon) {
    final selected = selectedMethod == value;

    return Card(
      elevation: 0,
      color: selected ? const Color(0xFFF1E5F6) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? brandColor : Colors.grey.shade200,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => setState(() => selectedMethod = value),
        leading: Icon(icon, color: selected ? brandColor : Colors.grey),
        title: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(
          selected ? Icons.check_circle : Icons.circle_outlined,
          color: selected ? brandColor : Colors.grey,
        ),
      ),
    );
  }
}