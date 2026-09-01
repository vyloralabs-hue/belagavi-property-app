import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/investment/presentation/localization/investment_localizations.dart';
import 'package:belagavi_property/features/investment/domain/entities/investment_entities.dart';

void main() {
  group('Phase 28 BELAGAVI PROPERTY LLP Investment Module Tests', () {
    test(
      'Four-Language Localization dictionary complete across all languages',
      () {
        const languages = InvestmentLanguage.values;

        final keysToVerify = [
          'title',
          'legalEntity',
          'subtitle',
          'projectSpecific',
          'projectSpecificDesc',
          'fundUtilisation',
          'fundUtilisationDesc',
          'profitSharing',
          'profitSharingDesc',
          'noGuaranteedReturns',
          'noGuaranteedReturnsDesc',
          'transparency',
          'transparencyDesc',
          'documents',
          'acknowledgement',
          'submitEnquiry',
          'legalDisclaimer',
          'governingLaw',
          'jurisdiction',
          'ack1',
          'ack2',
          'ack3',
          'ack4',
          'ack5',
          'ack6',
          'ack7',
        ];

        for (final lang in languages) {
          final loc = InvestmentLocalizations(lang);
          for (final key in keysToVerify) {
            final translated = loc.text(key);
            expect(
              translated,
              isNotEmpty,
              reason: 'Key $key in language ${lang.code} should not be empty',
            );
            expect(
              translated,
              isNot(equals(key)),
              reason: 'Key $key in language ${lang.code} should be translated',
            );
          }
        }
      },
    );

    test('Legal Entity Name strictly enforced as BELAGAVI PROPERTY LLP', () {
      final config = ComplianceContentConfig(updatedAt: DateTime.now());
      expect(config.legalEntityName, equals('BELAGAVI PROPERTY LLP'));

      for (final lang in InvestmentLanguage.values) {
        final loc = InvestmentLocalizations(lang);
        expect(loc.text('legalEntity'), isNotEmpty);
      }
    });

    test('Investment Language Notifier switches languages cleanly', () {
      final notifier = InvestmentLanguageNotifier();
      expect(notifier.currentLanguage, equals(InvestmentLanguage.english));

      notifier.setLanguage(InvestmentLanguage.hindi);
      expect(notifier.currentLanguage, equals(InvestmentLanguage.hindi));

      notifier.setLanguage(InvestmentLanguage.kannada);
      expect(notifier.currentLanguage, equals(InvestmentLanguage.kannada));

      notifier.setLanguage(InvestmentLanguage.marathi);
      expect(notifier.currentLanguage, equals(InvestmentLanguage.marathi));
    });

    test(
      'Legal Disclaimer includes No Guaranteed Returns warning across all languages',
      () {
        for (final lang in InvestmentLanguage.values) {
          final loc = InvestmentLocalizations(lang);
          final disclaimer = loc.text('legalDisclaimer');
          final paymentSafety = loc.text('paymentSafety');
          expect(disclaimer, isNotEmpty);
          expect(paymentSafety, isNotEmpty);
        }
      },
    );

    test(
      'InvestmentProjectEntity canAcceptEnquiries blocks paused or closed projects',
      () {
        final pausedProject = InvestmentProjectEntity(
          id: 'proj_1',
          name: 'Belagavi NA Plot Phase 1',
          location: 'Belagavi',
          propertyType: 'Plot',
          status: InvestmentProjectStatus.paused,
          description: 'NA Plot Project',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(pausedProject.canAcceptEnquiries, isFalse);

        final closedProject = InvestmentProjectEntity(
          id: 'proj_2',
          name: 'Belagavi NA Plot Phase 2',
          location: 'Belagavi',
          propertyType: 'Plot',
          status: InvestmentProjectStatus.closed,
          description: 'Closed Plot Project',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(closedProject.canAcceptEnquiries, isFalse);

        final openProject = InvestmentProjectEntity(
          id: 'proj_3',
          name: 'Belagavi Commercial Hub',
          location: 'Belagavi',
          propertyType: 'Commercial',
          status: InvestmentProjectStatus.open,
          description: 'Commercial Development',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(openProject.canAcceptEnquiries, isTrue);
      },
    );
  });
}
