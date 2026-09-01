import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_design_system.dart';
import '../../../../property_search/presentation/providers/property_search_notifier.dart';
import '../../../../property_search/presentation/providers/saved_search_notifier.dart';
import '../../../../property_search/domain/entities/search_entities.dart';
import '../../../../property/domain/entities/property_entities.dart';

class PropertyFilterModal extends ConsumerStatefulWidget {
  const PropertyFilterModal({super.key});

  @override
  ConsumerState<PropertyFilterModal> createState() =>
      _PropertyFilterModalState();
}

class _PropertyFilterModalState extends ConsumerState<PropertyFilterModal> {
  late String _selectedLocality;
  late String _propertyType;
  late String _commercialSubtype;
  late String _landSubtype;
  late String _listingPurpose;
  late String _bhk;
  late String _sortBy;
  late RangeValues _budgetRange;
  late RangeValues _areaRange;
  late bool _verifiedOnly;
  final Set<String> _selectedAmenities = {};
  String? _selectedAvailability;

  static const List<String> _localities = [
    'All Localities',
    'Tilakwadi',
    'Camp',
    'Khanapur Road',
    'Shahapur',
    'Hindwadi',
    'Udyambag',
    'Vadgaon',
    'Sambra',
    'Mandoli Road',
    'Kuvempu Nagar',
    'Angol',
  ];

  static const Map<String, String> _sortOptions = {
    'created_at_desc': 'Newest First',
    'price_asc': 'Price: Low to High',
    'price_desc': 'Price: High to Low',
    'area_desc': 'Area: High to Low',
    'area_asc': 'Area: Low to High',
  };

  static const List<String> _availableAmenities = [
    'Parking',
    'Lift',
    'Security',
    'Power Backup',
    'Borewell',
    'Water Connection',
    '3-Phase Power',
    'Road Access',
    'Fenced',
    'Swimming Pool',
    'Gym',
    'Garden',
    'Washroom',
    'Loading Dock',
    'Air Conditioning',
    'Furnished',
    'Semi-Furnished',
  ];

