import '../domain/entities/user_location_context.dart';

class IndiaLocationDirectory {
  IndiaLocationDirectory._();

  static const List<Map<String, dynamic>> popularCities = [
    {
      'name': 'Bengaluru',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'aliases': ['bangalore', 'blr'],
      'isPopular': true,
    },
    {
      'name': 'Mumbai',
      'state': 'Maharashtra',
      'stateCode': 'MH',
      'aliases': ['bombay', 'mumb'],
      'isPopular': true,
    },
    {
      'name': 'Pune',
      'state': 'Maharashtra',
      'stateCode': 'MH',
      'aliases': ['poona', 'pun'],
      'isPopular': true,
    },
    {
      'name': 'Belagavi',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'aliases': ['belgaum', 'bgm', 'belagaon'],
      'isPopular': true,
    },
    {
      'name': 'Hyderabad',
      'state': 'Telangana',
      'stateCode': 'TS',
      'aliases': ['secunderabad', 'hyd', 'cyberabad'],
      'isPopular': true,
    },
    {
      'name': 'Delhi NCR',
      'state': 'Delhi',
      'stateCode': 'DL',
      'aliases': ['delhi', 'new delhi', 'noida', 'gurgaon', 'gurugram', 'faridabad', 'ghaziabad'],
      'isPopular': true,
    },
    {
      'name': 'Chennai',
      'state': 'Tamil Nadu',
      'stateCode': 'TN',
      'aliases': ['madras', 'chn'],
      'isPopular': true,
    },
    {
      'name': 'Kolkata',
      'state': 'West Bengal',
      'stateCode': 'WB',
      'aliases': ['calcutta', 'ccu'],
      'isPopular': true,
    },
    {
      'name': 'Ahmedabad',
      'state': 'Gujarat',
      'stateCode': 'GJ',
      'aliases': ['amdavad', 'ahd'],
      'isPopular': false,
    },
    {
      'name': 'Hubballi',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'aliases': ['hubli'],
      'isPopular': false,
    },
    {
      'name': 'Dharwad',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'aliases': ['dharwar'],
      'isPopular': false,
    },

    {
      'name': 'Mysuru',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'aliases': ['mysore'],
      'isPopular': false,
    },
    {
      'name': 'Goa',
      'state': 'Goa',
      'stateCode': 'GA',
      'aliases': ['panaji', 'margao', 'mapusa', 'vasco'],
      'isPopular': false,
    },
  ];

