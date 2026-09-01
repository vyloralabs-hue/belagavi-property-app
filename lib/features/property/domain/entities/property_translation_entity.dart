import 'package:equatable/equatable.dart';

enum TranslationSource { manual, author, automatic, verified }
enum TranslationStatus { sourceOriginal, translated, reviewPending, fallback }

/// Canonical Translatable Property Entity for Multilingual Marketplace
class PropertyTranslationEntity extends Equatable {
  final String propertyId;
  final String languageCode; // 'en', 'hi', 'kn', 'mr', etc.
  final String title;
  final String description;
  final String? landmarks;
  final String? additionalNotes;
  final TranslationSource source;
  final TranslationStatus status;
  final DateTime updatedAt;

  const PropertyTranslationEntity({
    required this.propertyId,
    required this.languageCode,
    required this.title,
    required this.description,
    this.landmarks,
    this.additionalNotes,
    this.source = TranslationSource.author,
    this.status = TranslationStatus.sourceOriginal,
    required this.updatedAt,
  });

  /// Resolves translatable text with safe fallback to source language
  static PropertyTranslationEntity resolveTranslation({
    required List<PropertyTranslationEntity> translations,
    required String targetLanguageCode,
    required String defaultTitle,
    required String defaultDescription,
    String defaultLanguage = 'en',
  }) {
    // 1. Direct match
    final direct = translations.where((t) => t.languageCode == targetLanguageCode);
    if (direct.isNotEmpty) return direct.first;

    // 2. Default/Source language match
    final fallback = translations.where((t) => t.languageCode == defaultLanguage);
    if (fallback.isNotEmpty) return fallback.first;

    // 3. Any available translation
    if (translations.isNotEmpty) return translations.first;

    // 4. Default structured fallback
    return PropertyTranslationEntity(
      propertyId: '',
      languageCode: defaultLanguage,
      title: defaultTitle,
      description: defaultDescription,
      source: TranslationSource.author,
      status: TranslationStatus.fallback,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        propertyId,
        languageCode,
        title,
        description,
        landmarks,
        additionalNotes,
        source,
        status,
        updatedAt,
      ];
}
