import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: OrderHistoryPage.brandColor,
        foregroundColor: Colors.white,
      ),
      body: const OrderHistoryPage(),
    );
  }
}

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  static const Color brandColor = Color(0xFF7B1FA2);
  static const Color softBackground = Color(0xFFF8F5FA);

  CollectionReference<Map<String, dynamic>> get ordersRef {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('orders');
  }

  String formatDate(dynamic createdAt) {
    if (createdAt is! Timestamp) {
      return "Just now";
    }

    final date = createdAt.toDate();
    return "${date.month}/${date.day}/${date.year}";
  }

  Widget emptyOrders() {
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
                Icons.receipt_long_outlined,
                size: 48,
                color: brandColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "No orders yet",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Completed checkouts will show up here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget orderCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final order = doc.data();
    final items = (order['items'] as List<dynamic>? ?? []);
    final total = (order['total'] as num? ?? 0).toDouble();
    final status = order['status'] ?? 'Processing';
    final itemCount = items.fold<int>(0, (totalItems, item) {
      if (item is Map<String, dynamic>) {
        return totalItems + (item['quantity'] as num? ?? 1).toInt();
      }
      return totalItems + 1;
    });

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderRef: doc.reference),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E5F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long, color: brandColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${doc.id.substring(0, 6).toUpperCase()}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${formatDate(order['createdAt'])} - $itemCount item${itemCount == 1 ? "" : "s"}",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 6),
                    statusBadge(status),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String customToySummary(Map<String, dynamic> itemData) {
    final parts = [
      "Type: ${itemData['type'] ?? 'Custom'}",
      "Color: ${itemData['color'] ?? 'Not selected'}",
      "Accessory: ${itemData['accessory'] ?? 'None'}",
    ];

    final voiceMessage = (itemData['voiceMessage'] ?? '').toString().trim();
    if (voiceMessage.isNotEmpty) {
      parts.add("Voice: $voiceMessage");
    }

    return parts.join(" | ");
  }

  Widget statusBadge(String status) {
    final isCancelled = status == 'Cancelled';
    final background = isCancelled
        ? const Color(0xFFFFECEC)
        : const Color(0xFFE9F7EF);
    final foreground = isCancelled
        ? const Color(0xFFC62828)
        : const Color(0xFF237A3B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> confirmCancel(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> orderRef,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancel order?"),
          content: const Text(
            "This order will stay in your history with a Cancelled status.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Keep Order"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Cancel Order"),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) {
      return;
    }

    await orderRef.update({
      'status': 'Cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ordersRef.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Could not load orders"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return emptyOrders();
        }

        return Container(
          color: softBackground,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) => orderCard(context, orders[index]),
          ),
        );
      },
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> orderRef;

  const OrderDetailScreen({super.key, required this.orderRef});

  static const Color brandColor = OrderHistoryPage.brandColor;
  static const Color softBackground = OrderHistoryPage.softBackground;

  String formatDate(dynamic createdAt) {
    if (createdAt is! Timestamp) {
      return "Just now";
    }

    final date = createdAt.toDate();
    return "${date.month}/${date.day}/${date.year}";
  }

  String customToySummary(Map<String, dynamic> itemData) {
    final parts = [
      "Type: ${itemData['type'] ?? 'Custom'}",
      "Color: ${itemData['color'] ?? 'Not selected'}",
      "Accessory: ${itemData['accessory'] ?? 'None'}",
    ];

    final voiceMessage = (itemData['voiceMessage'] ?? '').toString().trim();
    if (voiceMessage.isNotEmpty) {
      parts.add("Voice: $voiceMessage");
    }

    return parts.join(" | ");
  }

  Widget statusBadge(String status) {
    final isCancelled = status == 'Cancelled';
    final background = isCancelled
        ? const Color(0xFFFFECEC)
        : const Color(0xFFE9F7EF);
    final foreground = isCancelled
        ? const Color(0xFFC62828)
        : const Color(0xFF237A3B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget moneyRow(String label, double value, {bool bold = false}) {
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
              fontSize: bold ? 18 : 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget itemTile(Map<String, dynamic> itemData) {
    final image = itemData['image'] ?? '';
    final name = itemData['name'] ?? 'Order item';
    final price = (itemData['price'] as num? ?? 0).toDouble();
    final quantity = (itemData['quantity'] as num? ?? 1).toInt();
    final isCustomToy = itemData['isCustomToy'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: image.toString().isNotEmpty
                ? Image.asset(
                    image,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return imageFallback();
                    },
                  )
                : Container(
                    width: 58,
                    height: 58,
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
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text("\$${price.toStringAsFixed(2)} x $quantity"),
                if (isCustomToy) ...[
                  const SizedBox(height: 3),
                  Text(
                    customToySummary(itemData),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> confirmCancel(BuildContext context) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancel order?"),
          content: const Text(
            "This order will stay in your history with a Cancelled status.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Keep Order"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Cancel Order"),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) {
      return;
    }

    await orderRef.update({
      'status': 'Cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  Widget imageFallback() {
    return Container(
      width: 58,
      height: 58,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: orderRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Could not load order"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data!.data();

          if (order == null) {
            return const Center(child: Text("Order not found"));
          }

          final items = (order['items'] as List<dynamic>? ?? []);
          final subtotal = (order['subtotal'] as num? ?? 0).toDouble();
          final shipping = (order['shipping'] as num? ?? 0).toDouble();
          final total = (order['total'] as num? ?? 0).toDouble();
          final status = order['status'] ?? 'Processing';
          final paymentMethod = order['paymentMethod'] ?? 'Demo payment';
          final shippingAddress = order['shippingAddress'];
          final canCancel = status == 'Processing';

          return Container(
            color: softBackground,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Order #${orderRef.id.substring(0, 6).toUpperCase()}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            statusBadge(status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        detailRow("Placed", formatDate(order['createdAt'])),
                        detailRow("Payment", paymentMethod),
                      ],
                    ),
                  ),
                ),
                sectionCard(
                  title: "Shipping",
                  child: shippingAddress is Map<String, dynamic>
                      ? Column(
                          children: [
                            detailRow(
                              "Name",
                              "${shippingAddress['firstName'] ?? ''} ${shippingAddress['lastName'] ?? ''}"
                                  .trim(),
                            ),
                            detailRow("Email", shippingAddress['email'] ?? ''),
                            detailRow("Phone", shippingAddress['phone'] ?? ''),
                            detailRow(
                              "Address",
                              "${shippingAddress['address'] ?? ''}, ${shippingAddress['city'] ?? ''}, ${shippingAddress['country'] ?? ''}",
                            ),
                          ],
                        )
                      : const Text("No shipping address saved"),
                ),
                sectionCard(
                  title: "Items",
                  child: Column(
                    children: items.map((item) {
                      return itemTile(item as Map<String, dynamic>);
                    }).toList(),
                  ),
                ),
                sectionCard(
                  title: "Payment Summary",
                  child: Column(
                    children: [
                      moneyRow("Subtotal", subtotal),
                      moneyRow("Shipping", shipping),
                      const Divider(height: 22),
                      moneyRow("Total", total, bold: true),
                    ],
                  ),
                ),
                if (canCancel)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    onPressed: () => confirmCancel(context),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text("Cancel Order"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
