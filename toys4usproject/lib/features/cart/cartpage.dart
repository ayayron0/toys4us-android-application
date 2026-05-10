import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../shared/product_image.dart';
import '../build_a_toy/build_a_toy.dart';
import '../checkout/checkout_page.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
        backgroundColor: CartPage.brandColor,
        foregroundColor: Colors.white,
      ),
      body: const CartPage(),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  static const Color brandColor = Color(0xFF7B1FA2);
  static const Color softBackground = Color(0xFFF8F5FA);

  CollectionReference<Map<String, dynamic>> get cartRef {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart_items');
  }

  double calculateTotal(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    double sum = 0;

    for (final item in docs) {
      final data = item.data();
      final price = (data['price'] as num? ?? 0).toDouble();
      final quantity = (data['quantity'] as num? ?? 1).toInt();

      sum += price * quantity;
    }

    return sum;
  }

  int calculateCount(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    int count = 0;

    for (final item in docs) {
      final data = item.data();
      count += (data['quantity'] as num? ?? 1).toInt();
    }

    return count;
  }

  Widget quantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: brandColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget emptyCart(BuildContext context) {
    return Container(
      width: double.infinity,
      color: softBackground,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(48),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: brandColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Your cart is empty",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Add a toy or game before heading to checkout.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  void editCustomToy(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text("Edit Custom Toy"),
            backgroundColor: brandColor,
            foregroundColor: Colors.white,
          ),
          body: BuildAToyPage(cartItemId: doc.id, initialData: doc.data()),
        ),
      ),
    );
  }

  Widget cartItem(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final image = data['image'] ?? '';
    final name = data['name'] ?? 'Cart item';
    final price = (data['price'] as num? ?? 0).toDouble();
    final quantity = (data['quantity'] as num? ?? 1).toInt();
    final isCustomToy = data['isCustomToy'] == true;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customToyImage(data, image),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isCustomToy)
                        const Text(
                          "Build-A-Toy",
                          style: TextStyle(
                            color: brandColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "\$${price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: brandColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          quantityButton(
                            icon: Icons.remove,
                            onPressed: quantity > 1
                                ? () => cartRef.doc(doc.id).update({
                                    'quantity': quantity - 1,
                                  })
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "$quantity",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          quantityButton(
                            icon: Icons.add,
                            onPressed: () => cartRef.doc(doc.id).update({
                              'quantity': quantity + 1,
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: "Remove",
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => cartRef.doc(doc.id).delete(),
                ),
              ],
            ),
            if (isCustomToy) ...[
              const SizedBox(height: 10),
              buildCustomDetails(data),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: brandColor,
                    side: const BorderSide(color: brandColor),
                  ),
                  onPressed: () => editCustomToy(context, doc),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text("Edit Custom Toy"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget customToyImage(Map<String, dynamic> data, String image) {
    final overlays = data['accessoryOverlays'];
    final overlayPaths = overlays is List
        ? overlays.map((item) => item.toString()).toList()
        : <String>[];

    if (data['isCustomToy'] == true && overlayPaths.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 76,
          height: 76,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ProductImage(
                imagePath: image,
                height: 76,
                width: 76,
                fit: BoxFit.contain,
              ),
              ...overlayPaths.map(
                (overlayPath) => Image.asset(
                  overlayPath,
                  width: 76,
                  height: 76,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ProductImage(
        imagePath: image,
        height: 76,
        width: 76,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget buildCustomDetails(Map<String, dynamic> data) {
    if (data['isCustomToy'] != true) {
      return const SizedBox.shrink();
    }

    final details = [
      "Type: ${data['type'] ?? 'Custom'}",
      "Color: ${data['color'] ?? 'Not selected'}",
      "Accessory: ${data['accessory'] ?? 'None'}",
      if ((data['voiceMessage'] ?? '').toString().trim().isNotEmpty)
        "Voice: ${data['voiceMessage']}",
    ];

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: details.map((detail) {
          return Chip(
            label: Text(detail),
            visualDensity: VisualDensity.compact,
            backgroundColor: const Color(0xFFF1E5F6),
            side: BorderSide.none,
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: cartRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Could not load cart"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs;
        final total = calculateTotal(items);
        final count = calculateCount(items);

        if (items.isEmpty) {
          return emptyCart(context);
        }

        return Container(
          color: softBackground,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "$count item${count == 1 ? "" : "s"} in your cart",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        for (final item in items) {
                          cartRef.doc(item.id).delete();
                        }
                      },
                      icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                      label: const Text("Clear"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      cartItem(context, items[index]),
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x0F000000),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Subtotal",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            Text(
                              "\$${total.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(140, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.lock_outline, size: 18),
                        label: const Text("Checkout"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
