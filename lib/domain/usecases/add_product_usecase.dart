import '../repositories/product_repository.dart';
import '../../data/models/product_model.dart';

class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  Future<ProductModel> execute({
    required String title,
    required double price,
    required String description,
    required String image,
    required String category,
  }) async {
    final newProduct = ProductModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      price: price,
      description: description,
      image: image,
      category: category,
    );
    return await repository.addProduct(newProduct);
  }
}
