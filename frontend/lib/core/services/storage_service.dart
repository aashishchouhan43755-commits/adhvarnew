import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // =========================
  // Generic Methods
  // =========================

  Future<void> saveString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await _prefs;
    return prefs.getBool(key);
  }

  Future<void> saveInt(String key, int value) async {
    final prefs = await _prefs;
    await prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await _prefs;
    return prefs.getInt(key);
  }

  Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  // =========================
  // Authentication
  // =========================

  Future<void> saveToken(String token) async {
    await saveString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return await getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await remove(_tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await saveString(_refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return await getString(_refreshTokenKey);
  }

  Future<void> saveLoginStatus(bool status) async {
    await saveBool(_isLoggedInKey, status);
  }

  Future<bool> isLoggedIn() async {
    return await getBool(_isLoggedInKey) ?? false;
  }

  // =========================
  // User
  // =========================

  Future<void> saveUserId(int id) async {
    await saveInt(_userIdKey, id);
  }

  Future<int?> getUserId() async {
    return await getInt(_userIdKey);
  }

  Future<void> saveUserName(String name) async {
    await saveString(_userNameKey, name);
  }

  Future<String?> getUserName() async {
    return await getString(_userNameKey);
  }

  Future<void> saveUserEmail(String email) async {
    await saveString(_userEmailKey, email);
  }

  Future<String?> getUserEmail() async {
    return await getString(_userEmailKey);
  }

  // =========================
  // Logout
  // =========================

  Future<void> logout() async {
    await removeToken();
    await remove(_refreshTokenKey);
    await remove(_userIdKey);
    await remove(_userNameKey);
    await remove(_userEmailKey);
    await saveLoginStatus(false);
  }
}
