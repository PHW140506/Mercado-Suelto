enum UserRole { admin, auditor, client }

class User {
  final int id;
  final String username;
  final String token;
  final UserRole role;

  User({
    required this.id,
    required this.username,
    required this.token,
    required this.role,
  });

  // Regla de negocio de US01: Asignación local de perfiles según el ID
  static UserRole assignRoleById(int id) {
    if (id == 1 || id == 2) {
      return UserRole.admin;
    } else if (id == 3) {
      return UserRole.auditor;
    } else {
      return UserRole.client;
    }
  }
}