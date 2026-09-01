import 'package:equatable/equatable.dart';

enum SharedShortlistRole { viewer, contributor, admin }

class ShortlistMember extends Equatable {
  final String userId;
  final String displayName;
  final SharedShortlistRole role;
  final DateTime joinedAt;

  const ShortlistMember({
    required this.userId,
    required this.displayName,
    required this.role,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [userId, displayName, role];
}

class ShortlistComment extends Equatable {
  final String id;
  final String propertyId;
  final String authorUserId;
  final String authorName;
  final String commentText;
  final DateTime createdAt;

  const ShortlistComment({
    required this.id,
    required this.propertyId,
    required this.authorUserId,
    required this.authorName,
    required this.commentText,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, propertyId, authorUserId, commentText, createdAt];
}

class SharedShortlistEntity extends Equatable {
  final String id;
  final String title;
  final String creatorUserId;
  final List<ShortlistMember> members;
  final List<String> propertyIds;
  final List<ShortlistComment> comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SharedShortlistEntity({
    required this.id,
    required this.title,
    required this.creatorUserId,
    required this.members,
    this.propertyIds = const [],
    this.comments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  SharedShortlistEntity copyWith({
    String? title,
    List<ShortlistMember>? members,
    List<String>? propertyIds,
    List<ShortlistComment>? comments,
    DateTime? updatedAt,
  }) {
    return SharedShortlistEntity(
      id: id,
      title: title ?? this.title,
      creatorUserId: creatorUserId,
      members: members ?? this.members,
      propertyIds: propertyIds ?? this.propertyIds,
      comments: comments ?? this.comments,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, creatorUserId, members, propertyIds, comments, updatedAt];
}
