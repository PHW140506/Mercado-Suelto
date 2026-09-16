import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class UsersScreen extends StatefulWidget {
  final String userRole; 

  const UsersScreen({super.key, required this.userRole});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserRepository _userRepository = UserRepository();
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() {
    setState(() {
      _usersFuture = _userRepository.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userRole == 'Cliente') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso Restringido'),
          backgroundColor: Colors.redAccent,
        ),
        body: const Center(
          child: Text(
            'No tienes permisos para ver el directorio de usuarios.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Usuarios'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _fetchUsers,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar conexión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      child: Text(
                        user.name.firstname.isNotEmpty 
                            ? user.name.firstname[0].toUpperCase() 
                            : 'U',
                        style: const TextStyle(
                          color: Colors.blueAccent, 
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                        ),
                      ),
                    ),
                    title: Text(
                      user.name.fullName, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                    ),
                    subtitle: Padding(
                      // Aquí está la corrección aplicada
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📧 ${user.email}'),
                          const SizedBox(height: 4),
                          Text('📱 ${user.phone}'),
                          const SizedBox(height: 4),
                          Text('👤 @${user.username}', style: const TextStyle(color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('El directorio está vacío.'));
        },
      ),
    );
  }
}