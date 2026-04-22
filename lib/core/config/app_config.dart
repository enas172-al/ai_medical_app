class AppConfig {
  /// Optional endpoint to send email notifications without Firebase Functions.
  ///
  /// Provide at build time:
  /// `--dart-define=EMAIL_WEBHOOK_URL=https://<your-worker>.workers.dev/email`
  static const String emailWebhookUrl = String.fromEnvironment('EMAIL_WEBHOOK_URL', defaultValue: '');
}

