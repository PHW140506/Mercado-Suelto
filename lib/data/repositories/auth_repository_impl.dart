import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login(String username, String password) async {
    final token = await remoteDataSource.login(username, password);

    // Nota: FakeStore API asigna ID simulado de prueba si la API no devuelve ID en el login
    const userId = 1; 
    final role = User.assignRoleById(userId);

    await localDataSource.saveSession(
      token: token,
      userId: userId,
      role: role.name,
    );

    return User(
      id: userId,
      username: username,
      token: token,
      role: role,
    );
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearSession();
  }

  @override
  Future<User?> getSavedSession() async {
    final session = await localDataSource.getSession();
    if (session != null) {
      final userId = int.parse(session['userId']!);
      return User(
        id: userId,
        username: 'Usuario Guardado',
        token: session['token']!,
        role: User.assignRoleById(userId),
      );
    }
    return null;
  }
}