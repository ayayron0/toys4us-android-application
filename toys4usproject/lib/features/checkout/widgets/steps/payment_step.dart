import 'package:flutter/material.dart';

import '../checkout_primary_button.dart';
import '../payment_option_tile.dart';

class PaymentStep extends StatelessWidget {
  final double total;
  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;
  final VoidCallback onPay;

  const PaymentStep({
    super.key,
    required this.total,
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          PaymentOptionTile(
            value: "Visa ****2109",
            icon: Icons.credit_card,
            selectedMethod: selectedMethod,
            onSelect: onMethodChanged,
          ),
          PaymentOptionTile(
            value: "PayPal",
            icon: Icons.account_balance_wallet_outlined,
            selectedMethod: selectedMethod,
            onSelect: onMethodChanged,
          ),
          PaymentOptionTile(
            value: "Apple Pay",
            icon: Icons.phone_iphone,
            selectedMethod: selectedMethod,
            onSelect: onMethodChanged,
          ),
          const Spacer(),
          CheckoutPrimaryButton(
            label: "Pay \$${(total + 30).toStringAsFixed(2)}",
            onPressed: onPay,
          ),
        ],
      ),
    );
  }
}