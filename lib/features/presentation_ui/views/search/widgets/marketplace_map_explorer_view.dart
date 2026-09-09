import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/utils/number_formatter.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property_search/presentation/providers/property_search_notifier.dart';
import 'package:belagavi_property/features/property_search/presentation/providers/user_location_notifier.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';

/// Facebook-Marketplace-style interactive map exploration view
/// Powered by flutter_map + OpenStreetMap (Zero Google billing / Zero API key dependency).
class MarketplaceMapExplorerView extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToList;

  const MarketplaceMapExplorerView({
    super.key,
    required this.onSwitchToList,
  });

  @override
  ConsumerState<MarketplaceMapExplorerView> createState() =>
      _MarketplaceMapExplorerViewState();
}

class _MarketplaceMapExplorerViewState
    extends ConsumerState<MarketplaceMapExplorerView> {
  final MapController _mapController = MapController();
  ll.LatLng _centerPosition = const ll.LatLng(15.8497, 74.4977); // Default Belagavi
  double _currentRadiusKm = 10.0;
  double _currentZoom = 12.0;
  bool _hasMovedSinceSearch = false;
  PropertyEntity? _selectedProperty;
  Timer? _debounceTimer;

  static const List<double> _availableRadii = [5.0, 10.0, 20.0, 50.0, 100.0];

  @override
  void initState() {
    super.initState();
    final currentLoc = ref.read(userLocationNotifierProvider).current;
    if (currentLoc.latitude != null && currentLoc.longitude != null) {
      _centerPosition = ll.LatLng(currentLoc.latitude!, currentLoc.longitude!);
    }
    if (currentLoc.radiusKm != null && currentLoc.radiusKm! > 0) {
      _currentRadiusKm = currentLoc.radiusKm!;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      _centerPosition = camera.center;
      _currentZoom = camera.zoom;
      if (!_hasMovedSinceSearch) {
        setState(() => _hasMovedSinceSearch = true);
      }
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted && _hasMovedSinceSearch) {
          setState(() {});
        }
      });
    }
  }

  void _triggerSearchThisArea() {
    setState(() => _hasMovedSinceSearch = false);
    ref.read(userLocationNotifierProvider.notifier).selectMapArea(
          centerLatitude: _centerPosition.latitude,
          centerLongitude: _centerPosition.longitude,
          radiusKm: _currentRadiusKm,
        );
  }

  void _onRadiusSelected(double radius) {
    setState(() {
      _currentRadiusKm = radius;
      _hasMovedSinceSearch = false;
    });

    ref.read(userLocationNotifierProvider.notifier).updateRadius(radius);

    // Zoom map according to selected radius
    double zoom = 13.0;
    if (radius <= 5.0) {
      zoom = 13.5;
    } else if (radius <= 10.0) {
      zoom = 12.0;
    } else if (radius <= 20.0) {
      zoom = 10.8;
    } else if (radius <= 50.0) {
      zoom = 9.5;
    } else {
      zoom = 8.0;
    }

    _mapController.move(_centerPosition, zoom);
  }

  List<Marker> _buildMarkers(List<PropertyEntity> properties) {
    final markers = <Marker>[];

    // If zoomed out (e.g. state/pan-India view zoom < 11.0), cluster close markers
    if (_currentZoom < 11.0) {
      final clusters = <String, List<PropertyEntity>>{};
      const cellSize = 0.15; // ~15km grid

      for (final p in properties) {
        if (p.latitude == null || p.longitude == null) continue;
        final cellLat = (p.latitude! / cellSize).floor();
        final cellLon = (p.longitude! / cellSize).floor();
        final key = '${cellLat}_$cellLon';
        clusters.putIfAbsent(key, () => []).add(p);
      }

      clusters.forEach((cellKey, clusterProps) {
        if (clusterProps.length == 1) {
          final p = clusterProps.first;
          final isSelected = _selectedProperty?.id == p.id;
          markers.add(
            Marker(
              point: ll.LatLng(p.latitude!, p.longitude!),
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () => setState(() => _selectedProperty = p),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppDesignSystem.brandGold
                        : AppDesignSystem.primaryNavy,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          );
        } else {
          // Centroid of cluster
          final avgLat = clusterProps
                  .map((e) => e.latitude!)
                  .reduce((a, b) => a + b) /
              clusterProps.length;
          final avgLon = clusterProps
                  .map((e) => e.longitude!)
                  .reduce((a, b) => a + b) /
              clusterProps.length;

          markers.add(
            Marker(
              point: ll.LatLng(avgLat, avgLon),
              width: 46,
              height: 46,
              child: GestureDetector(
                onTap: () {
                  _mapController.move(
                    ll.LatLng(avgLat, avgLon),
                    _currentZoom + 2.0,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B46C1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${clusterProps.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      });

      return markers;
    }

    // Closer zoom: Individual detailed markers
    for (final p in properties) {
      if (p.latitude == null || p.longitude == null) continue;

      final isSelected = _selectedProperty?.id == p.id;
      markers.add(
        Marker(
          point: ll.LatLng(p.latitude!, p.longitude!),
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () => setState(() => _selectedProperty = p),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppDesignSystem.brandGold
                    : AppDesignSystem.primaryNavy,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(propertySearchNotifierProvider);
    final cardBg = AppDesignSystem.cardBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);

    final properties = switch (searchState) {
      PropertySearchSuccess(result: final res) => res.properties,
      _ => <PropertyEntity>[],
    };

    final isLoading = searchState is PropertySearchLoading;

    return Stack(
      children: [
        // 1. flutter_map + OpenStreetMap Canvas (100% Zero-Billing, Zero-Key)
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _centerPosition,
            initialZoom: _currentZoom,
            minZoom: 4.0,
            maxZoom: 18.0,
            onPositionChanged: _onPositionChanged,
            onTap: (_, __) {
              if (_selectedProperty != null) {
                setState(() => _selectedProperty = null);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.belagavi.belagavi_property',
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: _centerPosition,
                  radius: _currentRadiusKm * 1000.0,
                  useRadiusInMeter: true,
                  color: AppDesignSystem.brandGold.withValues(alpha: 0.14),
                  borderColor: AppDesignSystem.brandGold,
                  borderStrokeWidth: 2,
                ),
              ],
            ),
            MarkerLayer(
              markers: _buildMarkers(properties),
            ),
          ],
        ),

        // 2. Center Crosshair / Location Target Pin
        Center(
          child: IgnorePointer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_searching_rounded,
                    color: AppDesignSystem.brandGold,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),

        // 3. Top Floating Control Bar: Radius Selector & Switch to List
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Radius pills & List toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: cardBg.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _availableRadii.map((r) {
                            final isSel = _currentRadiusKm == r;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text('${r.toInt()} km'),
                                selected: isSel,
                                selectedColor: AppDesignSystem.brandGold,
                                labelStyle: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSel ? Colors.white : textP,
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                onSelected: (_) => _onRadiusSelected(r),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Switch to List Button
                    ElevatedButton.icon(
                      onPressed: widget.onSwitchToList,
                      icon: const Icon(Icons.view_list_rounded, size: 16),
                      label: const Text('List'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesignSystem.brandGold,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. "Search This Area" floating button (appears when map moved)
              if (_hasMovedSinceSearch) ...[
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _triggerSearchThisArea,
                    icon: isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text(
                      'Search This Area',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.85),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          color: AppDesignSystem.brandGold,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // 5. Expand Area Callout if 0 results
        if (!isLoading && properties.isEmpty)
          Positioned(
            top: 90,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade700),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No properties within ${_currentRadiusKm.toInt()} km.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: textP,
                      ),
                    ),
                  ),
                  if (_currentRadiusKm < 100.0)
                    TextButton(
                      onPressed: () {
                        final nextIdx =
                            _availableRadii.indexOf(_currentRadiusKm) + 1;
                        if (nextIdx < _availableRadii.length) {
                          _onRadiusSelected(_availableRadii[nextIdx]);
                        }
                      },
                      child: const Text(
                        'Expand Area',
                        style: TextStyle(
                          color: AppDesignSystem.brandGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // 6. Selected Property Preview Bottom Card
        if (_selectedProperty != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Dismissible(
              key: Key(_selectedProperty!.id),
              direction: DismissDirection.down,
              onDismissed: (_) => setState(() => _selectedProperty = null),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Property Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade300,
                        child: _selectedProperty!.mediaList.isNotEmpty
                            ? Image.network(
                                _selectedProperty!
                                    .mediaList.first.effectiveThumbnailUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.home_rounded),
                              )
                            : const Icon(Icons.home_rounded, size: 36),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedProperty!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: textP,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_selectedProperty!.locality.isNotEmpty ? "${_selectedProperty!.locality}, " : ""}${_selectedProperty!.city}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: textS),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                NumberFormatter.formatPrice(
                                  _selectedProperty!.price,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppDesignSystem.brandGold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => context.push(
                                  '/property/${_selectedProperty!.id}',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppDesignSystem.brandGold,
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'View',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
