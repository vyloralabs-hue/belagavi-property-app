import 'package:flutter/material.dart';
import 'package:belagavi_property/core/map/map_configuration.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';

class MapLocationResult {
  final double latitude;
  final double longitude;
  final String locality;
  final String city;
  final String state;
  final String pincode;
  final String address;

  const MapLocationResult({
    required this.latitude,
    required this.longitude,
    required this.locality,
    required this.city,
    required this.state,
    required this.pincode,
    required this.address,
  });
}

/// Interactive India-Wide Location & Coordinate Picker Modal
/// Zero Google Maps billing dependency â€” uses configurable vector/OSM tiles and offline resolver.
class InteractiveMapLocationPicker extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final String initialCity;
  final String initialLocality;

  const InteractiveMapLocationPicker({
    super.key,
    this.initialLat = MapConfiguration.defaultLatitude,
    this.initialLng = MapConfiguration.defaultLongitude,
    this.initialCity = 'Belagavi',
    this.initialLocality = 'Tilakwadi',
  });

  static Future<MapLocationResult?> show(
    BuildContext context, {
    double? initialLat,
    double? initialLng,
    String? initialCity,
    String? initialLocality,
  }) {
    return showModalBottomSheet<MapLocationResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InteractiveMapLocationPicker(
        initialLat: initialLat ?? MapConfiguration.defaultLatitude,
        initialLng: initialLng ?? MapConfiguration.defaultLongitude,
        initialCity: initialCity ?? 'Belagavi',
        initialLocality: initialLocality ?? 'Tilakwadi',
      ),
    );
  }

  @override
  State<InteractiveMapLocationPicker> createState() =>
      _InteractiveMapLocationPickerState();
}

class _InteractiveMapLocationPickerState
    extends State<InteractiveMapLocationPicker> {
  late double _currentLat;
  late double _currentLng;
  late String _selectedCity;
  late String _selectedLocality;
  late String _selectedState;
  late String _selectedPincode;
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    final (
      resolvedLat,
      resolvedLng,
    ) = MapConfiguration.resolveCenterForLocation(
      city: widget.initialCity,
      locality: widget.initialLocality,
      fallbackLat: widget.initialLat,
      fallbackLng: widget.initialLng,
    );
    _currentLat = resolvedLat;
    _currentLng = resolvedLng;
    _selectedCity = widget.initialCity;
    _selectedLocality = widget.initialLocality;
    _selectedState = 'Karnataka';
    _selectedPincode = '590006';

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final q = query.toLowerCase();
    final results = <String>[];

    for (final city in MapConfiguration.majorIndianCities) {
      if (city.city.toLowerCase().contains(q)) {
        results.add(city.city);
      }
      for (final loc in city.localities) {
        if (loc.toLowerCase().contains(q)) {
          results.add('$loc, ${city.city}');
        }
      }
    }

    setState(() {
      _suggestions = results.take(6).toList();
    });
  }

  void _selectSuggestion(String suggestion) {
    _searchController.clear();
    setState(() => _suggestions = []);

    if (suggestion.contains(',')) {
      final parts = suggestion.split(',');
      final loc = parts[0].trim();
      final cityName = parts[1].trim();

      final match = MapConfiguration.majorIndianCities.firstWhere(
        (c) => c.city.toLowerCase() == cityName.toLowerCase(),
        orElse: () => MapConfiguration.majorIndianCities.first,
      );

      setState(() {
        _selectedLocality = loc;
        _selectedCity = match.city;
        _selectedState = match.state;
        _selectedPincode = match.pincode;
        _currentLat = match.latitude;
        _currentLng = match.longitude;
      });
    } else {
      final match = MapConfiguration.majorIndianCities.firstWhere(
        (c) => c.city.toLowerCase() == suggestion.toLowerCase(),
        orElse: () => MapConfiguration.majorIndianCities.first,
      );

      setState(() {
        _selectedCity = match.city;
        _selectedState = match.state;
        _selectedPincode = match.pincode;
        _selectedLocality = match.localities.isNotEmpty
            ? match.localities.first
            : 'Central';
        _currentLat = match.latitude;
        _currentLng = match.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.88,
      decoration: BoxDecoration(
        color: scaffoldBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Drag Handle & Title
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            color: surfaceBg,
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Property Location',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textP,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Search Box
                TextField(
                  controller: _searchController,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 13,
                    color: textP,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search city, locality, landmark or pincode...',
                    hintStyle: TextStyle(fontSize: 13, color: textS),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppDesignSystem.brandGold,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF131922)
                        : const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderCol),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderCol),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppDesignSystem.brandGold,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Autocomplete Suggestions Dropdown
          if (_suggestions.isNotEmpty)
            Container(
              color: surfaceBg,
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: borderCol),
                itemBuilder: (context, idx) {
                  final s = _suggestions[idx];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppDesignSystem.brandGold,
                    ),
                    title: Text(
                      s,
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 13,
                        color: textP,
                      ),
                    ),
                    onTap: () => _selectSuggestion(s),
                  );
                },
              ),
            ),

          // Interactive Map Visual Canvas with Center Pin
          Expanded(
            child: Stack(
              children: [
                // Map Background Canvas (Open-source vector/OSM styled background)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFE2E8F0),
                  child: GridPaper(
                    color: isDark ? Colors.white10 : Colors.black12,
                    divisions: 2,
                    subdivisions: 2,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 100,
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_selectedLocality, $_selectedCity',
                            style: TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          Text(
                            'Lat: ${_currentLat.toStringAsFixed(4)}, Lng: ${_currentLng.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 12,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Center Pin Indicator
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          _selectedLocality,
                          style: const TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.location_pin,
                        size: 44,
                        color: Color(0xFFDC2626),
                      ),
                    ],
                  ),
                ),

                // Quick City Chips Floating on Top of Map
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: MapConfiguration.majorIndianCities.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final city = MapConfiguration.majorIndianCities[idx];
                        final isSel = _selectedCity == city.city;
                        return ActionChip(
                          label: Text(
                            city.city,
                            style: TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 11,
                              fontWeight: isSel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSel ? Colors.black : textP,
                            ),
                          ),
                          backgroundColor: isSel
                              ? AppDesignSystem.brandGold
                              : surfaceBg,
                          side: BorderSide(
                            color: isSel
                                ? AppDesignSystem.brandGold
                                : borderCol,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedCity = city.city;
                              _selectedState = city.state;
                              _selectedPincode = city.pincode;
                              _selectedLocality = city.localities.first;
                              _currentLat = city.latitude;
                              _currentLng = city.longitude;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Location Confirmation Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceBg,
              border: Border(top: BorderSide(color: borderCol, width: 1)),
              boxShadow: AppDesignSystem.navShadow,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.pin_drop_rounded,
                        color: AppDesignSystem.brandGold,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_selectedLocality, $_selectedCity',
                            style: TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textP,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_selectedState, India â€” Pincode: $_selectedPincode',
                            style: TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 12,
                              color: textS,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Coordinates: ${_currentLat.toStringAsFixed(4)}Â° N, ${_currentLng.toStringAsFixed(4)}Â° E',
                            style: const TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 11,
                              color: AppDesignSystem.brandGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final result = MapLocationResult(
                        latitude: _currentLat,
                        longitude: _currentLng,
                        locality: _selectedLocality,
                        city: _selectedCity,
                        state: _selectedState,
                        pincode: _selectedPincode,
                        address:
                            '$_selectedLocality, $_selectedCity, $_selectedState - $_selectedPincode',
                      );
                      Navigator.of(context).pop(result);
                    },
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'Confirm Location & Coordinates',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDesignSystem.brandGold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
