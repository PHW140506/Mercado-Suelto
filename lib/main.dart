import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'data/datasources/product_remote_data_source.dart';
import 'data/repositories/product_repository_impl.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/screens/catalog_screen.dart';

void main() {
  final httpClient = http.Client();
  final remoteDataSource = ProductRemoteDataSourceImpl(client: httpClient);
  final repository = ProductRepositoryImpl(remoteDataSource: remoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(repository: repository),
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