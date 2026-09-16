import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Productos (sp1)
import 'data/datasources/product_remote_data_source.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/get_product_detail_usecase.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/product_detail_provider.dart';
import 'presentation/screens/catalog_screen.dart';

// Autenticación y roles (Tarea 1 y Tarea 2)
import 'data/datasources/auth_local_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/login_screen.dart';

// Carritos globales (Tarea 12)
import 'data/repositories/cart_repository_impl.dart';
import 'domain/usecases/get_global_carts_usecase.dart';
import 'presentation/providers/global_carts_provider.dart';
import 'presentation/screens/global_carts_screen.dart';

// Usuarios (Tarea 11)
import 'presentation/screens/users_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final httpClient = http.Client();
  const secureStorage = FlutterSecureStorage();

  // Dependencias de Productos
  final remoteProductDataSource = ProductRemoteDataSourceImpl(client: httpClient);
  final productRepository = ProductRepositoryImpl(remoteDataSource: remoteProductDataSource);
  final getProductDetailUseCase = GetProductDetailUseCase(productRepository);

  // Dependencias de Autenticación
  final remoteAuthDataSource = AuthRemoteDataSource(client: httpClient);
  final localAuthDataSource = AuthLocalDataSource(storage: secureStorage);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: remoteAuthDataSource,
    localDataSource: localAuthDataSource,
  );
  final loginUseCase = LoginUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  // Dependencias de Carritos
  final cartRepository = CartRepositoryImpl();
  final getGlobalCartsUseCase = GetGlobalCartsUseCase(cartRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(repository: productRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductDetailProvider(
            getProductDetailUseCase: getProductDetailUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUseCase: loginUseCase,
            logoutUseCase: logoutUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => GlobalCartsProvider(getGlobalCartsUseCase),
        ),
      ],
      child: const MercadoSueltoApp(),
    ),
  );
}

class MercadoSueltoApp extends StatelessWidget {
  const MercadoSueltoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercado Suelto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercado Suelto - Menú Principal'),
        actions: [
          IconButton(
            icon: Icon(authProvider.isAuthenticated ? Icons.logout : Icons.login),
            tooltip: authProvider.isAuthenticated ? 'Cerrar sesión' : 'Iniciar sesión',
            onPressed: () {
              if (authProvider.isAuthenticated) {
                authProvider.logout();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Panel del Sprint 1',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Botón Catálogo General (sp1)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CatalogScreen()),
                    );
                  },
                  icon: const Icon(Icons.storefront),
                  label: const Text('Ver Catálogo de Productos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botón Gestión de Sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.lock),
                  label: Text(authProvider.isAuthenticated ? 'Gestionar Sesión' : 'Iniciar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botón Directorio de Usuarios (Tarea 11)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UsersScreen(userRole: 'Administrador'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('Directorio de Usuarios'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botón Carritos Globales (Tarea 12)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GlobalCartsScreen()),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Ver Carritos Globales'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}