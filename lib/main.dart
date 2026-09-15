import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'data/datasources/product_remote_data_source.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/get_products_usecase.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/screens/catalog_screen.dart';

void main() {
  // Instanciamos las dependencias
  final httpClient = http.Client();
  final remoteDataSource = ProductRemoteDataSourceImpl(client: httpClient);
  final repository = ProductRepositoryImpl(remoteDataSource: remoteDataSource);
  final getProductsUseCase = GetProductsUseCase(repository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(getProductsUseCase: getProductsUseCase),
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
      title: 'Mercado Suelto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CatalogScreen(),
    );
  }
}