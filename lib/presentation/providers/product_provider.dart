import 'package:flutter/material.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';

class ProductProvider extends ChangeNotifier {
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;

  ProductProvider({
    required this.addProductUseCase,
    required this.updateProductUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> createProduct({
    required String title,
    required String priceText,
    required String description,
    required String imageUrl,
    required String category,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final double? price = double.tryParse(priceText);
      if (price == null) {
        _errorMessage = 'El precio debe ser un valor numérico válido';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await addProductUseCase.execute(
        title: title,
        price: price,
        description: description,
        imageUrl: imageUrl,
        category: category,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> editProduct({
    required int id,
    required String title,
    required String priceText,
    required String description,
    required String imageUrl,
    required String category,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final double? price = double.tryParse(priceText);
      if (price == null) {
        _errorMessage = 'El precio debe ser un valor numérico válido';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await updateProductUseCase.execute(
        id: id,
        title: title,
        price: price,
        description: description,
        imageUrl: imageUrl,
        category: category,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
