import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/intelligence/domain/entities/requirement_entities.dart';
import 'package:belagavi_property/features/intelligence/domain/entities/preference_entities.dart';
import 'package:belagavi_property/features/intelligence/domain/services/property_match_evaluator.dart';

Property createTestProperty({
  required String id,
  required double price,
  PropertyCategory category = PropertyCategory.residential,
  ListingStatus status = ListingStatus.active,
  bool isPaused = false,
  String locality = 'Tilakwadi',
  String taluk = 'Belagavi',
  String district = 'Belagavi',
  int bedrooms = 2,
  double carpetArea = 1000.0,
}) {
  return Property(
    id: id,
    ownerId: 'owner_1',
    title: 'Test Property $id',
    description: 'Beautiful property in Belagavi',
    category: category,
    type: PropertySubtype.apartment,
    status: status,
    isPaused: isPaused,
    price: price,
    state: 'Karnataka',
    district: district,
    taluk: taluk,
    city: 'Belagavi',
    locality: locality,
    address: 'Sample Address',
    pincode: '590006',
    specifications: PropertySpecificationsEntity(
      bedrooms: bedrooms,
      carpetArea: carpetArea,
      areaUnit: 'sqft',
    ),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  group('PropertyMatchEvaluator Tests', () {
    final baseRequirement = SavedRequirementEntity(
      id: 'req_1',
      profileId: 'prof_1',
      title: 'Tilakwadi 2BHK 40L-50L',
      purpose: 'buy',
      category: 'residential',
      state: 'Karnataka',
      district: 'Belagavi',
      taluk: 'Belagavi',
      preferredLocalities: const ['Tilakwadi'],
      minBudget: 4000000, // 40L
      maxBudget: 5000000, // 50L
      priceTolerancePercent: 10.0, // Allow 36L to 55L
      minBedrooms: 2,
      maxBedrooms: 3,
      alertFrequency: 'instant',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('Exact budget match (45L) receives perfect pricing score', () {
      final prop = createTestProperty(id: 'p_exact', price: 4500000);
      final res = PropertyMatchEvaluator.evaluateRequirement(
        requirement: baseRequirement,
        property: prop,
      );

      expect(res.isMatch, isTrue);
      expect(res.score, greaterThanOrEqualTo(85));
      expect(res.matchReasons.any((r) => r.contains('Exact budget match')), isTrue);
    });

    test('Price within +10% tolerance (54L) matches with tolerance points', () {
      final prop = createTestProperty(id: 'p_tol_plus', price: 5400000);
      final res = PropertyMatchEvaluator.evaluateRequirement(
        requirement: baseRequirement,
        property: prop,
      );

      expect(res.isMatch, isTrue);
      expect(res.score, greaterThanOrEqualTo(50));
      expect(res.matchReasons.any((r) => r.contains('tolerance')), isTrue);
    });

    test('Price within -10% tolerance (37L) matches with tolerance points', () {
      final prop = createTestProperty(id: 'p_tol_minus', price: 3700000);
      final res = PropertyMatchEvaluator.evaluateRequirement(
        requirement: baseRequirement,
        property: prop,
      );

      expect(res.isMatch, isTrue);
      expect(res.score, greaterThanOrEqualTo(50));
      expect(res.matchReasons.any((r) => r.contains('tolerance')), isTrue);
    });

    test('Price outside tolerance (>55L e.g. 58L) fails to match (score = 0)', () {
      final prop = createTestProperty(id: 'p_expensive', price: 5800000);
      final res = PropertyMatchEvaluator.evaluateRequirement(
        requirement: baseRequirement,
        property: prop,
      );

      expect(res.isMatch, isFalse);
      expect(res.score, 0);
    });

    test('Price outside tolerance (<36L e.g. 32L) fails to match (score = 0)', () {
      final prop = createTestProperty(id: 'p_cheap', price: 3200000);
      final res = PropertyMatchEvaluator.evaluateRequirement(
        requirement: baseRequirement,
        property: prop,
      );

      expect(res.isMatch, isFalse);
      expect(res.score, 0);
    });

    test('Category mismatch (Commercial vs Residential) returns score 0', () {
      final prop = createTestProperty(
        id: 'p_comm',
        price: 4500000,
        category: PropertyCategory.commercial,
      );
      final res = PropertyMatchEvaluator.evaluateRequirement(
        requirement: baseRequirement,
        property: prop,
      );

      expect(res.isMatch, isFalse);
      expect(res.score, 0);
    });

    test('Paused / On Hold property fails to match (score = 0)', () {
      final prop = createTestProperty(
        id: 'p_paused',
        price: 4500000,
        isPaused: true,
      );
      final res = PropertyMatchEvaluator.evaluateRequirement(
        requirement: baseRequirement,
        property: prop,
      );

      expect(res.isMatch, isFalse);
      expect(res.score, 0);
    });

    test('Preference Evaluation personalizes feed based on active criteria', () {
      final preference = PropertyPreferenceEntity(
        id: 'pref_1',
        profileId: 'prof_1',
        category: 'residential',
        preferredLocalities: const ['Tilakwadi'],
        minBudget: 3000000,
        maxBudget: 6000000,
        minBedrooms: 2,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final matchingProp = createTestProperty(id: 'p_pref_match', price: 4500000, locality: 'Tilakwadi');
      final res = PropertyMatchEvaluator.evaluatePreference(
        preference: preference,
        property: matchingProp,
      );

      expect(res.isMatch, isTrue);
      expect(res.score, greaterThanOrEqualTo(70));
    });
  });
}
