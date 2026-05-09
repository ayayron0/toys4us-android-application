import 'package:flutter/material.dart';

import '../checkout_primary_button.dart';

const Color brandColor = Color(0xFF7B1FA2);
const Color softBackground = Color(0xFFF8F5FA);

class OrderConfirmedStep extends StatelessWidget {
  final VoidCallback onViewOrders;
  final VoidCallback onContinueShopping;

  const OrderConfirmedStep({
    super.key,
    required this.onViewOrders,
    required this.onContinueShopping,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: softBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 96, color: brandColor),
              const SizedBox(height: 18),
              const Text(
                "Order Confirmed",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                "Your order is now saved in order history.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 28),
              CheckoutPrimaryButton(
                label: "View Orders",
                onPressed: onViewOrders,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: brandColor,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onContinueShopping,
                icon: const Icon(Icons.storefront),
                label: const Text("Continue Shopping"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}