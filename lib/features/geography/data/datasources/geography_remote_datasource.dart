import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/backend/supabase_service.dart';
import '../models/geography_models.dart';

abstract class GeographyRemoteDataSource {
  Future<List<CountryModel>> fetchCountries();
  Future<List<StateModel>> fetchStates(String countryCode);
  Future<List<DistrictModel>> fetchDistricts(String stateId);
  Future<List<TalukModel>> fetchTaluks(String districtId);
  Future<List<CityModel>> fetchCities(String talukId);
  Future<List<LocalityModel>> fetchLocalities(String cityId);
  Future<List<AreaModel>> fetchAreas(String localityId);
  Future<LocalityModel?> fetchLocalityByPincode(String pincode);
  Future<List<LocalityModel>> searchLocalities(String query);
}

@LazySingleton(as: GeographyRemoteDataSource)
class GeographyRemoteDataSourceImpl extends BaseRemoteDataSource
    implements GeographyRemoteDataSource {
  final SupabaseService _supabaseService;

  GeographyRemoteDataSourceImpl(this._supabaseService);

  @override
  Future<List<CountryModel>> fetchCountries() async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return _mockCountries;
      }
      final response = await _supabaseService
          .from('countries')
          .select()
          .order('name');
      return (response as List).map((json) => CountryModel.fromJson(json)).toList();
    });
  }

  @override
  Future<List<StateModel>> fetchStates(String countryCode) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return _mockStates.where((s) => s.countryCode == countryCode).toList();
      }
      final response = await _supabaseService
          .from('states')
          .select()
          .eq('country_code', countryCode)
          .order('name');
      return (response as List).map((json) => StateModel.fromJson(json)).toList();
    });
  }

  @override
  Future<List<DistrictModel>> fetchDistricts(String stateId) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return _mockDistricts.where((d) => d.stateId == stateId).toList();
      }
      final response = await _supabaseService
          .from('districts')
          .select()
          .eq('state_id', stateId)
          .order('name');
      return (response as List).map((json) => DistrictModel.fromJson(json)).toList();
    });
  }

  @override
  Future<List<TalukModel>> fetchTaluks(String districtId) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return _mockTaluks.where((t) => t.districtId == districtId).toList();
      }
      final response = await _supabaseService
          .from('taluks')
          .select()
          .eq('district_id', districtId)
          .order('name');
      return (response as List).map((json) => TalukModel.fromJson(json)).toList();
    });
  }

  @override
  Future<List<CityModel>> fetchCities(String talukId) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return _mockCities.where((c) => c.talukId == talukId).toList();
      }
      final response = await _supabaseService
          .from('cities')
          .select()
          .eq('taluk_id', talukId)
          .order('name');
      return (response as List).map((json) => CityModel.fromJson(json)).toList();
    });
  }

  @override
  Future<List<LocalityModel>> fetchLocalities(String cityId) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return _mockLocalities.where((l) => l.cityId == cityId).toList();
      }
      final response = await _supabaseService
          .from('localities')
          .select()
          .eq('city_id', cityId)
          .order('name');
      return (response as List).map((json) => LocalityModel.fromJson(json)).toList();
    });
  }

  @override
  Future<List<AreaModel>> fetchAreas(String localityId) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return _mockAreas.where((a) => a.localityId == localityId).toList();
      }
      final response = await _supabaseService
          .from('areas')
          .select()
          .eq('locality_id', localityId)
          .order('name');
      return (response as List).map((json) => AreaModel.fromJson(json)).toList();
    });
  }

  @override
  Future<LocalityModel?> fetchLocalityByPincode(String pincode) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        final matches = _mockLocalities.where((loc) => loc.pincode == pincode).toList();
        return matches.isNotEmpty ? matches.first : null;
      }
      final response = await _supabaseService
          .from('localities')
          .select()
          .eq('pincode', pincode)
          .maybeSingle();
      return response != null ? LocalityModel.fromJson(response) : null;
    });
  }

  @override
  Future<List<LocalityModel>> searchLocalities(String query) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return _mockLocalities
            .where((loc) => loc.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      final response = await _supabaseService
          .from('localities')
          .select()
          .ilike('name', '%$query%')
          .limit(20);
      return (response as List).map((json) => LocalityModel.fromJson(json)).toList();
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Production Mock Fallback Datasets
  // Covers India, USA, UK, UAE, Singapore, Australia for testing worldwide flow
  // ───────────────────────────────────────────────────────────────────────────

  static const _mockCountries = [
    CountryModel(code: 'IN', name: 'India', dialCode: '+91', currencyCode: 'INR', currencySymbol: '₹'),
    CountryModel(code: 'US', name: 'United States', dialCode: '+1', currencyCode: 'USD', currencySymbol: '\$'),
    CountryModel(code: 'GB', name: 'United Kingdom', dialCode: '+44', currencyCode: 'GBP', currencySymbol: '£'),
    CountryModel(code: 'AE', name: 'United Arab Emirates', dialCode: '+971', currencyCode: 'AED', currencySymbol: 'AED'),
    CountryModel(code: 'SG', name: 'Singapore', dialCode: '+65', currencyCode: 'SGD', currencySymbol: 'S\$'),
    CountryModel(code: 'AU', name: 'Australia', dialCode: '+61', currencyCode: 'AUD', currencySymbol: 'A\$'),
    CountryModel(code: 'CA', name: 'Canada', dialCode: '+1', currencyCode: 'CAD', currencySymbol: 'C\$'),
  ];

  static const _mockStates = [
    // India
    StateModel(id: 'st_ka', countryCode: 'IN', name: 'Karnataka', code: 'KA'),
    StateModel(id: 'st_mh', countryCode: 'IN', name: 'Maharashtra', code: 'MH'),
    StateModel(id: 'st_ga', countryCode: 'IN', name: 'Goa', code: 'GA'),
    StateModel(id: 'st_tn', countryCode: 'IN', name: 'Tamil Nadu', code: 'TN'),
    StateModel(id: 'st_dl', countryCode: 'IN', name: 'Delhi', code: 'DL', isUnionTerritory: true),
    StateModel(id: 'st_ts', countryCode: 'IN', name: 'Telangana', code: 'TS'),
    StateModel(id: 'st_gj', countryCode: 'IN', name: 'Gujarat', code: 'GJ'),
    StateModel(id: 'st_rj', countryCode: 'IN', name: 'Rajasthan', code: 'RJ'),
    // USA
    StateModel(id: 'st_us_ca', countryCode: 'US', name: 'California', code: 'CA'),
    StateModel(id: 'st_us_ny', countryCode: 'US', name: 'New York', code: 'NY'),
    StateModel(id: 'st_us_tx', countryCode: 'US', name: 'Texas', code: 'TX'),
    StateModel(id: 'st_us_fl', countryCode: 'US', name: 'Florida', code: 'FL'),
    // UK
    StateModel(id: 'st_gb_eng', countryCode: 'GB', name: 'England', code: 'ENG'),
    StateModel(id: 'st_gb_sco', countryCode: 'GB', name: 'Scotland', code: 'SCO'),
    // UAE
    StateModel(id: 'st_ae_dxb', countryCode: 'AE', name: 'Dubai', code: 'DXB'),
    StateModel(id: 'st_ae_auh', countryCode: 'AE', name: 'Abu Dhabi', code: 'AUH'),
  ];

  static const _mockDistricts = [
    // Karnataka
    DistrictModel(id: 'dis_belagavi', stateId: 'st_ka', name: 'Belagavi', stateCode: 'KA'),
    DistrictModel(id: 'dis_dharwad', stateId: 'st_ka', name: 'Dharwad', stateCode: 'KA'),
    DistrictModel(id: 'dis_bagalkot', stateId: 'st_ka', name: 'Bagalkot', stateCode: 'KA'),
    DistrictModel(id: 'dis_hubli', stateId: 'st_ka', name: 'Dharwad (Hubli)', stateCode: 'KA'),
    DistrictModel(id: 'dis_bangalore', stateId: 'st_ka', name: 'Bangalore Urban', stateCode: 'KA'),
    DistrictModel(id: 'dis_mysore', stateId: 'st_ka', name: 'Mysore', stateCode: 'KA'),
    // Maharashtra
    DistrictModel(id: 'dis_mumbai', stateId: 'st_mh', name: 'Mumbai', stateCode: 'MH'),
    DistrictModel(id: 'dis_pune', stateId: 'st_mh', name: 'Pune', stateCode: 'MH'),
    DistrictModel(id: 'dis_nashik', stateId: 'st_mh', name: 'Nashik', stateCode: 'MH'),
    // USA California
    DistrictModel(id: 'dis_la_county', stateId: 'st_us_ca', name: 'Los Angeles County', stateCode: 'CA'),
    DistrictModel(id: 'dis_sf_county', stateId: 'st_us_ca', name: 'San Francisco County', stateCode: 'CA'),
    // UK England
    DistrictModel(id: 'dis_greater_london', stateId: 'st_gb_eng', name: 'Greater London', stateCode: 'ENG'),
    DistrictModel(id: 'dis_manchester', stateId: 'st_gb_eng', name: 'Greater Manchester', stateCode: 'ENG'),
  ];

  static const _mockTaluks = [
    // Belagavi District
    TalukModel(id: 'tlk_belagavi', districtId: 'dis_belagavi', name: 'Belagavi'),
    TalukModel(id: 'tlk_chikodi', districtId: 'dis_belagavi', name: 'Chikodi'),
    TalukModel(id: 'tlk_gokak', districtId: 'dis_belagavi', name: 'Gokak'),
    TalukModel(id: 'tlk_athani', districtId: 'dis_belagavi', name: 'Athani'),
    // Bangalore
    TalukModel(id: 'tlk_bangalore_n', districtId: 'dis_bangalore', name: 'Bangalore North'),
    TalukModel(id: 'tlk_bangalore_s', districtId: 'dis_bangalore', name: 'Bangalore South'),
    // Mumbai
    TalukModel(id: 'tlk_mumbai_c', districtId: 'dis_mumbai', name: 'Mumbai City'),
    TalukModel(id: 'tlk_mumbai_sub', districtId: 'dis_mumbai', name: 'Mumbai Suburban'),
    // Los Angeles County
    TalukModel(id: 'tlk_la_central', districtId: 'dis_la_county', name: 'Central LA'),
    TalukModel(id: 'tlk_la_west', districtId: 'dis_la_county', name: 'West LA'),
    // Greater London
    TalukModel(id: 'tlk_central_london', districtId: 'dis_greater_london', name: 'Central London'),
    TalukModel(id: 'tlk_west_london', districtId: 'dis_greater_london', name: 'West London'),
  ];

  static const _mockCities = [
    CityModel(id: 'ct_belagavi', talukId: 'tlk_belagavi', name: 'Belagavi', isTier2: true),
    CityModel(id: 'ct_gokak', talukId: 'tlk_gokak', name: 'Gokak', isTier2: true),
    CityModel(id: 'ct_bangalore', talukId: 'tlk_bangalore_n', name: 'Bangalore', isTier1: true),
    CityModel(id: 'ct_mumbai', talukId: 'tlk_mumbai_c', name: 'Mumbai', isTier1: true),
    CityModel(id: 'ct_pune', talukId: 'tlk_bangalore_s', name: 'Pune', isTier1: true),
    CityModel(id: 'ct_los_angeles', talukId: 'tlk_la_central', name: 'Los Angeles', isTier1: true),
    CityModel(id: 'ct_beverly_hills', talukId: 'tlk_la_west', name: 'Beverly Hills', isTier1: true),
    CityModel(id: 'ct_london', talukId: 'tlk_central_london', name: 'London', isTier1: true),
  ];

  static const _mockLocalities = [
    // Belagavi
    LocalityModel(id: 'loc_tilakwadi', cityId: 'ct_belagavi', name: 'Tilakwadi', pincode: '590006', latitude: 15.8497, longitude: 74.5089),
    LocalityModel(id: 'loc_shahapur', cityId: 'ct_belagavi', name: 'Shahapur', pincode: '590003', latitude: 15.8364, longitude: 74.5165),
    LocalityModel(id: 'loc_hindalga', cityId: 'ct_belagavi', name: 'Hindalga', pincode: '591108', latitude: 15.8821, longitude: 74.4792),
    LocalityModel(id: 'loc_hanuman_nagar', cityId: 'ct_belagavi', name: 'Hanuman Nagar', pincode: '590019', latitude: 15.8712, longitude: 74.5298),
    LocalityModel(id: 'loc_college_road', cityId: 'ct_belagavi', name: 'College Road', pincode: '590001', latitude: 15.8580, longitude: 74.5080),
    LocalityModel(id: 'loc_camp', cityId: 'ct_belagavi', name: 'Camp', pincode: '590001', latitude: 15.8500, longitude: 74.5050),
    LocalityModel(id: 'loc_udyambag', cityId: 'ct_belagavi', name: 'Udyambag', pincode: '590008', latitude: 15.8620, longitude: 74.5120),
    LocalityModel(id: 'loc_vadgaon', cityId: 'ct_belagavi', name: 'Vadgaon', pincode: '591225', latitude: 15.8790, longitude: 74.5350),
    LocalityModel(id: 'loc_khanapur_road', cityId: 'ct_belagavi', name: 'Khanapur Road', pincode: '591302', latitude: 15.8900, longitude: 74.5400),
    LocalityModel(id: 'loc_hindwadi', cityId: 'ct_belagavi', name: 'Hindwadi', pincode: '590011', latitude: 15.8450, longitude: 74.5000),
    // Bangalore
    LocalityModel(id: 'loc_koramangala', cityId: 'ct_bangalore', name: 'Koramangala', pincode: '560034'),
    LocalityModel(id: 'loc_indiranagar', cityId: 'ct_bangalore', name: 'Indiranagar', pincode: '560038'),
    LocalityModel(id: 'loc_whitefield', cityId: 'ct_bangalore', name: 'Whitefield', pincode: '560066'),
    // Mumbai
    LocalityModel(id: 'loc_andheri', cityId: 'ct_mumbai', name: 'Andheri', pincode: '400053'),
    LocalityModel(id: 'loc_bandra', cityId: 'ct_mumbai', name: 'Bandra', pincode: '400050'),
    LocalityModel(id: 'loc_lower_parel', cityId: 'ct_mumbai', name: 'Lower Parel', pincode: '400013'),
    // Los Angeles
    LocalityModel(id: 'loc_beverly_hills', cityId: 'ct_los_angeles', name: 'Beverly Hills', pincode: '90210'),
    LocalityModel(id: 'loc_hollywood', cityId: 'ct_los_angeles', name: 'Hollywood', pincode: '90028'),
    // London
    LocalityModel(id: 'loc_mayfair', cityId: 'ct_london', name: 'Mayfair', pincode: 'W1J'),
    LocalityModel(id: 'loc_chelsea', cityId: 'ct_london', name: 'Chelsea', pincode: 'SW3'),
  ];

  static const _mockAreas = [
    // Tilakwadi, Belagavi
    AreaModel(id: 'area_tilak_phase1', localityId: 'loc_tilakwadi', name: 'Tilakwadi Phase 1'),
    AreaModel(id: 'area_tilak_phase2', localityId: 'loc_tilakwadi', name: 'Tilakwadi Phase 2'),
    AreaModel(id: 'area_congress_road', localityId: 'loc_tilakwadi', name: 'Congress Road'),
    // Hanuman Nagar, Belagavi
    AreaModel(id: 'area_hanuman_1st', localityId: 'loc_hanuman_nagar', name: '1st Stage'),
    AreaModel(id: 'area_hanuman_2nd', localityId: 'loc_hanuman_nagar', name: '2nd Stage'),
    // Koramangala
    AreaModel(id: 'area_korama_5blk', localityId: 'loc_koramangala', name: '5th Block'),
    AreaModel(id: 'area_korama_7blk', localityId: 'loc_koramangala', name: '7th Block'),
    // Andheri
    AreaModel(id: 'area_andheri_west', localityId: 'loc_andheri', name: 'Andheri West'),
    AreaModel(id: 'area_andheri_east', localityId: 'loc_andheri', name: 'Andheri East'),
  ];
}
