import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuildAToyPage extends StatefulWidget {
  const BuildAToyPage({super.key});

  @override
  State<BuildAToyPage> createState() => _BuildAToyPageState();
}

class _BuildAToyPageState extends State<BuildAToyPage> {
  final customName = TextEditingController();
  final voiceMessageController = TextEditingController();

  String plushType = "Bear";
  String color = "Brown";
  String accessory = "None";
  bool addingToCart = false;

  static const Color brandColor = Color(0xFF7B1FA2);
  static const Color softBackground = Color(0xFFF8F5FA);
  static const double basePrice = 34.99;

  final List<String> plushTypes = ["Bear", "Bunny", "Cat", "Dog", "Monkey"];
  final List<String> colors = [
    "Brown",
    "White",
    "Pink",
    "Blue",
    "Black",
    "Yellow",
    "Green",
    "Orange",
    "Purple",
  ];
  final List<String> accessories = ["None", "Bow", "Hat", "Sunglasses"];

  @override
  void dispose() {
    customName.dispose();
    voiceMessageController.dispose();
    super.dispose();
  }

  double get accessoryPrice {
    if (accessory == "None") {
      return 0;
    }
    return 5;
  }

  double get voicePrice {
    if (voiceMessageController.text.trim().isEmpty) {
      return 0;
    }
    return 3;
  }

  double get totalPrice => basePrice + accessoryPrice + voicePrice;

  String get displayName {
    final name = customName.text.trim();
    return name.isEmpty ? "Custom $plushType Plush" : name;
  }

  String get imagePath => 'assets/images/${plushType.toLowerCase()}.png';

  Future<void> addToCart() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please log in first")));
      return;
    }

    setState(() {
      addingToCart = true;
    });

    final cart = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart_items');

    await cart.add({
      'productId': 'custom-toy',
      'isCustomToy': true,
      'name': displayName,
      'price': totalPrice,
      'image': imagePath,
      'quantity': 1,
      'type': plushType,
      'color': color,
      'accessory': accessory,
      'voiceMessage': voiceMessageController.text.trim(),
      'customDetails': {
        'basePrice': basePrice,
        'accessoryPrice': accessoryPrice,
        'voicePrice': voicePrice,
        'createdFrom': 'Build-A-Toy',
      },
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) {
      return;
    }

    setState(() {
      addingToCart = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$displayName added to cart")));
  }

  Widget optionDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget priceRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: bold ? Colors.black : Colors.grey.shade700,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            "\$${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget detailChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: brandColor),
      label: Text(label),
      backgroundColor: const Color(0xFFF1E5F6),
      side: BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: softBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Image.asset(imagePath, height: 190, fit: BoxFit.contain),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        detailChip(Icons.toys, plushType),
                        detailChip(Icons.palette_outlined, color),
                        detailChip(Icons.style_outlined, accessory),
                        if (voiceMessageController.text.trim().isNotEmpty)
                          detailChip(Icons.record_voice_over, "Voice"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Customize Your Toy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: customName,
              decoration: InputDecoration(
                labelText: "Toy Name",
                prefixIcon: const Icon(Icons.badge_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            optionDropdown(
              label: "Plush Type",
              icon: Icons.toys_outlined,
              value: plushType,
              options: plushTypes,
              onChanged: (value) {
                setState(() {
                  plushType = value;
                });
              },
            ),
            optionDropdown(
              label: "Color",
              icon: Icons.palette_outlined,
              value: color,
              options: colors,
              onChanged: (value) {
                setState(() {
                  color = value;
                });
              },
            ),
            optionDropdown(
              label: "Accessory",
              icon: Icons.style_outlined,
              value: accessory,
              options: accessories,
              onChanged: (value) {
                setState(() {
                  accessory = value;
                });
              },
            ),
            TextField(
              controller: voiceMessageController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Voice Message",
                hintText: "Optional message for your plush",
                prefixIcon: const Icon(Icons.record_voice_over),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
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
                    priceRow("Base plush", basePrice),
                    priceRow("Accessory", accessoryPrice),
                    priceRow("Voice message", voicePrice),
                    const Divider(height: 22),
                    priceRow("Total", totalPrice, bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
              ),
              onPressed: addingToCart ? null : addToCart,
              icon: addingToCart
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_shopping_cart),
              label: Text(addingToCart ? "Adding..." : "Add Custom Toy"),
            ),
          ],
        ),
      ),
    );
  }
}
