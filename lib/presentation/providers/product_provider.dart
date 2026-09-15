import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../domain/usecases/get_products_usecase.dart';

enum ProductStatus { initial, loading, success, error }

class ProductProvider extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;

  ProductProvider({required this.getProductsUseCase});

  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  String _errorMessage = '';

  ProductStatus get status => _status;
  List<ProductModel> get products => _products;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == ProductStatus.loading;

  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _products = await getProductsUseCase.execute();
      _status = ProductStatus.success;
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = 'No se pudo cargar el catálogo. Comprueba tu conexión a internet.';
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createProduct({
    required String title,
    required String priceText,
    required String description,
    required String imageUrl,
    required String category,
  }) async {
    return true;
  }
}