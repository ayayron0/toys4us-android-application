class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });

  factory CartItem.fromFirestore(String id, Map<String, dynamic> data) {
    return CartItem(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      quantity: data['quantity'] ?? 1,
    );
  }

  double get subtotal {
    return price * quantity;
  }
}
