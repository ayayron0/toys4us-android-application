import 'package:flutter/material.dart';
import 'products.dart';
import 'buildatoy.dart';
import 'aboutus.dart';
import 'profile.dart';
import 'storelocation.dart';
import 'orderhistory.dart';



class MainProductNavigation extends StatefulWidget {
  @override
  _MainProductNavigationState createState() =>
      _MainProductNavigationState();
}

class _MainProductNavigationState extends State<MainProductNavigation> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const ProductsPage(),
    const BuildAToyPage(),
    AboutUsPage(),
    const StoreLocationPage(),
    const ProfilePage(),
    const OrderHistoryPage(),
  ];

  final List<String> titles = [
    "Products",
    "Build-A-Toy",
    "About Us",
    "Store Location",
    "Profile",
    "Order History",
  ];

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
    Navigator.pop(context); // close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        backgroundColor: Colors.purple,
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Center(
                child: Text(
                  "Toys 4 Us",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.storefront),
              title: const Text("Products"),
              onTap: () => changePage(0),
            ),

            ListTile(
              leading: const Icon(Icons.toys),
              title: const Text("Build-A-Toy"),
              onTap: () => changePage(1),
            ),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About Us"),
              onTap: () => changePage(2),
            ),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Store Location"),
              onTap: () => changePage(3),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () => changePage(4),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("Order History"),
              onTap: () => changePage(5),
            ),

          ],
        ),
      ),

      body: pages[selectedIndex],
    );
  }
}