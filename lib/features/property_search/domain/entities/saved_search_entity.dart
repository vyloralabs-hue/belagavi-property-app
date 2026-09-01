import 'package:equatable/equatable.dart';
import 'search_entities.dart';

class SavedSearchEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final SearchQueryEntity query;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedSearchEntity({
    required this.id,
    this.userId = '',
    required this.title,
    required this.query,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Generates a clean, 100% deterministic local summary string (0 AI)
  String get deterministicSummary {
    final parts = <String>[];

    if (query.minBedrooms != null) {
      parts.add('${query.minBedrooms} BHK');
    }
    if (query.category != null) {
      parts.add(query.category!.name.toUpperCase());
    } else if (query.type != null) {
      parts.add(query.type!.name);
    } else {
      parts.add('Properties');
    }

    final loc = query.locality ?? query.city ?? query.district ?? query.state ?? query.country;
    if (loc != null && loc.isNotEmpty) {
      parts.add('in $loc');
    }

    if (query.purpose != null) {
      parts.add('• ${query.purpose!.name.toUpperCase()}');
    }

    if (query.minPrice != null || query.maxPrice != null) {
      final minStr = query.minPrice != null ? '₹${query.minPrice!.toInt()}L' : '₹0';
      final maxStr = query.maxPrice != null ? '₹${query.maxPrice!.toInt()}L' : 'Max';
      parts.add('• $minStr–$maxStr');
    }

    return parts.join(' ');
  }

  SavedSearchEntity copyWith({
    String? userId,
    String? title,
    SearchQueryEntity? query,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return SavedSearchEntity(
      id: id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      query: query ?? this.query,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'query': query.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SavedSearchEntity.fromJson(Map<String, dynamic> json) {
    return SavedSearchEntity(
      id: json['id'] as String,
      userId: (json['userId'] ?? json['user_id'] ?? '') as String,
      title: (json['title'] ?? json['name'] ?? 'Saved Search') as String,
      query: SearchQueryEntity.fromJson(Map<String, dynamic>.from(json['query'] ?? json['query_json'] ?? {})),
      isActive: (json['isActive'] ?? json['is_active'] ?? true) as bool,
      createdAt: DateTime.parse((json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()) as String),
      updatedAt: DateTime.parse((json['updatedAt'] ?? json['updated_at'] ?? DateTime.now().toIso8601String()) as String),
    );
  }

  @override
  List<Object?> get props => [id, userId, title, query, isActive, createdAt, updatedAt];
}
