import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importamos tus nuevos archivos
import 'data/repositories/cart_repository_impl.dart';
import 'domain/usecases/get_global_carts_usecase.dart';
import 'presentation/providers/global_carts_provider.dart';
import 'presentation/screens/global_carts_screen.dart';

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
        primarySwatch: Colors.blue,
      ),
      // 3. ¡Aquí le decimos que muestre tu pantalla al abrir la app!
      home: GlobalCartsScreen(),
    );
  }
}
