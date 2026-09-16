import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Núcleo de Sesión y Roles
import 'core/user_session.dart';

// Productos (sp1)
import 'data/datasources/product_remote_data_source.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/get_product_detail_usecase.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/product_detail_provider.dart';
import 'presentation/screens/catalog_screen.dart';

// Autenticación y roles (US01 y US02)
import 'data/datasources/auth_local_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/login_screen.dart';

// Carrito de compras local y remoto (US09 y US10)
import 'data/repositories/cart_repository_impl.dart';
import 'domain/usecases/add_to_cart_use_case.dart';
import 'domain/usecases/remove_from_cart_use_case.dart';
import 'domain/usecases/update_cart_quantity_use_case.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/screens/cart_screen.dart';

// Carritos globales (US12)
import 'domain/usecases/get_global_carts_usecase.dart';
import 'presentation/providers/global_carts_provider.dart';
import 'presentation/screens/global_carts_screen.dart';

// Usuarios (US11)
import 'presentation/screens/users_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final httpClient = http.Client();
  const secureStorage = FlutterSecureStorage();

  // Dependencias de Productos
  final remoteProductDataSource = ProductRemoteDataSourceImpl(client: httpClient);
  final productRepository = ProductRepositoryImpl(
    remoteDataSource: remoteProductDataSource,
    client: httpClient,
  );
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

  // Repositorio unificado de Carrito
  final cartRepository = CartRepositoryImpl(client: httpClient);

  // Casos de uso de Carrito
  final addToCartUseCase = AddToCartUseCase(cartRepository);
  final updateCartQuantityUseCase = UpdateCartQuantityUseCase(cartRepository);
  final removeFromCartUseCase = RemoveFromCartUseCase(cartRepository);
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
          create: (_) => CartProvider(
            repository: cartRepository,
            addToCartUseCase: addToCartUseCase,
            updateCartQuantityUseCase: updateCartQuantityUseCase,
            removeFromCartUseCase: removeFromCartUseCase,
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
      // Inicia obligatoriamente en el formulario de Login
      home: const LoginScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final isAdmin = UserSession.currentRole == UserRole.admin;
    final isClient = UserSession.currentRole == UserRole.cliente;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mercado Suelto (${authProvider.userRole})'),
        actions: [
          // Ícono del carrito en AppBar (Solo Cliente)
          if (isClient)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Mi Carrito',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
                if (cartProvider.totalItemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cartProvider.totalItemCount}',
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          // US02: Botón de desconexión y purga total
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              context.read<CartProvider>().clearCart();
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
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
              Text(
                'Bienvenido, ${authProvider.username}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  'Rol: ${authProvider.userRole}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: isAdmin
                    ? Colors.amber.shade200
                    : isClient
                        ? Colors.blue.shade100
                        : Colors.purple.shade100,
              ),
              const SizedBox(height: 30),

              // US03 y US04: Catálogo de Productos (Disponible para todos los perfiles)
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

              // US09 y US10: Mi Carrito de Compras (Exclusivo Cliente)
              if (isClient) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Mi Carrito de Compras'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // US11: Directorio de Usuarios (Exclusivo Administrador y Auditor)
              if (!isClient) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UsersScreen(userRole: authProvider.userRole),
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

                // US12: Histórico de Carritos Globales (Exclusivo Administrador y Auditor)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => GlobalCartsScreen()),
                      );
                    },
                    icon: const Icon(Icons.assessment_outlined),
                    label: const Text('Auditoría de Carritos Globales'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}