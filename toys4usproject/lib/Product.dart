class Product {
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
    required this.name,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.types
  });
}