  static const List<Map<String, dynamic>> directoryEntries = [
    // ─── BENGALURU LOCALITIES ──────────────────────────────────────────────
    {
      'name': 'Whitefield',
      'type': LocationCandidateType.locality,
      'city': 'Bengaluru',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '560066',
      'aliases': ['whitefield main road', 'itpl'],
    },
    {
      'name': 'Koramangala',
      'type': LocationCandidateType.locality,
      'city': 'Bengaluru',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '560034',
      'aliases': ['koramangala 5th block', 'koramangala 7th block'],
    },
    {
      'name': 'Indiranagar',
      'type': LocationCandidateType.locality,
      'city': 'Bengaluru',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '560038',
      'aliases': ['100 feet road', 'indiranagar 1st stage'],
    },
    {
      'name': 'HSR Layout',
      'type': LocationCandidateType.locality,
      'city': 'Bengaluru',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '560102',
      'aliases': ['hsr', 'hsr sector 1', 'hsr sector 2'],
    },
    {
      'name': 'Electronic City',
      'type': LocationCandidateType.locality,
      'city': 'Bengaluru',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '560100',
      'aliases': ['e city', 'phase 1', 'phase 2'],
    },
    {
      'name': 'MG Road',
      'type': LocationCandidateType.landmark,
      'city': 'Bengaluru',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '560001',
      'aliases': ['mahatma gandhi road', 'brigade road'],
    },

    // ─── PUNE LOCALITIES ───────────────────────────────────────────────────
    {
      'name': 'Baner',
      'type': LocationCandidateType.locality,
      'city': 'Pune',
      'state': 'Maharashtra',
      'stateCode': 'MH',
      'pincode': '411045',
      'aliases': ['baner road', 'baner pashan link road'],
    },
    {
      'name': 'Hinjewadi',
      'type': LocationCandidateType.locality,
      'city': 'Pune',
      'state': 'Maharashtra',
      'stateCode': 'MH',
      'pincode': '411057',
      'aliases': ['hinjewadi it park', 'phase 1', 'phase 2', 'phase 3'],
    },
    {
      'name': 'Wakad',
      'type': LocationCandidateType.locality,
      'city': 'Pune',
      'state': 'Maharashtra',
      'stateCode': 'MH',
      'pincode': '411057',
      'aliases': ['dange chowk', 'bhujbal chowk'],
    },
    {
      'name': 'Kothrud',
      'type': LocationCandidateType.locality,
      'city': 'Pune',
      'state': 'Maharashtra',
      'stateCode': 'MH',
      'pincode': '411038',
      'aliases': ['paud road', 'karve road'],
    },
    {
      'name': 'Viman Nagar',
      'type': LocationCandidateType.locality,
      'city': 'Pune',
      'state': 'Maharashtra',
      'stateCode': 'MH',
      'pincode': '411014',
      'aliases': ['phoenix marketcity'],
    },

    // ─── MUMBAI LOCALITIES ─────────────────────────────────────────────────
    {
      'name': 'Andheri',
      'type': LocationCandidateType.locality,
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'stateCode': 'MH',
      'pincode': '400053',
      'aliases': ['andheri west', 'andheri east', 'lokhandwala'],
    },
    {
      'name': 'Bandra',
      'type': LocationCandidateType.locality,
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'stateCode': 'MH',
      'pincode': '400050',
      'aliases': ['bandra west', 'bandra east', 'bkc', 'bandra kurla complex'],
    },
    {
      'name': 'Lower Parel',
      'type': LocationCandidateType.locality,
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'stateCode': 'MH',
      'pincode': '400013',
      'aliases': ['high street phoenix', 'senapati bapat marg'],
    },
    {
      'name': 'Powai',
      'type': LocationCandidateType.locality,
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'stateCode': 'MH',
      'pincode': '400076',
      'aliases': ['hiranandani gardens', 'iit bombay'],
    },

    // ─── BELAGAVI LOCALITIES ───────────────────────────────────────────────
    {
      'name': 'Tilakwadi',
      'type': LocationCandidateType.locality,
      'city': 'Belagavi',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '590006',
      'aliases': ['tilakwadi 1st gate', 'tilakwadi 2nd gate', 'congress road'],
    },
    {
      'name': 'Shahapur',
      'type': LocationCandidateType.locality,
      'city': 'Belagavi',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '590003',
      'aliases': ['shahapur main market'],
    },
    {
      'name': 'Hindalga',
      'type': LocationCandidateType.locality,
      'city': 'Belagavi',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '591108',
      'aliases': ['hindalga road', 'ganesh temple road'],
    },
    {
      'name': 'Hanuman Nagar',
      'type': LocationCandidateType.locality,
      'city': 'Belagavi',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '590019',
      'aliases': ['hanuman nagar 1st stage', 'hanuman nagar 2nd stage'],
    },
    {
      'name': 'College Road',
      'type': LocationCandidateType.locality,
      'city': 'Belagavi',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '590001',
      'aliases': ['rpd corner', 'lingraj college'],
    },
    {
      'name': 'Camp',
      'type': LocationCandidateType.locality,
      'city': 'Belagavi',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '590001',
      'aliases': ['cantonment', 'camp market'],
    },
    {
      'name': 'Udyambag',
      'type': LocationCandidateType.locality,
      'city': 'Belagavi',
      'state': 'Karnataka',
      'stateCode': 'KA',
      'pincode': '590008',
      'aliases': ['udyambag industrial area'],
    },

    // ─── HYDERABAD LOCALITIES ──────────────────────────────────────────────
    {
      'name': 'Gachibowli',
      'type': LocationCandidateType.locality,
      'city': 'Hyderabad',
      'state': 'Telangana',
      'stateCode': 'TS',
      'pincode': '500032',
      'aliases': ['financial district', 'gachibowli stadium'],
    },
    {
      'name': 'Hitec City',
      'type': LocationCandidateType.locality,
      'city': 'Hyderabad',
      'state': 'Telangana',
      'stateCode': 'TS',
      'pincode': '500081',
      'aliases': ['madhapur', 'cyber towers'],
    },
    {
      'name': 'Jubilee Hills',
      'type': LocationCandidateType.locality,
      'city': 'Hyderabad',
      'state': 'Telangana',
      'stateCode': 'TS',
      'pincode': '500033',
      'aliases': ['road no 36', 'road no 45'],
    },

    // ─── DELHI NCR LOCALITIES ──────────────────────────────────────────────
    {
      'name': 'Connaught Place',
      'type': LocationCandidateType.landmark,
      'city': 'Delhi NCR',
      'state': 'Delhi',
      'stateCode': 'DL',
      'pincode': '110001',
      'aliases': ['cp', 'rajiv chowk', 'inner circle'],
    },
    {
      'name': 'Cyber Hub',
      'type': LocationCandidateType.landmark,
      'city': 'Delhi NCR',
      'state': 'Delhi',
      'stateCode': 'DL',
      'pincode': '122002',
      'aliases': ['dlf cyber city', 'gurugram', 'gurgaon'],
    },
    {
      'name': 'Sector 62',
      'type': LocationCandidateType.locality,
      'city': 'Delhi NCR',
      'state': 'Delhi',
      'stateCode': 'DL',
      'pincode': '201309',
      'aliases': ['noida sector 62', 'noida'],
    },

    // ─── CHENNAI LOCALITIES ────────────────────────────────────────────────
    {
      'name': 'Anna Nagar',
      'type': LocationCandidateType.locality,
      'city': 'Chennai',
      'state': 'Tamil Nadu',
      'stateCode': 'TN',
      'pincode': '600040',
      'aliases': ['anna nagar west', 'anna nagar east', 'roundtana'],
    },
    {
      'name': 'OMR - IT Corridor',
      'type': LocationCandidateType.locality,
      'city': 'Chennai',
      'state': 'Tamil Nadu',
      'stateCode': 'TN',
      'pincode': '600096',
      'aliases': ['old mahabalipuram road', 'thoraipakkam', 'sholinganallur'],
    },
  ];

