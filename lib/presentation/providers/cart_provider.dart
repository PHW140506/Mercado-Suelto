import 'package:flutter/material.dart';
import '../../data/models/cart_item_model.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart_use_case.dart';
import '../../domain/usecases/remove_from_cart_use_case.dart';
import '../../domain/usecases/update_cart_quantity_use_case.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository repository;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartQuantityUseCase updateCartQuantityUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;

  String _userRole = 'Cliente';
  bool _isLoading = false;

  CartProvider({
    required this.repository,
    required this.addToCartUseCase,
    required this.updateCartQuantityUseCase,
    required this.removeFromCartUseCase,
  });

  String get userRole => _userRole;
  bool get isLoading => _isLoading;
  List<CartItem> get cartItems => repository.getItems();

  int get totalItemCount =>
      cartItems.fold(0, (total, item) => total + item.quantity);

  double get totalAmount {
    final total = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
    return double.parse(total.toStringAsFixed(2));
  }

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

  Future<bool> incrementQuantity(int productId) async {
    final item = cartItems.firstWhere((element) => element.product.id == productId);
    return await updateQuantity(productId, item.quantity + 1);
  }

  Future<bool> decrementQuantity(int productId) async {
    final item = cartItems.firstWhere((element) => element.product.id == productId);
    final newQuantity = item.quantity - 1;

    if (newQuantity <= 0) {
      return await removeItem(productId);
    } else {
      return await updateQuantity(productId, newQuantity);
    }
  }

  Future<bool> updateQuantity(int productId, int quantity) async {
    _isLoading = true;
    notifyListeners();

    final success = await updateCartQuantityUseCase.execute(
      cartId: 1,
      productId: productId,
      quantity: quantity,
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> removeItem(int productId) async {
    _isLoading = true;
    notifyListeners();

    final success = await removeFromCartUseCase.execute(
      cartId: 1,
      productId: productId,
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }
}