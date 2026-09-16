import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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

  // Inyección de dependencias - Autenticación
  final httpClient = http.Client();
  const secureStorage = FlutterSecureStorage();

  final remoteDataSource = AuthRemoteDataSource(client: httpClient);
  final localDataSource = AuthLocalDataSource(storage: secureStorage);

  final authRepository = AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  final loginUseCase = LoginUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  // Inyección de dependencias - Carritos
  final cartRepository = CartRepositoryImpl();
  final getGlobalCartsUseCase = GetGlobalCartsUseCase(cartRepository);

  runApp(
    MultiProvider(
      providers: [
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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mercado Suelto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Menú Principal'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Bienvenido a Mercado Suelto',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Botón Login / Logout
              ElevatedButton.icon(
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),

              // Botón Tarea 11 (Usuarios)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UsersScreen(userRole: 'Administrador'),
                    ),
                  );
                },
                icon: const Icon(Icons.people),
                label: const Text('Directorio de Usuarios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),

              // Botón Tarea 12 (Carritos)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GlobalCartsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Ver Carritos Globales'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}