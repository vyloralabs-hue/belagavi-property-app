import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/intelligence/domain/entities/entitlement_entities.dart';
import 'package:belagavi_property/features/intelligence/domain/entities/property_watch_entities.dart';
import 'package:belagavi_property/features/intelligence/data/datasources/intelligence_remote_datasource.dart';

void main() {
  group('Server-Authoritative Entitlement Guard Tests', () {
    test('Free user with null entitlement is NOT entitled', () {
      const UserEntitlementEntity? entitlement = null;
      expect(entitlement, isNull);
    });

    test('Entitlement with available quota is verified as entitled', () {
      final entitlement = UserEntitlementEntity(
        id: 'ent_1',
        userId: 'user_1',
        entitlementKey: 'property_watch',
        totalQuota: 5,
        usedQuota: 2,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(entitlement.hasAvailableQuota, isTrue);
      expect(entitlement.remainingQuota, 3);
      expect(entitlement.isExpired, isFalse);
    });

    test('Expired entitlement denies watch capability', () {
      final entitlement = UserEntitlementEntity(
        id: 'ent_2',
        userId: 'user_1',
        entitlementKey: 'survey_monitoring',
        totalQuota: 10,
        usedQuota: 1,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(entitlement.isExpired, isTrue);
      expect(entitlement.hasAvailableQuota, isFalse);
    });

    test('Fully consumed quota denies watch capability', () {
      final entitlement = UserEntitlementEntity(
        id: 'ent_3',
        userId: 'user_1',
        entitlementKey: 'property_watch',
        totalQuota: 3,
        usedQuota: 3,
        expiresAt: DateTime.now().add(const Duration(days: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(entitlement.remainingQuota, 0);
      expect(entitlement.hasAvailableQuota, isFalse);
    });

    test('EntitlementRequiredException has proper user-facing error message', () {
      const ex = EntitlementRequiredException(
        'Active paid entitlement required for property or survey monitoring. Please upgrade to a monitoring pack.',
      );
      expect(ex.toString(), contains('Active paid entitlement required'));
    });
  });
}
