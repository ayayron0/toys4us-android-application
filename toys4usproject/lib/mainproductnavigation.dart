import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'adminproductspage.dart';
import 'products.dart';
import 'buildatoy.dart';
import 'cartpage.dart';
import 'aboutus.dart';
import 'profile.dart';
import 'storelocation.dart';
import 'orderhistory.dart';

class MainProductNavigation extends StatefulWidget {
  const MainProductNavigation({super.key});

  @override
  State<MainProductNavigation> createState() => _MainProductNavigationState();
}

class _MainProductNavigationState extends State<MainProductNavigation> {
  int selectedIndex = 0;
  static const Color brandColor = Color(0xFF7B1FA2);
  static const String adminEmail = "admin@toys4us.com";

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
    Navigator.pop(context); // close drawer
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? "";
    final isAdmin = email.toLowerCase() == adminEmail;

    final pages = [
      const ProductsPage(),
      const BuildAToyPage(),
      const CartPage(),
      const OrderHistoryPage(),
      const ProfilePage(),
      const StoreLocationPage(),
      AboutUsPage(),
      if (isAdmin) const AdminProductsPage(),
    ];

    final titles = [
      "Products",
      "Build-A-Toy",
      "Cart",
      "Order History",
      "Profile",
      "Store Location",
      "About Us",
      if (isAdmin) "Manage Products",
    ];

    if (selectedIndex >= pages.length) {
      selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: brandColor),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.toys, color: Colors.white, size: 36),
                  SizedBox(height: 10),
                  Text(
                    "Toys 4 Us",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Shop, build, and track orders",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.storefront),
              title: const Text("Products"),
              selected: selectedIndex == 0,
              selectedColor: brandColor,
              onTap: () => changePage(0),
            ),

            ListTile(
              leading: const Icon(Icons.toys),
              title: const Text("Build-A-Toy"),
              selected: selectedIndex == 1,
              selectedColor: brandColor,
              onTap: () => changePage(1),
            ),

            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Cart"),
              selected: selectedIndex == 2,
              selectedColor: brandColor,
              onTap: () => changePage(2),
            ),

            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("Order History"),
              selected: selectedIndex == 3,
              selectedColor: brandColor,
              onTap: () => changePage(3),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              selected: selectedIndex == 4,
              selectedColor: brandColor,
              onTap: () => changePage(4),
            ),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Store Location"),
              selected: selectedIndex == 5,
              selectedColor: brandColor,
              onTap: () => changePage(5),
            ),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About Us"),
              selected: selectedIndex == 6,
              selectedColor: brandColor,
              onTap: () => changePage(6),
            ),

            if (isAdmin) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text("Manage Products"),
                selected: selectedIndex == 7,
                selectedColor: brandColor,
                onTap: () => changePage(7),
              ),
            ],
          ],
        ),
      ),

      body: pages[selectedIndex],
    );
  }
}
