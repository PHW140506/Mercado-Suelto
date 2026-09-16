import '../../data/models/cart_model.dart';

abstract class CartRepository {
  Future<List<CartModel>> getGlobalCarts();
}