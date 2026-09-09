class SurveyIdentityNormalizer {
  SurveyIdentityNormalizer._();

  /// Canonical survey identity normalizer.
  /// Formats: COUNTRY:STATE:DISTRICT:TALUK:CITY_OR_VILLAGE:LOCALITY:SURVEY_SUBDIVISION
  /// Preserves exact subdivision identities: '123' != '123/1' != '123/2'.
  /// Prevents cross-district collisions: Belagavi/123/2 != Pune/123/2.
  static String normalize({
    String? country,
    String? state,
    String? district,
    String? taluk,
    String? cityOrVillage,
    String? locality,
    required String surveyNumber,
    String? subdivisionNumber,
  }) {
    final c = _cleanPart(country, defaultValue: 'IND');
    final s = _cleanPart(state, defaultValue: 'KA');
    final d = _cleanPart(district, defaultValue: 'BELAGAVI');
    final t = _cleanPart(taluk, defaultValue: 'BELAGAVI');
    final cv = _cleanPart(cityOrVillage, defaultValue: 'BELAGAVI');
    final loc = _cleanPart(locality, defaultValue: 'GENERAL');

    final cleanSurv = surveyNumber.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    final cleanSub = (subdivisionNumber ?? '').trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');

    String combinedSurvey;
    if (cleanSurv.isEmpty) {
      combinedSurvey = 'UNSPECIFIED';
    } else if (cleanSub.isNotEmpty) {
      if (cleanSurv.contains('/')) {
        combinedSurvey = cleanSurv;
      } else {
        combinedSurvey = '$cleanSurv/$cleanSub';
      }
    } else {
      combinedSurvey = cleanSurv;
    }

    return '$c:$s:$d:$t:$cv:$loc:$combinedSurvey';
  }

  static String _cleanPart(String? part, {required String defaultValue}) {
    if (part == null || part.trim().isEmpty) return defaultValue;
    return part
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9_-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  /// Extracts display components from a normalized identity
  static Map<String, String> parseIdentity(String normalized) {
    final parts = normalized.split(':');
    return {
      'country': parts.isNotEmpty ? parts[0] : 'IND',
      'state': parts.length > 1 ? parts[1] : '',
      'district': parts.length > 2 ? parts[2] : '',
      'taluk': parts.length > 3 ? parts[3] : '',
      'cityOrVillage': parts.length > 4 ? parts[4] : '',
      'locality': parts.length > 5 ? parts[5] : '',
      'surveyNumber': parts.length > 6 ? parts.sublist(6).join(':') : '',
    };
  }
}
