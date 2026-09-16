import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    required this.loginUseCase,
    required this.logoutUseCase,
  });

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Login con verificación de red (US01)
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Comprobación de red (Escenario 3)
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _errorMessage = 'Sin conexión a internet. Verifique su red.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      _user = await loginUseCase.execute(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Usuario o contraseña inválidos';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cierre de sesión y reset de variables en memoria (US02)
  Future<void> logout() async {
    await logoutUseCase.execute();
    _user = null; // Reseteo de memoria
    _errorMessage = null;
    notifyListeners();
  }
}