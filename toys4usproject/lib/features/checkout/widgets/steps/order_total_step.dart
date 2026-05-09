import 'package:flutter/material.dart';

import '../checkout_primary_button.dart';
import '../checkout_summary_row.dart';

class OrderTotalStep extends StatelessWidget {
  final double total;
  final VoidCallback onContinue;

  const OrderTotalStep({
    super.key,
    required this.total,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CheckoutSummaryRow(
                    label: "Subtotal",
                    value: "\$${total.toStringAsFixed(2)}",
                  ),
                  const CheckoutSummaryRow(label: "Shipping", value: "\$30.00"),
                  const Divider(height: 24),
                  CheckoutSummaryRow(
                    label: "Total",
                    value: "\$${(total + 30).toStringAsFixed(2)}",
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          CheckoutPrimaryButton(
            label: "Proceed to Payment",
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}