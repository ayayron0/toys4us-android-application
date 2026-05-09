import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'adminorderspage.dart';
import 'adminproductspage.dart';
import 'logon.dart';
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

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget drawerItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Material(
        color: selected ? const Color(0xFFF1E5F6) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(icon),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          trailing: selected
              ? const Icon(Icons.chevron_right, color: brandColor)
              : null,
          selected: selected,
          selectedColor: brandColor,
          iconColor: selected ? brandColor : Colors.grey.shade700,
          onTap: () => changePage(index),
        ),
      ),
    );
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
      const StoreLocationPage(),
      AboutUsPage(),
      const ProfilePage(),
      if (isAdmin) const AdminProductsPage(),
      if (isAdmin) const AdminOrdersPage(),
    ];

    final titles = [
      "Products",
      "Build-A-Toy",
      "Cart",
      "Order History",
      "Store Location",
      "About Us",
      "Profile",
      if (isAdmin) "Manage Products",
      if (isAdmin) "Manage Orders",
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
            Container(
              padding: const EdgeInsets.fromLTRB(18, 52, 18, 18),
              decoration: const BoxDecoration(color: brandColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.toys, color: brandColor, size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Toys 4 Us",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email.isEmpty ? "Signed in" : email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x29FFFFFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "ADMIN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            drawerItem(index: 0, icon: Icons.storefront, title: "Products"),
            drawerItem(index: 1, icon: Icons.toys, title: "Build-A-Toy"),
            drawerItem(index: 2, icon: Icons.shopping_cart, title: "Cart"),
            drawerItem(
              index: 3,
              icon: Icons.receipt_long,
              title: "Order History",
            ),

            drawerItem(
              index: 4,
              icon: Icons.location_on,
              title: "Store Location",
            ),
            drawerItem(index: 5, icon: Icons.info, title: "About Us"),
            drawerItem(index: 6, icon: Icons.person, title: "Profile"),

            if (isAdmin) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 6),
                child: Text(
                  "Admin Tools",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              drawerItem(
                index: 7,
                icon: Icons.admin_panel_settings,
                title: "Manage Products",
              ),
              drawerItem(
                index: 8,
                icon: Icons.assignment_outlined,
                title: "Manage Orders",
              ),
            ],
            const Divider(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () => logout(context),
              ),
            ),
          ],
        ),
      ),

      body: pages[selectedIndex],
    );
  }
}
