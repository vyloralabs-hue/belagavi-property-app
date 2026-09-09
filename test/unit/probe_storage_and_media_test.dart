import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:belagavi_property/core/constants/env.dart';

String _generateUuidV4() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  values[6] = (values[6] & 0x0f) | 0x40; // version 4
  values[8] = (values[8] & 0x3f) | 0x80; // variant
  final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
}

void main() {
  test('test property and media insertion with UUID and anon key', () async {
    final supabase = SupabaseClient(
      EnvProd.supabaseUrl,
      EnvProd.supabaseAnonKey,
    );

    final testUuid = _generateUuidV4();
    print('Generated UUID: $testUuid');

    // Test querying existing profiles to find a valid profile id
    try {
      final profiles = await supabase.from('profiles').select('id, firebase_uid, full_name').limit(2);
      print('Profiles count: ${profiles.length}');
      if (profiles.isNotEmpty) {
        print('Sample profile: ${profiles.first}');
      }
    } catch (e) {
      print('Profiles select error: $e');
    }
  });
}
