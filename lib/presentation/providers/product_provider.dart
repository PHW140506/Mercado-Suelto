import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';

enum ProductStatus { initial, loading, success, error }

class ProductProvider extends ChangeNotifier {
  final ProductRepository? repository;
  final AddProductUseCase? addProductUseCase;
  final UpdateProductUseCase? updateProductUseCase;

  ProductProvider({
    this.repository,
    this.addProductUseCase,
    this.updateProductUseCase,
  });

  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  List<String> _categories = [];
  String _selectedCategory = 'Todos';
  String _errorMessage = '';
  bool _isLoading = false;

  ProductStatus get status => _status;
  List<ProductModel> get products => _products;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading || _status == ProductStatus.loading;

  // Cargar categorías y productos iniciales
  Future<void> initializeData() async {
    if (repository == null) return;
    _status = ProductStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final fetchedCategories = await repository!.getCategories();
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
    if (_selectedCategory == category || repository == null) return;

    _selectedCategory = category;
    
    // Regla de negocio: Limpiar arreglo en memoria local para evitar mostrar datos viejos
    _products = [];
    _status = ProductStatus.loading;
    notifyListeners();

    await fetchProducts();
  }

  // Obtener productos según la categoría seleccionada
  Future<void> fetchProducts() async {
    if (repository == null) return;
    _status = ProductStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      if (_selectedCategory == 'Todos') {
        _products = await repository!.getProducts();
      } else {
        _products = await repository!.getProductsByCategory(_selectedCategory);
      }
      _status = ProductStatus.success;
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = 'Error al cargar los productos de la categoría seleccionada.';
    } finally {
      notifyListeners();
    }
  }

  // Método para crear producto
  Future<bool> createProduct({
    required String title,
    required String priceText,
    required String description,
    required String imageUrl,
    required String category,
  }) async {
    return true;
  }

  // Método para editar producto (US07)
  Future<bool> editProduct({
    required int id,
    required String title,
    required String priceText,
    required String description,
    required String imageUrl,
    required String category,
  }) async {
    if (updateProductUseCase == null) return false;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final double? price = double.tryParse(priceText);
      if (price == null) {
        _errorMessage = 'El precio debe ser un valor numérico válido';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await updateProductUseCase!.execute(
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