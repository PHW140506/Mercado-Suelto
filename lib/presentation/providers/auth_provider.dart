import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/user_session.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase? loginUseCase;
  final LogoutUseCase? logoutUseCase;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  String? _errorMessage;
  String _username = '';
  String _userRole = '';
  int _userId = 0;

  AuthProvider({this.loginUseCase, this.logoutUseCase});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get username => _username;
  String get user => _username;
  String get userRole => _userRole;
  int get userId => _userId;
  bool get isAuthenticated => UserSession.currentRole != UserRole.ninguno;

  Future<bool> login(String usernameInput, String passwordInput) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // US01: Validación previa de conectividad
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _errorMessage = 'Sin conexión a Internet. Verifica tu red.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final cleanUser = usernameInput.trim();
    final cleanPass = passwordInput.trim();

    try {
      // Determinación de ID según usuario de FakeStore API
      int assignedId = 0;
      if (cleanUser == 'johnd' && cleanPass == 'm38rmF\$') {
        assignedId = 1; // Administrador
      } else if (cleanUser == 'mor_2314' && cleanPass == '83r5^_') {
        assignedId = 3; // Auditor
      } else if (cleanUser == 'donero' && cleanPass == 'ewedon') {
        assignedId = 8; // Cliente
      }

      String token = '';

      if (assignedId != 0) {
        token = 'jwt_token_${cleanUser}_$assignedId';
      } else {
        // Intento directo en la API si se usan otras credenciales
        final response = await http.post(
          Uri.parse('https://fakestoreapi.com/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': cleanUser, 'password': cleanPass}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          token = data['token'] ?? 'jwt_token';
          assignedId = 4; // Por defecto Cliente si no está en el mapa
        } else {
          _errorMessage = 'Credenciales inválidas (Código 401)';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // US01: Regla de asignación formal por ID
      // ID in {1, 2} -> Administrador | ID == 3 -> Auditor | ID > 3 -> Cliente
      if (assignedId == 1 || assignedId == 2) {
        _userRole = 'Administrador';
      } else if (assignedId == 3) {
        _userRole = 'Auditor';
      } else {
        _userRole = 'Cliente';
      }

      _username = cleanUser;
      _userId = assignedId;

      UserSession.setSession(
        username: _username,
        roleStr: _userRole,
        userToken: token,
      );

      // Persistencia segura nativa
      await _storage.write(key: 'token', value: token);
      await _storage.write(key: 'role', value: _userRole);
      await _storage.write(key: 'userId', value: assignedId.toString());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error de conexión con el servidor';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // US02: Purga irreversible de sesión
  Future<void> logout() async {
    UserSession.clear();
    await _storage.deleteAll();
    _username = '';
    _userRole = '';
    _userId = 0;
    notifyListeners();
  }
}