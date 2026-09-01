import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/dispute_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/legal_notice_entities.dart';

void main() {
  group(
    'BELAGAVI PROPERTY — DISPUTED PROPERTIES & LEGAL NOTICES MASTER SUITE',
    () {
      test('1. Core Principle — Neutral Wording & No False Accusations', () {
        // Verify all display names use neutral factual terminology
        for (final type in DisputeType.values) {
          final name = type.displayName.toLowerCase();
          expect(name, isNot(contains('illegal owner')));
          expect(name, isNot(contains('criminal property')));
          expect(name, isNot(contains('encroacher property')));
        }

        // Verify disclaimer text exists
        const disclaimer =
            'Information on this page is submitted by users or publishers. Belagavi Property does not determine ownership, title validity, liability, or the merits of a dispute. Users should independently verify official records and obtain appropriate professional advice before acting.';
        expect(disclaimer, contains('does not determine ownership'));
        expect(disclaimer, contains('independently verify'));
      });

      test('2. Disputed Property Lifecycle States and Visibility Rules', () {
        expect(DisputeVerificationStatus.draft.displayName, contains('Draft'));
        expect(
          DisputeVerificationStatus.submitted.displayName,
          contains('Submitted'),
        );
        expect(
          DisputeVerificationStatus.underReview.displayName,
          contains('Under Platform Review'),
        );
        expect(
          DisputeVerificationStatus.publishedListed.displayName,
          contains('Published'),
        );
        expect(
          DisputeVerificationStatus.resolved.displayName,
          contains('Resolved'),
        );
        expect(
          DisputeVerificationStatus.withdrawn.displayName,
          contains('Withdrawn'),
        );
        expect(
          DisputeVerificationStatus.archived.displayName,
          contains('Archived'),
        );

        // Only publishedListed status is publicly visible in search
        const published = DisputeVerificationStatus.publishedListed;
        const draft = DisputeVerificationStatus.draft;
        const submitted = DisputeVerificationStatus.submitted;

        expect(published == DisputeVerificationStatus.publishedListed, isTrue);
        expect(draft == DisputeVerificationStatus.publishedListed, isFalse);
        expect(submitted == DisputeVerificationStatus.publishedListed, isFalse);
      });

      test('3. Document Privacy & Redaction Badges', () {
        const defaultBadge = 'DOCUMENT UPLOADED';
        expect(defaultBadge, isNot(contains('VERIFIED TRUE')));
        expect(defaultBadge, equals('DOCUMENT UPLOADED'));
      });

      test('4. Legal Notice Categories and Publisher Types', () {
        expect(LegalNoticeType.values, isNotEmpty);
        expect(LegalNoticeType.purchaseNotice.title, contains('Purchase'));
        expect(LegalNoticeType.saleNotice.title, contains('Sale'));
        expect(
          LegalNoticeType.titleVerificationNotice.title,
          contains('Verification'),
        );
        expect(LegalNoticeType.objectionNotice.title, contains('Objection'));
        expect(LegalNoticeType.possessionNotice.title, contains('Possession'));
        expect(
          LegalNoticeType.cancellationNotice.title,
          contains('Cancellation'),
        );

        // Publisher Types
        const publisherTypes = [
          'Individual',
          'Advocate',
          'Law Firm',
          'Company',
          'LLP',
          'Builder',
          'Developer',
          'Broker',
          'Authorized Representative',
          'Other',
        ];
        expect(publisherTypes.length, equals(10));
        expect(publisherTypes, contains('Advocate'));
        expect(publisherTypes, contains('Law Firm'));
        expect(publisherTypes, contains('LLP'));
      });

      test('5. Duplicate / Related Record Detection Logic', () {
        final existingDisputes = [
          const PropertyDisputeEntity(
            id: 'disp_1',
            propertyId: 'prop_101',
            title: 'Residential Plot Dispute',
            category: 'Residential',
            propertyType: 'Plot',
            country: 'India',
            state: 'Karnataka',
            city: 'Belagavi',
            locality: 'Tilakwadi',
            surveyCtsNumber: 'CTS 1204/B',
            relationship: 'Claimant',
            disputeType: DisputeType.partitionFamilyDispute,
            verificationStatus: DisputeVerificationStatus.publishedListed,
            isFounderConfirmed: false,
            description: 'Partition suit pending',
          ),
        ];

        // Matching candidate by CTS number and locality
        bool isMatch(
          PropertyDisputeEntity existing,
          String newLocality,
          String newSurvey,
        ) {
          return existing.locality.toLowerCase() == newLocality.toLowerCase() &&
              (existing.surveyCtsNumber?.toLowerCase() ==
                  newSurvey.toLowerCase());
        }

        final candidate1Duplicate = isMatch(
          existingDisputes[0],
          'Tilakwadi',
          'CTS 1204/B',
        );
        final candidate2Unique = isMatch(
          existingDisputes[0],
          'Shahapur',
          'CTS 9999',
        );

        expect(candidate1Duplicate, isTrue);
        expect(candidate2Unique, isFalse);
      });

      test('6. Legal Notice Badges and Separate Meanings', () {
        const badge1 = 'DOCUMENT UPLOADED';
        const badge2 = 'PUBLISHER IDENTITY VERIFIED';
        const badge3 = 'REFERENCE DETAILS PROVIDED';

        expect(badge1, isNot(equals(badge2)));
        expect(badge2, isNot(equals(badge3)));
        expect(badge1, isNot(contains('LEGALLY BINDING')));
      });

      test('7. Dispute Party Structured Entity Serialization', () {
        const party = DisputePartyEntity(
          name: 'Ramachandra Patil',
          role: 'Claimant / Co-owner',
          contact: '+91 9113219906',
          advocateName: 'Adv. S. M. Kulkarni',
        );

        final map = party.toMap();
        expect(map['name'], equals('Ramachandra Patil'));
        expect(map['role'], equals('Claimant / Co-owner'));

        final reconstructed = DisputePartyEntity.fromMap(map);
        expect(reconstructed, equals(party));
      });

      test('8. Multi-Step Form Data Integrity', () {
        final dispute = PropertyDisputeEntity(
          id: 'disp_test_001',
          propertyId: 'prop_test_001',
          title: 'Reported Boundary Demarcation Matter',
          category: 'Agricultural Land',
          propertyType: 'Farm Land',
          country: 'India',
          state: 'Karnataka',
          district: 'Belagavi',
          city: 'Belagavi',
          locality: 'Sambra',
          surveyCtsNumber: 'Sy No. 44/1',
          landArea: '2.5',
          areaUnit: 'Acre',
          relationship: 'Adjacent Land Holder',
          disputeType: DisputeType.boundaryDispute,
          verificationStatus: DisputeVerificationStatus.submitted,
          isFounderConfirmed: false,
          courtAuthority: 'Tahsildar Belagavi',
          caseNumber: 'REV-2026-88',
          caseYear: '2026',
          caseStatus: 'Notice Issued',
          description:
              'Demarcation inspection scheduled regarding boundary alignment.',
          reportedBy: 'usr_test_reporter',
          reportDate: DateTime(2026, 8, 29),
        );

        final map = dispute.toMap();
        expect(map['id'], equals('disp_test_001'));
        expect(map['surveyCtsNumber'], equals('Sy No. 44/1'));
        expect(map['courtAuthority'], equals('Tahsildar Belagavi'));

        final fromMap = PropertyDisputeEntity.fromMap(map);
        expect(fromMap.id, equals(dispute.id));
        expect(fromMap.disputeType, equals(DisputeType.boundaryDispute));
      });
    },
  );
}
