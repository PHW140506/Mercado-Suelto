import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importamos tus nuevos archivos de la Tarea 12 (Carritos)
import 'data/repositories/cart_repository_impl.dart';
import 'domain/usecases/get_global_carts_usecase.dart';
import 'presentation/providers/global_carts_provider.dart';
import 'presentation/screens/global_carts_screen.dart';

// Importamos la pantalla de la Tarea 11 (Usuarios)
import 'presentation/screens/users_screen.dart';

void main() {
  // 1. Preparamos tus herramientas (Clean Architecture)
  final repository = CartRepositoryImpl();
  final useCase = GetGlobalCartsUseCase(repository);

  // 2. Arrancamos la app con tu Provider inyectado
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalCartsProvider(useCase)),
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
      // Dejamos el Menú Principal como la pantalla de inicio
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Bienvenido a Mercado Suelto',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40), 

            // --- BOTÓN DE LA TAREA 11 (Usuarios) ---
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
                textStyle: const TextStyle(fontSize: 18)
              ),
            ),
            
            const SizedBox(height: 20), // Espacio entre botones

            // --- BOTÓN DE LA TAREA 12 (Carritos) ---
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
                textStyle: const TextStyle(fontSize: 18)
              ),
            ),
            // ---------------------------------------------
          ],
        ),
      ),
    );
  }
}