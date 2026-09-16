enum UserRole { admin, client, auditor }

class UserSession {
  // Simulación de variable de sesión local
  // Cambia este valor a UserRole.client o UserRole.auditor para probar las distintas vistas
  static UserRole currentRole = UserRole.client;
}