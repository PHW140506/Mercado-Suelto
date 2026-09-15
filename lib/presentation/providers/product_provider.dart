import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

enum ProductStatus { initial, loading, success, error }

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  ProductProvider({required this.repository});

  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  List<String> _categories = [];
  String _selectedCategory = 'Todos';
  String _errorMessage = '';

  ProductStatus get status => _status;
  List<ProductModel> get products => _products;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == ProductStatus.loading;

  // Cargar categorías y productos iniciales
  Future<void> initializeData() async {
    _status = ProductStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final fetchedCategories = await repository.getCategories();
      _categories = ['Todos', ...fetchedCategories];
      await fetchProducts();
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = 'No se pudieron cargar los datos iniciales.';
      notifyListeners();
    }
  }

  // Filtrar por categoría o restablecer a todos
  Future<void> selectCategory(String category) async {
    if (_selectedCategory == category) return;

    _selectedCategory = category;
    
    // Regla de negocio: Limpiar arreglo en memoria local para evitar mostrar datos viejos
    _products = [];
    _status = ProductStatus.loading;
    notifyListeners();

    await fetchProducts();
  }

  // Obtener productos según la categoría seleccionada
  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      if (_selectedCategory == 'Todos') {
        _products = await repository.getProducts();
      } else {
        _products = await repository.getProductsByCategory(_selectedCategory);
      }
      _status = ProductStatus.success;
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = 'Error al cargar los productos de la categoría seleccionada.';
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