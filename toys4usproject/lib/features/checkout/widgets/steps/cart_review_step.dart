import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../cart_item_card.dart';
import '../checkout_primary_button.dart';
import '../checkout_summary_row.dart';

class CartReviewStep extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> items;
  final double total;
  final CollectionReference<Map<String, dynamic>> cartRef;
  final VoidCallback onContinue;

  const CartReviewStep({
    super.key,
    required this.items,
    required this.total,
    required this.cartRef,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text("Your cart is empty"))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) => CartItemCard(
              doc: items[index],
              cartRef: cartRef,
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                CheckoutSummaryRow(
                  label: "Subtotal",
                  value: "\$${total.toStringAsFixed(2)}",
                  bold: true,
                ),
                const SizedBox(height: 8),
                CheckoutPrimaryButton(
                  label: "Continue",
                  onPressed: items.isEmpty ? null : onContinue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}