import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color brandColor = Color(0xFF7B1FA2);

class CartItemCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final CollectionReference<Map<String, dynamic>> cartRef;

  const CartItemCard({
    super.key,
    required this.doc,
    required this.cartRef,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final name = data['name'] ?? 'Cart item';
    final image = data['image'] ?? '';
    final price = (data['price'] as num? ?? 0).toDouble();
    final quantity = (data['quantity'] as num? ?? 1).toInt();
    final isCustomToy = data['isCustomToy'] == true;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: image.isNotEmpty
                      ? Image.asset(
                    image,
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageFallback(),
                  )
                      : Container(
                    width: 68,
                    height: 68,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                ),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "\$${price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: brandColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _quantityButton(
                            icon: Icons.remove,
                            onPressed: quantity > 1
                                ? () => cartRef.doc(doc.id).update(
                                {'quantity': quantity - 1})
                                : null,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 10),
                            child: Text("$quantity"),
                          ),
                          _quantityButton(
                            icon: Icons.add,
                            onPressed: () => cartRef
                                .doc(doc.id)
                                .update({'quantity': quantity + 1}),
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
              _buildCustomDetails(data),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDetails(Map<String, dynamic> data) {
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
        children: details
            .map((detail) => Chip(
          label: Text(detail),
          visualDensity: VisualDensity.compact,
          backgroundColor: const Color(0xFFF1E5F6),
          side: BorderSide.none,
        ))
            .toList(),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 68,
      height: 68,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Icon(icon, size: 16),
      ),
    );
  }
}