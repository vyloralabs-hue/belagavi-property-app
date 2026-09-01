import 'package:equatable/equatable.dart';

class FavoriteCollectionEntity extends Equatable {
  final String id;
  final String userId;
  final String collectionName; // 'Saved', 'For Family', 'Investment', 'Visit Later', 'Compare Later', custom
  final String? description;
  final List<String> propertyIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FavoriteCollectionEntity({
    required this.id,
    required this.userId,
    required this.collectionName,
    this.description,
    this.propertyIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  FavoriteCollectionEntity copyWith({
    String? collectionName,
    String? description,
    List<String>? propertyIds,
    DateTime? updatedAt,
  }) {
    return FavoriteCollectionEntity(
      id: id,
      userId: userId,
      collectionName: collectionName ?? this.collectionName,
      description: description ?? this.description,
      propertyIds: propertyIds ?? this.propertyIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, collectionName, propertyIds, updatedAt];
}
