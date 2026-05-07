import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'product.dart';
import 'cartpage.dart';
import 'checkout.dart';

class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.product.types.isNotEmpty
        ? widget.product.types.first
        : null;
  }

  Future<void> addToCart({bool goToCheckout = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    final product = widget.product;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please log in first")));
      return;
    }

    final cart = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart_items');

    final existing = await cart.where('name', isEqualTo: product.name).get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final currentQty = doc['quantity'] ?? 1;

      await cart.doc(doc.id).update({'quantity': currentQty + 1});
    } else {
      await cart.add({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'image': product.image,
        'quantity': 1,
        'type': selectedType,
      });
    }

    if (!mounted) {
      return;
    }

    if (goToCheckout) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CheckoutPage()),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Added to cart")));
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                product.image,
                height: 260,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (product.subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                product.subtitle,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text("${product.rating} (${product.reviews} reviews)"),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                if (product.oldPrice > 0) ...[
                  const SizedBox(width: 10),
                  Text(
                    "\$${product.oldPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            if (product.types.isNotEmpty) ...[
              Text("Type: ${selectedType ?? ""}"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: product.types.map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: selectedType == type,
                    onSelected: (_) {
                      setState(() {
                        selectedType = type;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
            ],
            const Text(
              "Product Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(product.description, style: const TextStyle(height: 1.35)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => addToCart(),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("Add to Cart"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => addToCart(goToCheckout: true),
                icon: const Icon(Icons.touch_app),
                label: const Text("Buy Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
