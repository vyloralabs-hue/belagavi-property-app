import '../domain/entities/property_entities.dart';

class PropertyUnlockGuard {
  PropertyUnlockGuard._();

  /// Determines if a requesting user is authorized to view protected fields (exact location & contact info).
  static bool isUnlocked({
    required String? requestingUserId,
    required PropertyEntity property,
    required List<PropertyUnlockEntity> userUnlocks,
  }) {
    if (requestingUserId == null || requestingUserId.isEmpty) {
      return false;
    }

    // Property Owner always has access to full protected details of their own property
    if (requestingUserId == property.ownerId) {
      return true;
    }

    // Check for an active property unlock record
    final now = DateTime.now();
    return userUnlocks.any((unlock) {
      if (unlock.propertyId != property.id || unlock.userId != requestingUserId) {
        return false;
      }
      if (unlock.status != UnlockStatus.active) {
        return false;
      }
      if (unlock.expiresAt != null && unlock.expiresAt!.isBefore(now)) {
        return false;
      }
      return true;
    });
  }
}
