import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'data/models/cart_item_model.dart';
import 'data/repositories/cart_repository_impl.dart';
import 'domain/usecases/add_to_cart_use_case.dart';
import 'domain/usecases/remove_from_cart_use_case.dart';
import 'domain/usecases/update_cart_quantity_use_case.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/screens/cart_screen.dart';
import 'presentation/screens/product_detail_screen.dart';

void main() {
  final httpClient = http.Client();
  final cartRepository = CartRepositoryImpl(client: httpClient);
  final addToCartUseCase = AddToCartUseCase(cartRepository);
  final updateCartQuantityUseCase = UpdateCartQuantityUseCase(cartRepository);
  final removeFromCartUseCase = RemoveFromCartUseCase(cartRepository);

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(
        repository: cartRepository,
        addToCartUseCase: addToCartUseCase,
        updateCartQuantityUseCase: updateCartQuantityUseCase,
        removeFromCartUseCase: removeFromCartUseCase,
      ),
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
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const CatalogScreen(),
    );
  }
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Error al cargar productos');
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercado Suelto'),
        actions: [
          DropdownButton<String>(
            value: cartProvider.userRole,
            underline: const SizedBox(),
            items: ['Cliente', 'Auditor'].map((role) {
              return DropdownMenuItem(value: role, child: Text(role));
            }).toList(),
            onChanged: (role) {
              if (role != null) cartProvider.setRole(role);
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
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
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          return ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Image.network(product.image, width: 48, height: 48),
                title: Text(product.title, maxLines: 1),
                subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}