import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';
import 'package:belagavi_property/features/transaction/domain/entities/transaction_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/dispute_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/legal_notice_entities.dart';

void main() {
  group('REAL DEVICE BETA QA & PROPERTY CONTEXT VERIFICATION TEST MATRIX', () {
    const ownerId = 'usr_seller_101';
    const buyerId = 'usr_buyer_202';
    const unauthorizedUserId = 'usr_intruder_999';

    // ─── 1. HOUSING / RESIDENTIAL CATEGORY QUALITY ──────────────────────────────
    test(
      '1. Housing: Complete residential specifications verify and serialize cleanly',
      () {
        final housingProp = PropertyEntity(
          id: 'prop_house_01',
          ownerId: ownerId,
          title: 'Luxury 3 BHK Villa in Tilakwadi',
          description:
              'Prime independent villa with garden and modular kitchen.',
          category: PropertyCategory.residential,
          type: PropertySubtype.villa,
          status: ListingStatus.published,
          verificationStatus: VerificationStatus.verified,
          price: 12500000,
          isNegotiable: true,
          specifications: const PropertySpecificationsEntity(
            bedrooms: 3,
            bathrooms: 3,
            balconies: 2,
            floorNumber: 1,
            totalFloors: 2,
            carpetArea: 2200,
            superBuiltUpArea: 2800,
            furnishingStatus: 'Semi-Furnished',
            facingDirection: 'East',
          ),
          mediaList: const [],
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: '1st Cross, Tilakwadi',
          pincode: '590006',
          latitude: 15.8497,
          longitude: 74.4977,
          viewsCount: 25,
          features: const {'hasCoveredParking': true, 'hasPowerBackup': true},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(housingProp.category, PropertyCategory.residential);
        expect(housingProp.specifications.bedrooms, 3);
        expect(housingProp.specifications.carpetArea, 2200);
        expect(housingProp.specifications.furnishingStatus, 'Semi-Furnished');
      },
    );

    // ─── 2. PLOTS & LAYOUT CATEGORY QUALITY ──────────────────────────────────────
    test(
      '2. Plots: Complete layout specifications, dimensions and survey attributes verify cleanly',
      () {
        final plotProp = PropertyEntity(
          id: 'prop_plot_01',
          ownerId: ownerId,
          title: '40x60 North Facing BUDA Approved Plot',
          description: 'Ready to build residential plot in gated layout.',
          category: PropertyCategory.plotLand,
          type: PropertySubtype.residentialPlot,
          status: ListingStatus.published,
          verificationStatus: VerificationStatus.verified,
          price: 4800000,
          isNegotiable: false,
          specifications: const PropertySpecificationsEntity(
            plotArea: 2400,
            areaUnit: 'sqft',
            facingDirection: 'North',
          ),
          mediaList: const [],
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Hindwadi',
          address: 'Opposite Golf Course Road',
          pincode: '590011',
          latitude: 15.8350,
          longitude: 74.5120,
          viewsCount: 40,
          features: const {
            'plotLength': 60.0,
            'plotWidth': 40.0,
            'roadWidth': 30.0,
            'isCornerPlot': false,
            'isGatedLayout': true,
            'surveyNumber': 'CTS No. 4410 Plot 12',
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(plotProp.category, PropertyCategory.plotLand);
        expect(plotProp.features['plotLength'], 60.0);
        expect(plotProp.features['surveyNumber'], 'CTS No. 4410 Plot 12');
        expect(plotProp.features['isGatedLayout'], true);
      },
    );

    // ─── 3. COMMERCIAL CATEGORY QUALITY (SALE & LEASE) ──────────────────────────
    test(
      '3. Commercial: Purpose (Sale vs Lease), specs, power load, and frontage verify cleanly',
      () {
        final commercialProp = PropertyEntity(
          id: 'prop_comm_01',
          ownerId: ownerId,
          title: 'Prime 1500 Sqft Showroom on Khanapur Road',
          description:
              'High footfall retail commercial showroom with wide frontage.',
          category: PropertyCategory.commercial,
          type: PropertySubtype.commercialShowroom,
          status: ListingStatus.published,
          verificationStatus: VerificationStatus.verified,
          price: 9500000,
          isNegotiable: true,
          specifications: const PropertySpecificationsEntity(
            carpetArea: 1500,
            superBuiltUpArea: 1850,
            floorNumber: 0, // Ground floor
            totalFloors: 4,
            bathrooms: 2,
            facingDirection: 'Main Road Facing',
          ),
          mediaList: const [],
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Khanapur Road',
          address: 'Near RPD Cross, Khanapur Road',
          pincode: '590006',
          latitude: 15.8420,
          longitude: 74.5050,
          viewsCount: 65,
          features: const {
            'entranceWidth': 25.0,
            'ceilingHeight': 14.0,
            'powerLoad': '15 KW 3-Phase',
            'parkingSpaces': 3,
            'hasLift': true,
            'hasLoadingDock': true,
            'monthlyRent': 75000.0,
            'depositAmount': 500000.0,
            'leaseDurationMonths': 36,
            'maintenanceCharges': 4500.0,
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(commercialProp.category, PropertyCategory.commercial);
        expect(commercialProp.type, PropertySubtype.commercialShowroom);
        expect(commercialProp.features['powerLoad'], '15 KW 3-Phase');
        expect(commercialProp.features['entranceWidth'], 25.0);
        expect(commercialProp.features['hasLoadingDock'], true);
        expect(commercialProp.features['monthlyRent'], 75000.0);
      },
    );

    // ─── 4. RAW LAND / AGRICULTURAL CATEGORY QUALITY ────────────────────────────
    test(
      '4. Raw Land: Acreage, soil type, irrigation, and RTC reference verify cleanly',
      () {
        final rawLandProp = PropertyEntity(
          id: 'prop_land_01',
          ownerId: ownerId,
          title: '5 Acre Fertile Agricultural Farm Land in Sambra',
          description:
              'Well-irrigated sugarcane farm land with tar road approach.',
          category: PropertyCategory.land,
          type: PropertySubtype.agriculturalLand,
          status: ListingStatus.published,
          verificationStatus: VerificationStatus.verified,
          price: 15000000,
          isNegotiable: true,
          specifications: const PropertySpecificationsEntity(
            plotArea: 217800, // 5 Acres in sqft
            areaUnit: 'acre',
          ),
          mediaList: const [],
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Sambra Road',
          address: 'Near Sambra Airport Ring Road',
          pincode: '591124',
          latitude: 15.8600,
          longitude: 74.6200,
          viewsCount: 30,
          features: const {
            'soilType': 'Black Cotton Soil',
            'waterSource': 'Borewell & Canal Irrigation',
            'electricityType': '3-Phase Agri Power (10 HP)',
            'roadAccessType': 'Tar Road Frontage (30 ft)',
            'fencingType': 'Barbed Wire Fencing with Gate',
            'existingCropsTrees': 'Sugarcane & 50 Mango Trees',
            'surveyNumber': 'Sy. No. 214/1A & 214/1B',
            'hasBorewell': true,
            'hasFarmHouse': true,
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(rawLandProp.category, PropertyCategory.land);
        expect(rawLandProp.type, PropertySubtype.agriculturalLand);
        expect(rawLandProp.features['soilType'], 'Black Cotton Soil');
        expect(rawLandProp.features['surveyNumber'], 'Sy. No. 214/1A & 214/1B');
        expect(rawLandProp.features['hasBorewell'], true);
      },
    );

    // ─── 5. PURCHASE / SALE UNIFIED PROPERTY CONTEXT ─────────────────────────────
    test(
      '5. Purchase / Sale: Enquiry is authoritatively bound to property_id and communicates full context',
      () {
        final enquiry = PropertyEnquiryEntity(
          id: 'enq_101',
          propertyId: 'prop_house_01',
          propertyTitle: 'Luxury 3 BHK Villa in Tilakwadi',
          propertyCategory: 'Residential Housing',
          propertyLocation: 'Tilakwadi, Belagavi',
          buyerId: buyerId,
          buyerName: 'Amit Sharma',
          buyerPhone: '+919880011223',
          sellerId: ownerId,
          interestType: TransactionInterestType.buy,
          initialMessage: 'Interested in site visit this weekend.',
          listedPrice: 12500000,
          buyerOfferPrice: 11800000,
          sellerCounterOfferPrice: 12200000,
          status: TransactionStatus.negotiation,
          siteVisitStatus: SiteVisitStatus.scheduled,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(enquiry.propertyId, 'prop_house_01');
        expect(enquiry.propertyTitle, contains('Villa in Tilakwadi'));
        expect(enquiry.canUserAccess(buyerId), isTrue);
        expect(enquiry.canUserAccess(ownerId), isTrue);
        expect(enquiry.canUserAccess(unauthorizedUserId), isFalse);
      },
    );

    // ─── 6. DISPUTE UNIFIED PROPERTY CONTEXT ─────────────────────────────────────
    test(
      '6. Dispute: Registry entry is authoritatively linked to property_id with legal authority details',
      () {
        final dispute = PropertyDisputeEntity(
          propertyId: 'prop_comm_01',
          disputeType: DisputeType.courtCaseStayOrder,
          verificationStatus: DisputeVerificationStatus.documentVerified,
          caseNumber: 'WP 48291/2024',
          courtAuthority: 'High Court of Karnataka (Dharwad Bench)',
          caseYear: '2024',
          description:
              'Interim status-quo order regarding municipal building setback clearance.',
          reportedBy: 'Legal Advocate Search',
          reportDate: DateTime(2026, 2, 4),
          lastUpdated: DateTime(2026, 2, 10),
        );

        expect(dispute.propertyId, 'prop_comm_01');
        expect(dispute.caseNumber, 'WP 48291/2024');
        expect(
          dispute.verificationStatus,
          DisputeVerificationStatus.documentVerified,
        );
        expect(dispute.courtAuthority, contains('High Court'));
      },
    );

    // ─── 7. LEGAL NOTICE & DUE DILIGENCE COMPLIANCE ──────────────────────────────
    test(
      '7. Legal Notice & Due Diligence: Standard checklists verify Karnataka statutory requirements',
      () {
        const buyerItems = LegalNoticeRepositoryData.buyerChecklist;
        expect(buyerItems.length, 13);
        expect(
          buyerItems.any(
            (i) =>
                i.title.contains('Encumbrance Certificate') ||
                i.requiredDocument.contains('EC'),
          ),
          isTrue,
        );
        expect(
          buyerItems.any(
            (i) =>
                i.requiredDocument.contains('RTC') ||
                i.requiredDocument.contains('Pahani'),
          ),
          isTrue,
        );
        expect(
          buyerItems.any(
            (i) =>
                i.verificationAuthority.contains('BUDA') ||
                i.title.contains('Layout'),
          ),
          isTrue,
        );

        const sellerItems = LegalNoticeRepositoryData.sellerChecklist;
        expect(sellerItems.length, 7);
        expect(sellerItems.any((i) => i.title.contains('Title Deeds')), isTrue);
      },
    );

    // ─── 8. IMMUTABILITY & SECURITY ATTACK GUARDS ────────────────────────────────
    test(
      '8. Security: Unauthorized user cannot mutate property_id, owner_id, or moderation state',
      () {
        // Attempt 1: Intruder modifies owner_id -> DENIED
        expect(
          () => PropertySecurityGuard.verifyPropertyUpdate(
            existingOwnerId: ownerId,
            updatedOwnerId: unauthorizedUserId,
            currentUserId: unauthorizedUserId,
            userRole: UserRole.user,
          ),
          throwsA(isA<AccessDeniedException>()),
        );

        // Attempt 2: Seller attempts self-approval from draft to published -> DENIED
        expect(
          () => PropertySecurityGuard.verifyPropertyUpdate(
            existingOwnerId: ownerId,
            updatedOwnerId: ownerId,
            currentUserId: ownerId,
            userRole: UserRole.sellerOwner,
            currentStatus: ListingStatus.draft,
            targetStatus: ListingStatus.published,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );
  });
}
