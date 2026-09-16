import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<bool> execute(int id) async {
    return await repository.deleteProduct(id);
  }
}
