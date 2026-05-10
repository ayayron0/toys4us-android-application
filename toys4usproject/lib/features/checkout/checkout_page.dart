import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/local_notification_service.dart';
import '../../core/notification_manager.dart';
import '../orders/orderhistory.dart';
import 'widgets/step_indicator.dart';
import 'widgets/steps/cart_review_step.dart';
import 'widgets/steps/delivery_info_step.dart';
import 'widgets/steps/order_confirmed_step.dart';
import 'widgets/steps/order_total_step.dart';
import 'widgets/steps/payment_step.dart';
import '../../services/stripe_service.dart';

const Color brandColor = Color(0xFF7B1FA2);
const Color softBackground = Color(0xFFF8F5FA);

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

  Future<void> _saveOrder(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> items,
    double capturedTotal,
  ) async {
    await ordersRef.add({
      'items': items.map((doc) => doc.data()).toList(),
      'shippingAddress': deliveryDetails(),
      'subtotal': capturedTotal,
      'shipping': 30,
      'total': capturedTotal + 30,
      'status': 'Processing',
      'paymentMethod': 'Stripe',
      'createdAt': FieldValue.serverTimestamp(),
    });

    for (final doc in items) {
      await cartRef.doc(doc.id).delete();
    }

    await LocalNotificationService.showOrderConfirmedNotification(
      total: capturedTotal + 30,
    );

    if (!mounted) return;
    setState(() => step = 4);
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
    if (data == null || !mounted || loadedSavedProfile) return;

    firstName.text = data['firstName'] ?? '';
    lastName.text = data['lastName'] ?? '';
    email.text =
        data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
    phone.text = data['phone'] ?? '';
    address.text = data['address'] ?? '';
    city.text = data['city'] ?? '';
    country.text = data['country'] ?? '';
    setState(() => loadedSavedProfile = true);
  }

  double calculateTotal(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    double sum = 0;
    for (final item in docs) {
      final data = item.data();
      sum +=
          (data['price'] as num? ?? 0).toDouble() *
          (data['quantity'] as num? ?? 1).toInt();
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

  Map<String, dynamic> deliveryDetails() => {
    'firstName': firstName.text.trim(),
    'lastName': lastName.text.trim(),
    'email': email.text.trim(),
    'phone': phone.text.trim(),
    'address': address.text.trim(),
    'city': city.text.trim(),
    'country': country.text.trim(),
  };

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
    if (fields.any((v) => v.trim().isEmpty)) {
      NotificationManager.info(context, "Please fill in every delivery field.");
      return false;
    }
    if (!email.text.contains("@")) {
      NotificationManager.info(context, "Please enter a valid email address.");
      return false;
    }
    return true;
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
                  StepIndicator(currentStep: step),
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

  Future<void> placeOrder(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> items,
  ) async {
    if (items.isEmpty) {
      NotificationManager.info(context, "Your cart is empty");
      return;
    }

    try {
      final capturedTotal = total;

      if (!kIsWeb) {
        final success = await StripeService.processPayment(
          amount: capturedTotal + 30,
          customerName: '${firstName.text.trim()} ${lastName.text.trim()}',
        );
        if (!success) return;
      }

      await _saveOrder(items, capturedTotal);
    } catch (e) {
      if (!mounted) return;
      NotificationManager.error(context, "Payment failed. Please try again.");
    }
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
                child: CartReviewStep(
                  items: items,
                  total: total,
                  cartRef: cartRef,
                  onContinue: () => setState(() => step = 1),
                ),
              );
            case 1:
              return pageShell(
                title: "Delivery Info",
                subtitle: "Tell us where to send your order.",
                child: DeliveryInfoStep(
                  firstName: firstName,
                  lastName: lastName,
                  email: email,
                  phone: phone,
                  address: address,
                  city: city,
                  country: country,
                  onContinue: () async {
                    if (!validateDeliveryInfo()) return;
                    await saveDetails();
                    if (!mounted) return;
                    setState(() => step = 2);
                  },
                ),
              );
            case 2:
              return pageShell(
                title: "Order Total",
                subtitle: "Review your subtotal, shipping, and final total.",
                child: OrderTotalStep(
                  total: total,
                  onContinue: () => setState(() => step = 3),
                ),
              );
            case 3:
              return pageShell(
                title: "Payment",
                subtitle: "Complete your purchase securely.",
                child: PaymentStep(
                  total: total,
                  onPay: () => placeOrder(items),
                  onGooglePay: () async {
                    final capturedTotal = total;
                    final success = await StripeService.processGooglePay(
                      amount: capturedTotal + 30,
                    );
                    if (success && mounted) {
                      await _saveOrder(items, capturedTotal);
                    }
                  },
                  onApplePay: () async {
                    final capturedTotal = total;
                    final success = await StripeService.processApplePay(
                      amount: capturedTotal + 30,
                    );
                    if (success && mounted) {
                      await _saveOrder(items, capturedTotal);
                    }
                  },
                ),
              );
            case 4:
              return OrderConfirmedStep(
                onViewOrders: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                ),
                onContinueShopping: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              );
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
