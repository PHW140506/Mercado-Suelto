import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';

enum DetailStatus { initial, loading, success, error }

class ProductDetailProvider extends ChangeNotifier {
  final GetProductDetailUseCase getProductDetailUseCase;

  ProductDetailProvider({required this.getProductDetailUseCase});

  DetailStatus _status = DetailStatus.initial;
  ProductModel? _product;
  String _errorMessage = '';

  DetailStatus get status => _status;
  ProductModel? get product => _product;
  String get errorMessage => _errorMessage;

  Future<void> loadProductDetail(int id) async {
    _status = DetailStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _product = await getProductDetailUseCase.execute(id);
      _status = DetailStatus.success;
    } catch (e) {
      _status = DetailStatus.error;
      _errorMessage = 'Producto no disponible';
    } finally {
      notifyListeners();
    }
  }
}