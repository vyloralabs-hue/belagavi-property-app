import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  const supabaseUrl = 'https://fzgfgimscwrafnhahzlk.supabase.co';
  const supabaseAnonKey = 'sb_publishable_BqAkfODFgovvimGMZU3ytQ_T5_LeZGg';

  late SupabaseClient client;

  setUpAll(() {
    client = SupabaseClient(supabaseUrl, supabaseAnonKey);
  });

  group('TASK 1 & TASK 12: Backend Column Privacy & Isolation Tests', () {
    test('Public buyer querying properties_public receives sanitized address and no contacts', () async {
      final res = await client.from('properties_public').select().limit(5);
      expect(res, isA<List>());

      for (final item in (res as List)) {
        final map = item as Map<String, dynamic>;
        // 1. Raw exact address must be empty string
        expect(map['address'], equals(''), reason: 'Address must be empty in public view');
        // 2. Pincode must be empty string
        expect(map['pincode'], equals(''), reason: 'Pincode must be empty in public view');
        // 3. Locality / city must be present for discovery
        expect(map['locality'], isNotNull);
        expect(map['city'], isNotNull);

        // 4. Features must NOT contain private owner fields
        final features = map['features'] as Map<String, dynamic>? ?? {};
        expect(features.containsKey('ownerPhone'), isFalse);
        expect(features.containsKey('ownerEmail'), isFalse);
        expect(features.containsKey('ownerWhatsApp'), isFalse);
        expect(features.containsKey('exactAddress'), isFalse);
      }
    });

    test('get_public_properties RPC returns sanitized results', () async {
      final res = await client.rpc('get_public_properties', params: {
        'p_limit': 5,
        'p_offset': 0,
      });
      expect(res, isA<List>());

      for (final item in (res as List)) {
        final map = item as Map<String, dynamic>;
        expect(map['address'], equals(''));
        expect(map['pincode'], equals(''));
        final features = map['features'] as Map<String, dynamic>? ?? {};
        expect(features.containsKey('ownerPhone'), isFalse);
        expect(features.containsKey('ownerEmail'), isFalse);
        expect(features.containsKey('ownerWhatsApp'), isFalse);
      }
    });
  });

  group('TASK 2: Commercial Day-1 Server-Side Enforcement Tests', () {
    test('Unentitled user attempting to create active commercial property is blocked by DB trigger', () async {
      bool caught = false;
      try {
        await client.from('properties').insert({
          'owner_id': '00000000-0000-0000-0000-000000000001',
          'title': 'Test Commercial Complex Bypass Attempt',
          'description': 'Malicious attempt to publish commercial property without plan',
          'category': 'commercial',
          'type': 'commercial_office',
          'status': 'active',
          'price': 15000000,
          'locality': 'Tilakwadi',
          'city': 'Belagavi',
          'state': 'Karnataka',
          'district': 'Belagavi',
          'taluk': 'Belagavi',
          'address': 'Private Road 10',
          'pincode': '590006',
        }).select();
      } catch (e) {
        caught = true;
        // Either RLS or our trigger P0002 blocks this
        expect(
          e.toString().contains('P0002') || 
          e.toString().contains('commercial') || 
          e.toString().contains('violates row-level security policy') ||
          e.toString().contains('policy'),
          isTrue,
        );
      }
      expect(caught, isTrue, reason: 'Commercial publish must be strictly blocked by server');
    });
  });

  group('TASK 8: Normal Property / Survey Watch Paid From First', () {
    test('Unentitled user cannot create property watch (trigger trg_check_property_watch_entitlement)', () async {
      bool caught = false;
      try {
        await client.from('property_watches').insert({
          'profile_id': '00000000-0000-0000-0000-000000000001',
          'watch_name': 'Unauthorized Survey Watch',
          'relationship_type': 'prospective_buyer',
          'country': 'India',
          'state': 'Karnataka',
          'district': 'Belagavi',
          'taluk': 'Belagavi',
          'city_or_village': 'Belagavi',
          'locality': 'Tilakwadi',
          'survey_number': '1234',
        }).select();
      } catch (e) {
        caught = true;
        expect(
          e.toString().contains('P0001') || 
          e.toString().contains('entitlement') || 
          e.toString().contains('violates row-level security policy') ||
          e.toString().contains('42501'),
          isTrue,
        );
      }
      expect(caught, isTrue, reason: 'Property watch without active entitlement must be rejected by DB');
    });
  });

  group('TASK 10: Legal Notices and Dispute Listings Expiry & Retention', () {
    test('Public query on legal_notices only returns non-expired published records', () async {
      final res = await client.from('legal_notices').select().eq('status', 'published');
      expect(res, isA<List>());

      final now = DateTime.now();
      for (final item in (res as List)) {
        final map = item as Map<String, dynamic>;
        if (map['public_until'] != null) {
          final until = DateTime.parse(map['public_until'] as String);
          expect(until.isAfter(now) || until.isAtSameMomentAs(now), isTrue,
              reason: 'Public query must never return expired legal notices');
        }
      }
    });

    test('Pricing Plans Catalog contains 19 official V1 plans', () async {
      final res = await client.from('pricing_plans').select().eq('is_active', true);
      expect(res, isA<List>());
      expect((res as List).length, equals(19));
    });
  });
}
