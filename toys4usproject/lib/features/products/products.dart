import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/joke_service.dart';
import 'product.dart';
import 'product_page.dart';

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
  Future<ToyJoke>? jokeFuture;

  static const Color brandColor = Color(0xFF7B1FA2);
  static const Color softBackground = Color(0xFFF8F5FA);

  final List<String> categories = ["All", "toy", "game", "cards"];

  CollectionReference<Map<String, dynamic>> get productsRef {
    return FirebaseFirestore.instance.collection('products');
  }

  @override
  void initState() {
    super.initState();
    seedDefaultProducts(); //comment this out after adding all the products please, this thing keeps updating the page each time it opens ressetting the stuff in the firebase to what's in teh json
    jokeFuture = JokeService().fetchJoke();
  }

  Future<List<Product>> _loadDefaultProducts() async {
    final jsonString = await rootBundle.loadString('assets/data/products.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => Product.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> seedDefaultProducts() async {
    if (seedingProducts) return;
    setState(() => seedingProducts = true);

    final products = await _loadDefaultProducts();
    final batch = FirebaseFirestore.instance.batch();

    for (final product in products) {
      batch.set(productsRef.doc(product.id), {
        ...product.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    if (!mounted) return;
    setState(() => seedingProducts = false);
    print("Seeded stuff");
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

        return Container(
          color: softBackground,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Find Your Next Favorite",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${products.length} products available",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search toys, games, cards...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: brandColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
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
                              category == "All"
                                  ? "All"
                                  : category.toUpperCase(),
                            ),
                            selected: selectedCategory == category,
                            selectedColor: const Color(0xFFF1E5F6),
                            side: BorderSide(
                              color: selectedCategory == category
                                  ? brandColor
                                  : Colors.grey.shade300,
                            ),
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 64,
                                color: brandColor,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "No products found",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Try another search or category.",
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            sliver: SliverLayoutBuilder(
                              builder: (context, constraints) {
                                final isWeb = kIsWeb;

                                return SliverGrid(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isWeb? (constraints.crossAxisExtent / 200).floor() : 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: isWeb ? 0.65 : 0.55,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                      final product = filteredProducts[index];
                                      return _buildProductCard(context, product);
                                    },
                                    childCount: filteredProducts.length,
                                  ),
                                );
                              },
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            sliver: SliverToBoxAdapter(child: playBreakCard()),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget playBreakCard() {
    return FutureBuilder<ToyJoke>(
      future: jokeFuture ??= JokeService().fetchJoke(),
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final joke = snapshot.data;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE7D6EF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E5F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: brandColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Play Break",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (loading)
                      Text(
                        "Loading a quick joke...",
                        style: TextStyle(color: Colors.grey.shade700),
                      )
                    else if (snapshot.hasError)
                      Text(
                        "Why did the toy smile? Because playtime started.",
                        style: TextStyle(color: Colors.grey.shade700),
                      )
                    else ...[
                      Text(
                        joke!.setup,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        joke.punchline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: brandColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
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
  
  Widget buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 42,
              color: Colors.grey,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 42,
              color: Colors.grey,
            ),
          );
        },
      );
    }
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
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: 
                buildImage(product.image)
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
                    if (product.types.isNotEmpty)
                      Text(
                        product.types.first.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: brandColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (product.types.isNotEmpty) const SizedBox(height: 3),
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
