import 'package:flutter/material.dart';
import 'products.dart';
import 'buildatoy.dart';
import 'aboutus.dart';

class MainProductNavigation extends StatefulWidget {
  @override
  _MainProductNavigationState createState() =>
      _MainProductNavigationState();
}

class _MainProductNavigationState extends State<MainProductNavigation> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    ProductsPage(),
    BuildAToyPage(),
    AboutUsPage(),
  ];

  final List<String> titles = [
    "Products",
    "Build-A-Toy",
    "About Us",
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
              title: Text("Products"),
              onTap: () => changePage(0),
            ),

            ListTile(
              title: Text("Build-A-Toy"),
              onTap: () => changePage(1),
            ),

            ListTile(
              title: Text("About Us"),
              onTap: () => changePage(2),
            ),
          ],
        ),
      ),

      body: pages[selectedIndex],
    );
  }
}