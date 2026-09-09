import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/config/legal_notice_config.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/legal_notice_entities.dart';

void main() {
  group('10-Day Public Notice Lifecycle & Expiry Tests', () {
    test('1. Default public notice days constant equals 10', () {
      expect(LegalNoticeConfig.defaultPublicNoticeDays, equals(10));
      expect(LegalNoticeConfig.defaultPublicNoticeDuration.inDays, equals(10));
    });

    test('2. calculatePublicUntil computes publishedAt + 10 days', () {
      final pubAt = DateTime(2026, 9, 1, 10, 0);
      final pubUntil = LegalNoticeConfig.calculatePublicUntil(pubAt);
      expect(pubUntil, equals(DateTime(2026, 9, 11, 10, 0)));
      expect(pubUntil.difference(pubAt).inDays, equals(10));
    });

    test('3. Notice is publicly active while within 10-day window', () {
      final now = DateTime.now();
      final notice = TransactionLegalNoticeEntity(
        id: 'not_active_1',
        title: 'Active Notice',
        locality: 'Tilakwadi',
        contactName: 'Counsel',
        contactPhone: '+91 99999 99999',
        verificationStatus: LegalNoticeStatus.published,
        publishedAt: now.subtract(const Duration(days: 3)),
        publicUntil: now.add(const Duration(days: 7)),
      );

      expect(notice.isPubliclyActive, isTrue);
      expect(notice.isExpiredFromPublicView, isFalse);
      expect(notice.remainingPublicDays, equals(7));
    });

    test('4. Notice is expired from public view when publicUntil is in the past', () {
      final now = DateTime.now();
      final notice = TransactionLegalNoticeEntity(
        id: 'not_expired_1',
        title: 'Expired Notice',
        locality: 'Camp',
        contactName: 'Counsel',
        contactPhone: '+91 99999 99999',
        verificationStatus: LegalNoticeStatus.published,
        publishedAt: now.subtract(const Duration(days: 12)),
        publicUntil: now.subtract(const Duration(days: 2)),
      );

      expect(notice.isPubliclyActive, isFalse);
      expect(notice.isExpiredFromPublicView, isTrue);
      expect(notice.remainingPublicDays, equals(0));
    });

    test('5. Non-published notices (draft, underReview) are not publicly active', () {
      const draftNotice = TransactionLegalNoticeEntity(
        id: 'not_draft_1',
        title: 'Draft Notice',
        locality: 'Shahapur',
        contactName: 'Counsel',
        contactPhone: '+91 99999 99999',
        verificationStatus: LegalNoticeStatus.draft,
        publishedAt: null,
        publicUntil: null,
      );

      expect(draftNotice.isPubliclyActive, isFalse);
      expect(draftNotice.isExpiredFromPublicView, isFalse);

      final reviewNotice = draftNotice.copyWith(
        verificationStatus: LegalNoticeStatus.underReview,
      );
      expect(reviewNotice.isPubliclyActive, isFalse);
    });

    test('6. Serialization (toMap/fromMap) preserves lifecycle timestamps', () {
      final pubAt = DateTime(2026, 9, 8, 12, 0, 0);
      final pubUntil = DateTime(2026, 9, 18, 12, 0, 0);
      final expAt = DateTime(2026, 9, 18, 12, 0, 0);

      final notice = TransactionLegalNoticeEntity(
        id: 'not_serial_1',
        title: 'Serial Notice',
        locality: 'Tilakwadi',
        contactName: 'Counsel',
        contactPhone: '+91 99999 99999',
        verificationStatus: LegalNoticeStatus.published,
        publishedAt: pubAt,
        publicUntil: pubUntil,
        expiredAt: expAt,
      );

      final map = notice.toMap();
      expect(map['publishedAt'], equals(pubAt.toIso8601String()));
      expect(map['publicUntil'], equals(pubUntil.toIso8601String()));
      expect(map['expiredAt'], equals(expAt.toIso8601String()));

      final reconstructed = TransactionLegalNoticeEntity.fromMap(map);
      expect(reconstructed.publishedAt, equals(pubAt));
      expect(reconstructed.publicUntil, equals(pubUntil));
      expect(reconstructed.expiredAt, equals(expAt));
      expect(reconstructed.remainingPublicDays, notice.remainingPublicDays);
    });

    test('7. toSupabaseMap outputs snake_case lifecycle columns', () {
      final pubAt = DateTime(2026, 9, 8, 12, 0, 0);
      final pubUntil = DateTime(2026, 9, 18, 12, 0, 0);

      final notice = TransactionLegalNoticeEntity(
        id: 'not_supa_1',
        title: 'Supa Notice',
        locality: 'Tilakwadi',
        contactName: 'Counsel',
        contactPhone: '+91 99999 99999',
        verificationStatus: LegalNoticeStatus.published,
        publishedAt: pubAt,
        publicUntil: pubUntil,
      );

      final supaMap = notice.toSupabaseMap();
      expect(supaMap['published_at'], equals(pubAt.toIso8601String()));
      expect(supaMap['public_until'], equals(pubUntil.toIso8601String()));
    });
  });
}
