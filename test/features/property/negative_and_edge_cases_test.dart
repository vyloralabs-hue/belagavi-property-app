import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/config/listing_pricing_config.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_form_notifier.dart';
import 'package:belagavi_property/features/property/utils/media_file_validator.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';
import 'package:belagavi_property/features/legal_dispute/data/datasources/dispute_remote_datasource.dart';
import 'package:belagavi_property/features/legal_dispute/data/repositories/dispute_repository_impl.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/dispute_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/repositories/dispute_repository.dart';

class MockPropertyRepository implements PropertyRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockPropertyRepository mockPropertyRepo;
  late PropertyFormNotifier formNotifier;
  late SupabaseService supabase;
  late DisputeRemoteDataSource disputeDataSource;
  late DisputeRepository disputeRepository;

  setUp(() {
    mockPropertyRepo = MockPropertyRepository();
    formNotifier = PropertyFormNotifier(mockPropertyRepo);
    supabase = SupabaseService();
    disputeDataSource = DisputeRemoteDataSourceImpl(supabase);
    disputeRepository = DisputeRepositoryImpl(disputeDataSource);
  });

  group('BELAGAVI PROPERTY â€” NEGATIVE TESTS & EDGE CASE MATRIX', () {
    test(
      '1. Negative: Zero photos fails publish validation with clear message',
      () {
        formNotifier.initForNewProperty('usr_seller_neg_01');
        formNotifier.updatePropertyType(
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
        );
        formNotifier.updateBasicDetails(
          title: '2 BHK Apartment in Tilakwadi',
          description: 'Well maintained residential apartment.',
        );
        formNotifier.updateLocation(
          locality: 'Tilakwadi',
          city: 'Belagavi',
          district: 'Belagavi',
          stateName: 'Karnataka',
          pincode: '590006',
        );
        formNotifier.updatePriceAndArea(price: 4500000.0, carpetArea: 950.0);

        // No photos added
        final missing = formNotifier.getMissingPublishFields();
        expect(missing.any((m) => m.toLowerCase().contains('photo')), isTrue);
        expect(
          formNotifier.validateStep(7),
          isFalse,
        ); // Full validation gate fails
      },
    );

    test(
      '2. Negative: Invalid file format / oversized file rejected by MediaFileValidator',
      () {
        // Invalid extension
        expect(
          () => MediaFileValidator.validateImage(
            fileName: 'malicious.exe',
            fileSizeBytes: 1024,
          ),
          throwsA(isA<Exception>()),
        );

        // Oversized image (> 15 MB)
        expect(
          () => MediaFileValidator.validateImage(
            fileName: 'huge_photo.jpg',
            fileSizeBytes: 20 * 1024 * 1024,
          ),
          throwsA(isA<Exception>()),
        );

        // Valid image (under 15 MB)
        expect(
          () => MediaFileValidator.validateImage(
            fileName: 'good_photo.jpg',
            fileSizeBytes: 2 * 1024 * 1024,
          ),
          returnsNormally,
        );
      },
    );

    test(
      '3. Negative: Zero or negative price on For-Sale listing fails validation',
      () {
        formNotifier.initForNewProperty('usr_seller_neg_02');
        formNotifier.updatePropertyType(
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
        );
        formNotifier.updateBasicDetails(
          title: 'Apartment for sale',
          description: 'Test desc',
          listingType: 'FOR_SALE',
        );
        formNotifier.updatePriceAndArea(price: 0.0);

        expect(formNotifier.validateStep(3), isFalse);
        expect(formNotifier.state.fieldErrors['price'], isNotNull);
      },
    );

    test(
      '4. Negative: Missing locality or location fields fails validation',
      () {
        formNotifier.initForNewProperty('usr_seller_neg_03');
        formNotifier.updateLocation(
          locality: '', // Empty locality
          city: 'Belagavi',
          district: 'Belagavi',
          stateName: 'Karnataka',
        );

        expect(formNotifier.validateStep(2), isFalse);
        expect(formNotifier.state.fieldErrors['locality'], isNotNull);
      },
    );

    test(
      '5. Security: Unauthorized seller cannot modify or delete another user property',
      () {
        // User A owns property
        const ownerId = 'usr_legitimate_owner';
        const attackerId = 'usr_attacker_hacker';

        expect(
          () => PropertySecurityGuard.verifyPropertyOwnership(
            authenticatedUserId: attackerId,
            ownerId: ownerId,
            actionName: 'update property',
          ),
          throwsA(isA<AccessDeniedException>()),
        );

        // Legitimate owner is allowed
        expect(
          () => PropertySecurityGuard.verifyPropertyOwnership(
            authenticatedUserId: ownerId,
            ownerId: ownerId,
            actionName: 'update property',
          ),
          returnsNormally,
        );
      },
    );

    test(
      '6. Security: Private legal documents and claimant contact are masked for public viewers',
      () async {
        const dispute = PropertyDisputeEntity(
          id: 'disp_priv_001',
          propertyId: 'prop_priv_001',
          title: 'Title Suit over Ancestral Property',
          description: 'Pending court stay order on ancestral survey parcel.',
          locality: 'Camp',
          disputeType: DisputeType.courtCaseStayOrder,
          verificationStatus: DisputeVerificationStatus.underReview,
          contactPhone: '+91 98450 99887',
          documentUrls: const [
            'https://storage.belagaviproperty.com/legal/secret_will.pdf',
          ],
          isDocumentPrivate: true,
          reportedBy: 'usr_claimant_secret',
        );

        await disputeRepository.createDispute(
          dispute,
          authenticatedUserId: 'usr_claimant_secret',
        );

        final publicView = await disputeRepository.getDisputeById(
          'disp_priv_001',
          requestingUserId: 'usr_public_buyer',
          userRole: UserRole.user,
        );

        publicView.fold((_) => fail('Dispute fetch failed'), (d) {
          expect(d, isNotNull);
          expect(d!.documentUrls, isEmpty); // Hidden from public
          expect(d.contactPhone, contains('•••••')); // Phone masked
        });
      },
    );

    test(
      '7. Architecture: Centralized pricing prevents client-side fee manipulation',
      () {
        expect(ListingPricingConfig.disputeListingFeeInRupees, 500);
        expect(ListingPricingConfig.purchaseSaleDealFeeInRupees, 500);
      },
    );
  });
}
