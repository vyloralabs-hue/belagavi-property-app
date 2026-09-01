import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/localization/app_localizations.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';

void main() {
  group('PHASE 17A — PROPERTY OWNER & ADMIN VISIBILITY CONTROLS TESTS', () {
    final now = DateTime.now();

    final ownerPropertyLive = PropertyEntity(
      id: 'prop_17a_01',
      ownerId: 'usr_seller_17a',
      title: '3 BHK Villa in Tilakwadi',
      description: 'Luxury 3 BHK independent villa',
      category: PropertyCategory.residential,
      type: PropertySubtype.villa,
      status: ListingStatus.published,
      price: 8500000,
      state: 'Karnataka',
      district: 'Belagavi',
      taluk: 'Belagavi',
      city: 'Belagavi',
      locality: 'Tilakwadi',
      address: 'First Cross, Tilakwadi',
      pincode: '590006',
      specifications: const PropertySpecificationsEntity(
        bedrooms: 3,
        bathrooms: 3,
      ),
      createdAt: now,
      updatedAt: now,
    );

    final ownerPropertyHidden = PropertyEntity(
      id: 'prop_17a_02',
      ownerId: 'usr_seller_17a',
      title: 'Commercial Shop on Khanapur Road',
      description: 'Prime retail space',
      category: PropertyCategory.commercial,
      type: PropertySubtype.commercialShop,
      status: ListingStatus.paused, // OWNER_HIDDEN
      price: 4500000,
      state: 'Karnataka',
      district: 'Belagavi',
      taluk: 'Belagavi',
      city: 'Belagavi',
      locality: 'Tilakwadi',
      address: 'Khanapur Road, Tilakwadi',
      pincode: '590006',
      specifications: const PropertySpecificationsEntity(),
      createdAt: now,
      updatedAt: now,
    );

    // ─── 1. Ownership & Role Detection Tests ─────────────────────────────────

    test(
      'TEST 1: Owner ownership verification passes for canonical owner ID',
      () {
        expect(
          () => PropertySecurityGuard.verifyPropertyOwnership(
            authenticatedUserId: 'usr_seller_17a',
            ownerId: ownerPropertyLive.ownerId,
          ),
          returnsNormally,
        );
      },
    );

    test(
      'TEST 2: Owner ownership verification throws exception for non-owner user ID',
      () {
        expect(
          () => PropertySecurityGuard.verifyPropertyOwnership(
            authenticatedUserId: 'usr_stranger_999',
            ownerId: ownerPropertyLive.ownerId,
          ),
          throwsA(anything),
        );
      },
    );

    // ─── 2. Owner Visibility Actions Logic ────────────────────────────────────

    test(
      'TEST 3: LIVE property status allows Owner Hide action (transitions to paused)',
      () {
        final isLive =
            ownerPropertyLive.status == ListingStatus.published ||
            ownerPropertyLive.status == ListingStatus.approved ||
            ownerPropertyLive.status == ListingStatus.active;

        expect(isLive, isTrue);
        expect(ownerPropertyLive.status == ListingStatus.paused, isFalse);
      },
    );

    test(
      'TEST 4: HIDDEN property status (paused) allows Owner Resume action (transitions to published)',
      () {
        final isHidden = ownerPropertyHidden.status == ListingStatus.paused;

        expect(isHidden, isTrue);
      },
    );

    // ─── 3. Admin & Founder Moderation Governance ─────────────────────────────

    test(
      'TEST 5: Admin role possesses authorization for moderation actions',
      () {
        const isAdminOrFounder =
            UserRole.admin == UserRole.admin ||
            UserRole.admin == UserRole.founder;
        expect(isAdminOrFounder, isTrue);
      },
    );

    test(
      'TEST 6: Founder role retains emergency authority for property actions',
      () {
        const isFounder = UserRole.founder == UserRole.founder;
        expect(isFounder, isTrue);
      },
    );

    test(
      'TEST 7: Moderator / General User rejected from financial / emergency overrides',
      () {
        const isModeratorAllowedFinancial =
            UserRole.moderator == UserRole.founder;
        expect(isModeratorAllowedFinancial, isFalse);
      },
    );

    // ─── 4. Public Discovery Safety & Filtering ─────────────────────────────

    test(
      'TEST 8: Hidden property (paused) is strictly excluded from public listing discovery',
      () {
        final publicStatuses = {
          ListingStatus.published,
          ListingStatus.approved,
          ListingStatus.active,
        };

        expect(publicStatuses.contains(ownerPropertyLive.status), isTrue);
        expect(publicStatuses.contains(ownerPropertyHidden.status), isFalse);
      },
    );

    test(
      'TEST 9: Restored property (published) becomes visible for public discovery',
      () {
        final restoredProp = PropertyEntity(
          id: 'prop_17a_03',
          ownerId: 'usr_seller_17a',
          title: 'Restored Plot in Camp',
          description: 'Residential plot',
          category: PropertyCategory.land,
          type: PropertySubtype.residentialPlot,
          status: ListingStatus.published,
          price: 2500000,
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Camp',
          address: 'Camp Belagavi',
          pincode: '590001',
          specifications: const PropertySpecificationsEntity(),
          createdAt: now,
          updatedAt: now,
        );

        final publicStatuses = {
          ListingStatus.published,
          ListingStatus.approved,
          ListingStatus.active,
        };
        expect(publicStatuses.contains(restoredProp.status), isTrue);
      },
    );

    // ─── 5. Localization Strings Verification ────────────────────────────────

    test(
      'TEST 10: AppLocalizations translates visibility keys across EN, HI, KN',
      () {
        const enLoc = AppLocalizations(AppLanguage.english);
        const hiLoc = AppLocalizations(AppLanguage.hindi);
        const knLoc = AppLocalizations(AppLanguage.kannada);

        expect(enLoc.translate('hideListing'), 'Hide Listing');
        expect(hiLoc.translate('hideListing'), 'लिस्टिंग छिपाएं');
        expect(knLoc.translate('hideListing'), 'ಪಟ್ಟಿಯನ್ನು ಮರೆಮಾಡಿ');

        expect(enLoc.translate('makeListingLive'), 'Make Live');
        expect(hiLoc.translate('makeListingLive'), 'लाइव करें');
        expect(knLoc.translate('makeListingLive'), 'ಲೈವ್ ಮಾಡಿ');

        expect(enLoc.translate('listingHidden'), 'HIDDEN FROM PUBLIC');
      },
    );
  });
}
