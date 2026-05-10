import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../shared/product_image.dart';
import 'product.dart';
import '../cart/cartpage.dart';
import '../checkout/checkout_page.dart';
import '../../core/notification_manager.dart';

class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final reviewController = TextEditingController();
  String? selectedType;
  int selectedRating = 5;
  static const Color brandColor = Color(0xFF7B1FA2);
  static const Color softBackground = Color(0xFFF8F5FA);

  @override
  void initState() {
    super.initState();
    selectedType = widget.product.types.isNotEmpty
        ? widget.product.types.first
        : null;
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  DocumentReference<Map<String, dynamic>> get productRef {
    return FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id);
  }

  CollectionReference<Map<String, dynamic>> get reviewsRef {
    return productRef.collection('reviews');
  }

  Future<void> addToCart({bool goToCheckout = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    final product = widget.product;

    if (user == null) {
      NotificationManager.error(context, "Please log in first");
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

    NotificationManager.success(context, "Added to cart");
  }

  Future<void> submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    final comment = reviewController.text.trim();

    if (user == null) {
      NotificationManager.error(context, "Please log in first");
      return;
    }

    if (comment.isEmpty) {
      NotificationManager.info(context, "Write a review first");
      return;
    }

    final existingReview = await reviewsRef.doc(user.uid).get();

    if (existingReview.exists) {
      if (!mounted) {
        return;
      }

      NotificationManager.info(context, "You already reviewed this product");
      return;
    }

    await reviewsRef.doc(user.uid).set({
      'userId': user.uid,
      'userEmail': user.email ?? 'Customer',
      'rating': selectedRating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await updateProductRating();

    if (!mounted) {
      return;
    }

    reviewController.clear();
    setState(() {
      selectedRating = 5;
    });

    NotificationManager.success(context, "Review saved");
  }

  Future<void> updateProductRating() async {
    final reviews = await reviewsRef.get();

    if (reviews.docs.isEmpty) {
      await productRef.update({'rating': 0, 'reviews': 0});
      return;
    }

    double sum = 0;

    for (final review in reviews.docs) {
      final data = review.data();
      sum += (data['rating'] as num? ?? 0).toDouble();
    }

    final average = sum / reviews.docs.length;

    await productRef.update({
      'rating': double.parse(average.toStringAsFixed(1)),
      'reviews': reviews.docs.length,
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: softBackground,
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: product.id.isEmpty ? null : productRef.snapshots(),
        builder: (context, snapshot) {
          final productData = snapshot.data?.data();
          final currentRating =
              (productData?['rating'] as num? ?? product.rating).toDouble();
          final currentReviews =
              (productData?['reviews'] as num? ?? product.reviews).toInt();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ProductImage(
                            imagePath: product.image,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (product.types.isNotEmpty)
                          Text(
                            product.types.first.toUpperCase(),
                            style: const TextStyle(
                              color: brandColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (product.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.subtitle,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text("$currentRating ($currentReviews reviews)"),
                            const Spacer(),
                            Text(
                              "\$${product.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: brandColor,
                              ),
                            ),
                          ],
                        ),
                        if (product.oldPrice > 0) ...[
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "\$${product.oldPrice.toStringAsFixed(2)}",
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (product.types.isNotEmpty) ...[
                  const Text(
                    "Choose Type",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
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
                      backgroundColor: brandColor,
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
                      backgroundColor: const Color(0xFF237A3B),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                buildReviewsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildReviewsSection() {
    if (widget.product.id.isEmpty) {
      return const SizedBox.shrink();
    }

    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Customer Reviews",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        buildReviewForm(user),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: reviewsRef.orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Could not load reviews");
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final reviews = snapshot.data!.docs;

            if (reviews.isEmpty) {
              return Text(
                "No reviews yet",
                style: TextStyle(color: Colors.grey.shade700),
              );
            }

            return Column(
              children: reviews.map((doc) {
                final data = doc.data();
                final rating = (data['rating'] as num? ?? 0).toInt();
                final email = data['userEmail'] ?? 'Customer';
                final comment = data['comment'] ?? '';

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(comment),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget buildReviewForm(User? user) {
    if (user == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text("Log in to write a review."),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: reviewsRef.doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() ?? {};
          final rating = (data['rating'] as num? ?? 0).toInt();

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "You already reviewed this product",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Write a Review",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: List.generate(5, (index) {
                    final rating = index + 1;

                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("$rating"),
                          const SizedBox(width: 3),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                        ],
                      ),
                      selected: selectedRating == rating,
                      onSelected: (_) {
                        setState(() {
                          selectedRating = rating;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Share what you thought about this product",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: submitReview,
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text("Submit Review"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
