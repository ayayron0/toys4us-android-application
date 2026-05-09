import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'notification_manager.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  static const Color brandColor = Color(0xFF7B1FA2);
  static const Color softBackground = Color(0xFFF8F5FA);

  CollectionReference<Map<String, dynamic>> get productsRef {
    return FirebaseFirestore.instance.collection('products');
  }

  Future<void> openProductDialog(
    BuildContext context, {
    QueryDocumentSnapshot<Map<String, dynamic>>? productDoc,
  }) async {
    final data = productDoc?.data() ?? {};
    final name = TextEditingController(text: data['name'] ?? '');
    final subtitle = TextEditingController(text: data['subtitle'] ?? '');
    final description = TextEditingController(text: data['description'] ?? '');
    final price = TextEditingController(text: "${data['price'] ?? ''}");
    final oldPrice = TextEditingController(text: "${data['oldPrice'] ?? 0}");
    final image = TextEditingController(text: data['image'] ?? '');
    final rating = TextEditingController(text: "${data['rating'] ?? 0}");
    final reviews = TextEditingController(text: "${data['reviews'] ?? 0}");
    final types = TextEditingController(
      text: List<String>.from(data['types'] ?? []).join(', '),
    );

    final isEditing = productDoc != null;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1E5F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isEditing
                                ? Icons.edit_outlined
                                : Icons.add_box_outlined,
                            color: brandColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isEditing ? "Edit Product" : "Add Product",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    input(name, "Name", Icons.sell_outlined),
                    input(subtitle, "Subtitle", Icons.short_text),
                    input(
                      description,
                      "Description",
                      Icons.notes_outlined,
                      maxLines: 3,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: input(
                            price,
                            "Price",
                            Icons.attach_money,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: input(
                            oldPrice,
                            "Old Price",
                            Icons.price_change_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    input(image, "Image Path", Icons.image_outlined),
                    Row(
                      children: [
                        Expanded(
                          child: input(
                            rating,
                            "Rating",
                            Icons.star_outline,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: input(
                            reviews,
                            "Reviews",
                            Icons.rate_review_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    input(
                      types,
                      "Types: toy, game, cards",
                      Icons.category_outlined,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            onPressed: () async {
                              if (name.text.trim().isEmpty ||
                                  description.text.trim().isEmpty ||
                                  price.text.trim().isEmpty ||
                                  image.text.trim().isEmpty ||
                                  types.text.trim().isEmpty) {
                                NotificationManager.error(
                                  context,
                                  "Name, description, price, image, and types are required",
                                );
                                return;
                              }

                              final productData = {
                                'name': name.text.trim(),
                                'subtitle': subtitle.text.trim(),
                                'description': description.text.trim(),
                                'price':
                                    double.tryParse(price.text.trim()) ?? 0,
                                'oldPrice':
                                    double.tryParse(oldPrice.text.trim()) ?? 0,
                                'image': image.text.trim(),
                                'rating':
                                    double.tryParse(rating.text.trim()) ?? 0,
                                'reviews':
                                    int.tryParse(reviews.text.trim()) ?? 0,
                                'types': types.text
                                    .split(',')
                                    .map((type) => type.trim().toLowerCase())
                                    .where((type) => type.isNotEmpty)
                                    .toList(),
                                'updatedAt': FieldValue.serverTimestamp(),
                              };

                              if (isEditing) {
                                await productDoc.reference.update(productData);
                              } else {
                                await productsRef.add({
                                  ...productData,
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
                              }

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: Text(isEditing ? "Save Changes" : "Add"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    name.dispose();
    subtitle.dispose();
    description.dispose();
    price.dispose();
    oldPrice.dispose();
    image.dispose();
    rating.dispose();
    reviews.dispose();
    types.dispose();
  }

  Widget input(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: brandColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Future<void> confirmDelete(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> productDoc,
  ) async {
    final data = productDoc.data();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete product?"),
          content: Text(
            "${data['name'] ?? 'This product'} will be removed from Firestore.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await productDoc.reference.delete();
    }
  }

  Widget statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1E5F6),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: brandColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget productCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final name = data['name'] ?? 'Product';
    final subtitle = data['subtitle'] ?? '';
    final image = data['image'] ?? '';
    final price = (data['price'] as num? ?? 0).toDouble();
    final oldPrice = (data['oldPrice'] as num? ?? 0).toDouble();
    final rating = (data['rating'] as num? ?? 0).toDouble();
    final reviews = (data['reviews'] as num? ?? 0).toInt();
    final types = List<String>.from(data['types'] ?? []);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: image.toString().isNotEmpty
                  ? Image.asset(
                      image,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return imageFallback();
                      },
                    )
                  : imageFallback(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: types.map((type) {
                      return Chip(
                        label: Text(type),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: const Color(0xFFF1E5F6),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "\$${price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: brandColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (oldPrice > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          "\$${oldPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text("$rating ($reviews)"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Column(
              children: [
                IconButton(
                  tooltip: "Edit",
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => openProductDialog(context, productDoc: doc),
                ),
                IconButton(
                  tooltip: "Delete",
                  color: Colors.red,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => confirmDelete(context, doc),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget imageFallback() {
    return Container(
      width: 72,
      height: 72,
      color: Colors.grey.shade200,
      child: const Icon(Icons.inventory_2_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBackground,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
        onPressed: () => openProductDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Product"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: productsRef.orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Could not load products"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 72,
                      color: brandColor,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "No products yet",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Add the first product to publish it to the catalog.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            );
          }

          final categoryCount = products
              .expand((doc) => List<String>.from(doc.data()['types'] ?? []))
              .toSet()
              .length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              Row(
                children: [
                  statCard(
                    "Products",
                    "${products.length}",
                    Icons.inventory_2_outlined,
                  ),
                  const SizedBox(width: 10),
                  statCard(
                    "Categories",
                    "$categoryCount",
                    Icons.category_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Product Catalog",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                "Add, edit, or remove products shown in the store.",
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 14),
              ...products.map((doc) => productCard(context, doc)),
            ],
          );
        },
      ),
    );
  }
}
