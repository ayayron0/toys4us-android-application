import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/notification_manager.dart';

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

  double get accessoryPrice => accessory == "None" ? 0 : 5;

  double get voicePrice => voiceMessageController.text.trim().isEmpty ? 0 : 3;

  double get totalPrice => basePrice + accessoryPrice + voicePrice;

  String get displayName {
    final name = customName.text.trim();
    return name.isEmpty ? "Custom $plushType Plush" : name;
  }

  String get imagePath {
    if (plushType == "Bear") {
      final suffix = color.toLowerCase();
      return suffix == "brown"
          ? 'assets/images/bear.png'
          : 'assets/images/bear_$suffix.png';
    }

    return 'assets/images/${plushType.toLowerCase()}.png';
  }

  Color get selectedToyColor {
    return switch (color) {
      "Brown" => const Color(0xFF9C6B3D),
      "White" => Colors.white,
      "Pink" => const Color(0xFFFF9BCB),
      "Blue" => const Color(0xFF64A6FF),
      "Black" => const Color(0xFF2E2E2E),
      "Yellow" => const Color(0xFFFFD84D),
      "Green" => const Color(0xFF62C370),
      "Orange" => const Color(0xFFFFA142),
      "Purple" => brandColor,
      _ => const Color(0xFF9C6B3D),
    };
  }

  IconData get plushIcon {
    return switch (plushType) {
      "Bunny" => Icons.cruelty_free,
      "Cat" => Icons.pets,
      "Dog" => Icons.pets,
      "Monkey" => Icons.emoji_nature,
      _ => Icons.toys,
    };
  }

  Future<void> addToCart() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      NotificationManager.error(context, "Please log in first");
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

    NotificationManager.success(context, "$displayName added to cart");
  }

  Widget sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget previewPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 230,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F1FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 164,
                    height: 164,
                    decoration: BoxDecoration(
                      color: selectedToyColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 22,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: Image.asset(
                        imagePath,
                        key: ValueKey(imagePath),
                        width: 190,
                        height: 190,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            key: ValueKey("fallback-$plushType"),
                            width: 190,
                            height: 190,
                            child: Icon(
                              plushIcon,
                              size: 96,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
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
    );
  }

  IconData accessoryIcon(String value) {
    return switch (value) {
      "Bow" => Icons.workspace_premium,
      "Hat" => Icons.school_outlined,
      "Sunglasses" => Icons.visibility_outlined,
      _ => Icons.block,
    };
  }

  Widget detailChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: brandColor),
      label: Text(label),
      backgroundColor: const Color(0xFFF1E5F6),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget plushSelector() {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: plushTypes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final option = plushTypes[index];
          final selected = plushType == option;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                plushType = option;
              });
            },
            child: Container(
              width: 88,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFF1E5F6) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? brandColor : Colors.grey.shade200,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    option == "Bunny"
                        ? Icons.cruelty_free
                        : option == "Bear"
                        ? Icons.toys
                        : Icons.pets,
                    color: selected ? brandColor : Colors.grey.shade700,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    option,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget colorSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((option) {
        final selected = color == option;
        final swatch = switch (option) {
          "Brown" => const Color(0xFF9C6B3D),
          "White" => Colors.white,
          "Pink" => const Color(0xFFFF9BCB),
          "Blue" => const Color(0xFF64A6FF),
          "Black" => const Color(0xFF2E2E2E),
          "Yellow" => const Color(0xFFFFD84D),
          "Green" => const Color(0xFF62C370),
          "Orange" => const Color(0xFFFFA142),
          "Purple" => brandColor,
          _ => Colors.grey,
        };

        return Tooltip(
          message: option,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                color = option;
              });
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: swatch,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? brandColor : Colors.grey.shade300,
                  width: selected ? 3 : 1,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check,
                      color: option == "White" || option == "Yellow"
                          ? Colors.black
                          : Colors.white,
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget accessorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: accessories.map((option) {
        final selected = accessory == option;

        return ChoiceChip(
          avatar: Icon(
            accessoryIcon(option),
            size: 17,
            color: selected ? brandColor : Colors.grey.shade700,
          ),
          label: Text(option == "None" ? "No accessory" : option),
          selected: selected,
          selectedColor: const Color(0xFFF1E5F6),
          side: BorderSide(color: selected ? brandColor : Colors.grey.shade300),
          onSelected: (_) {
            setState(() {
              accessory = option;
            });
          },
        );
      }).toList(),
    );
  }

  Widget pricePanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          priceRow("Base plush", basePrice),
          priceRow("Accessory", accessoryPrice),
          priceRow("Voice message", voicePrice),
          const Divider(height: 22),
          priceRow("Total", totalPrice, bold: true),
        ],
      ),
    );
  }

  Widget priceRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
              color: bold ? brandColor : Colors.black,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
              fontSize: bold ? 20 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget textInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandColor, width: 1.5),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: softBackground,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                previewPanel(),
                const SizedBox(height: 18),
                sectionTitle(
                  "Name Your Plush",
                  "Give your custom toy a name for the cart and order.",
                ),
                textInput(
                  controller: customName,
                  label: "Toy Name",
                  icon: Icons.badge_outlined,
                  hint: "Example: Luna Bear",
                ),
                const SizedBox(height: 18),
                sectionTitle("Pick A Plush", "Choose the starting toy shape."),
                plushSelector(),
                const SizedBox(height: 18),
                sectionTitle("Choose Color", "Select the toy color theme."),
                colorSelector(),
                const SizedBox(height: 18),
                sectionTitle("Add Accessory", "Optional add-ons cost \$5.00."),
                accessorySelector(),
                const SizedBox(height: 18),
                sectionTitle(
                  "Voice Message",
                  "Optional message adds \$3.00 to the custom toy.",
                ),
                textInput(
                  controller: voiceMessageController,
                  label: "Voice Message",
                  icon: Icons.record_voice_over,
                  hint: "Optional message for your plush",
                  maxLines: 2,
                ),
                const SizedBox(height: 18),
                pricePanel(),
                const SizedBox(height: 18),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "\$${totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: brandColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(148, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: addingToCart ? null : addToCart,
                    icon: addingToCart
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_shopping_cart),
                    label: Text(addingToCart ? "Adding" : "Add"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
