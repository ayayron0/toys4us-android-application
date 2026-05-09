import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  static const Color brandColor = Color(0xFF7B1FA2);
  static const Color softBackground = Color(0xFFF8F5FA);

  static const List<String> statuses = [
    "Processing",
    "Shipped",
    "Delivered",
    "Cancelled",
  ];

  Query<Map<String, dynamic>> get ordersQuery {
    return FirebaseFirestore.instance.collectionGroup('orders');
  }

  String formatDate(dynamic createdAt) {
    if (createdAt is! Timestamp) {
      return "Just now";
    }

    final date = createdAt.toDate();
    return "${date.month}/${date.day}/${date.year}";
  }

  int itemCount(List<dynamic> items) {
    return items.fold<int>(0, (totalItems, item) {
      if (item is Map<String, dynamic>) {
        return totalItems + (item['quantity'] as num? ?? 1).toInt();
      }
      return totalItems + 1;
    });
  }

  String customerLabel(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> order,
  ) {
    final shippingAddress = order['shippingAddress'];

    if (shippingAddress is Map<String, dynamic>) {
      final name =
          "${shippingAddress['firstName'] ?? ''} ${shippingAddress['lastName'] ?? ''}"
              .trim();
      final email = (shippingAddress['email'] ?? '').toString();

      if (name.isNotEmpty && email.isNotEmpty) {
        return "$name - $email";
      }

      if (email.isNotEmpty) {
        return email;
      }

      if (name.isNotEmpty) {
        return name;
      }
    }

    final userId = doc.reference.parent.parent?.id;
    return userId == null ? "Unknown customer" : "User $userId";
  }

  Widget statusBadge(String status) {
    final color = switch (status) {
      "Delivered" => const Color(0xFF237A3B),
      "Shipped" => const Color(0xFF1565C0),
      "Cancelled" => const Color(0xFFC62828),
      _ => const Color(0xFF8A5A00),
    };

    final background = switch (status) {
      "Delivered" => const Color(0xFFE9F7EF),
      "Shipped" => const Color(0xFFEAF2FF),
      "Cancelled" => const Color(0xFFFFECEC),
      _ => const Color(0xFFFFF4D8),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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

  Future<void> updateStatus(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String status,
  ) async {
    await doc.reference.update({
      'status': status,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Widget itemSummary(List<dynamic> items) {
    if (items.isEmpty) {
      return const Text("No items saved");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.take(3).map((item) {
        final itemData = item as Map<String, dynamic>;
        final name = itemData['name'] ?? 'Order item';
        final quantity = (itemData['quantity'] as num? ?? 1).toInt();
        final custom = itemData['isCustomToy'] == true ? "Build-A-Toy" : null;

        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            custom == null ? "$name x$quantity" : "$name x$quantity - $custom",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  Widget orderCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final order = doc.data();
    final items = (order['items'] as List<dynamic>? ?? []);
    final total = (order['total'] as num? ?? 0).toDouble();
    final status = (order['status'] ?? 'Processing').toString();
    final paymentMethod = order['paymentMethod'] ?? 'Demo payment';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1E5F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.local_shipping_outlined, color: brandColor),
        ),
        title: Text(
          "Order #${doc.id.substring(0, 6).toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "${customerLabel(doc, order)}\n${formatDate(order['createdAt'])} - ${itemCount(items)} item${itemCount(items) == 1 ? "" : "s"}",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "\$${total.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            statusBadge(status),
          ],
        ),
        children: [
          const Divider(height: 18),
          Row(
            children: [
              Expanded(child: Text("Payment: $paymentMethod")),
              PopupMenuButton<String>(
                tooltip: "Update status",
                onSelected: (newStatus) => updateStatus(doc, newStatus),
                itemBuilder: (context) {
                  return statuses.map((statusOption) {
                    return PopupMenuItem(
                      value: statusOption,
                      child: Row(
                        children: [
                          if (statusOption == status)
                            const Icon(Icons.check, size: 18)
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(statusOption),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: brandColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: brandColor),
                      SizedBox(width: 6),
                      Text(
                        "Change Status",
                        style: TextStyle(
                          color: brandColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          itemSummary(items),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: softBackground,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ordersQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 56, color: brandColor),
                    const SizedBox(height: 14),
                    const Text(
                      "Could not load admin orders",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = [...snapshot.data!.docs];
          orders.sort((a, b) {
            final aDate = a.data()['createdAt'];
            final bDate = b.data()['createdAt'];

            if (aDate is Timestamp && bDate is Timestamp) {
              return bDate.compareTo(aDate);
            }

            return 0;
          });
          final processingCount = orders.where((doc) {
            return (doc.data()['status'] ?? 'Processing') == 'Processing';
          }).length;
          final shippedCount = orders.where((doc) {
            return doc.data()['status'] == 'Shipped';
          }).length;

          if (orders.isEmpty) {
            return const Center(child: Text("No customer orders yet"));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Row(
                children: [
                  statCard("Orders", "${orders.length}", Icons.receipt_long),
                  const SizedBox(width: 10),
                  statCard(
                    "Processing",
                    "$processingCount",
                    Icons.pending_actions,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  statCard("Shipped", "$shippedCount", Icons.local_shipping),
                  const SizedBox(width: 10),
                  statCard(
                    "Customers",
                    "${orders.map((doc) => doc.reference.parent.parent?.id).whereType<String>().toSet().length}",
                    Icons.people_outline,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Customer Orders",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                "View customer orders and update fulfillment status.",
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 14),
              ...orders.map((doc) => orderCard(context, doc)),
            ],
          );
        },
      ),
    );
  }
}
