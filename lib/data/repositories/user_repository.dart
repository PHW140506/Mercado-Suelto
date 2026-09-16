import 'dart:convert';
import 'package:http/http.dart' as http;
// Asegúrate de que esta ruta coincida con donde guardaste tu modelo
import '../models/user_model.dart'; 

class UserRepository {
  // El endpoint oficial que pide la historia de usuario
  final String _baseUrl = 'https://fakestoreapi.com/users';

  Future<List<UserModel>> getUsers() async {
    try {
      // Hacemos la petición GET al servidor
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // Si el servidor responde un OK (200), decodificamos el JSON
        List<dynamic> jsonList = jsonDecode(response.body);
        
        // Convertimos la lista de JSON a una lista de objetos UserModel seguros
        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      } else {
        // Si el servidor falla (ej. error 500 o 404)
        throw Exception('Error del servidor: No se pudieron cargar los usuarios');
      }
    } catch (e) {
      // Este catch es vital para cumplir con el Escenario 3 (interrupción de red)
      // Atrapa caídas de internet y lanza un mensaje limpio para la interfaz
      throw Exception('Fallo de conexión. Revisa tu red y vuelve a intentarlo.');
    }
  }
}