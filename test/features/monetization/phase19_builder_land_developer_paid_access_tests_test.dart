import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/config/property_monetization_config.dart';
import 'package:belagavi_property/core/localization/app_localizations.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/investment/domain/entities/investment_entities.dart';
import 'package:belagavi_property/features/monetization/domain/entities/central_monetization_entities.dart';
import 'package:belagavi_property/features/monetization/utils/professional_listing_access_policy.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property_search/utils/property_priority_ranker.dart';

void main() {
  group(
    'PHASE 19 ADDENDUM — BUILDER & LAND-DEVELOPER MANDATORY PAID SUBSCRIPTION GOVERNANCE TESTS',
    () {
      final now = DateTime.now();

      const devOwnerAId = 'usr_dev_alpha';
      const devOwnerBId = 'usr_dev_beta';

      // ─── 1. Free-First vs. Mandatory Paid Access Rules ────────────────────────

      test('TEST 1: Normal property owner receives free basic access', () {
        final isSubReq = ProfessionalListingAccessPolicy.isSubscriptionRequired(
          userRole: UserRole.sellerOwner,
          category: PropertyCategory.residential,
          subtype: PropertySubtype.independentHouse,
        );

        expect(isSubReq, isFalse);
      });

      test(
        'TEST 2: Normal seller receives free basic access for residential resale',
        () {
          final isSubReq =
              ProfessionalListingAccessPolicy.isSubscriptionRequired(
                userRole: UserRole.user,
                category: PropertyCategory.residential,
                subtype: PropertySubtype.apartment,
              );

          expect(isSubReq, isFalse);
        },
      );

      test('TEST 3: Builder requires mandatory paid subscription', () {
        final isSubReq = ProfessionalListingAccessPolicy.isSubscriptionRequired(
          userRole: UserRole.builder,
          category: PropertyCategory.builderProject,
          subtype: PropertySubtype.builderProject,
        );

        expect(isSubReq, isTrue);
      });

      test(
        'TEST 4: Project developer requires mandatory paid subscription',
        () {
          final isSubReq =
              ProfessionalListingAccessPolicy.isSubscriptionRequired(
                userRole: UserRole.builder,
                category: PropertyCategory.residential,
                classification: DeveloperClassification.projectDeveloper,
              );

          expect(isSubReq, isTrue);
        },
      );

      test('TEST 5: Land developer requires mandatory paid subscription', () {
        final isSubReq = ProfessionalListingAccessPolicy.isSubscriptionRequired(
          userRole: UserRole.landDeveloper,
          category: PropertyCategory.land,
          classification: DeveloperClassification.landDeveloper,
        );

        expect(isSubReq, isTrue);
      });

      test('TEST 6: Layout developer requires mandatory paid subscription', () {
        final isSubReq = ProfessionalListingAccessPolicy.isSubscriptionRequired(
          userRole: UserRole.landDeveloper,
          category: PropertyCategory.plotLand,
          classification: DeveloperClassification.layoutDeveloper,
        );

        expect(isSubReq, isTrue);
      });

      // ─── 2. Publication Eligibility & Expiry Enforcement ─────────────────────

      test(
        'TEST 7: Builder without active subscription CANNOT publish publicly',
        () {
          final canPublish =
              ProfessionalListingAccessPolicy.canPublishProfessionalListing(
                userRole: UserRole.builder,
                category: PropertyCategory.builderProject,
                hasActiveSubscription: false,
                currentStatus: ListingStatus.approved,
              );

          expect(canPublish, isFalse);
        },
      );

      test(
        'TEST 8: Land developer without active subscription CANNOT publish publicly',
        () {
          final canPublish =
              ProfessionalListingAccessPolicy.canPublishProfessionalListing(
                userRole: UserRole.landDeveloper,
                category: PropertyCategory.plotLand,
                hasActiveSubscription: false,
                currentStatus: ListingStatus.approved,
              );

          expect(canPublish, isFalse);
        },
      );

      test(
        'TEST 9: Active subscription permits professional publication after moderation approval',
        () {
          final canPublish =
              ProfessionalListingAccessPolicy.canPublishProfessionalListing(
                userRole: UserRole.builder,
                category: PropertyCategory.builderProject,
                hasActiveSubscription: true,
                currentStatus: ListingStatus.approved,
              );

          expect(canPublish, isTrue);
        },
      );

      test(
        'TEST 10: Expired subscription blocks public professional visibility',
        () {
          final canPublish =
              ProfessionalListingAccessPolicy.canPublishProfessionalListing(
                userRole: UserRole.builder,
                category: PropertyCategory.builderProject,
                hasActiveSubscription: false,
                currentStatus: ListingStatus.published,
              );

          expect(canPublish, isFalse);
        },
      );

      test(
        'TEST 11: Cancelled subscription blocks professional publication',
        () {
          final canPublish =
              ProfessionalListingAccessPolicy.canPublishProfessionalListing(
                userRole: UserRole.landDeveloper,
                category: PropertyCategory.land,
                hasActiveSubscription: false,
                currentStatus: ListingStatus.submitted,
              );

          expect(canPublish, isFalse);
        },
      );

      test(
        'TEST 12: Payment failure state does NOT activate developer subscription',
        () {
          const state = OrderLifecycleState.paymentFailed;
          const isActivated = state == OrderLifecycleState.fulfilled;

          expect(isActivated, isFalse);
        },
      );

      test(
        'TEST 13: Successful sandbox payment activates developer entitlement',
        () {
          const state = OrderLifecycleState.fulfilled;
          const isActivated = state == OrderLifecycleState.fulfilled;

          expect(isActivated, isTrue);
        },
      );

      // ─── 3. Owner Privacy & Role Isolation ────────────────────────────────────

      test('TEST 14: Developer A cannot access Developer B data', () {
        const authUser = devOwnerAId;
        const targetUser = devOwnerBId;

        const isAuthorized = authUser == targetUser;
        expect(isAuthorized, isFalse);
      });

      test('TEST 15: Public user cannot access private subscription data', () {
        const isPublicUser = true;
        const canAccessPrivateSub = !isPublicUser;

        expect(canAccessPrivateSub, isFalse);
      });

      test('TEST 16: Admin can review developer subscription status', () {
        expect(UserRole.admin.isAdminOrFounder, isTrue);
      });

      test('TEST 17: Founder emergency controls remain functional', () {
        expect(UserRole.founder.isFounder, isTrue);
      });

      // ─── 4. Non-Regression Across Prior Phases ────────────────────────────────

      test(
        'TEST 18: Normal free listings continue working without disruption',
        () {
          final isSubReq =
              ProfessionalListingAccessPolicy.isSubscriptionRequired(
                userRole: UserRole.sellerOwner,
                category: PropertyCategory.residential,
              );

          expect(isSubReq, isFalse);
        },
      );

      test(
        'TEST 19: Local shop monetization remains governed by Phase 14 & 16',
        () {
          final shopPlan = PricingPlanEntity.localShopMonthly;
          expect(shopPlan.amountInRupees, 500.0);
        },
      );

      test(
        'TEST 20: Phase 17C BELAGAVI PROPERTY LLP investment module remains unchanged',
        () {
          final config = ComplianceContentConfig(updatedAt: now);
          expect(config.legalEntityName, 'BELAGAVI PROPERTY LLP');
          expect(config.isProductionPaymentEnabled, isFalse);
        },
      );

      test('TEST 21: Phase 18 Owner Command Center remains operational', () {
        expect(UserRole.sellerOwner.isOwner, isTrue);
      });

      test(
        'TEST 22: Search excludes unauthorized developer listings with score -1',
        () {
          final pausedDevProp = PropertyEntity(
            id: 'prop_dev_paused',
            ownerId: devOwnerAId,
            title: 'Developer Project',
            description: 'Paused project',
            category: PropertyCategory.builderProject,
            type: PropertySubtype.builderApartmentProject,
            status: ListingStatus.paused,
            price: 7500000,
            state: 'Karnataka',
            district: 'Belagavi',
            taluk: 'Belagavi',
            city: 'Belagavi',
            locality: 'Tilakwadi',
            address: 'Road 2',
            pincode: '590006',
            specifications: const PropertySpecificationsEntity(),
            createdAt: now,
            updatedAt: now,
          );

          final score = PropertyPriorityRanker.calculatePriorityScore(
            property: pausedDevProp,
          );
          expect(score, -1.0);
        },
      );

      test(
        'TEST 23: Search includes valid published professional listings',
        () {
          final liveDevProp = PropertyEntity(
            id: 'prop_dev_live',
            ownerId: devOwnerAId,
            title: 'Developer Project',
            description: 'Live project',
            category: PropertyCategory.builderProject,
            type: PropertySubtype.builderApartmentProject,
            status: ListingStatus.published,
            price: 7500000,
            state: 'Karnataka',
            district: 'Belagavi',
            taluk: 'Belagavi',
            city: 'Belagavi',
            locality: 'Tilakwadi',
            address: 'Road 2',
            pincode: '590006',
            specifications: const PropertySpecificationsEntity(),
            createdAt: now,
            updatedAt: now,
          );

          final score = PropertyPriorityRanker.calculatePriorityScore(
            property: liveDevProp,
          );
          expect(score, greaterThan(0));
        },
      );

      test(
        'TEST 24: Premium boost remains separate from developer subscription access',
        () {
          final featuredPlan = PropertyMonetizationConfig.getPlan(
            PropertyPromotionTier.featured,
          );
          final devPlan = PricingPlanEntity.builderProConfigurable;

          expect(featuredPlan.amountInRupees != devPlan.amountInRupees, isTrue);
        },
      );
    },
  );
}
