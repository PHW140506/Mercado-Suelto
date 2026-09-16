enum UserRole { admin, cliente, auditor, ninguno }

class UserSession {
  static UserRole currentRole = UserRole.ninguno;
  static String currentUsername = '';
  static String token = '';

  static void setSession({
    required String username,
    required String roleStr,
    required String userToken,
  }) {
    currentUsername = username;
    token = userToken;
    final cleanRole = roleStr.toLowerCase().trim();
    if (cleanRole.contains('admin')) {
      currentRole = UserRole.admin;
    } else if (cleanRole.contains('audit')) {
      currentRole = UserRole.auditor;
    } else {
      currentRole = UserRole.cliente;
    }
  }

  static void clear() {
    currentRole = UserRole.ninguno;
    currentUsername = '';
    token = '';
  }
}