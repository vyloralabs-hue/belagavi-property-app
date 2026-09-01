import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../../property/data/models/property_models.dart';
import '../../../property/domain/entities/property_entities.dart';
import '../../../property/utils/location_privacy_helper.dart';
import '../../domain/entities/search_entities.dart';
import '../models/search_models.dart';

import '../../utils/india_location_directory.dart';

abstract class PropertySearchRemoteDataSource {
  Future<SearchResultModel> executeSearch(SearchQueryEntity query);
  Future<List<String>> fetchSuggestions(String query);
}

@LazySingleton(as: PropertySearchRemoteDataSource)
class PropertySearchRemoteDataSourceImpl extends BaseRemoteDataSource
    implements PropertySearchRemoteDataSource {
  final SupabaseService _supabaseService;

  PropertySearchRemoteDataSourceImpl(this._supabaseService);

  // --- Public status values that are safe to show on category / search feeds ---
  static const List<String> _publicStatuses = [
    'active', // PostgreSQL listing_status enum valid live public value
  ];


  @override
  Future<SearchResultModel> executeSearch(SearchQueryEntity query) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return const SearchResultModel(
          properties: [],
          totalCount: 0,
          hasMore: false,
        );
      }

      // Supabase Live Query Layer — database-first, bounded, indexed
      var q = _supabaseService.from('properties').select();

      // ── Public visibility isolation ─────────────────────────────────────────
      // NEVER expose draft / submitted / pending / under_review / rejected /
      // on_hold / archived to public search feeds.
      // Use dbValue (snake_case) to match the PostgreSQL enum stored value.
      if (query.status == null) {
        q = q.inFilter('status', _publicStatuses);
      } else {
        q = q.eq('status', query.status!.dbValue);
      }

      // ── Normalize Location Inputs against canonical directory & aliases ──────
      final normState = query.state != null && query.state!.isNotEmpty
          ? IndiaLocationDirectory.normalizeStateName(query.state!)
          : null;
      final normCity = query.city != null && query.city!.isNotEmpty
          ? IndiaLocationDirectory.normalizeCityName(query.city!)
          : null;
      String? normLocality = query.locality != null && query.locality!.isNotEmpty
          ? IndiaLocationDirectory.normalizeLocalityName(query.locality!, normCity)
          : null;

      // ── City + Locality Parent Validation ────────────────────────────────────
      // If city and locality are both specified, ensure locality belongs to city.
      // e.g. Bengaluru + Tilakwadi -> clear invalid locality 'Tilakwadi'
      if (normCity != null && normCity.isNotEmpty && normLocality != null && normLocality.isNotEmpty) {
        final cityLocalities = IndiaLocationDirectory.getLocalitiesForCity(normCity);
        if (cityLocalities.isNotEmpty && !cityLocalities.contains(normLocality)) {
          // Check if locality belongs to a known different city
          final belongsToOtherCity = IndiaLocationDirectory.directoryEntries.any((entry) {
            final entryLoc = entry['name'] as String;
            final entryCity = entry['city'] as String;
            return entryLoc.toLowerCase() == normLocality!.toLowerCase() &&
                entryCity.toLowerCase() != normCity.toLowerCase();
          });
          if (belongsToOtherCity) {
            normLocality = null; // Clear incompatible child locality
          }
        }
      }

      // ── Location hierarchy filters (real indexed columns only) ──────────────
      if (normState != null && normState.isNotEmpty) q = q.eq('state', normState);
      if (query.district != null && query.district!.isNotEmpty) q = q.eq('district', query.district!);
      if (normCity != null && normCity.isNotEmpty) q = q.eq('city', normCity);
      if (normLocality != null && normLocality.isNotEmpty) q = q.eq('locality', normLocality);
      if (query.pincode != null && query.pincode!.isNotEmpty) q = q.eq('pincode', query.pincode!);



      // ── Taxonomy filters (use dbValue to match DB snake_case enum) ──────────
      if (query.category != null) q = q.eq('category', query.category!.dbValue);
      if (query.type != null) q = q.eq('type', query.type!.dbValue);
      // NOTE: 'listing_purpose' column does NOT exist — purpose is stored in
      // the 'features' JSONB column. Skip this filter for now.

      // ── Price filters ────────────────────────────────────────────────────────
      if (query.minPrice != null) q = q.gte('price', query.minPrice!);
      if (query.maxPrice != null) q = q.lte('price', query.maxPrice!);

      // ── Area filters — use carpet_area (real column; built_up_area does NOT exist) ─
      if (query.minArea != null) q = q.gte('carpet_area', query.minArea!);
      if (query.maxArea != null) q = q.lte('carpet_area', query.maxArea!);

      // ── Bedroom filters ──────────────────────────────────────────────────────
      if (query.minBedrooms != null) q = q.gte('bedrooms', query.minBedrooms!);
      if (query.maxBedrooms != null) q = q.lte('bedrooms', query.maxBedrooms!);

      // NOTE: 'project_id' and 'builder_id' columns do NOT exist — removed.

      // ── Verification filter ──────────────────────────────────────────────────
      if (query.isVerifiedOnly == true) q = q.eq('verification_status', 'verified');

      // ── Free-text search (real columns only) ─────────────────────────────────
      if (query.rawQuery != null && query.rawQuery!.isNotEmpty) {
        q = q.or(
          'title.ilike.%${query.rawQuery}%,'
          'locality.ilike.%${query.rawQuery}%,'
          'city.ilike.%${query.rawQuery}%,'
          'district.ilike.%${query.rawQuery}%,'
          'state.ilike.%${query.rawQuery}%,'
          'pincode.ilike.%${query.rawQuery}%,'
          'description.ilike.%${query.rawQuery}%',
        );
      }

      // ── Sort order ───────────────────────────────────────────────────────────
      dynamic finalQ;
      switch (query.sortBy) {
        case 'price_asc':
          finalQ = q.order('price', ascending: true);
        case 'price_desc':
          finalQ = q.order('price', ascending: false);
        case 'area_desc':
          // Use carpet_area (real column) for area sorting
          finalQ = q.order('carpet_area', ascending: false);
        default:
          finalQ = q.order('created_at', ascending: false);
      }

      // ── Paged bounded query — NEVER unbounded ────────────────────────────────
      final response = await (finalQ as dynamic).range(query.offset, query.offset + query.limit - 1);
      final rawList = (response as List).map((json) => PropertyModel.fromJson(json)).toList();

      // ── Accurate totalCount: separate count query (real columns only) ────────
      int totalCount = rawList.length;
      try {
        var countQ = _supabaseService.from('properties').select('id');
        if (query.status == null) {
          countQ = countQ.inFilter('status', _publicStatuses);
        } else {
          countQ = countQ.eq('status', query.status!.dbValue);
        }
        if (query.state != null && query.state!.isNotEmpty) countQ = countQ.eq('state', query.state!);
        if (query.district != null && query.district!.isNotEmpty) countQ = countQ.eq('district', query.district!);
        if (query.city != null && query.city!.isNotEmpty) countQ = countQ.eq('city', query.city!);
        if (query.locality != null && query.locality!.isNotEmpty) countQ = countQ.ilike('locality', '%${query.locality}%');
        if (query.pincode != null && query.pincode!.isNotEmpty) countQ = countQ.eq('pincode', query.pincode!);
        if (query.category != null) countQ = countQ.eq('category', query.category!.dbValue);
        if (query.minPrice != null) countQ = countQ.gte('price', query.minPrice!);
        if (query.maxPrice != null) countQ = countQ.lte('price', query.maxPrice!);
        if (query.rawQuery != null && query.rawQuery!.isNotEmpty) {
          countQ = countQ.or(
            'title.ilike.%${query.rawQuery}%,'
            'locality.ilike.%${query.rawQuery}%,'
            'city.ilike.%${query.rawQuery}%,'
            'district.ilike.%${query.rawQuery}%,'
            'state.ilike.%${query.rawQuery}%,'
            'pincode.ilike.%${query.rawQuery}%',
          );
        }
        final countResponse = await countQ;
        totalCount = (countResponse as List).length;
      } catch (_) {
        // Fallback: estimate from page result
        totalCount = rawList.length >= query.limit
            ? query.offset + rawList.length + 1
            : query.offset + rawList.length;
      }

      final publicList = rawList
          .map((m) => LocationPrivacyHelper.toPublicPropertyModel(m))
          .toList();

      return SearchResultModel(
        properties: publicList,
        totalCount: totalCount,
        hasMore: rawList.length >= query.limit,
      );
    });
  }

  @override
  Future<List<String>> fetchSuggestions(String query) async {
    return safeQuery(() async {
      if (query.isEmpty) return const [];
      if (!_supabaseService.isInitialized) {
        return const [];
      }

      // Try the localities lookup table first
      try {
        final response = await _supabaseService
            .from('localities')
            .select('name')
            .ilike('name', '%$query%')
            .limit(5);
        final locSuggestions = (response as List).map((json) => json['name'].toString()).toList();
        if (locSuggestions.isNotEmpty) return locSuggestions;
      } catch (_) {
        // Localities table may not exist — fall through to property city/locality search
      }

      // Fallback: search from published property city/locality columns
      final response = await _supabaseService
          .from('properties')
          .select('city, locality')
          .inFilter('status', _publicStatuses)
          .or('city.ilike.%$query%,locality.ilike.%$query%')
          .limit(10);

      final seen = <String>{};
      final suggestions = <String>[];
      for (final row in (response as List)) {
        for (final col in ['locality', 'city']) {
          final val = row[col] as String?;
          if (val != null && val.isNotEmpty && val.toLowerCase().contains(query.toLowerCase()) && seen.add(val)) {
            suggestions.add(val);
          }
        }
      }
      return suggestions.take(5).toList();
    });
  }
}
