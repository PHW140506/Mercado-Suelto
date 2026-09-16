import '../../data/models/cart_item_model.dart';
import 'cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<bool> execute({
    required Product product,
    required int quantity,
    required String userRole,
  }) async {
    // Regla de negocio: Auditor tiene solo lectura (Escenario 3)
    if (userRole == 'Auditor' || quantity <= 0) {
      return false;
    }

    // Petición POST a la API (Fake Store)
    final apiSuccess = await repository.postCartToApi(1, product.id, quantity);

    if (apiSuccess) {
      // Guardado y acumulación en memoria local (Escenarios 1 y 2)
      repository.addOrUpdateLocal(product, quantity);
      return true;
    }
    return false;
  }
}