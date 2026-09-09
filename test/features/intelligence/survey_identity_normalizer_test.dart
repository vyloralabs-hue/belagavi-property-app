import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/intelligence/domain/services/survey_identity_normalizer.dart';

void main() {
  group('SurveyIdentityNormalizer Tests', () {
    test('Subdivisions are preserved distinctly: 123 != 123/1 != 123/2 != 123/2A', () {
      final idBase = SurveyIdentityNormalizer.normalize(
        district: 'Belagavi',
        taluk: 'Belagavi',
        locality: 'Shahapur',
        surveyNumber: '123',
      );

      final idSub1 = SurveyIdentityNormalizer.normalize(
        district: 'Belagavi',
        taluk: 'Belagavi',
        locality: 'Shahapur',
        surveyNumber: '123',
        subdivisionNumber: '1',
      );

      final idSub2 = SurveyIdentityNormalizer.normalize(
        district: 'Belagavi',
        taluk: 'Belagavi',
        locality: 'Shahapur',
        surveyNumber: '123',
        subdivisionNumber: '2',
      );

      final idSub2A = SurveyIdentityNormalizer.normalize(
        district: 'Belagavi',
        taluk: 'Belagavi',
        locality: 'Shahapur',
        surveyNumber: '123',
        subdivisionNumber: '2A',
      );

      expect(idBase, 'IND:KA:BELAGAVI:BELAGAVI:BELAGAVI:SHAHAPUR:123');
      expect(idSub1, 'IND:KA:BELAGAVI:BELAGAVI:BELAGAVI:SHAHAPUR:123/1');
      expect(idSub2, 'IND:KA:BELAGAVI:BELAGAVI:BELAGAVI:SHAHAPUR:123/2');
      expect(idSub2A, 'IND:KA:BELAGAVI:BELAGAVI:BELAGAVI:SHAHAPUR:123/2A');

      expect(idBase != idSub1, isTrue);
      expect(idSub1 != idSub2, isTrue);
      expect(idSub2 != idSub2A, isTrue);
    });

    test('Cross-district isolation prevents survey number collisions', () {
      final belagaviSurvey = SurveyIdentityNormalizer.normalize(
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        cityOrVillage: 'Belagavi',
        locality: 'Shahapur',
        surveyNumber: '123/2',
      );

      final puneSurvey = SurveyIdentityNormalizer.normalize(
        state: 'Maharashtra',
        district: 'Pune',
        taluk: 'Haveli',
        cityOrVillage: 'Pune',
        locality: 'Kothrud',
        surveyNumber: '123/2',
      );

      expect(belagaviSurvey != puneSurvey, isTrue);
      expect(belagaviSurvey.contains('BELAGAVI'), isTrue);
      expect(puneSurvey.contains('PUNE'), isTrue);
    });

    test('Whitespace and case trimming produces identical canonical keys', () {
      final key1 = SurveyIdentityNormalizer.normalize(
        state: '  karnataka  ',
        district: 'Belagavi ',
        taluk: ' belagavi',
        locality: 'Tilakwadi ',
        surveyNumber: ' 45 / A ',
      );

      final key2 = SurveyIdentityNormalizer.normalize(
        state: 'KARNATAKA',
        district: 'BELAGAVI',
        taluk: 'BELAGAVI',
        locality: 'TILAKWADI',
        surveyNumber: '45/A',
      );

      expect(key1, key2);
    });
  });
}
