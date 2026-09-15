import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProductModel>> getProducts() async {
    return await remoteDataSource.getProducts();
  }

  @override
  Future<List<String>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    return await remoteDataSource.getProductsByCategory(category);
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    return product;
  }
}