  @override
  void initState() {
    super.initState();
    final currentQuery = ref
        .read(propertySearchNotifierProvider.notifier)
        .currentQuery;
    _selectedLocality = currentQuery.locality ?? 'All Localities';
    _propertyType = currentQuery.category?.name.toUpperCase() ?? 'ALL';
    _commercialSubtype = switch (currentQuery.type) {
      PropertySubtype.commercialOffice => 'OFFICE',
      PropertySubtype.commercialShop => 'SHOP',
      PropertySubtype.commercialShowroom => 'SHOWROOM',
      PropertySubtype.warehouse ||
      PropertySubtype.warehouseGodown => 'WAREHOUSE',
      _ => 'ALL',
    };
    _landSubtype = switch (currentQuery.type) {
      PropertySubtype.agriculturalLand => 'AGRICULTURAL',
      PropertySubtype.nonNaLand => 'NON_NA',
      PropertySubtype.naLand => 'NA_APPROVED',
      PropertySubtype.residentialPlot => 'RESIDENTIAL_PLOT',
      PropertySubtype.commercialPlot => 'COMMERCIAL_PLOT',
      _ => 'ALL',
    };
    _listingPurpose = currentQuery.purpose?.name.toUpperCase() ?? 'ALL';
    _bhk = currentQuery.minBedrooms != null
        ? '${currentQuery.minBedrooms} BHK'
        : 'ALL';
    _sortBy = currentQuery.sortBy;
    _budgetRange = RangeValues(
      (currentQuery.minPrice ?? 5).clamp(5, 500),
      (currentQuery.maxPrice ?? 500).clamp(5, 500),
    );
    _areaRange = RangeValues(
      (currentQuery.minArea ?? 100).clamp(100, 10000),
      (currentQuery.maxArea ?? 10000).clamp(100, 10000),
    );
    _verifiedOnly = currentQuery.isVerifiedOnly ?? false;
    _selectedAvailability = currentQuery.unitStatus;
    if (currentQuery.amenities != null) {
      _selectedAmenities.addAll(currentQuery.amenities!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advanced Property Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textP,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      ref
                          .read(propertySearchNotifierProvider.notifier)
                          .resetFilters();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: textP),
                  ),
                ],
              ),
            ],
          ),
          Divider(color: borderCol),
          Expanded(
            child: ListView(
              children: [
                // Sort By Section
                Text(
                  'Sort Results By',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textP,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  dropdownColor: surfaceBg,
                  style: TextStyle(color: textP, fontSize: 14),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: AppDesignSystem.borderRadiusM,
                      borderSide: BorderSide(color: borderCol),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppDesignSystem.borderRadiusM,
                      borderSide: BorderSide(color: borderCol),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _sortOptions.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value, style: TextStyle(color: textP)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _sortBy = val);
                  },
                ),
                const SizedBox(height: 20),

                // Location & Locality Section
                Text(
                  'Location & Locality',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textP,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _localities.contains(_selectedLocality)
                      ? _selectedLocality
                      : 'All Localities',
                  dropdownColor: surfaceBg,
                  style: TextStyle(color: textP, fontSize: 14),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: AppDesignSystem.borderRadiusM,
                      borderSide: BorderSide(color: borderCol),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppDesignSystem.borderRadiusM,
                      borderSide: BorderSide(color: borderCol),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _localities
                      .map(
                        (loc) => DropdownMenuItem(
                          value: loc,
                          child: Text(loc, style: TextStyle(color: textP)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLocality = val);
                  },
                ),
                const SizedBox(height: 20),

                // Listing Purpose Section
                Text(
                  'Listing Purpose',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textP,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['ALL', 'SALE', 'RENT', 'LEASE'].map((purpose) {
                    final isSelected = _listingPurpose == purpose;
                    return _buildFilterChoiceChip(purpose, isSelected, () {
                      setState(() => _listingPurpose = purpose);
                    });
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Budget Range Section
                Text(
                  'Budget Range: ₹${_budgetRange.start.round()} Lakhs - ₹${_budgetRange.end.round()} Lakhs',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textP,
                  ),
                ),
                RangeSlider(
                  values: _budgetRange,
                  min: 5,
                  max: 500,
                  divisions: 99,
                  activeColor: AppDesignSystem.brandGold,
                  inactiveColor: borderCol,
                  onChanged: (val) => setState(() => _budgetRange = val),
                ),
                const SizedBox(height: 16),

                // Property Category Section
                Text(
                  'Property Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textP,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      [
                        'ALL',
                        'RESIDENTIAL',
                        'COMMERCIAL',
                        'PLOTLAND',
                        'BUILDERPROJECT',
                      ].map((cat) {
                        final isSelected = _propertyType == cat;
                        return _buildFilterChoiceChip(cat, isSelected, () {
                          setState(() => _propertyType = cat);
                        });
                      }).toList(),
                ),
                const SizedBox(height: 16),

                // Commercial Subtype Section — Commercial Only
                if (_propertyType == 'COMMERCIAL') ...[
                  Text(
                    'Commercial Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['ALL', 'OFFICE', 'SHOP', 'SHOWROOM', 'WAREHOUSE']
                        .map((sub) {
                          final isSelected = _commercialSubtype == sub;
                          return _buildFilterChoiceChip(sub, isSelected, () {
                            setState(() => _commercialSubtype = sub);
                          });
                        })
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Land / Plot Subtype Section — Land Only
                if (_propertyType == 'PLOTLAND' || _propertyType == 'LAND') ...[
                  Text(
                    'Land / Plot Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                          'ALL',
                          'AGRICULTURAL',
                          'NON_NA',
                          'NA_APPROVED',
                          'RESIDENTIAL_PLOT',
                          'COMMERCIAL_PLOT',
                        ].map((sub) {
                          final isSelected = _landSubtype == sub;
                          final label = switch (sub) {
                            'AGRICULTURAL' => 'Agricultural',
                            'NON_NA' => 'Raw / Non-NA',
                            'NA_APPROVED' => 'NA Land',
                            'RESIDENTIAL_PLOT' => 'Residential Plot',
                            'COMMERCIAL_PLOT' => 'Commercial Plot',
                            _ => 'All Land',
                          };
                          return _buildFilterChoiceChip(label, isSelected, () {
                            setState(() => _landSubtype = sub);
                          });
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Bedrooms (BHK) Section — Residential Only
                if (_propertyType == 'ALL' ||
                    _propertyType == 'RESIDENTIAL') ...[
                  Text(
                    'Bedrooms (BHK)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['ALL', '1 BHK', '2 BHK', '3 BHK', '4+ BHK'].map((
                      bhk,
                    ) {
                      final isSelected = _bhk == bhk;
                      return _buildFilterChoiceChip(bhk, isSelected, () {
                        setState(() => _bhk = bhk);
                      });
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Amenities Section
                Text(
                  'Amenities & Features',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textP,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _availableAmenities.map((amenity) {
                    final isSelected = _selectedAmenities.contains(amenity);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedAmenities.remove(amenity);
                          } else {
                            _selectedAmenities.add(amenity);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppDesignSystem.brandGold
                              : (isDark
                                    ? const Color(0xFF1B2330)
                                    : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppDesignSystem.brandGold
                                : borderCol,
                          ),
                        ),
                        child: Text(
                          amenity,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected ? Colors.white : textP,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Verified Only Toggle
                SwitchListTile(
                  title: Text(
                    'RERA / Verified Listings Only',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textP,
                    ),
                  ),
                  subtitle: Text(
                    'Only show verified listings',
                    style: TextStyle(fontSize: 12, color: textS),
                  ),
                  value: _verifiedOnly,
                  activeThumbColor: AppDesignSystem.accentEmerald,
                  onChanged: (val) => setState(() => _verifiedOnly = val),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppDesignSystem.brandGold),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDesignSystem.borderRadiusM,
                    ),
                  ),
                  icon: const Icon(
                    Icons.bookmark_add_outlined,
                    size: 18,
                    color: AppDesignSystem.brandGold,
                  ),
                  label: const Text(
                    'Save Search',
                    style: TextStyle(
                      color: AppDesignSystem.brandGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _showSaveSearchDialog,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.brandGold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDesignSystem.borderRadiusM,
                    ),
                  ),
                  onPressed: _applyFilters,
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChoiceChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final isDark = AppDesignSystem.isDark(context);
    final textP = AppDesignSystem.textP(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppDesignSystem.brandGold
              : (isDark ? const Color(0xFF1B2330) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppDesignSystem.brandGold : borderCol,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : textP,
          ),
        ),
      ),
    );
  }

  SearchQueryEntity _buildQueryFromState() {
    final currentQuery = ref
        .read(propertySearchNotifierProvider.notifier)
        .currentQuery;
    PropertyCategory? category;
    if (_propertyType != 'ALL') {
      if (_propertyType == 'RESIDENTIAL')
        category = PropertyCategory.residential;
      if (_propertyType == 'COMMERCIAL') category = PropertyCategory.commercial;
      if (_propertyType == 'PLOTLAND') category = PropertyCategory.plotLand;
      if (_propertyType == 'BUILDERPROJECT')
        category = PropertyCategory.builderProject;
    }

    PropertySubtype? subtype;
    if (_propertyType == 'COMMERCIAL' && _commercialSubtype != 'ALL') {
      if (_commercialSubtype == 'OFFICE')
        subtype = PropertySubtype.commercialOffice;
      if (_commercialSubtype == 'SHOP')
        subtype = PropertySubtype.commercialShop;
      if (_commercialSubtype == 'SHOWROOM')
        subtype = PropertySubtype.commercialShowroom;
      if (_commercialSubtype == 'WAREHOUSE')
        subtype = PropertySubtype.warehouseGodown;
    }
    if ((_propertyType == 'PLOTLAND' || _propertyType == 'LAND') &&
        _landSubtype != 'ALL') {
      if (_landSubtype == 'AGRICULTURAL')
        subtype = PropertySubtype.agriculturalLand;
      if (_landSubtype == 'NON_NA') subtype = PropertySubtype.nonNaLand;
      if (_landSubtype == 'NA_APPROVED') subtype = PropertySubtype.naLand;
      if (_landSubtype == 'RESIDENTIAL_PLOT')
        subtype = PropertySubtype.residentialPlot;
      if (_landSubtype == 'COMMERCIAL_PLOT')
        subtype = PropertySubtype.commercialPlot;
    }

    ListingPurpose? purpose;
    if (_listingPurpose == 'SALE') purpose = ListingPurpose.forSale;
    if (_listingPurpose == 'RENT') purpose = ListingPurpose.forRent;
    if (_listingPurpose == 'LEASE') purpose = ListingPurpose.lease;

    int? bhkVal;
    if (_bhk == '1 BHK') bhkVal = 1;
    if (_bhk == '2 BHK') bhkVal = 2;
    if (_bhk == '3 BHK') bhkVal = 3;
    if (_bhk == '4+ BHK') bhkVal = 4;

    return currentQuery.copyWith(
      locality: _selectedLocality == 'All Localities'
          ? null
          : _selectedLocality,
      category: category,
      type: subtype,
      purpose: purpose,
      minPrice: _budgetRange.start,
      maxPrice: _budgetRange.end,
      minBedrooms: bhkVal,
      amenities: _selectedAmenities.isNotEmpty
          ? _selectedAmenities.toList()
          : null,
      unitStatus: _selectedAvailability,
      isVerifiedOnly: _verifiedOnly,
      sortBy: _sortBy,
      offset: 0,
    );
  }

  void _applyFilters() {
    final query = _buildQueryFromState();
    ref.read(propertySearchNotifierProvider.notifier).executeSearch(query);
    Navigator.pop(context);
  }

  void _showSaveSearchDialog() {
    final titleController = TextEditingController(
      text:
          '${_selectedLocality != 'All Localities' ? _selectedLocality : 'Belagavi'} ${_propertyType != 'ALL' ? _propertyType : 'Properties'}',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text(
            'Save Current Search',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Search Title',
              hintText: 'e.g. 3 BHK in Tilakwadi under 50L',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
              ),
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  final query = _buildQueryFromState();
                  ref
                      .read(savedSearchNotifierProvider.notifier)
                      .saveCurrentQuery(title, query);
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Search "$title" saved successfully'),
                    ),
                  );
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
