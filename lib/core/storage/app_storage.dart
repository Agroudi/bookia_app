import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Contract for the app's local session store.
///
/// Declared as an interface so the auth interceptor and the repositories
/// depend on the abstraction, not on `SharedPreferences`.
abstract interface class SessionStorage {
  String? get token;
  bool get isLoggedIn;
  Future<void> saveToken(String token);

  Map<String, dynamic>? get cachedUser;
  Future<void> saveUser(Map<String, dynamic> user);

  bool get hasSeenOnboarding;
  Future<void> markOnboardingSeen();

  /// Drops the token and the cached user. Called on logout, on account
  /// deletion, and by the auth interceptor when the server returns 401.
  Future<void> clearSession();
}

final class AppStorage implements SessionStorage {
  AppStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'cached_user';
  static const String _onboardingKey = 'onboarding_seen';

  /// Loads the backing store once at startup so every read below is
  /// synchronous — the Dio interceptor cannot await.
  static Future<AppStorage> create() async =>
      AppStorage(await SharedPreferences.getInstance());

  @override
  String? get token {
    final value = _prefs.getString(_tokenKey);
    return (value == null || value.isEmpty) ? null : value;
  }

  @override
  bool get isLoggedIn => token != null;

  @override
  Future<void> saveToken(String token) => _prefs.setString(_tokenKey, token);

  @override
  Map<String, dynamic>? get cachedUser {
    final raw = _prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      // A corrupted cache must never crash startup; treat it as absent.
      return null;
    }
  }

  @override
  Future<void> saveUser(Map<String, dynamic> user) =>
      _prefs.setString(_userKey, jsonEncode(user));

  @override
  bool get hasSeenOnboarding => _prefs.getBool(_onboardingKey) ?? false;

  @override
  Future<void> markOnboardingSeen() => _prefs.setBool(_onboardingKey, true);

  @override
  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}
