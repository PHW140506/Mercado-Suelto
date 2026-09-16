import '../repositories/cart_repository.dart';

class UpdateCartQuantityUseCase {
  final CartRepository repository;

  UpdateCartQuantityUseCase(this.repository);

  Future<bool> execute({
    required int cartId,
    required int productId,
    required int quantity,
  }) async {
    repository.updateQuantityLocal(productId, quantity);
    return await repository.putCartToApi(cartId, productId, quantity);
  }
}