import 'package:equatable/equatable.dart';

/// Geocoded location place result
class GeocodedPlace extends Equatable {
  final String id;
  final String displayName;
  final String mainText;
  final String secondaryText;
  final double latitude;
  final double longitude;
  final String? street;
  final String? locality;
  final String? taluk;
  final String? city;
  final String? district;
  final String? state;
  final String? pincode;
  final String country;
  final String providerName;

  const GeocodedPlace({
    required this.id,
    required this.displayName,
    required this.mainText,
    required this.secondaryText,
    required this.latitude,
    required this.longitude,
    this.street,
    this.locality,
    this.taluk,
    this.city,
    this.district,
    this.state,
    this.pincode,
    this.country = 'India',
    required this.providerName,
  });

  @override
  List<Object?> get props => [
        id,
        displayName,
        mainText,
        secondaryText,
        latitude,
        longitude,
        street,
        locality,
        taluk,
        city,
        district,
        state,
        pincode,
        country,
        providerName,
      ];
}

/// Abstract provider interface for Geocoding and Autocomplete Search
abstract class LocationSearchProvider {
  String get name;

  /// Autocomplete or search query for places/streets/landmarks
  Future<List<GeocodedPlace>> searchPlaces(
    String query, {
    double? biasLatitude,
    double? biasLongitude,
    int limit = 10,
  });

  /// Reverse geocode coordinates to structured address
  Future<GeocodedPlace?> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}
