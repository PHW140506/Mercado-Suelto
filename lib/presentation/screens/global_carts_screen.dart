import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/global_carts_provider.dart';

class GlobalCartsScreen extends StatefulWidget {
  @override
  _GlobalCartsScreenState createState() => _GlobalCartsScreenState();
}

class _GlobalCartsScreenState extends State<GlobalCartsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GlobalCartsProvider>().fetchCarts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GlobalCartsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Auditoría de Carritos')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(GlobalCartsProvider provider) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (provider.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)),
            if (provider.userRole != 'cliente') 
              ElevatedButton(
                onPressed: () => provider.fetchCarts(),
                child: Text('Reintentar conexión'),
              )
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.carts.length,
      itemBuilder: (context, index) {
        final cart = provider.carts[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text('Carrito ID: ${cart.id}'),
            subtitle: Text('Usuario ID: ${cart.userId} | Fecha: ${cart.date.toLocal().toString().split(' ')[0]}'),
            children: cart.products.map((product) {
              return ListTile(
                leading: Icon(Icons.shopping_bag),
                title: Text('ID del Producto: ${product.productId}'),
                trailing: Text('Cantidad: ${product.quantity}'),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}