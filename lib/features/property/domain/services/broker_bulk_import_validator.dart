import 'package:equatable/equatable.dart';

class BulkImportRowError extends Equatable {
  final int rowIndex;
  final String? externalReference;
  final String fieldName;
  final String errorMessage;

  const BulkImportRowError({
    required this.rowIndex,
    this.externalReference,
    required this.fieldName,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [
    rowIndex,
    externalReference,
    fieldName,
    errorMessage,
  ];
}

class NormalizedBulkPropertyRow extends Equatable {
  final int rowIndex;
  final String externalReference;
  final String title;
  final String description;
  final String category;
  final String subtype;
  final String purpose;
  final double price;
  final String currency;
  final double area;
  final String areaUnit;
  final String city;
  final String locality;
  final String pincode;
  final int? bedrooms;
  final int? bathrooms;
  final double? latitude;
  final double? longitude;

  const NormalizedBulkPropertyRow({
    required this.rowIndex,
    required this.externalReference,
    required this.title,
    required this.description,
    required this.category,
    required this.subtype,
    required this.purpose,
    required this.price,
    this.currency = 'INR',
    required this.area,
    this.areaUnit = 'sqft',
    required this.city,
    required this.locality,
    required this.pincode,
    this.bedrooms,
    this.bathrooms,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    rowIndex,
    externalReference,
    title,
    category,
    subtype,
    price,
    city,
    locality,
    pincode,
    area,
  ];
}

class BulkImportValidationResult extends Equatable {
  final int totalRows;
  final List<NormalizedBulkPropertyRow> validRows;
  final List<BulkImportRowError> rejectedRows;
  final bool isBatchValid;

  const BulkImportValidationResult({
    required this.totalRows,
    required this.validRows,
    required this.rejectedRows,
    required this.isBatchValid,
  });

  @override
  List<Object?> get props => [totalRows, validRows, rejectedRows, isBatchValid];
}

class BrokerBulkImportValidator {
  static const int maxBatchSize = 500;

  /// Validate and normalize a batch of raw property rows from CSV / JSON
  static BulkImportValidationResult validateBatch(
    List<Map<String, dynamic>> rawRows,
  ) {
    if (rawRows.length > maxBatchSize) {
      return BulkImportValidationResult(
        totalRows: rawRows.length,
        validRows: const [],
        rejectedRows: [
          const BulkImportRowError(
            rowIndex: 0,
            fieldName: 'batch_size',
            errorMessage:
                'Batch exceeds maximum allowed size of $maxBatchSize rows.',
          ),
        ],
        isBatchValid: false,
      );
    }

    final valid = <NormalizedBulkPropertyRow>[];
    final rejected = <BulkImportRowError>[];
    final seenReferences = <String>{};

    for (int i = 0; i < rawRows.length; i++) {
      final row = rawRows[i];
      final rowIndex = i + 1;
      final extRef =
          (row['external_reference'] ?? row['ext_id'] ?? 'row_$rowIndex')
              .toString()
              .trim();

      // Check for duplicate external reference within the same batch
      if (seenReferences.contains(extRef)) {
        rejected.add(
          BulkImportRowError(
            rowIndex: rowIndex,
            externalReference: extRef,
            fieldName: 'external_reference',
            errorMessage: 'Duplicate external_reference "$extRef" in batch.',
          ),
        );
        continue;
      }
      seenReferences.add(extRef);

      // 1. Title validation
      final title = (row['title'] ?? '').toString().trim();
      if (title.length < 10) {
        rejected.add(
          BulkImportRowError(
            rowIndex: rowIndex,
            externalReference: extRef,
            fieldName: 'title',
            errorMessage: 'Title must be at least 10 characters long.',
          ),
        );
        continue;
      }

      // 2. Category & Subtype
      final category = (row['category'] ?? '').toString().trim().toLowerCase();
      final subtype = (row['subtype'] ?? '').toString().trim().toLowerCase();
      if (category.isEmpty || subtype.isEmpty) {
        rejected.add(
          BulkImportRowError(
            rowIndex: rowIndex,
            externalReference: extRef,
            fieldName: 'category',
            errorMessage: 'Both category and subtype must be specified.',
          ),
        );
        continue;
      }

      // 3. Price validation
      final rawPrice = row['price'];
      final price = (rawPrice is num)
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice?.toString() ?? '');
      if (price == null || price <= 0) {
        rejected.add(
          BulkImportRowError(
            rowIndex: rowIndex,
            externalReference: extRef,
            fieldName: 'price',
            errorMessage: 'Price must be a positive number.',
          ),
        );
        continue;
      }

      // 4. Area validation
      final rawArea = row['area'];
      final area = (rawArea is num)
          ? rawArea.toDouble()
          : double.tryParse(rawArea?.toString() ?? '');
      if (area == null || area <= 0) {
        rejected.add(
          BulkImportRowError(
            rowIndex: rowIndex,
            externalReference: extRef,
            fieldName: 'area',
            errorMessage: 'Area must be a positive number.',
          ),
        );
        continue;
      }

      // 5. Location validation
      final city = (row['city'] ?? '').toString().trim();
      final locality = (row['locality'] ?? '').toString().trim();
      final pincode = (row['pincode'] ?? '').toString().trim();
      if (city.isEmpty || locality.isEmpty || pincode.length < 6) {
        rejected.add(
          BulkImportRowError(
            rowIndex: rowIndex,
            externalReference: extRef,
            fieldName: 'location',
            errorMessage:
                'Valid city, locality, and 6-digit pincode are required.',
          ),
        );
        continue;
      }

      valid.add(
        NormalizedBulkPropertyRow(
          rowIndex: rowIndex,
          externalReference: extRef,
          title: title,
          description: (row['description'] ?? '').toString().trim(),
          category: category,
          subtype: subtype,
          purpose: (row['purpose'] ?? 'forSale').toString().trim(),
          price: price,
          currency: (row['currency'] ?? 'INR').toString().trim().toUpperCase(),
          area: area,
          areaUnit: (row['area_unit'] ?? 'sqft').toString().trim(),
          city: city,
          locality: locality,
          pincode: pincode,
          bedrooms: (row['bedrooms'] is num)
              ? (row['bedrooms'] as num).toInt()
              : int.tryParse(row['bedrooms']?.toString() ?? ''),
          bathrooms: (row['bathrooms'] is num)
              ? (row['bathrooms'] as num).toInt()
              : int.tryParse(row['bathrooms']?.toString() ?? ''),
          latitude: (row['latitude'] is num)
              ? (row['latitude'] as num).toDouble()
              : double.tryParse(row['latitude']?.toString() ?? ''),
          longitude: (row['longitude'] is num)
              ? (row['longitude'] as num).toDouble()
              : double.tryParse(row['longitude']?.toString() ?? ''),
        ),
      );
    }

    return BulkImportValidationResult(
      totalRows: rawRows.length,
      validRows: valid,
      rejectedRows: rejected,
      isBatchValid: rejected.isEmpty && valid.isNotEmpty,
    );
  }
}
