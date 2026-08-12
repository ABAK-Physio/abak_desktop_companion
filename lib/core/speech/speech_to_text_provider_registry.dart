import 'speech_to_text_provider.dart';

class SpeechToTextProviderRegistry {
  SpeechToTextProviderRegistry._();

  static final List<SpeechToTextProvider> _providers = [];

  static void register(SpeechToTextProvider provider) {
    final alreadyRegistered = _providers.any(
          (existingProvider) => existingProvider.id == provider.id,
    );

    if (alreadyRegistered) {
      return;
    }

    _providers.add(provider);
  }

  static void unregister(String providerId) {
    _providers.removeWhere(
          (provider) => provider.id == providerId,
    );
  }

  static List<SpeechToTextProvider> get providers =>
      List.unmodifiable(_providers);

  static Future<List<SpeechToTextProvider>> availableProviders() async {
    final available = <SpeechToTextProvider>[];

    for (final provider in _providers) {
      if (await provider.isAvailable()) {
        available.add(provider);
      }
    }

    return available;
  }

  static Future<SpeechToTextProvider?> firstAvailableProvider() async {
    for (final provider in _providers) {
      if (await provider.isAvailable()) {
        return provider;
      }
    }

    return null;
  }
}