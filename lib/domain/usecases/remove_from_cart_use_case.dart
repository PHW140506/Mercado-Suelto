import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<bool> execute({
    required int cartId,
    required int productId,
  }) async {
    repository.removeItemLocal(productId);
    return await repository.deleteCartFromApi(cartId);
  }
}