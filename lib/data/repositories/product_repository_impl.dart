import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final http.Client client;

  ProductRepositoryImpl({required this.client});

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    final response = await client.post(
      Uri.parse('https://fakestoreapi.com/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProductModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al registrar el producto en la API');
    }
  }

  @override
  Future<bool> deleteProduct(int id) async {
    final response = await client.delete(
      Uri.parse('https://fakestoreapi.com/products/$id'),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al eliminar el producto en la API');
    }
  }
}
