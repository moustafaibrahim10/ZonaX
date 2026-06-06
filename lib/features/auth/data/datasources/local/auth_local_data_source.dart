import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zona_x_16_4/features/auth/data/models/responses/auth_response.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();

  Future<void> saveUserProfile(AuthResponse profile);
  Future<AuthResponse?> getUserProfile();
  Future<void> clearAllData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final Box _hiveBox;

  static const String _tokenKey = 'PREFS_KEY_TOKEN';
  static const String _profileKey = 'HIVE_KEY_PROFILE';

  AuthLocalDataSourceImpl(this._secureStorage, this._hiveBox);

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<void> saveUserProfile(AuthResponse profile) async {
    await _hiveBox.put(_profileKey, {
      'id': profile.id,
      'role': profile.role,
      'fullName': profile.fullName,
    });
  }

  @override
  Future<AuthResponse?> getUserProfile() async {
    final Map<dynamic, dynamic>? data = _hiveBox.get(_profileKey);
    if (data != null) {
      return AuthResponse(
        id: data['id'] as String?,
        role: data['role'] as String?,
        fullName: data['fullName'] as String?,
      );
    }
    return null;
  }

  @override
  Future<void> clearAllData() async {
    await deleteToken();
    await _hiveBox.delete(_profileKey);
    await _hiveBox.delete('terms_accepted');
    await _hiveBox.delete('gallery_permission_accepted');
  }
}
