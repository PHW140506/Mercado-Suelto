import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/user_session.dart';
import '../../data/models/cart_item_model.dart';
import '../providers/cart_provider.dart';
import '../providers/product_detail_provider.dart';
import '../providers/product_provider.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedQuantity = 1;

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
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    });
  }

  void _confirmDelete(BuildContext context, int productId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await _executeDelete(context, productId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeDelete(BuildContext context, int productId) async {
    if (UserSession.currentRole != UserRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acceso denegado: Operación no permitida')),
      );
      return;
    }

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final success = await provider.removeProduct(productId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado exitosamente del catálogo'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage.isNotEmpty ? provider.errorMessage : 'Error al eliminar el producto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isAuditor = cartProvider.userRole == 'Auditor';

    return Consumer<ProductDetailProvider>(
      builder: (context, provider, child) {
        if (provider.status == DetailStatus.error) {
          _showErrorAndPop(provider.errorMessage);
        }

        final product = provider.product;

        return Scaffold(
          appBar: AppBar(
            title: Text(product?.title ?? 'Detalle del producto'),
            actions: [
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
          body: provider.status == DetailStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : product == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.network(
                              product.image,
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            product.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(product.category.toUpperCase()),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),

                          // Sección para agregar al carrito
                          if (!isAuditor) ...[
                            Row(
                              children: [
                                const Text('Cantidad:', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: _selectedQuantity > 1
                                      ? () => setState(() => _selectedQuantity--)
                                      : null,
                                ),
                                Text(
                                  '$_selectedQuantity',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => setState(() => _selectedQuantity++),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                icon: cartProvider.isLoading
                                    ? const SizedBox.shrink()
                                    : const Icon(Icons.shopping_cart_outlined),
                                label: cartProvider.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Agregar al carrito', style: TextStyle(fontSize: 16)),
                                onPressed: cartProvider.isLoading
                                    ? null
                                    : () async {
                                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                                        
                                        final cartProduct = Product(
                                          id: product.id,
                                          title: product.title,
                                          price: product.price,
                                          description: product.description,
                                          category: product.category,
                                          image: product.image,
                                        );

                                        final success = await cartProvider.addToCart(
                                          cartProduct,
                                          _selectedQuantity,
                                        );

                                        if (!mounted) return;

                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? 'Producto añadido al carrito'
                                                  : 'Error al procesar en servidor',
                                            ),
                                            backgroundColor: success ? Colors.green : Colors.red,
                                          ),
                                        );
                                      },
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Modo Auditor: Botón deshabilitado (solo lectura)',
                                style: TextStyle(color: Colors.brown, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Opciones exclusivas de Administrador (Editar / Eliminar)
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
                                    onPressed: () => _confirmDelete(context, widget.productId),
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