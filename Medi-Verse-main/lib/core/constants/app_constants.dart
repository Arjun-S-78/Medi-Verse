abstract class AppConstants {
  static const String appName = 'MediVerse';
  static const String appVersion = '1.0.0 Enterprise';

  // Timeouts
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // Keys
  static const String authTokenKey = 'mediverse_auth_token';
  static const String refreshTokenKey = 'mediverse_refresh_token';
  static const String userProfileKey = 'mediverse_user_profile';
  static const String themeModeKey = 'mediverse_theme_mode';

  // SOS Config
  static const int sosHoldDurationSeconds = 3;
}
