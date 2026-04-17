import 'package:flutter/material.dart';
import 'Product.dart';
import 'productpage.dart';

class ProductsPage extends StatelessWidget {
  ProductsPage({super.key});

  final List<Product> products = [
    Product(
      name: "Tomodachi Life",
      subtitle: "Living the Dream",
      description: "Who doesn't want this new switch game...",
      price: 21.99,
      oldPrice: 68.90,
      image: "assets/images/tomodachi.jpg",
      rating: 4.5,
      reviews: 6890,
      types: ["game"],
    ),
    Product(
      name: "Owl Plush",
      subtitle: "",
      description: "Reminds us all of who we truly love...OWLS",
      price: 29.99,
      oldPrice: 0,
      image: "assets/images/owl.jpg",
      rating: 4.8,
      reviews: 152344,
      types: ["toy"],
    ),
    Product(
      name: "Jigsaw Puzzle",
      subtitle: "",
      description: "For those with the brains for it...",
      price: 9.99,
      oldPrice: 0,
      image: "assets/images/puzzle.jpg",
      rating: 4.2,
      reviews: 320,
      types: ["game"],
    ),
    Product(
      name: "Mega Evo ETB",
      subtitle: "",
      description: "Become poor for your interests...",
      price: 999.99,
      oldPrice: 0,
      image: "assets/images/box.jpg",
      rating: 5.0,
      reviews: 12,
      types: ["cards"],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 🔥 more columns
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.6,
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductPage(product: product),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: Colors.black12,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      child: Image.asset(
                        product.image,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 3),

                          // Description
                          Text(
                            product.description,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Price
                          Text(
                            "\$${product.price}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),

                          // Rating
                          Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  "${product.rating} (${product.reviews})",
                                  style: const TextStyle(fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}