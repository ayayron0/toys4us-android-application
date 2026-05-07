import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'product.dart';
import 'productpage.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String searchText = "";
  String selectedCategory = "All";
  bool seedingProducts = false;
  bool checkedAutoSeed = false;

  static const Color brandColor = Color(0xFF7B1FA2);

  final List<String> categories = ["All", "toy", "game", "cards"];

  CollectionReference<Map<String, dynamic>> get productsRef {
    return FirebaseFirestore.instance.collection('products');
  }

  List<Product> get defaultProducts {
    return [
      Product(
        id: 'tomodachi-life',
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
        id: 'owl-plush',
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
        id: 'jigsaw-puzzle',
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
        id: 'mega-evo-etb',
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
  }

  Future<void> seedDefaultProducts() async {
    if (seedingProducts) {
      return;
    }

    setState(() {
      seedingProducts = true;
    });

    final batch = FirebaseFirestore.instance.batch();

    for (final product in defaultProducts) {
      batch.set(productsRef.doc(product.id), {
        ...product.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    if (!mounted) {
      return;
    }

    setState(() {
      seedingProducts = false;
    });
  }

  List<Product> filterProducts(List<Product> products) {
    return products.where((product) {
      final query = searchText.toLowerCase();
      final matchesSearch =
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);

      final matchesCategory =
          selectedCategory == "All" || product.types.contains(selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: productsRef.orderBy('name').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Could not load products"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          if (!checkedAutoSeed && !seedingProducts) {
            checkedAutoSeed = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                seedDefaultProducts();
              }
            });
          }
          return emptyProducts();
        }

        final products = docs.map(Product.fromFirestore).toList();
        final filteredProducts = filterProducts(products);

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
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return ChoiceChip(
                      label: Text(
                        category == "All" ? "All" : category.toUpperCase(),
                      ),
                      selected: selectedCategory == category,
                      selectedColor: const Color(0xFFF1E5F6),
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
                child: filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                          "No products found",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 600;

                          return GridView.builder(
                            itemCount: filteredProducts.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isWide ? 3 : 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: isWide ? 0.72 : 0.68,
                                ),
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];

                              return _buildProductCard(context, product);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget emptyProducts() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 72, color: brandColor),
            const SizedBox(height: 16),
            const Text(
              "Setting up products",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              seedingProducts
                  ? "Adding the starter toy catalog to Firestore..."
                  : "The product catalog will load in a moment.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 18),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(product: product),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: Image.asset(
                product.image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      "\$${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            "${product.rating} (${product.reviews})",
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
