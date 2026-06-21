import 'gemini_api_key.local.dart';

/// Clave embebida para builds locales (archivo gitignored).
String get embeddedGeminiApiKey => geminiApiKeyLocal.trim();
