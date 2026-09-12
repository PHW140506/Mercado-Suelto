import '../../data/models/cart_item_model.dart';

abstract class CartRepository {
  List<CartItem> getItems();
  void addOrUpdateLocal(Product product, int quantity);
  Future<bool> postCartToApi(int userId, int productId, int quantity);
}