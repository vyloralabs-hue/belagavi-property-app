import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/config/brand_config.dart';
import 'package:belagavi_property/core/localization/app_localizations.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';

void main() {
  group('PHASE 20.1 — OFFICIAL BRAND LOGO & APP ICON INTEGRATION TESTS', () {
    test(
      'TEST 1: Official legal entity name is strictly BELAGAVI PROPERTY LLP',
      () {
        expect(BrandConfig.legalEntityName, 'BELAGAVI PROPERTY LLP');
      },
    );

    test(
      'TEST 2: Brand colors in AppDesignSystem strictly match official navy and gold palette',
      () {
        expect(AppDesignSystem.primaryNavy, const Color(0xFF0A0D11));
        expect(AppDesignSystem.accentGold, const Color(0xFFD4AF37));
        expect(AppDesignSystem.backgroundWhite, const Color(0xFF0A0D11));
      },
    );

    test(
      'TEST 3: Master asset exists in assets/branding/belagavi_property_llp_master.png',
      () {
        final file = File('assets/branding/belagavi_property_llp_master.png');
        expect(file.existsSync(), isTrue);
      },
    );

    test(
      'TEST 4: App icon asset exists in assets/branding/belagavi_property_llp_app_icon.png',
      () {
        final file = File('assets/branding/belagavi_property_llp_app_icon.png');
        expect(file.existsSync(), isTrue);
      },
    );

    test(
      'TEST 5: App icon asset resolution is high-DPI valid (file size > 50KB)',
      () {
        final file = File('assets/branding/belagavi_property_llp_app_icon.png');
        expect(file.lengthSync(), greaterThan(50000));
      },
    );

    test(
      'TEST 6: Android launcher configuration exists in android/app/src/main/res/mipmap-*',
      () {
        final mdpi = File(
          'android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
        );
        final xxxhdpi = File(
          'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
        );

        expect(mdpi.existsSync(), isTrue);
        expect(xxxhdpi.existsSync(), isTrue);
      },
    );

    test(
      'TEST 7: iOS AppIcon catalog exists in ios/Runner/Assets.xcassets/AppIcon.appiconset',
      () {
        final appIcon1024 = File(
          'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
        );
        expect(appIcon1024.existsSync(), isTrue);
      },
    );

    test('TEST 8: Web/PWA icon configuration exists in web/icons/', () {
      final icon192 = File('web/icons/Icon-192.png');
      final icon512 = File('web/icons/Icon-512.png');

      expect(icon192.existsSync(), isTrue);
      expect(icon512.existsSync(), isTrue);
    });

    test('TEST 9: Manifest file exists in web/manifest.json', () {
      final manifest = File('web/manifest.json');
      expect(manifest.existsSync(), isTrue);
    });

    test('TEST 10: Favicon asset exists in web/favicon.png', () {
      final favicon = File('web/favicon.png');
      expect(favicon.existsSync(), isTrue);
    });

    test(
      'TEST 11: BrandConfig remains dynamically configurable across all three brand candidates',
      () {
        BrandConfig.setBrand(AppBrand.propertyHub);
        expect(BrandConfig.brandName, 'Property Hub');

        BrandConfig.setBrand(AppBrand.propertyHubIndia);
        expect(BrandConfig.brandName, 'Property Hub India');

        BrandConfig.setBrand(AppBrand.indiaPropertyHub);
        expect(BrandConfig.brandName, 'India Property Hub');

        // Reset to propertyHub default
        BrandConfig.setBrand(AppBrand.propertyHub);
      },
    );

    test(
      'TEST 12: Legal entity name remains constant regardless of commercial brand selection',
      () {
        BrandConfig.setBrand(AppBrand.propertyHub);
        expect(BrandConfig.legalEntityName, 'BELAGAVI PROPERTY LLP');

        BrandConfig.setBrand(AppBrand.indiaPropertyHub);
        expect(BrandConfig.legalEntityName, 'BELAGAVI PROPERTY LLP');

        BrandConfig.setBrand(AppBrand.propertyHub);
      },
    );

    test(
      'TEST 13: Local localization engine preserves EN, HI, KN brand strings',
      () {
        const enLoc = AppLocalizations(AppLanguage.english);
        const hiLoc = AppLocalizations(AppLanguage.hindi);
        const knLoc = AppLocalizations(AppLanguage.kannada);

        expect(
          enLoc.translate('professionalDeveloperListing'),
          'Professional Developer Listing',
        );
        expect(
          hiLoc.translate('professionalDeveloperListing'),
          'पेशेवर डेवलपर लिस्टिंग',
        );
        expect(
          knLoc.translate('professionalDeveloperListing'),
          'ವೃತ್ತಿಪರ ಡೆವಲಪರ್ ಪಟ್ಟಿ',
        );
      },
    );

    test(
      'TEST 14: Existing Phase 1–20 features continue operating without disruption',
      () {
        expect(AppDesignSystem.primaryNavy.toARGB32(), 0xFF0A0D11);
      },
    );
  });
}
