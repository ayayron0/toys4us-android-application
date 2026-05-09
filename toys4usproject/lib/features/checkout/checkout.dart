import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/local_notification_service.dart';
import '../../core/notification_manager.dart';
import '../orders/orderhistory.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final country = TextEditingController();

  int step = 0;
  double total = 0;
  String paymentMethod = "Visa ****2109";
  bool loadedSavedProfile = false;

  static const Color brandColor = Color(0xFF7B1FA2);
  static const Color softBackground = Color(0xFFF8F5FA);

  CollectionReference<Map<String, dynamic>> get cartRef {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart_items');
  }

  DocumentReference<Map<String, dynamic>> get profileRef {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance.collection('users').doc(user!.uid);
  }

  CollectionReference<Map<String, dynamic>> get ordersRef {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('orders');
  }

  @override
  void initState() {
    super.initState();
    email.text = FirebaseAuth.instance.currentUser?.email ?? '';
    loadSavedProfile();
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
    address.dispose();
    city.dispose();
    country.dispose();
    super.dispose();
  }

  Future<void> loadSavedProfile() async {
    final snapshot = await profileRef.get();
    final data = snapshot.data();

    if (data == null || !mounted || loadedSavedProfile) {
      return;
    }

    firstName.text = data['firstName'] ?? '';
    lastName.text = data['lastName'] ?? '';
    email.text =
        data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
    phone.text = data['phone'] ?? '';
    address.text = data['address'] ?? '';
    city.text = data['city'] ?? '';
    country.text = data['country'] ?? '';

    setState(() {
      loadedSavedProfile = true;
    });
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

  Future<void> saveDetails() async {
    await profileRef.set({
      'firstName': firstName.text.trim(),
      'lastName': lastName.text.trim(),
      'email': email.text.trim(),
      'phone': phone.text.trim(),
      'address': address.text.trim(),
      'city': city.text.trim(),
      'country': country.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Map<String, dynamic> deliveryDetails() {
    return {
      'firstName': firstName.text.trim(),
      'lastName': lastName.text.trim(),
      'email': email.text.trim(),
      'phone': phone.text.trim(),
      'address': address.text.trim(),
      'city': city.text.trim(),
      'country': country.text.trim(),
    };
  }

  bool validateDeliveryInfo() {
    final fields = [
      firstName.text,
      lastName.text,
      email.text,
      phone.text,
      address.text,
      city.text,
      country.text,
    ];

    if (fields.any((value) => value.trim().isEmpty)) {
      showMessage("Please fill in every delivery field.");
      return false;
    }

    if (!email.text.contains("@")) {
      showMessage("Please enter a valid email address.");
      return false;
    }

    return true;
  }

  void showMessage(String message) {
    NotificationManager.info(context, message);
  }

  Widget pageShell({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      color: softBackground,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildStepIndicator(),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget buildStepIndicator() {
    final labels = ["Cart", "Info", "Total", "Pay"];

    return Row(
      children: List.generate(labels.length, (index) {
        final isActive = index == step;
        final isComplete = index < step;

        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isActive || isComplete
                    ? brandColor
                    : Colors.grey.shade300,
                child: Icon(
                  isComplete ? Icons.check : Icons.circle,
                  size: isComplete ? 16 : 8,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  labels[index],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive || isComplete
                        ? brandColor
                        : Colors.grey.shade600,
                  ),
                ),
              ),
              if (index != labels.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: isComplete ? brandColor : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget input(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
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

  Widget primaryButton(String label, VoidCallback? onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: bold ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCartItem(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
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
                          errorBuilder: (context, error, stackTrace) {
                            return imageFallback();
                          },
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
                          quantityButton(
                            icon: Icons.remove,
                            onPressed: quantity > 1
                                ? () => cartRef.doc(doc.id).update({
                                    'quantity': quantity - 1,
                                  })
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text("$quantity"),
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
            ],
          ],
        ),
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

  Widget imageFallback() {
    return Container(
      width: 68,
      height: 68,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported_outlined),
    );
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget paymentOption(String value, IconData icon) {
    final selected = paymentMethod == value;

    return Card(
      elevation: 0,
      color: selected ? const Color(0xFFF1E5F6) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? brandColor : Colors.grey.shade200,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            paymentMethod = value;
          });
        },
        leading: Icon(icon, color: selected ? brandColor : Colors.grey),
        title: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(
          selected ? Icons.check_circle : Icons.circle_outlined,
          color: selected ? brandColor : Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
        leading: step > 0 && step < 4
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => step--),
              )
            : null,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: cartRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Could not load checkout"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;
          total = calculateTotal(items);

          switch (step) {
            case 0:
              return pageShell(
                title: "Review Cart",
                subtitle: "Confirm your toys before entering delivery details.",
                child: Column(
                  children: [
                    Expanded(
                      child: items.isEmpty
                          ? const Center(child: Text("Your cart is empty"))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, index) =>
                                  buildCartItem(items[index]),
                            ),
                    ),
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          children: [
                            summaryRow(
                              "Subtotal",
                              "\$${total.toStringAsFixed(2)}",
                              bold: true,
                            ),
                            const SizedBox(height: 8),
                            primaryButton(
                              "Continue",
                              items.isEmpty
                                  ? null
                                  : () => setState(() => step = 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );

            case 1:
              return pageShell(
                title: "Delivery Info",
                subtitle: "Tell us where to send your order.",
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      input(firstName, "First Name", Icons.person_outline),
                      input(lastName, "Last Name", Icons.person_outline),
                      input(email, "Email", Icons.email_outlined),
                      input(phone, "Phone", Icons.phone_outlined),
                      input(address, "Address", Icons.home_outlined),
                      input(city, "City", Icons.location_city_outlined),
                      input(country, "Country", Icons.public),
                      const SizedBox(height: 6),
                      primaryButton("Continue", () async {
                        if (!validateDeliveryInfo()) {
                          return;
                        }

                        await saveDetails();
                        if (!mounted) {
                          return;
                        }
                        setState(() => step = 2);
                      }),
                    ],
                  ),
                ),
              );

            case 2:
              return pageShell(
                title: "Order Total",
                subtitle: "Review your subtotal, shipping, and final total.",
                child: Padding(
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
                              summaryRow(
                                "Subtotal",
                                "\$${total.toStringAsFixed(2)}",
                              ),
                              summaryRow("Shipping", "\$30.00"),
                              const Divider(height: 24),
                              summaryRow(
                                "Total",
                                "\$${(total + 30).toStringAsFixed(2)}",
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      primaryButton(
                        "Proceed to Payment",
                        () => setState(() => step = 3),
                      ),
                    ],
                  ),
                ),
              );

            case 3:
              return pageShell(
                title: "Payment",
                subtitle: "Choose a demo payment method to complete checkout.",
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      paymentOption("Visa ****2109", Icons.credit_card),
                      paymentOption(
                        "PayPal",
                        Icons.account_balance_wallet_outlined,
                      ),
                      paymentOption("Apple Pay", Icons.phone_iphone),
                      const Spacer(),
                      primaryButton(
                        "Pay \$${(total + 30).toStringAsFixed(2)}",
                        () async {
                          if (items.isEmpty) {
                            showMessage("Your cart is empty");
                            return;
                          }

                          final orderItems = items.map((doc) {
                            final data = doc.data();

                            return {
                              'productId': data['productId'],
                              'isCustomToy': data['isCustomToy'],
                              'name': data['name'],
                              'price': data['price'],
                              'image': data['image'],
                              'quantity': data['quantity'],
                              'type': data['type'],
                              'color': data['color'],
                              'accessory': data['accessory'],
                              'voiceMessage': data['voiceMessage'],
                              'customDetails': data['customDetails'],
                            };
                          }).toList();

                          await ordersRef.add({
                            'items': orderItems,
                            'shippingAddress': deliveryDetails(),
                            'subtotal': total,
                            'shipping': 30,
                            'total': total + 30,
                            'status': 'Processing',
                            'paymentMethod': paymentMethod,
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          for (final doc in items) {
                            await cartRef.doc(doc.id).delete();
                          }

                          await LocalNotificationService.showOrderConfirmedNotification(
                            total: total + 30,
                          );

                          if (!mounted) {
                            return;
                          }
                          setState(() => step = 4);
                        },
                      ),
                    ],
                  ),
                ),
              );

            case 4:
              return Container(
                width: double.infinity,
                color: softBackground,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 96,
                          color: brandColor,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "Order Confirmed",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your order is now saved in order history.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 28),
                        primaryButton("View Orders", () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrderHistoryScreen(),
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: brandColor,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          },
                          icon: const Icon(Icons.storefront),
                          label: const Text("Continue Shopping"),
                        ),
                      ],
                    ),
                  ),
                ),
              );

            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
