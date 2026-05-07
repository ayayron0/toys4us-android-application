import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'logon.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final country = TextEditingController();

  bool loadedProfile = false;
  bool saving = false;

  static const Color brandColor = Color(0xFF7B1FA2);
  static const Color softBackground = Color(0xFFF8F5FA);

  DocumentReference<Map<String, dynamic>> get profileRef {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('users').doc(user!.uid);
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    phone.dispose();
    address.dispose();
    city.dispose();
    country.dispose();
    super.dispose();
  }

  void fillControllers(Map<String, dynamic> data) {
    if (loadedProfile) {
      return;
    }

    firstName.text = data['firstName'] ?? '';
    lastName.text = data['lastName'] ?? '';
    phone.text = data['phone'] ?? '';
    address.text = data['address'] ?? '';
    city.text = data['city'] ?? '';
    country.text = data['country'] ?? '';
    loadedProfile = true;
  }

  Future<void> saveProfile() async {
    setState(() {
      saving = true;
    });

    await profileRef.set({
      'email': FirebaseAuth.instance.currentUser?.email ?? '',
      'firstName': firstName.text.trim(),
      'lastName': lastName.text.trim(),
      'phone': phone.text.trim(),
      'address': address.text.trim(),
      'city': city.text.trim(),
      'country': country.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) {
      return;
    }

    setState(() {
      saving = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile saved")));
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: profileRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Could not load profile"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() ?? {};
        fillControllers(data);
        final fullName = "${firstName.text.trim()} ${lastName.text.trim()}"
            .trim();

        return Container(
          color: softBackground,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        backgroundColor: Color(0xFFF1E5F6),
                        child: Icon(Icons.person, color: brandColor, size: 34),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName.isEmpty
                                  ? "Toys 4 Us Customer"
                                  : fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? "No email available",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Saved Delivery Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              input(firstName, "First Name", Icons.person_outline),
              input(lastName, "Last Name", Icons.person_outline),
              input(phone, "Phone", Icons.phone_outlined),
              input(address, "Address", Icons.home_outlined),
              input(city, "City", Icons.location_city_outlined),
              input(country, "Country", Icons.public),
              const SizedBox(height: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                ),
                onPressed: saving ? null : saveProfile,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(saving ? "Saving..." : "Save Profile"),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 52),
                ),
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ],
          ),
        );
      },
    );
  }
}
