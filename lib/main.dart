import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'data/datasources/product_remote_data_source.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/get_product_detail_usecase.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/product_detail_provider.dart';
import 'presentation/screens/catalog_screen.dart';

import 'data/models/cart_item_model.dart';
import 'data/repositories/cart_repository_impl.dart';
import 'domain/usecases/add_to_cart_use_case.dart';
import 'presentation/providers/cart_provider.dart';

void main() {
  final httpClient = http.Client();
  
  // Repositorios y casos de uso de Productos
  final remoteDataSource = ProductRemoteDataSourceImpl(client: httpClient);
  final repository = ProductRepositoryImpl(remoteDataSource: remoteDataSource);
  final getProductDetailUseCase = GetProductDetailUseCase(repository);

  // Repositorio y casos de uso del Carrito (Task 9)
  final cartRepository = CartRepositoryImpl(client: httpClient);
  final addToCartUseCase = AddToCartUseCase(cartRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductDetailProvider(
            getProductDetailUseCase: getProductDetailUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(
            repository: cartRepository,
            addToCartUseCase: addToCartUseCase,
          ),
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
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CatalogScreen(),
    );
  }
}