  static String normalize(String query) {
    return query
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String? resolveCityAlias(String input) {
    final norm = normalize(input);
    if (norm.isEmpty) return null;

    for (final city in popularCities) {
      final cityNameNorm = normalize(city['name'] as String);
      if (cityNameNorm == norm) return city['name'] as String;

      final aliases = city['aliases'] as List<String>? ?? const [];
      for (final alias in aliases) {
        if (normalize(alias) == norm) {
          return city['name'] as String;
        }
      }
    }
    return null;
  }

  static List<LocationCandidate> search(String query, {int limit = 15}) {
    final norm = normalize(query);
    if (norm.isEmpty) return const [];

    final results = <LocationCandidate>[];
    final seenIds = <String>{};

    // 1. Check City Exact / Alias Matches
    for (final city in popularCities) {
      final cityName = city['name'] as String;
      final stateName = city['state'] as String;
      final stateCode = city['stateCode'] as String?;
      final cityNameNorm = normalize(cityName);

      bool match = cityNameNorm.contains(norm);
      if (!match) {
        final aliases = city['aliases'] as List<String>? ?? const [];
        match = aliases.any((a) => normalize(a).contains(norm));
      }

      if (match) {
        final id = 'city_${cityName.toLowerCase()}';
        if (seenIds.add(id)) {
          results.add(
            LocationCandidate(
              id: id,
              name: cityName,
              subtitle: stateName,
              type: LocationCandidateType.city,
              cityName: cityName,
              stateName: stateName,
              stateCode: stateCode,
            ),
          );
        }
      }
    }

    // 2. Check Pincode Matches
    if (RegExp(r'^\d+$').hasMatch(norm)) {
      for (final entry in directoryEntries) {
        final pin = entry['pincode'] as String? ?? '';
        if (pin.startsWith(norm) || pin.contains(norm)) {
          final id = 'pin_${entry['name']}_$pin';
          if (seenIds.add(id)) {
            final locName = entry['name'] as String;
            final cityName = entry['city'] as String;
            final stateName = entry['state'] as String;
            final stateCode = entry['stateCode'] as String?;
            results.add(
              LocationCandidate(
                id: id,
                name: pin,
                subtitle: '$locName, $cityName, $stateName',
                type: LocationCandidateType.pincode,
                cityName: cityName,
                stateName: stateName,
                stateCode: stateCode,
                localityName: locName,
                pincode: pin,
              ),
            );
          }
        }
      }
    }

    // 3. Check Locality / Landmark / Area Matches
    for (final entry in directoryEntries) {
      final name = entry['name'] as String;
      final cityName = entry['city'] as String;
      final stateName = entry['state'] as String;
      final stateCode = entry['stateCode'] as String?;
      final type = entry['type'] as LocationCandidateType;
      final pincode = entry['pincode'] as String?;
      final aliases = entry['aliases'] as List<String>? ?? const [];

      final nameNorm = normalize(name);
      bool match = nameNorm.contains(norm) ||
          normalize('$name $cityName').contains(norm) ||
          aliases.any((a) => normalize(a).contains(norm));

      if (match) {
        final id = 'loc_${name.toLowerCase()}_${cityName.toLowerCase()}';
        if (seenIds.add(id)) {
          results.add(
            LocationCandidate(
              id: id,
              name: name,
              subtitle: '$cityName, $stateName${pincode != null ? ' ($pincode)' : ''}',
              type: type,
              cityName: cityName,
              stateName: stateName,
              stateCode: stateCode,
              localityName: type == LocationCandidateType.locality ? name : null,
              areaName: type == LocationCandidateType.area ? name : null,
              pincode: pincode,
            ),
          );
        }
      }
    }

    return results.take(limit).toList();
  }

  /// Normalizes city name input against canonical directory & aliases.
  /// e.g. belgaum/bgm -> Belagavi, bangalore/blr -> Bengaluru, poona -> Pune
  static String normalizeCityName(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return clean;
    final lower = clean.toLowerCase();

    for (final city in popularCities) {
      final canonical = city['name'] as String;
      if (canonical.toLowerCase() == lower) return canonical;
      final aliases = city['aliases'] as List<String>? ?? const [];
      if (aliases.any((a) => a.toLowerCase() == lower)) return canonical;
    }

    // Well-known alias fallbacks
    if (lower == 'belgaum' || lower == 'bgm' || lower == 'belagaon') return 'Belagavi';
    if (lower == 'bangalore' || lower == 'blr') return 'Bengaluru';
    if (lower == 'poona' || lower == 'pun') return 'Pune';
    if (lower == 'hubli') return 'Hubballi';
    if (lower == 'dharwad' || lower == 'dharwar') return 'Dharwad';
    if (lower == 'mysore') return 'Mysuru';
    if (lower == 'bombay' || lower == 'mumb') return 'Mumbai';
    if (lower == 'madras' || lower == 'chn') return 'Chennai';
    if (lower == 'calcutta' || lower == 'ccu') return 'Kolkata';

    return clean;
  }

  /// Normalizes state name input against canonical directory.
  static String normalizeStateName(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return clean;
    final lower = clean.toLowerCase();

    if (lower == 'karnataka' || lower == 'kar' || lower == 'ka') return 'Karnataka';
    if (lower == 'maharashtra' || lower == 'mah' || lower == 'mh') return 'Maharashtra';
    if (lower == 'telangana' || lower == 'ts') return 'Telangana';
    if (lower == 'delhi' || lower == 'dl') return 'Delhi';
    if (lower == 'tamil nadu' || lower == 'tn') return 'Tamil Nadu';
    if (lower == 'west bengal' || lower == 'wb') return 'West Bengal';
    if (lower == 'gujarat' || lower == 'gj') return 'Gujarat';
    if (lower == 'goa' || lower == 'ga') return 'Goa';

    return clean;
  }

  /// Normalizes locality name input, strictly scoped by canonical city.
  /// Must NOT pass locality through city alias mapper.
  static String normalizeLocalityName(String locality, String? canonicalCity) {
    final cleanLoc = locality.trim();
    if (cleanLoc.isEmpty) return cleanLoc;
    final lowerLoc = cleanLoc.toLowerCase();
    final normCity = canonicalCity != null ? normalizeCityName(canonicalCity) : null;

    // Search directory entries matching parent city if provided
    for (final entry in directoryEntries) {
      final entryCity = entry['city'] as String;
      if (normCity != null && entryCity.toLowerCase() != normCity.toLowerCase()) {
        continue;
      }
      final canonicalLoc = entry['name'] as String;
      if (canonicalLoc.toLowerCase() == lowerLoc) return canonicalLoc;
      final aliases = entry['aliases'] as List<String>? ?? const [];
      if (aliases.any((a) => a.toLowerCase() == lowerLoc)) return canonicalLoc;
    }

    // High-confidence spelling variant fallbacks for Belagavi
    if (normCity == null || normCity.toLowerCase() == 'belagavi') {
      if (lowerLoc == 'tilakvadi' || lowerLoc == 'tilakwadi belagavi') return 'Tilakwadi';
      if (lowerLoc == 'shahpur' || lowerLoc == 'shahpur belagavi') return 'Shahapur';
      if (lowerLoc == 'piranvadi') return 'Piranwadi';
    }

    return cleanLoc;
  }


  /// Returns list of localities belonging strictly to the specified city.
  static List<String> getLocalitiesForCity(String city) {
    final normCity = normalizeCityName(city);
    final localities = <String>[];
    for (final entry in directoryEntries) {
      final entryCity = entry['city'] as String;
      if (entryCity.toLowerCase() == normCity.toLowerCase()) {
        localities.add(entry['name'] as String);
      }
    }
    return localities;
  }
}

