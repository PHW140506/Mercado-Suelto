class CartModel {
  final int id;
  final int userId;
  final DateTime date;
  final List<CartItemModel> products;

  CartModel({
    required this.id, 
    required this.userId, 
    required this.date, 
    required this.products
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      products: (json['products'] as List<dynamic>?)?.map((item) => CartItemModel.fromJson(item)).toList() ?? [],
    );
  }
}

class CartItemModel {
  final int productId;
  final int quantity;

  CartItemModel({required this.productId, required this.quantity});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
    );
  }
}