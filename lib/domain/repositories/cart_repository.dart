import '../../data/models/cart_item_model.dart';

abstract class CartRepository {
  List<CartItem> getItems();
  void addOrUpdateLocal(Product product, int quantity);
  Future<bool> postCartToApi(int userId, int productId, int quantity);
  void updateQuantityLocal(int productId, int quantity);
  void removeItemLocal(int productId);
  Future<bool> putCartToApi(int cartId, int productId, int quantity);
  Future<bool> deleteCartFromApi(int cartId);
}