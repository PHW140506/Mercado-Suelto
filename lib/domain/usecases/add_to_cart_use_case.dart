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
    // Escenario 3: Si es Auditor o cantidad <= 0, no procede
    if (userRole == 'Auditor' || quantity <= 0) {
      return false;
    }

    // Petición a la API (Fake Store)
    final apiSuccess = await repository.postCartToApi(1, product.id, quantity);

    if (apiSuccess) {
      // Escenarios 1 y 2: Acumular sin duplicar en local
      repository.addOrUpdateLocal(product, quantity);
      return true;
    }
    return false;
  }
}