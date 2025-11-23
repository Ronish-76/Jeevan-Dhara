class AppConfig {
  AppConfig._();

  /// Base REST API endpoint. Override with `--dart-define API_BASE_URL=<url>`
  /// Using ADB reverse: adb reverse tcp:5000 tcp:5000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  /// Socket endpoint to reuse for realtime features.
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://localhost:5000',
  );

  static const Duration networkTimeout = Duration(seconds: 20);
}
