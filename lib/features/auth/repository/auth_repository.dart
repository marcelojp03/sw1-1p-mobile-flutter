import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sw1_p1/core/api/api_client.dart';
import 'package:sw1_p1/features/auth/entities/auth_models.dart';

class AuthRepository {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'current_user';

  // ===== Login =====
  Future<CurrentUser> login(String email, String password) async {
    try {
      final response = await ApiClient.instance.dio.post(
        '/auth/login',
        data: LoginRequest(email: email, password: password).toJson(),
      );

      final loginResp = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Guardar token
      await _storage.write(key: _tokenKey, value: loginResp.token);

      // Obtener perfil completo con /auth/me
      final meResponse = await ApiClient.instance.dio.get('/auth/me');
      final user = CurrentUser.fromJson(
        meResponse.data as Map<String, dynamic>,
      );
      await _storage.write(key: _userKey, value: user.toJsonString());

      return user;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final detail =
          e.response?.data is Map
              ? (e.response!.data as Map)['message'] ??
                  (e.response!.data as Map)['error'] ??
                  'Error de autenticación'
              : 'Error de autenticación';

      if (statusCode == 401 || statusCode == 403) {
        throw Exception('Credenciales inválidas');
      }
      throw Exception(detail.toString());
    } catch (e) {
      throw Exception('No se pudo conectar al servidor');
    }
  }

  // ===== Logout =====
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // ===== Leer usuario guardado =====
  Future<CurrentUser?> getSavedUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;
    try {
      return CurrentUser.fromJsonString(userJson);
    } catch (_) {
      return null;
    }
  }

  // ===== ¿Hay token? =====
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }
}
