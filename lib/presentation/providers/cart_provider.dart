import 'package:flutter/material.dart';
import '../../data/models/cart_item_model.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart_use_case.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository repository;
  final AddToCartUseCase addToCartUseCase;

  String _userRole = 'Cliente';
  bool _isLoading = false;

  CartProvider({
    required this.repository,
    required this.addToCartUseCase,
  });

  String get userRole => _userRole;
  bool get isLoading => _isLoading;
  List<CartItem> get cartItems => repository.getItems();
  int get totalItemCount =>
      cartItems.fold(0, (total, item) => total + item.quantity);

  void setRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  Future<bool> addToCart(Product product, int quantity) async {
    _isLoading = true;
    notifyListeners();

    final success = await addToCartUseCase.execute(
      product: product,
      quantity: quantity,
      userRole: _userRole,
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }
}