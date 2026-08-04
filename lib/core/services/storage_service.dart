import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _languageKey = 'app_language';
  static const String _themeKey = 'is_dark_mode';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _prefs.setString(_accessTokenKey, access);
    await _prefs.setString(_refreshTokenKey, refresh);
  }

  String? get accessToken => _prefs.getString(_accessTokenKey);
  String? get refreshToken => _prefs.getString(_refreshTokenKey);

  Future<void> saveUser(String userJson) async {
    await _prefs.setString(_userKey, userJson);
  }

  String? get user => _prefs.getString(_userKey);

  Future<void> saveLanguage(String langCode) async {
    await _prefs.setString(_languageKey, langCode);
  }

  String get language => _prefs.getString(_languageKey) ?? 'ar';

  Future<void> saveIsDarkMode(bool isDark) async {
    await _prefs.setBool(_themeKey, isDark);
  }

  bool get isDarkMode => _prefs.getBool(_themeKey) ?? false;

  Future<void> clearAll() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userKey);
  }
}
