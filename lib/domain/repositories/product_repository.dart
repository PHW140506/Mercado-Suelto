import '../../data/models/product_model.dart';

abstract class ProductRepository {
  Future<ProductModel> addProduct(ProductModel product);
}
