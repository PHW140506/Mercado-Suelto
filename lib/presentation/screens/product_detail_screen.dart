import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/user_session.dart';
import '../providers/product_detail_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailProvider>().loadProductDetail(widget.productId);
    });
  }

  void _showErrorAndPop(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Alerta'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Cerrar diálogo
                Navigator.of(context).pop(); // Regresar al catálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailProvider>(
      builder: (context, provider, child) {
        if (provider.status == DetailStatus.error) {
          _showErrorAndPop(provider.errorMessage);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(provider.product?.title ?? 'Detalle del producto'),
          ),
          body: provider.status == DetailStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.product == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.network(
                              provider.product!.image,
                              height: 250,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.product!.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(provider.product!.category.toUpperCase()),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${provider.product!.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.product!.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          
                          // Regla de Negocio: Exclusión condicional según el rol de sesión local
                          if (UserSession.currentRole == UserRole.admin) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Editar'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {},
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Eliminar'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
        );
      },
    );
  }
}