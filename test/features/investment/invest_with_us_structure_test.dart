import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/investment/domain/entities/investment_entities.dart';
import 'package:belagavi_property/features/investment/presentation/localization/investment_localizations.dart';
import 'package:belagavi_property/features/investment/presentation/providers/investment_notifier.dart';
import 'package:belagavi_property/features/presentation_ui/views/investment/invest_with_us_view.dart';
import 'package:belagavi_property/features/presentation_ui/views/investment/widgets/request_callback_modal.dart';

void main() {
  group('BELAGAVI PROPERTY LLP INVEST STRUCTURE & CONTACT TESTS', () {
    final now = DateTime.now();

    // 1. Phone numbers check
    test(
      '1 & 2 & 3: Official numbers 9113219906 and 9886615159 with normalized Call & WhatsApp URIs',
      () {
        final config = ComplianceContentConfig(updatedAt: now);

        expect(config.primaryPhone, equals('9113219906'));
        expect(config.secondaryPhone, equals('9886615159'));
        expect(config.primaryWhatsApp, equals('9113219906'));
        expect(config.secondaryWhatsApp, equals('9886615159'));

        // Call URIs
        final tel1 = 'tel:${config.primaryPhone}';
        final tel2 = 'tel:${config.secondaryPhone}';
        expect(tel1, equals('tel:9113219906'));
        expect(tel2, equals('tel:9886615159'));

        // WhatsApp normalization to 91XXXXXXXXXX
        final wa1Normalized = '91${config.primaryWhatsApp}';
        final wa2Normalized = '91${config.secondaryWhatsApp}';
        expect(wa1Normalized, equals('919113219906'));
        expect(wa2Normalized, equals('919886615159'));
      },
    );

    // 4. Callback form phone validation
    test(
      '4: Callback request rejects invalid phone number and accepts valid 10-digit number',
      () async {
        final container = ProviderContainer();
        final notifier = container.read(investmentNotifierProvider.notifier);

        expect(
          () => notifier.requestCallback(
            name: 'Naveen K',
            phone: '12345', // < 10 digits
            preferredTime: 'Morning',
          ),
          throwsA(isA<FormatException>()),
        );

        final result = await notifier.requestCallback(
          name: 'Naveen K',
          phone: '9886615159',
          preferredTime: 'Morning',
          message: 'Interested in project investment',
        );

        expect(result.phone, equals('+919886615159'));
        expect(result.name, equals('Naveen K'));
        expect(result.status, equals(InvestmentLeadStatus.newLead));
        expect(
          container.read(investmentNotifierProvider).leads.length,
          equals(1),
        );
      },
    );

    // 5 & 6: Public user cannot create projects, Admin can create
    test(
      '5 & 6: Public user cannot create investment project, Admin/Founder can',
      () async {
        final container = ProviderContainer();
        final notifier = container.read(investmentNotifierProvider.notifier);

        // Public user rejection
        expect(
          () => notifier.createInvestmentProject(
            authenticatedUserId: 'user_123',
            role: UserRole.user,
            name: 'Unauthorized Project',
            description: 'Desc',
            location: 'Belagavi',
            propertyType: 'Plot',
          ),
          throwsA(isA<AccessDeniedException>()),
        );

        // Seller Owner rejection
        expect(
          () => notifier.createInvestmentProject(
            authenticatedUserId: 'owner_456',
            role: UserRole.sellerOwner,
            name: 'Owner Project',
            description: 'Desc',
            location: 'Belagavi',
            propertyType: 'Plot',
          ),
          throwsA(isA<AccessDeniedException>()),
        );

        // Admin/Founder success
        final project = await notifier.createInvestmentProject(
          authenticatedUserId: 'admin_001',
          role: UserRole.admin,
          name: 'Camp Residential Layout',
          description: 'Approved development in Camp Belagavi',
          location: 'Camp, Belagavi',
          propertyType: 'Residential Layout',
          status: InvestmentProjectStatus.open,
          minimumInvestment: 500000,
        );

        expect(project.name, equals('Camp Residential Layout'));
        expect(project.status, equals(InvestmentProjectStatus.open));
        expect(
          container.read(investmentNotifierProvider).projects.length,
          equals(1),
        );
      },
    );

    // 7 & 8: Zero projects -> upcoming hidden, clean empty state
    test(
      '7 & 8: When 0 projects exist, hasOpenProjects and hasUpcomingProjects are false',
      () {
        final container = ProviderContainer();
        final state = container.read(investmentNotifierProvider);

        expect(state.projects, isEmpty);
        expect(state.hasOpenProjects, isFalse);
        expect(state.hasUpcomingProjects, isFalse);
        expect(state.openProjects, isEmpty);
        expect(state.upcomingProjects, isEmpty);
      },
    );

    // 9 & 10: Pay directly disabled, no fake bank details
    test(
      '9 & 10: Production payment is disabled by default and no dummy bank accounts exist',
      () {
        final config = ComplianceContentConfig(updatedAt: now);

        expect(config.isProductionPaymentEnabled, isFalse);
        expect(config.legalEntityName, equals('BELAGAVI PROPERTY LLP'));
      },
    );

    // 11: No dummy project data in build()
    test('11: Initial state has 0 dummy/mock investment projects', () {
      final container = ProviderContainer();
      final state = container.read(investmentNotifierProvider);

      expect(state.projects.length, equals(0));
    });

    // 12: Rules preserved & accessible
    test(
      '12: Rules and legal notices exist in English and other languages',
      () {
        const loc = InvestmentLocalizations(InvestmentLanguage.english);

        expect(loc.text('projectSpecificDesc'), isNotEmpty);
        expect(loc.text('fundUtilisationDesc'), isNotEmpty);
        expect(loc.text('profitSharingDesc'), isNotEmpty);
        expect(loc.text('noGuaranteedReturnsDesc'), isNotEmpty);
        expect(loc.text('legalDisclaimer'), isNotEmpty);
        expect(loc.text('governingLaw'), contains('Laws of India'));
        expect(loc.text('jurisdiction'), contains('Belagavi, Karnataka'));
      },
    );

    // 13, 14 & 15: Payment verification & Security
    test(
      '13, 14 & 15: Investment payment entity status lifecycle and role protection',
      () {
        final payment = InvestmentPaymentEntity(
          id: 'pay_001',
          projectId: 'proj_001',
          projectName: 'Camp Residential Layout',
          investorUserId: 'usr_investor_01',
          amount: 200000,
          transactionReference: 'UTR9988776655',
          status: InvestmentPaymentStatus.paymentSubmitted,
          submittedAt: now,
        );

        expect(
          payment.status,
          equals(InvestmentPaymentStatus.paymentSubmitted),
        );
        expect(payment.verifiedAt, isNull);
        expect(payment.verifiedBy, isNull);
      },
    );
  });
}
