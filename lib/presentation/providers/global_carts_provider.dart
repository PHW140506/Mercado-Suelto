import 'package:flutter/material.dart';
import '../../data/models/cart_model.dart';
import '../../domain/usecases/get_global_carts_usecase.dart';

class GlobalCartsProvider extends ChangeNotifier {
  final GetGlobalCartsUseCase getGlobalCartsUseCase;
  
  List<CartModel> carts = [];
  bool isLoading = false;
  String errorMessage = '';
  // Simulación de rol. Si el usuario es Cliente, esto debe ser 'cliente' y bloqueará la vista.
  String userRole = 'auditor'; 

  GlobalCartsProvider(this.getGlobalCartsUseCase);

  Future<void> fetchCarts() async {
    if (userRole == 'cliente') {
      errorMessage = 'Acceso denegado. Permisos insuficientes.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      carts = await getGlobalCartsUseCase.call();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}