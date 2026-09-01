import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';

void main() {
  group('DATABASE MIGRATION & ENUM CONSISTENCY MATRIX', () {
    test('1. Dart ListingStatus enum covers all canonical lifecycle states', () {
      final names = ListingStatus.values.map((e) => e.name).toSet();

      expect(names.contains('draft'), isTrue);
      expect(names.contains('submitted'), isTrue);
      expect(names.contains('underReview'), isTrue);
      expect(names.contains('approved'), isTrue);
      expect(names.contains('published'), isTrue);
      expect(names.contains('active'), isTrue);
      expect(names.contains('paused'), isTrue);
      expect(names.contains('rejected'), isTrue);
      expect(names.contains('sold'), isTrue);
      expect(names.contains('rented'), isTrue);
      expect(names.contains('leased'), isTrue);
      expect(names.contains('disputed'), isTrue);
      expect(names.contains('archived'), isTrue);
    });

    test('2. 00001_create_enum_types.sql defines complete listing_status values', () {
      final file = File('supabase/migrations/00001_create_enum_types.sql');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();

      // Canonical enum values required by RLS and business logic
      final expectedStatuses = [
        "'draft'",
        "'submitted'",
        "'pending_verification'",
        "'under_review'",
        "'changes_requested'",
        "'approved'",
        "'published'",
        "'active'",
        "'paused'",
        "'rejected'",
        "'sold'",
        "'rented'",
        "'leased'",
        "'disputed'",
        "'archived'",
      ];

      for (final status in expectedStatuses) {
        expect(content, contains(status), reason: 'Enum 00001 missing $status');
      }
    });

    test('3. Migration 00006 RLS literals are valid canonical enum members', () {
      final file = File('supabase/migrations/00006_owner_admin_rbac_properties_rls.sql');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains("status IN ('active', 'published')"));
    });

    test('4. Migration 00018 ensures forward-compatible enum consistency', () {
      final file = File('supabase/migrations/00018_ensure_complete_enum_types_consistency.sql');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains("ALTER TYPE public.listing_status ADD VALUE IF NOT EXISTS 'published'"));
      expect(content, contains("ALTER TYPE public.listing_status ADD VALUE IF NOT EXISTS 'approved'"));
    });

    test('5. Properties table RLS and triggers only use canonical listing_status values', () {
      final propertyMigrations = [
        '00003_create_properties_table.sql',
        '00006_owner_admin_rbac_properties_rls.sql',
        '00011_create_saved_property_searches_and_price_history.sql',
        '00016_enforce_database_authoritative_property_lifecycle.sql',
        '00017_scale_hardening_composite_indexes_and_media_derivatives.sql',
      ];

      final canonicalStatuses = {
        'draft',
        'submitted',
        'pending_verification',
        'under_review',
        'changes_requested',
        'approved',
        'published',
        'active',
        'paused',
        'rejected',
        'sold',
        'rented',
        'leased',
        'disputed',
        'archived',
      };

      for (final migName in propertyMigrations) {
        final file = File('supabase/migrations/$migName');
        expect(file.existsSync(), isTrue, reason: '$migName missing');
        final content = file.readAsStringSync();

        final matches = RegExp(r"(?:p\.)?status(?:::text)?\s+IN\s*\(([^)]+)\)", caseSensitive: false)
            .allMatches(content);

        for (final match in matches) {
          final inGroup = match.group(1)!;
          final literals = inGroup
              .split(',')
              .map((s) => s.replaceAll("'", "").trim().toLowerCase())
              .where((s) => s.isNotEmpty && !s.contains('select'));

          for (final literal in literals) {
            expect(
              canonicalStatuses.contains(literal),
              isTrue,
              reason: '$migName contains non-canonical status "$literal"',
            );
          }
        }
      }
    });
  });
}
