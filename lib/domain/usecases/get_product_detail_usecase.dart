import '../repositories/product_repository.dart';
import '../../data/models/product_model.dart';

class GetProductDetailUseCase {
  final ProductRepository repository;

  GetProductDetailUseCase(this.repository);

  Future<ProductModel> execute(int id) async {
    return await repository.getProductById(id);
  }
}