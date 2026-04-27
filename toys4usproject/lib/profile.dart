import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'logon.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 45,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              user?.email ?? "No user signed in",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              "Member Status: Toys 4 Us Customer",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Saved profile connected with Firebase account",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
