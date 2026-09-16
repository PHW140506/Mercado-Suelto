import '../repositories/cart_repository.dart';
import '../../data/models/cart_model.dart';

class GetGlobalCartsUseCase {
  final CartRepository repository;
  GetGlobalCartsUseCase(this.repository);

  Future<List<CartModel>> call() async {
    return await repository.getGlobalCarts();
  }
}