import 'package:equatable/equatable.dart';

enum AdPlacement {
  homeTop,
  homeMiddle,
  homeBottom,
  propertyList,
  propertyDetail,
  searchResults,
  builderSection,
  projectSection,
}

enum AdStatus {
  draft,
  scheduled,
  active,
  paused,
  expired,
  archived,
}

class AdvertisementEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? videoUrl;
  final String businessName;
  final String? targetUrl;
  final AdPlacement placement;
  final AdStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final int priority; // 1 (Highest), 2, 3...
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdvertisementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.videoUrl,
    required this.businessName,
    this.targetUrl,
    this.placement = AdPlacement.homeMiddle,
    this.status = AdStatus.draft,
    required this.startDate,
    required this.endDate,
    this.priority = 1,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  bool isActiveNow(DateTime now) {
    if (status == AdStatus.paused || status == AdStatus.archived || status == AdStatus.draft) {
      return false;
    }
    if (now.isBefore(startDate)) return false;
    if (now.isAfter(endDate)) return false;
    return true;
  }

  AdvertisementEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? videoUrl,
    String? businessName,
    String? targetUrl,
    AdPlacement? placement,
    AdStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? priority,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdvertisementEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      businessName: businessName ?? this.businessName,
      targetUrl: targetUrl ?? this.targetUrl,
      placement: placement ?? this.placement,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        videoUrl,
        businessName,
        targetUrl,
        placement,
        status,
        startDate,
        endDate,
        priority,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
