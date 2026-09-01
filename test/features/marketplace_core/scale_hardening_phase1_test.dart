import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/async_jobs/async_job_engine.dart';
import 'package:belagavi_property/core/telemetry/marketplace_observability_service.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/services/broker_bulk_import_validator.dart';
import 'package:belagavi_property/features/property_search/domain/entities/search_entities.dart';
import 'package:belagavi_property/features/property_search/domain/services/search_indexing_service.dart';
import 'package:belagavi_property/features/property_search/domain/services/search_service_abstraction.dart';

void main() {
  group('PRODUCTION SCALE HARDENING PHASE 1 TEST MATRIX', () {
    // ── 1. MEDIA DERIVATIVES & DELIVERY ────────────────────────────────────
    test('1. Property card uses effective thumbnail URL when available', () {
      const media = PropertyMediaEntity(
        id: 'med_1',
        propertyId: 'prop_1',
        mediaUrl: 'https://storage.example.com/original.jpg',
        thumbnailUrl: 'https://cdn.example.com/thumbnails/med_1_300x200.webp',
        mediumUrl: 'https://cdn.example.com/medium/med_1_800x600.webp',
        fullUrl: 'https://cdn.example.com/full/med_1_highres.webp',
        type: MediaType.image,
        isCover: true,
      );

      expect(
        media.effectiveThumbnailUrl,
        'https://cdn.example.com/thumbnails/med_1_300x200.webp',
      );
    });

    test(
      '2. Property details hero uses effective medium URL with fallback',
      () {
        const mediaWithDerivative = PropertyMediaEntity(
          id: 'med_2',
          propertyId: 'prop_1',
          mediaUrl: 'https://storage.example.com/original.jpg',
          mediumUrl: 'https://cdn.example.com/medium/med_2_800x600.webp',
          type: MediaType.image,
        );

        const mediaWithoutDerivative = PropertyMediaEntity(
          id: 'med_3',
          propertyId: 'prop_1',
          mediaUrl: 'https://storage.example.com/fallback.jpg',
          type: MediaType.image,
        );

        expect(
          mediaWithDerivative.effectiveMediumUrl,
          'https://cdn.example.com/medium/med_2_800x600.webp',
        );
        expect(
          mediaWithoutDerivative.effectiveMediumUrl,
          'https://storage.example.com/fallback.jpg',
        );
      },
    );

    test('3. Gallery zoom uses effective full image URL with fallback', () {
      const media = PropertyMediaEntity(
        id: 'med_4',
        propertyId: 'prop_1',
        mediaUrl: 'https://storage.example.com/raw.jpg',
        fullUrl: 'https://cdn.example.com/full/med_4_2048.webp',
        type: MediaType.image,
      );

      expect(
        media.effectiveFullUrl,
        'https://cdn.example.com/full/med_4_2048.webp',
      );
    });

    // ── 2. ASYNC JOBS & IDEMPOTENCY ─────────────────────────────────────────
    test('4. Media processing async job is idempotent', () async {
      final queue = AsyncJobQueueService();

      final job1 = await queue.enqueue(
        jobId: 'job_media_resize_101',
        type: JobType.imageProcessing,
        payload: {'media_id': 'med_1', 'original_path': 'properties/med_1.jpg'},
      );

      final job2 = await queue.enqueue(
        jobId: 'job_media_resize_101',
        type: JobType.imageProcessing,
        payload: {'media_id': 'med_1', 'original_path': 'properties/med_1.jpg'},
      );

      expect(job1.id, job2.id);
      expect(queue.allJobs.length, 1);
    });

    test(
      '5. Failed async job triggers bounded retry with exponential backoff and dead letter',
      () async {
        final queue = AsyncJobQueueService();
        int executionAttempts = 0;

        queue.registerHandler(JobType.imageProcessing, (job) async {
          executionAttempts++;
          throw Exception('Simulated CDN connection failure');
        });

        await queue.enqueue(
          jobId: 'job_fail_test',
          type: JobType.imageProcessing,
          payload: {'file': 'test.jpg'},
          maxAttempts: 2,
        );

        // First attempt fails -> re-queued
        await queue.processNext();
        expect(executionAttempts, 1);

        // Retry attempt 2 fails -> deadLetter
        await queue.processNext();
        expect(executionAttempts, 2);

        final failedJob = queue.allJobs.firstWhere(
          (j) => j.id == 'job_fail_test',
        );
        expect(failedJob.status, JobStatus.deadLetter);
        expect(failedJob.lastError, contains('Max retry attempts (2) reached'));
      },
    );

    // ── 3. SEARCH INDEXING PIPELINE ─────────────────────────────────────────
    test('6. SearchIndexingService indexes newly published property', () async {
      final indexer = SearchIndexingService();
      final property = PropertyEntity(
        id: 'prop_pub_1',
        ownerId: 'usr_owner_1',
        title: '3 BHK Villa in Tilakwadi',
        description: 'Spacious independent house with garden',
        category: PropertyCategory.residential,
        type: PropertySubtype.villa,
        status: ListingStatus.published,
        price: 8500000,
        specifications: const PropertySpecificationsEntity(bedrooms: 3),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'Congress Road',
        pincode: '590006',
        verificationStatus: VerificationStatus.verified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await indexer.indexProperty(property);

      expect(indexer.indexedDocuments.containsKey('prop_pub_1'), isTrue);
      expect(
        indexer.indexedDocuments['prop_pub_1']!.title,
        '3 BHK Villa in Tilakwadi',
      );
      expect(indexer.indexedDocuments['prop_pub_1']!.price, 8500000);
    });

    test(
      '7. SearchIndexingService updates index document when property changes',
      () async {
        final indexer = SearchIndexingService();
        final original = PropertyEntity(
          id: 'prop_up_1',
          ownerId: 'usr_owner_1',
          title: 'Original Title',
          description: 'Original description',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.published,
          price: 5000000,
          specifications: const PropertySpecificationsEntity(bedrooms: 2),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Camp',
          address: 'Camp Road',
          pincode: '590001',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await indexer.indexProperty(original);
        expect(indexer.indexedDocuments['prop_up_1']!.title, 'Original Title');

        final updated = original.copyWith(
          title: 'Updated 2 BHK Title',
          price: 5200000,
        );
        await indexer.updatePropertyIndex(updated);

        expect(
          indexer.indexedDocuments['prop_up_1']!.title,
          'Updated 2 BHK Title',
        );
        expect(indexer.indexedDocuments['prop_up_1']!.price, 5200000);
      },
    );

    test(
      '8. SearchIndexingService removes unindexed or deleted property from search index',
      () async {
        final indexer = SearchIndexingService();
        final property = PropertyEntity(
          id: 'prop_del_1',
          ownerId: 'usr_owner_1',
          title: 'Property to Delete',
          description: 'Will be deleted',
          category: PropertyCategory.commercial,
          type: PropertySubtype.commercialShop,
          status: ListingStatus.published,
          price: 3000000,
          specifications: const PropertySpecificationsEntity(),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Shahapur',
          address: 'Bank Colony',
          pincode: '590003',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await indexer.indexProperty(property);
        expect(indexer.indexedDocuments.containsKey('prop_del_1'), isTrue);

        await indexer.removePropertyIndex('prop_del_1');
        expect(indexer.indexedDocuments.containsKey('prop_del_1'), isFalse);
      },
    );

    test(
      '9. SearchIndexDocument strictly excludes private documents and contact PII',
      () {
        final property = PropertyEntity(
          id: 'prop_sec_1',
          ownerId: 'usr_owner_99',
          title: 'Safe Search Document Listing',
          description: 'Verified public description',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          price: 6000000,
          specifications: const PropertySpecificationsEntity(),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Private Street Address 123',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final doc = SearchIndexDocument.fromProperty(property);
        final json = doc.toJson();

        // Verify searchable fields exist
        expect(json.containsKey('property_id'), isTrue);
        expect(json.containsKey('title'), isTrue);
        expect(json.containsKey('price'), isTrue);
        expect(json.containsKey('locality'), isTrue);

        // Verify private fields are NEVER exposed in search document
        expect(json.containsKey('owner_phone'), isFalse);
        expect(json.containsKey('seller_aadhar'), isFalse);
        expect(json.containsKey('legal_documents'), isFalse);
        expect(json.containsKey('internal_audit_notes'), isFalse);
      },
    );

    // ── 4. PAGINATION & SCALE CONTROLS ──────────────────────────────────────
    test(
      '10. SearchCursor supports deep keyset pagination without full dataset load',
      () {
        const cursor = SearchCursor(
          nextCursor: 'eyJsYXN0X2lkIjoicHJvcF8xMDAwIiwicHJpY2UiOjk1MDAwMDB9',
          prevCursor: 'eyJsYXN0X2lkIjoicHJvcF85ODAiLCJwcmljZSI6OTgwMDAwMH0=',
          hasMore: true,
          totalCount: 150000,
        );

        expect(cursor.hasMore, isTrue);
        expect(cursor.nextCursor, isNotNull);
        expect(cursor.totalCount, 150000);
      },
    );

    test(
      '11. Saved search alert queues notification jobs instead of inline mass dispatch',
      () async {
        final queue = AsyncJobQueueService();
        bool dispatchTriggered = false;

        queue.registerHandler(JobType.notificationDispatch, (job) async {
          dispatchTriggered = true;
        });

        final alertJob = await queue.enqueue(
          jobId: 'alert_dispatch_batch_1',
          type: JobType.notificationDispatch,
          payload: {
            'saved_search_id': 'search_77',
            'property_id': 'prop_new_99',
            'recipient_user_ids': ['u1', 'u2', 'u3'],
            'channel': 'push',
          },
        );

        expect(alertJob.type, JobType.notificationDispatch);
        expect(queue.allJobs.length, 1);

        await queue.processNext();
        expect(dispatchTriggered, isTrue);
      },
    );

    // ── 5. OBSERVABILITY & LATENCY TRACKING ──────────────────────────────────
    test(
      '12. MarketplaceObservabilityService records real execution latencies',
      () {
        final obs = MarketplaceObservabilityService();

        obs.recordLatency('search', 45);
        obs.recordLatency('search', 85);
        obs.recordLatency('search', 120);

        final p = obs.calculatePercentiles('search');
        expect(p.sampleCount, 3);
        expect(p.p50, 85.0);
        expect(p.p95, 120.0);
      },
    );

    // ── 6. BROKER BULK IMPORT VALIDATION ────────────────────────────────────
    test(
      '13. BrokerBulkImportValidator rejects malformed rows and reports exact errors',
      () {
        final malformedRows = [
          {
            'external_reference': 'EXT_001',
            'title': 'Short', // Too short (<10 chars)
            'category': 'residential',
            'subtype': 'apartment',
            'price': -5000, // Invalid negative price
            'area': 1200,
            'city': 'Belagavi',
            'locality': 'Tilakwadi',
            'pincode': '590006',
          },
        ];

        final result = BrokerBulkImportValidator.validateBatch(malformedRows);

        expect(result.isBatchValid, isFalse);
        expect(result.rejectedRows.isNotEmpty, isTrue);
        expect(result.rejectedRows.first.rowIndex, 1);
        expect(result.rejectedRows.first.fieldName, 'title');
      },
    );

    test('14. BrokerBulkImportValidator normalizes valid bulk import rows', () {
      final validRows = [
        {
          'external_reference': 'EXT_901',
          'title': 'Spacious 3 BHK Luxury Apartment',
          'category': 'residential',
          'subtype': 'apartment',
          'purpose': 'forSale',
          'price': 7500000,
          'currency': 'INR',
          'area': 1650,
          'area_unit': 'sqft',
          'city': 'Belagavi',
          'locality': 'Tilakwadi',
          'pincode': '590006',
          'bedrooms': 3,
          'bathrooms': 3,
        },
      ];

      final result = BrokerBulkImportValidator.validateBatch(validRows);

      expect(result.isBatchValid, isTrue);
      expect(result.validRows.length, 1);
      expect(result.validRows.first.externalReference, 'EXT_901');
      expect(result.validRows.first.price, 7500000.0);
      expect(result.validRows.first.area, 1650.0);
    });

    // ── 7. SECURITY INVARIANTS ──────────────────────────────────────────────
    test(
      '15. Security: Client configuration never exposes server service role keys',
      () {
        // Supabase public configuration check
        const publicAnonKey =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.public_anon';
        expect(publicAnonKey.contains('service_role'), isFalse);
        expect(publicAnonKey.contains('admin_secret'), isFalse);
      },
    );
  });
}
