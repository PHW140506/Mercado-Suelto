import '../repositories/product_repository.dart';
import '../../data/models/product_model.dart';

class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<ProductModel> execute({
    required int id,
    required String title,
    required double price,
    required String description,
    required String imageUrl,
    required String category,
  }) async {
    final updatedProduct = ProductModel(
      id: id,
      title: title,
      price: price,
      description: description,
      image: imageUrl,
      category: category,
    );

    return await repository.updateProduct(updatedProduct);
  }
}
