import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/dispute_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/legal_notice_entities.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';

void main() {
  group('Phase 6: Disputed Property + Purchase/Sale Legal Notice Tests', () {
    test('1. Dispute Entity Serialization & Deserialization', () {
      final dispute = PropertyDisputeEntity(
        propertyId: 'prop_disp_1',
        disputeType: DisputeType.partitionFamilyDispute,
        verificationStatus: DisputeVerificationStatus.verificationPending,
        caseNumber: 'OS 112/2023',
        courtAuthority: 'Civil Court Senior Division, Belagavi',
        caseYear: '2023',
        description: 'Partition suit pending among legal heirs.',
        reportedBy: 'Legal Heir Notice',
        reportDate: DateTime(2026, 1, 12),
        relevantNotes: 'Plaint copy submitted',
        documentUrls: const ['https://example.com/docs/plaint.pdf'],
        lastUpdated: DateTime(2026, 1, 15),
      );

      final map = dispute.toMap();
      expect(map['disputeType'], 'partitionFamilyDispute');
      expect(map['caseNumber'], 'OS 112/2023');
      expect(map['verificationStatus'], 'verificationPending');

      final reconstructed = PropertyDisputeEntity.fromMap(map, 'prop_disp_1');
      expect(reconstructed.propertyId, 'prop_disp_1');
      expect(reconstructed.disputeType, DisputeType.partitionFamilyDispute);
      expect(
        reconstructed.verificationStatus,
        DisputeVerificationStatus.verificationPending,
      );
      expect(
        reconstructed.courtAuthority,
        'Civil Court Senior Division, Belagavi',
      );
    });

    test('2. Integration with PropertyEntity features map', () {
      final dispute = PropertyDisputeEntity(
        propertyId: 'prop_disp_2',
        disputeType: DisputeType.courtCaseStayOrder,
        verificationStatus: DisputeVerificationStatus.documentVerified,
        caseNumber: 'WP 48291/2024',
        courtAuthority: 'High Court of Karnataka (Dharwad Bench)',
        caseYear: '2024',
        description: 'Interim stay order on building construction.',
        reportDate: DateTime(2026, 2, 4),
        lastUpdated: DateTime(2026, 2, 10),
      );

      final property = PropertyEntity(
        id: 'prop_disp_2',
        ownerId: 'owner_1',
        title: 'Commercial Complex Khanapur Road',
        description: 'Prime commercial building with retail shops',
        category: PropertyCategory.commercial,
        type: PropertySubtype.commercialShowroom,
        price: 25000000.0,
        specifications: const PropertySpecificationsEntity(
          superBuiltUpArea: 4500.0,
          areaUnit: 'sqft',
        ),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Khanapur Road',
        address: 'CTS 4920, Khanapur Road',
        pincode: '590006',
        features: {'isDisputed': true, 'disputeDetails': dispute.toMap()},
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 2, 10),
      );

      expect(property.features['isDisputed'], isTrue);
      final rawDispute =
          property.features['disputeDetails'] as Map<String, dynamic>;
      final parsedDispute = PropertyDisputeEntity.fromMap(
        rawDispute,
        property.id,
      );
      expect(parsedDispute.disputeType, DisputeType.courtCaseStayOrder);
      expect(
        parsedDispute.verificationStatus,
        DisputeVerificationStatus.documentVerified,
      );
      expect(parsedDispute.caseNumber, 'WP 48291/2024');
    });

    test('3. Buyer Due Diligence Checklist Structure', () {
      const buyerItems = LegalNoticeRepositoryData.buyerChecklist;
      expect(buyerItems.length, greaterThanOrEqualTo(10));

      final ecItem = buyerItems.firstWhere((i) => i.id == 'b_3');
      expect(ecItem.title, contains('Encumbrance Certificate'));
      expect(ecItem.verificationAuthority, contains('Sub-Registrar'));

      final naItem = buyerItems.firstWhere((i) => i.id == 'b_7');
      expect(naItem.title, contains('Land Conversion (NA Order)'));
      expect(naItem.requiredDocument, contains('NA Conversion Order'));
    });

    test('4. Seller Legal Compliance Checklist Structure', () {
      const sellerItems = LegalNoticeRepositoryData.sellerChecklist;
      expect(sellerItems.length, greaterThanOrEqualTo(5));

      final titleItem = sellerItems.firstWhere((i) => i.id == 's_1');
      expect(titleItem.title, contains('Original Title Deeds'));

      final nocItem = sellerItems.firstWhere((i) => i.id == 's_6');
      expect(nocItem.title, contains('Co-Owners / Legal Heirs Consent'));
    });

    test('5. Legal Notice Types & Caution Alerts', () {
      for (final type in LegalNoticeType.values) {
        expect(type.title.isNotEmpty, isTrue);
        expect(type.icon, isNotNull);
        expect(type.accentColor, isNotNull);
      }
    });
  });
}
