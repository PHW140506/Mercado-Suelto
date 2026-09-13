import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  final String userRole; // Ej: 'Admin', 'Cliente', 'Auditor'

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.userRole,
  });

  /// Muestra el cuadro de diálogo de confirmación obligatorio (Escenarios 1 y 2)
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogCtx).pop(), // Cancela sin petición
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop(); // Cierra el modal
              await _executeDelete(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Ejecuta la acción DELETE a través del Provider
  Future<void> _executeDelete(BuildContext context) async {
    // Escenario 3: Bloqueo de seguridad adicional a nivel de código
    if (userRole != 'Admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acceso denegado: Operación no permitida'),
        ),
      );
      return;
    }

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final success = await provider.removeProduct(product.id ?? 0);

    if (!context.mounted) return;

    if (success) {
      // Escenario 1: Mostrar Snackbar de éxito y redirigir
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado exitosamente del catálogo'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Regresa al catálogo general
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(provider.errorMessage ?? 'Error al eliminar el producto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProductProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          // Escenario 3: El botón solo se renderiza si el rol es Admin
          if (userRole == 'Admin')
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: isLoading ? null : () => _confirmDelete(context),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      product.image,
                      height: 200,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 100),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(label: Text(product.category)),
                  const SizedBox(height: 16),
                  Text(product.description),
                ],
              ),
            ),
    );
  }
}
