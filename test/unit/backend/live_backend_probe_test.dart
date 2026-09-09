import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Probe live Supabase RLS for insertion', () async {
    final client = SupabaseClient(
      'https://fzgfgimscwrafnhahzlk.supabase.co',
      'sb_publishable_BqAkfODFgovvimGMZU3ytQ_T5_LeZGg',
    );

    // Probe 1: Try inserting a test profile
    print('\n[PROBE] Testing profile insert as anon...');
    try {
      final res = await client.from('profiles').insert({
        'firebase_uid': 'test_anon_fb_123',
        'full_name': 'Test Probe User',
        'phone_number': '+919999999999',
        'role': 'buyer',
      }).select();
      print('[PROBE] Profile insert succeeded: $res');
    } catch (e) {
      print('[PROBE] Profile insert blocked: $e');
    }

    // Probe 2: Try inserting a test property as anon
    print('\n[PROBE] Testing property insert as anon...');
    try {
      final res = await client.from('properties').insert({
        'title': 'Test Property',
        'owner_id': '00000000-0000-0000-0000-000000000000',
        'price': 5000000,
        'status': 'pending_verification',
        'category': 'residential',
        'type': 'apartment',
      }).select();
      print('[PROBE] Property insert succeeded: $res');
    } catch (e) {
      print('[PROBE] Property insert blocked: $e');
    }
  });

  test('Probe live Supabase geography tables', () async {
    final client = SupabaseClient(
      'https://fzgfgimscwrafnhahzlk.supabase.co',
      'sb_publishable_BqAkfODFgovvimGMZU3ytQ_T5_LeZGg',
    );

    final tables = [
      'countries',
      'states',
      'districts',
      'taluks',
      'cities',
      'localities',
      'areas',
      'location_aliases',
      'geo_countries',
      'geo_admin_level_1',
      'geo_admin_level_2',
      'geo_cities',
      'geo_localities',
      'geo_aliases',
    ];

    print('\n=== PROBING LIVE SUPABASE GEOGRAPHY TABLES ===');
    for (final t in tables) {
      try {
        final res = await client.from(t).select('id').limit(1);
        print('TABLE: $t => EXISTS (count: ${res.length})');
      } catch (e) {
        if (e.toString().contains('PGRST205') || e.toString().contains('42P01') || e.toString().contains('does not exist') || e.toString().contains('Could not find')) {
          print('TABLE: $t => MISSING');
        } else {
          print('TABLE: $t => ERROR: $e');
        }
      }
    }
  });
}
