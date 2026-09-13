import '../../data/models/cart_item_model.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<bool> execute({
    required Product product,
    required int quantity,
    required String userRole,
  }) async {
    if (userRole == 'Auditor' || quantity <= 0) {
      return false;
    }

    final apiSuccess = await repository.postCartToApi(1, product.id, quantity);

    if (apiSuccess) {
      repository.addOrUpdateLocal(product, quantity);
      return true;
    }
    return false;
  }
}