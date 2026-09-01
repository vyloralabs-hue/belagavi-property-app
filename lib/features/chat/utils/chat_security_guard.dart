import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import '../domain/entities/chat_entities.dart';

class ChatSecurityGuard {
  ChatSecurityGuard._();

  /// Verifies that the user is an authorized participant (Buyer, Seller, or Admin/Founder).
  static void verifyParticipant({
    required String? requestingUserId,
    required PropertyConversationEntity conversation,
    UserRole? userRole,
    String actionName = 'access this conversation',
  }) {
    if (requestingUserId == null || requestingUserId.trim().isEmpty) {
      throw const AccessDeniedException('Authentication required to access messages.');
    }

    if (userRole != null && userRole.isAdminOrFounder) {
      return;
    }

    if (requestingUserId != conversation.buyerId && requestingUserId != conversation.sellerId) {
      throw AccessDeniedException(
        'Access Denied: You are not an authorized participant to $actionName.',
      );
    }
  }

  /// Validates message payload to prevent empty or abusive spam.
  static String validateMessageText(String? rawMessage) {
    if (rawMessage == null) {
      throw const AccessDeniedException('Message cannot be null.');
    }
    final trimmed = rawMessage.trim();
    if (trimmed.isEmpty) {
      throw const AccessDeniedException('Message cannot be empty or whitespace-only.');
    }
    if (trimmed.length > 2000) {
      throw const AccessDeniedException('Message exceeds maximum limit of 2000 characters.');
    }
    return trimmed;
  }

  /// Verifies property eligibility for starting a direct chat.
  static void verifyPropertyChatEligibility(PropertyEntity property) {
    final isPublic = property.status == ListingStatus.published ||
        property.status == ListingStatus.active ||
        property.status == ListingStatus.approved;

    if (!isPublic) {
      throw AccessDeniedException(
        'Chat is unavailable: Listing "${property.id}" is not in active published status.',
      );
    }
  }

  /// Validates new conversation initiation constraints.
  static void verifyConversationCreation({
    required String buyerId,
    required String sellerId,
    required PropertyEntity property,
  }) {
    if (buyerId.trim().isEmpty) {
      throw const AccessDeniedException('Buyer authentication required to start a chat.');
    }
    if (buyerId == sellerId || buyerId == property.ownerId) {
      throw const AccessDeniedException('You cannot initiate a chat on your own property.');
    }
    if (sellerId != property.ownerId) {
      throw const AccessDeniedException('Seller ID must match the verified property owner.');
    }
    verifyPropertyChatEligibility(property);
  }
}
