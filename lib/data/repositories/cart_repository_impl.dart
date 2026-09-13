import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final http.Client client;
  final Map<int, CartItem> _localCart = {};

  CartRepositoryImpl({required this.client});

  @override
  List<CartItem> getItems() => _localCart.values.toList();

  @override
  void addOrUpdateLocal(Product product, int quantity) {
    if (_localCart.containsKey(product.id)) {
      _localCart[product.id]!.quantity += quantity;
    } else {
      _localCart[product.id] = CartItem(product: product, quantity: quantity);
    }
  }

  @override
  Future<bool> postCartToApi(int userId, int productId, int quantity) async {
    try {
      final response = await client.post(
        Uri.parse('https://fakestoreapi.com/carts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'date': DateTime.now().toIso8601String().substring(0, 10),
          'products': [
            {'productId': productId, 'quantity': quantity},
          ],
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // --- Implementaciones para US10 ---

  @override
  void updateQuantityLocal(int productId, int quantity) {
    if (_localCart.containsKey(productId)) {
      if (quantity <= 0) {
        _localCart.remove(productId);
      } else {
        _localCart[productId]!.quantity = quantity;
      }
    }
  }

  @override
  void removeItemLocal(int productId) {
    _localCart.remove(productId);
  }

  @override
  Future<bool> putCartToApi(int cartId, int productId, int quantity) async {
    try {
      final response = await client.put(
        Uri.parse('https://fakestoreapi.com/carts/$cartId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': 1,
          'date': DateTime.now().toIso8601String().substring(0, 10),
          'products': [
            {'productId': productId, 'quantity': quantity},
          ],
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteCartFromApi(int cartId) async {
    try {
      final response = await client.delete(
        Uri.parse('https://fakestoreapi.com/carts/$cartId'),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}