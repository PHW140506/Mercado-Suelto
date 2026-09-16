import '../../data/models/cart_item_model.dart';
import '../../data/models/cart_model.dart';

abstract class CartRepository {
  // Carritos globales (Tarea 12)
  Future<List<CartModel>> getGlobalCarts();

  // Gestión de carrito de compras (Tarea 9 y 10)
  List<CartItem> getItems();
  void addOrUpdateLocal(Product product, int quantity);
  Future<bool> postCartToApi(int userId, int productId, int quantity);
  void updateQuantityLocal(int productId, int quantity);
  void removeItemLocal(int productId);
  Future<bool> putCartToApi(int cartId, int productId, int quantity);
  Future<bool> deleteCartFromApi(int cartId);
}