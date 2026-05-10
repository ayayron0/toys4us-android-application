import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final double price;
  final double oldPrice;
  final String image;
  final double rating;
  final int reviews;
  final List<String> types;

  Product({
    this.id = '',
    required this.name,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.types,
  });

  factory Product.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc,)
  {
    final data = doc.data();

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      subtitle: data['subtitle'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num? ?? 0).toDouble(),
      oldPrice: (data['oldPrice'] as num? ?? 0).toDouble(),
      image: data['image'] ?? '',
      rating: (data['rating'] as num? ?? 0).toDouble(),
      reviews: (data['reviews'] as num? ?? 0).toInt(),
      types: List<String>.from(data['types'] ?? []),
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      subtitle: map['subtitle'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num? ?? 0).toDouble(),
      oldPrice: (map['oldPrice'] as num? ?? 0).toDouble(),
      image: map['image'] ?? '',
      rating: (map['rating'] as num? ?? 0).toDouble(),
      reviews: (map['reviews'] as num? ?? 0).toInt(),
      types: List<String>.from(map['types'] ?? []),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'subtitle': subtitle,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'image': image,
      'rating': rating,
      'reviews': reviews,
      'types': types,
    };
  }
}
