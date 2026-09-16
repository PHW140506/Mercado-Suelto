import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/user_session.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/error_view.dart';
import '../widgets/category_filter_chips.dart';
import 'add_product_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = UserSession.currentRole == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        centerTitle: true,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // US04: Selector de filtros por categoría
              CategoryFilterChips(
                categories: provider.categories,
                selectedCategory: provider.selectedCategory,
                onSelected: (category) {
                  provider.selectCategory(category);
                },
              ),
              Expanded(
                child: _buildBody(provider),
              ),
            ],
          );
        },
      ),
      // US06: Agregar nuevo producto (Exclusivo Administrador)
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddProductScreen(userRole: 'Admin'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Producto'),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildBody(ProductProvider provider) {
    switch (provider.status) {
      case ProductStatus.initial:
      case ProductStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case ProductStatus.error:
        return ErrorView(
          message: provider.errorMessage,
          onRetry: () => provider.fetchProducts(),
        );

      case ProductStatus.success:
        if (provider.products.isEmpty) {
          return const Center(
            child: Text('No hay productos disponibles en esta categoría.'),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: provider.products[index]);
          },
        );
    }
  }
}