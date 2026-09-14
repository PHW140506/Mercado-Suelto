import '../repositories/product_repository.dart';
import '../repositories/product_model.dart';

class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  Future<ProductModel> execute({
    required String title,
    required double price,
    required String description,
    required String imageUrl,
    required String category,
  }) async {
    final newProduct = ProductModel(
      title: title,
      price: price,
      description: description,
      image: imageUrl,
      category: category,
    );

    return await repository.addProduct(newProduct);
  }
}
