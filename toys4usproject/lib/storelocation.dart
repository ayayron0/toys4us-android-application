import 'package:flutter/material.dart';

class StoreLocationPage extends StatelessWidget {
  const StoreLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.location_on, size: 80, color: Colors.purple),
            SizedBox(height: 20),
            Text(
              "Toys 4 Us Store Location",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "123 Avenue Street, Montreal, QC",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 12),
            Text(
              "Open Monday to Saturday\n10:00 AM - 8:00 PM",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
