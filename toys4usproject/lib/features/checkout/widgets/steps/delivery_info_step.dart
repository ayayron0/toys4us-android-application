import 'package:flutter/material.dart';

import '../checkout_input.dart';
import '../checkout_primary_button.dart';

class DeliveryInfoStep extends StatelessWidget {
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController address;
  final TextEditingController city;
  final TextEditingController country;
  final VoidCallback onContinue;

  const DeliveryInfoStep({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          CheckoutInput(controller: firstName, label: "First Name", icon: Icons.person_outline),
          CheckoutInput(controller: lastName, label: "Last Name", icon: Icons.person_outline),
          CheckoutInput(controller: email, label: "Email", icon: Icons.email_outlined),
          CheckoutInput(controller: phone, label: "Phone", icon: Icons.phone_outlined),
          CheckoutInput(controller: address, label: "Address", icon: Icons.home_outlined),
          CheckoutInput(controller: city, label: "City", icon: Icons.location_city_outlined),
          CheckoutInput(controller: country, label: "Country", icon: Icons.public),
          const SizedBox(height: 6),
          CheckoutPrimaryButton(label: "Continue", onPressed: onContinue),
        ],
      ),
    );
  }
}