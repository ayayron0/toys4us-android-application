import 'package:flutter/material.dart';
import 'Product.dart';
import 'productpage.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String searchText = "";

  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "toy",
    "game",
    "cards",
  ];

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

    final filteredProducts = products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(searchText.toLowerCase()) ||
              product.description.toLowerCase().contains(searchText.toLowerCase());

      final matchesCategory =
          selectedCategory == "All" || product.types.contains(selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search products",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];

                return ChoiceChip(
                  label: Text(category == "All" ? "All" : category.toUpperCase()),
                  selected: selectedCategory == category,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 10),


          Expanded(
            child: GridView.builder(
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];

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

                              Text(
                                "\$${product.price}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.amber,
                                  ),
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
        ],
      ),
    );
  }
}
