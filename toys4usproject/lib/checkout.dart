import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int step = 0;

  CollectionReference<Map<String, dynamic>> get cartRef {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart_items');
  }

  CollectionReference<Map<String, dynamic>> get userRef {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('user_details');
  }

  CollectionReference<Map<String, dynamic>> get ordersRef {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('orders');
  }



  // Controllers
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final country = TextEditingController();

  double total = 0;

  double calculateTotal(List docs) {
    double sum = 0;
    for (var item in docs) {
      sum += item['price'] * item['quantity'];
    }
    return sum;
  }

  Future<void> saveDetails() async {
    await userRef.add({
      'firstName': firstName.text,
      'lastName': lastName.text,
      'email': email.text,
      'phone': phone.text,
      'address': address.text,
      'city': city.text,
      'country': country.text,
    });
  }

  Widget input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        leading: step > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => step--),
        )
            : null,
      ),

      body: StreamBuilder(
        stream: cartRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;
          total = calculateTotal(items);

          switch (step) {

          /// ---------------- STEP 0: DETAILS ----------------
            case 0:
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircleAvatar(radius: 40),
                    const SizedBox(height: 10),

                    input(firstName, "First Name"),
                    input(lastName, "Last Name"),
                    input(email, "Email"),
                    input(phone, "Phone"),
                    input(address, "Address"),
                    input(city, "City"),
                    input(country, "Country"),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        await saveDetails();
                        setState(() => step = 1);
                      },
                      child: const Text("Continue"),
                    )
                  ],
                ),
              );

          /// ---------------- STEP 1: CART ----------------
            case 1:
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: items.map((doc) {
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: Image.asset(doc['image'], width: 50),
                            title: Text(doc['name']),
                            subtitle: Text(
                                "\$${doc['price']} x ${doc['quantity']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    int q = doc['quantity'];
                                    if (q > 1) {
                                      cartRef
                                          .doc(doc.id)
                                          .update({'quantity': q - 1});
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    int q = doc['quantity'];
                                    cartRef
                                        .doc(doc.id)
                                        .update({'quantity': q + 1});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    cartRef.doc(doc.id).delete();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => setState(() => step = 2),
                    child: const Text("Continue"),
                  )
                ],
              );

          /// ---------------- STEP 2: TOTAL ----------------
            case 2:
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text("Order"),
                      trailing: Text("\$${total.toStringAsFixed(2)}"),
                    ),
                    const ListTile(
                      title: Text("Shipping"),
                      trailing: Text("\$30"),
                    ),
                    ListTile(
                      title: const Text("Total"),
                      trailing:
                      Text("\$${(total + 30).toStringAsFixed(2)}"),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () => setState(() => step = 3),
                      child: const Text("Proceed to Payment"),
                    )
                  ],
                ),
              );

          /// ---------------- STEP 3: PAYMENT ----------------
            case 3:
              return Column(
                children: [
                  const ListTile(title: Text("Visa ****2109")),
                  const ListTile(title: Text("PayPal")),
                  const ListTile(title: Text("Apple Pay")),

                  const Spacer(),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      if (items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Your cart is empty")),
                        );
                        return;
                      }
                      final orderItems = items.map((doc) {
                        final data = doc.data();

                        return {
                          'name': data['name'],
                          'price': data['price'],
                          'image': data['image'],
                          'quantity': data['quantity'],
                          'type': data['type'],
                          'color': data['color'],
                          'accessory': data['accessory'],
                          'voiceMessage': data['voiceMessage'],
                        };
                      }).toList();

                      await ordersRef.add({
                        'items': orderItems,
                        'subtotal': total,
                        'shipping': 30,
                        'total': total + 30,
                        'status': 'Processing',
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      for (var doc in items) {
                        await cartRef.doc(doc.id).delete();
                      }

                      setState(() => step = 4);
                    },
                    child: const Text("Pay Now"),
                  )
                ],
              );

          /// ---------------- STEP 4: SUCCESS ----------------
            case 4:
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        size: 100, color: Colors.purple),
                    SizedBox(height: 20),
                    Text("Payment Successful",
                        style: TextStyle(fontSize: 18)),
                  ],
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