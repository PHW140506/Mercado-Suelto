import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<String>> getCategories();
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<ProductModel> getProductById(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await client.get(
      Uri.parse('https://fakestoreapi.com/products'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al conectar con el servidor (${response.statusCode})');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await client.get(
      Uri.parse('https://fakestoreapi.com/products/categories'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((item) => item.toString()).toList();
    } else {
      throw Exception('Error al obtener categorías (${response.statusCode})');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final response = await client.get(
      Uri.parse('https://fakestoreapi.com/products/category/$category'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al filtrar productos (${response.statusCode})');
    }
  }
  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await client.get(
      Uri.parse('https://fakestoreapi.com/products/$id'),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty && response.body != 'null') {
      return ProductModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Producto no disponible');
    }
  }
}