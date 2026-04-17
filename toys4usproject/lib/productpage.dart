import 'package:flutter/material.dart';

import 'Product.dart';

void main() {
  runApp(MaterialApp(home: ProductPage(product:
  Product(
      name: "Tomodachi Life: Living the Dream",
      subtitle: "Who doesn’t want this new switch game? Build relationships and explore a fun virtual world.",
      description: "Tomodachi Life: Living the Dream, known in Japan as Tomodachi Collection: Exciting Life, is a 2026 social simulation game by Nintendo for the Nintendo Switch. It is the third overall and second international entry in the Tomodachi Life series, succeeding Tomodachi Collection and Tomodachi Life. SOURCE: Wikipedia",
      price: 21.99,
      oldPrice: 29.99,
      image: "assets/images/bear.png",
      rating: 4.5,
      reviews: 6780,
      types: ['Digital', 'Physical']
  )
  ), debugShowCheckedModeBanner: false,
  )
  );
}

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
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          leading: Icon(Icons.arrow_back),
          actions: [
            Icon(Icons.shopping_cart_outlined),
            SizedBox(width: 10),
          ],),

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
                      onPressed: () {},
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
