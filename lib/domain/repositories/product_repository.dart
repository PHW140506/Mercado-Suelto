import '../../data/models/product_model.dart';

abstract class ProductRepository {
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<bool> deleteProduct(int id);
}
