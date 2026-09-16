import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return PopScope(
      canPop: false, // Bloquear el botón físico atrás si está autenticado
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mercado Suelto'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.logout();
                if (!context.mounted) return;
                
                // Destrucción total de pantallas anteriores (US02)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¡Bienvenido, ${user?.username ?? 'Usuario'}!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Rol Asignado: ${user?.role.name.toUpperCase() ?? 'S/D'}',
                style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}