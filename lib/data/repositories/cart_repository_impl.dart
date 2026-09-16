import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl implements CartRepository {
  @override
  Future<List<CartModel>> getGlobalCarts() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/carts'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => CartModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los carritos del servidor');
    }
  }
}