import '../repositories/product_repository.dart';
import '../../data/models/product_model.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ProductModel>> execute() async {
    return await repository.getProducts();
  }
}