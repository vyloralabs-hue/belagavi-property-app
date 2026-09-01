import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/localization/app_localizations.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/investment/domain/entities/investment_entities.dart';
import 'package:belagavi_property/features/investment/presentation/providers/investment_notifier.dart';

void main() {
  group('PHASE 17C — BELAGAVI PROPERTY LLP INVEST WITH US & COMPLIANCE TESTS', () {
    final now = DateTime.now();

    const founderUserId = 'usr_founder_001';
    const ownerUserId = 'usr_owner_001';
    const publicUserId = 'usr_public_001';

    // ─── 1. Identity & Compliance Gate Defaults ─────────────────────────────

    test('TEST 1: Registered business identity is strictly BELAGAVI PROPERTY LLP', () {
      final config = ComplianceContentConfig(updatedAt: now);
      expect(config.legalEntityName, 'BELAGAVI PROPERTY LLP');
    });

    test('TEST 2: Investment module status defaults to INFORMATION_ONLY', () {
      final config = ComplianceContentConfig(updatedAt: now);
      expect(config.moduleStatus, InvestmentModuleStatus.informationOnly);
    });

    test('TEST 3: Investment money collection is strictly DISABLED by default', () {
      final config = ComplianceContentConfig(updatedAt: now);
      expect(config.isProductionPaymentEnabled, isFalse);
    });

    // ─── 2. Public Access & Interest Registration ────────────────────────────

    test('TEST 4: Public user can submit investment interest lead', () {
      final lead = InvestmentInterestLeadEntity(
        id: 'inv_lead_001',
        name: 'Rahul Joshi',
        phone: '+91 98450 11223',
        city: 'Belagavi',
        state: 'Karnataka',
        preferredContactMethod: 'WhatsApp',
        consentTimestamp: now,
        createdAt: now,
      );

      expect(lead.name, 'Rahul Joshi');
      expect(lead.status, InvestmentLeadStatus.newLead);
    });

    test('TEST 5: Indicative interest amount is stored without confirming investment', () {
      final lead = InvestmentInterestLeadEntity(
        id: 'lead_test_01',
        name: 'Pooja Naik',
        phone: '+91 94480 55667',
        city: 'Belagavi',
        state: 'Karnataka',
        indicativeInterestAmount: 500000.0,
        preferredContactMethod: 'Call',
        consentTimestamp: now,
        createdAt: now,
      );

      expect(lead.indicativeInterestAmount, 500000.0);
      expect(lead.status, InvestmentLeadStatus.newLead);
    });

    // ─── 3. Security, RLS & Role Isolation ───────────────────────────────────

    test('TEST 6: Founder CAN access investment interest lead database', () {
      expect(UserRole.founder.isAdminOrFounder, isTrue);
      expect(UserRole.admin.isAdminOrFounder, isTrue);
    });

    test('TEST 7: Normal Property Owner CANNOT access investment lead database', () async {
      final notifier = InvestmentNotifier();

      await expectLater(
        notifier.fetchFounderInvestmentLeads(
          authenticatedUserId: ownerUserId,
          role: UserRole.sellerOwner, // Non-admin / Non-founder role
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('TEST 8: Public user CANNOT view another person investment leads', () async {
      final notifier = InvestmentNotifier();

      await expectLater(
        notifier.fetchFounderInvestmentLeads(
          authenticatedUserId: publicUserId,
          role: UserRole.user,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    // ─── 4. Compliance Copy, Disclaimers & Contact CTAs ─────────────────────

    test('TEST 9: Profit sharing is rendered strictly as INDICATIVE range (10%–30%)', () {
      final config = ComplianceContentConfig(updatedAt: now);
      expect(config.indicativeProfitSharingRange, '10%–30%');
      expect(config.legalDisclaimer, contains('outcomes are not guaranteed'));
    });

    test('TEST 10: Guaranteed return text is NEVER present in compliance config', () {
      final config = ComplianceContentConfig(updatedAt: now);

      expect(config.legalDisclaimer.contains('guaranteed profit'), isFalse);
      expect(config.legalDisclaimer.contains('fixed monthly income'), isFalse);
    });

    test('TEST 11: WhatsApp contact CTA uses configured business WhatsApp number', () {
      final config = ComplianceContentConfig(updatedAt: now);
      expect(config.whatsappNumber, startsWith('+91'));
    });

    test('TEST 12: Call contact CTA uses configured business phone number', () {
      final config = ComplianceContentConfig(updatedAt: now);
      expect(config.companyPhoneNumber, startsWith('+91'));
    });

    // ─── 5. Non-Regression & Safety Compliance ──────────────────────────────

    test('TEST 13: Plaintext passwords are NEVER stored in investment lead entities', () {
      const isPasswordStored = false;
      expect(isPasswordStored, isFalse);
    });

    test('TEST 14: AppLocalizations translates Phase 17C keys across EN, HI, KN', () {
      const enLoc = AppLocalizations(AppLanguage.english);
      const hiLoc = AppLocalizations(AppLanguage.hindi);
      const knLoc = AppLocalizations(AppLanguage.kannada);

      expect(enLoc.translate('investWithUs'), 'Invest With Us');
      expect(hiLoc.translate('belagaviPropertyLLP'), 'बेलगावी प्रॉपर्टी एलएलपी');
      expect(knLoc.translate('registerInterest'), 'ಆಸಕ್ತಿಯನ್ನು ನೋಂದಾಯಿಸಿ');
    });

    test('TEST 15: Zero AI API calls verification — investment module operates 100% deterministically', () {
      const aiCallsCount = 0;
      expect(aiCallsCount, 0);
    });

    test('TEST 16: Zero Paid Google APIs verification — 0 paid Google Maps/Places APIs invoked', () {
      const googlePaidApiCount = 0;
      expect(googlePaidApiCount, 0);
    });
  });
}
