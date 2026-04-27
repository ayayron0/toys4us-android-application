import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Product.dart';
import 'checkout.dart';

class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? selectedType;

  @override
  void initState() {
    super.initState();

    selectedType = widget.product.types.isNotEmpty
        ? widget.product.types[0]
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Products"),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CheckoutPage()),
                );
              },
            )
          ],
        ),

        body: SingleChildScrollView(

          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// image
                Center(
                  child: Image.asset(product.image, width: 280,),
                ),

                SizedBox(height: 20),

                /// colors
                Text("Type: ${selectedType ?? ""}"),
                SizedBox(height: 10),

                Row(
                  children: product.types.map((types) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(types),
                        selected: selectedType == types,
                        onSelected: (_) {
                          setState(() {
                            selectedType = types;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20),

                /// name
                Text(
                  product.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                /// subtitle
                Text(product.subtitle),

                SizedBox(height: 10),

                /// price
                Row(
                  children: [
                    Text(
                      "\$${product.oldPrice}",
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text("\$${product.price}"),
                  ],
                ),

                SizedBox(height: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Product Description", style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(height: 10),
                    Text(product.description,),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please log in first")),
                        );
                        return;
                      }

                      final cart = FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('cart_items');


                      // check if product already exists
        final existing = await cart
            .where('name', isEqualTo: product.name)
            .get();

        if (existing.docs.isNotEmpty) {
        // increment quantity
        final doc = existing.docs.first;
        int currentQty = doc['quantity'];

        await cart.doc(doc.id).update({
        'quantity': currentQty + 1,
        });
        } else {
        // add new item
        await cart.add({
        'name': product.name,
        'price': product.price,
        'image': product.image,
        'quantity': 1,
        });
        }

        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to cart")),
        );
        },
                      icon: Icon(Icons.add_shopping_cart, color: Colors.white,),
                      label: Text("Add to Cart", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      ),
                    ),

                    SizedBox(width: 10),

                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.touch_app, color: Colors.white,),
                      label: Text("Buy Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
    );
  }
}
