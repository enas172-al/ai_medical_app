class AppConfig {
  /// Optional endpoint to send email notifications without Firebase Functions.
  ///
  /// Provide at build time:
  /// `--dart-define=EMAIL_WEBHOOK_URL=https://<your-worker>.workers.dev/email`
  static const String emailWebhookUrl = String.fromEnvironment('EMAIL_WEBHOOK_URL', defaultValue: '');

  /// Backend base URL for the Python/FastAPI server (no trailing slash).
  ///
  /// Example:
  /// `--dart-define=BACKEND_BASE_URL=http://192.168.1.5:8000`
  ///
  /// Notes:
  /// - Android Emulator uses `http://10.0.2.2:8000`
  /// - A physical device must use your PC's LAN IP (same Wi‑Fi), e.g. `http://192.168.x.x:8000`
  static const String backendBaseUrl =
      String.fromEnvironment('BACKEND_BASE_URL', defaultValue: '');

  /// Local Ollama base URL (no trailing slash).
  ///
  /// Default is Ollama's local endpoint.
  /// Override at build time:
  /// `--dart-define=OLLAMA_BASE_URL=http://127.0.0.1:11434`
  static const String ollamaBaseUrl =
      String.fromEnvironment('OLLAMA_BASE_URL', defaultValue: 'http://127.0.0.1:11434');

  /// Ollama model name (must be pulled/available locally).
  /// When set, the app uses it for (1) structured lab extraction from OCR text and
  /// (2) optional Arabic explanation on the results screen.
  ///
  /// Example:
  /// `--dart-define=OLLAMA_MODEL=llama3.1:8b-instruct-q4_K_M`
  static const String ollamaModel =
      String.fromEnvironment('OLLAMA_MODEL', defaultValue: '');
}

