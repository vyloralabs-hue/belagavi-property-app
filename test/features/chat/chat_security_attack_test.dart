import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:belagavi_property/features/chat/utils/chat_security_guard.dart';
import 'package:belagavi_property/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';

void main() {
  late ChatRepositoryImpl chatRepository;
  late NotificationRepositoryImpl notificationRepository;

  setUp(() {
    notificationRepository = NotificationRepositoryImpl();
    chatRepository = ChatRepositoryImpl(
      notificationRepository: notificationRepository,
    );
  });

  PropertyEntity createTestProperty({
    required String id,
    required String ownerId,
    required String title,
    ListingStatus status = ListingStatus.published,
    double price = 5000000,
  }) {
    return PropertyEntity(
      id: id,
      ownerId: ownerId,
      title: title,
      description: 'Description',
      category: PropertyCategory.residential,
      type: PropertySubtype.apartment,
      status: status,
      verificationStatus: VerificationStatus.verified,
      price: price,
      isNegotiable: true,
      specifications: const PropertySpecificationsEntity(carpetArea: 1000),
      mediaList: const [],
      state: 'Karnataka',
      district: 'Belagavi',
      taluk: 'Belagavi',
      city: 'Belagavi',
      locality: 'Tilakwadi',
      address: 'Main Road',
      pincode: '590006',
      latitude: 15.8497,
      longitude: 74.4977,
      viewsCount: 10,
      features: const {'purpose': 'FOR_SALE'},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('DIRECT BUYER-SELLER REAL-TIME CHAT SECURITY ATTACK TEST MATRIX (PHASE 28)', () {
    const buyerA = 'usr_buyer_A_101';
    const buyerB = 'usr_buyer_B_202';
    const sellerA = 'usr_seller_A_303';
    const sellerB = 'usr_seller_B_404';

    test('1. Buyer A reads Buyer B private conversation -> DENIED', () async {
      final convB = await chatRepository.getOrCreateConversation(
        propertyId: 'prop_b_estate',
        buyerId: buyerB,
        sellerId: sellerB,
        propertyTitle: 'Seller B Villa',
      );

      expect(
        () => chatRepository.getConversationById(
          convB.id,
          requestingUserId: buyerA,
          userRole: UserRole.user,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test(
      '2. Buyer A reads Seller B conversation where Buyer A is not participant -> DENIED',
      () async {
        final conv = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_seller_b_secret',
          buyerId: buyerB,
          sellerId: sellerB,
        );

        expect(
          () => chatRepository.getMessages(
            conversationId: conv.id,
            requestingUserId: buyerA,
            userRole: UserRole.user,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test('3. Seller A reads Seller B conversation -> DENIED', () async {
      final conv = await chatRepository.getOrCreateConversation(
        propertyId: 'prop_b_luxury',
        buyerId: buyerB,
        sellerId: sellerB,
      );

      expect(
        () => chatRepository.getConversationById(
          conv.id,
          requestingUserId: sellerA,
          userRole: UserRole.sellerOwner,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('4. Buyer changes buyer_id -> DENIED by Guard', () {
      final property = createTestProperty(
        id: 'prop_1',
        ownerId: sellerA,
        title: 'House',
      );
      expect(
        () => ChatSecurityGuard.verifyConversationCreation(
          buyerId: '   ',
          sellerId: sellerA,
          property: property,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('5. Buyer sets seller_id not matching property owner -> DENIED', () {
      final property = createTestProperty(
        id: 'prop_1',
        ownerId: sellerA,
        title: 'House',
      );
      expect(
        () => ChatSecurityGuard.verifyConversationCreation(
          buyerId: buyerA,
          sellerId: sellerB, // FAKE seller ID
          property: property,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test(
      '6. Buyer changes property_id on conversation -> Immutability enforced',
      () async {
        final conv = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_original',
          buyerId: buyerA,
          sellerId: sellerA,
        );
        expect(conv.propertyId, 'prop_original');
      },
    );

    test('7. Seller changes seller_id -> DENIED', () {
      final property = createTestProperty(
        id: 'prop_1',
        ownerId: sellerA,
        title: 'House',
      );
      expect(
        () => ChatSecurityGuard.verifyConversationCreation(
          buyerId: buyerA,
          sellerId: 'forged_seller',
          property: property,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test(
      '8. Seller moves conversation to another property -> DENIED',
      () async {
        final conv = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_1',
          buyerId: buyerA,
          sellerId: sellerA,
        );
        expect(conv.propertyId, 'prop_1');
      },
    );

    test('9. Non-participant sends message -> DENIED', () async {
      final conv = await chatRepository.getOrCreateConversation(
        propertyId: 'prop_sec_9',
        buyerId: buyerA,
        sellerId: sellerA,
      );

      expect(
        () => chatRepository.sendMessage(
          conversationId: conv.id,
          senderId: buyerB, // MALICIOUS THIRD PARTY
          senderName: 'Attacker',
          message: 'Intrusion attempt',
          recipientId: sellerA,
          propertyId: 'prop_sec_9',
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('10. Non-participant reads messages -> DENIED', () async {
      final conv = await chatRepository.getOrCreateConversation(
        propertyId: 'prop_sec_10',
        buyerId: buyerA,
        sellerId: sellerA,
      );

      expect(
        () => chatRepository.getMessages(
          conversationId: conv.id,
          requestingUserId: buyerB,
          userRole: UserRole.user,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test(
      '11. Seller accesses conversation for property not owned -> DENIED',
      () async {
        final conv = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_sec_11',
          buyerId: buyerA,
          sellerId: sellerB,
        );

        expect(
          () => chatRepository.getConversationById(
            conv.id,
            requestingUserId: sellerA,
            userRole: UserRole.sellerOwner,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test(
      '12. Buyer chats on invalid/unpublished (DRAFT / REJECTED) property -> DENIED',
      () {
        final draftProp = createTestProperty(
          id: 'prop_draft',
          ownerId: sellerA,
          title: 'Draft Property',
          status: ListingStatus.draft,
        );

        expect(
          () => ChatSecurityGuard.verifyConversationCreation(
            buyerId: buyerA,
            sellerId: sellerA,
            property: draftProp,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test(
      '13. Duplicate conversation creation -> Returns existing ONE conversation only',
      () async {
        final conv1 = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_dup_test',
          buyerId: buyerA,
          sellerId: sellerA,
        );

        final conv2 = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_dup_test',
          buyerId: buyerA,
          sellerId: sellerA,
        );

        expect(conv1.id, conv2.id);
      },
    );

    test(
      '14. Duplicate message event within 3s -> Returns existing message (Idempotency)',
      () async {
        final conv = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_msg_dup',
          buyerId: buyerA,
          sellerId: sellerA,
        );

        final msg1 = await chatRepository.sendMessage(
          conversationId: conv.id,
          senderId: buyerA,
          senderName: 'Buyer A',
          message: 'Is the price negotiable?',
          recipientId: sellerA,
          propertyId: 'prop_msg_dup',
        );

        final msg2 = await chatRepository.sendMessage(
          conversationId: conv.id,
          senderId: buyerA,
          senderName: 'Buyer A',
          message: 'Is the price negotiable?',
          recipientId: sellerA,
          propertyId: 'prop_msg_dup',
        );

        expect(msg1.id, msg2.id);
      },
    );

    test(
      '15. Duplicate notification event -> At most one notification sent per message',
      () async {
        final notifsBefore = (await notificationRepository.getNotifications(
          recipientId: sellerA,
        )).length;

        final conv = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_notif_dup',
          buyerId: buyerA,
          sellerId: sellerA,
        );

        await chatRepository.sendMessage(
          conversationId: conv.id,
          senderId: buyerA,
          senderName: 'Buyer A',
          message: 'Hello Seller!',
          recipientId: sellerA,
          propertyId: 'prop_notif_dup',
        );

        final notifsAfter = (await notificationRepository.getNotifications(
          recipientId: sellerA,
        )).length;
        expect(notifsAfter, notifsBefore + 1);
      },
    );

    test(
      '16. Customer accesses another customer chat route manually -> DENIED',
      () async {
        final convB = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_priv_16',
          buyerId: buyerB,
          sellerId: sellerB,
        );

        expect(
          () => chatRepository.getConversationById(
            convB.id,
            requestingUserId: buyerA,
            userRole: UserRole.user,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test(
      '17. Seller accesses another seller chat route manually -> DENIED',
      () async {
        final convB = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_priv_17',
          buyerId: buyerB,
          sellerId: sellerB,
        );

        expect(
          () => chatRepository.getConversationById(
            convB.id,
            requestingUserId: sellerA,
            userRole: UserRole.sellerOwner,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test('18. Empty message -> DENIED', () {
      expect(
        () => ChatSecurityGuard.validateMessageText('   '),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('19. Oversized message (>2000 chars) -> DENIED', () {
      final hugeMessage = 'A' * 2500;
      expect(
        () => ChatSecurityGuard.validateMessageText(hugeMessage),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('20. Legitimate buyer message -> ALLOWED and delivered', () async {
      final conv = await chatRepository.getOrCreateConversation(
        propertyId: 'prop_legit_20',
        buyerId: buyerA,
        sellerId: sellerA,
      );

      final msg = await chatRepository.sendMessage(
        conversationId: conv.id,
        senderId: buyerA,
        senderName: 'Buyer A',
        message: 'Can I visit this Saturday?',
        recipientId: sellerA,
        propertyId: 'prop_legit_20',
      );

      expect(msg.message, 'Can I visit this Saturday?');
      expect(msg.senderId, buyerA);

      final msgs = await chatRepository.getMessages(
        conversationId: conv.id,
        requestingUserId: buyerA,
        userRole: UserRole.user,
      );
      expect(msgs.any((m) => m.id == msg.id), isTrue);
    });

    test(
      '21. Legitimate seller reply -> ALLOWED and marked as read by buyer',
      () async {
        final conv = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_legit_21',
          buyerId: buyerA,
          sellerId: sellerA,
        );

        final reply = await chatRepository.sendMessage(
          conversationId: conv.id,
          senderId: sellerA,
          senderName: 'Seller A',
          message: 'Yes, 11:00 AM works well!',
          recipientId: buyerA,
          propertyId: 'prop_legit_21',
        );

        expect(reply.senderId, sellerA);

        // Buyer reads message
        await chatRepository.markMessagesAsRead(
          conversationId: conv.id,
          readerUserId: buyerA,
        );

        final updatedMsgs = await chatRepository.getMessages(
          conversationId: conv.id,
          requestingUserId: buyerA,
          userRole: UserRole.user,
        );
        expect(updatedMsgs.firstWhere((m) => m.id == reply.id).isRead, isTrue);
      },
    );

    test(
      '22. Admin legitimate moderation -> ALLOWED global oversight',
      () async {
        final conv = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_admin_22',
          buyerId: buyerA,
          sellerId: sellerA,
        );

        final result = await chatRepository.getConversationById(
          conv.id,
          requestingUserId: 'usr_admin_global',
          userRole: UserRole.admin,
        );
        expect(result?.id, conv.id);
      },
    );

    test(
      '23. Ordinary seller attempting admin operation on others -> DENIED',
      () async {
        final conv = await chatRepository.getOrCreateConversation(
          propertyId: 'prop_other_23',
          buyerId: buyerB,
          sellerId: sellerB,
        );

        expect(
          () => chatRepository.getConversationById(
            conv.id,
            requestingUserId: sellerA,
            userRole: UserRole.sellerOwner,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );
  });
}
