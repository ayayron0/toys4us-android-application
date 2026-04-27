import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  CollectionReference<Map<String, dynamic>> get ordersRef {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('orders');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ordersRef.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return const Center(
            child: Text(
              "No orders yet",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data();
            final items = order['items'] as List<dynamic>;
            final total = (order['total'] ?? 0).toDouble();
            final status = order['status'] ?? 'Processing';


            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: const Icon(Icons.receipt_long),
                title: Text("Order #${orders[index].id.substring(0, 6)}"),
                subtitle: Text(
                  "Total: \$${total.toStringAsFixed(2)} - Status: $status",
                ),
                children: items.map((item) {
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text(
                      "\$${item['price']} x ${item['quantity']}",
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
