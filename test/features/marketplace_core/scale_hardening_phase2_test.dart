import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/async_jobs/async_job_engine.dart';
import 'package:belagavi_property/core/async_jobs/database_async_job_executor.dart';
import 'package:belagavi_property/core/telemetry/marketplace_observability_service.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property_search/domain/services/search_indexing_service.dart';
import '../../../staging/staging_data_generator.dart';
import '../../../staging/staging_cleanup_tool.dart';

void main() {
  group('SCALE HARDENING PHASE 2: STAGING, WORKERS & OBSERVABILITY TEST MATRIX', () {
    // ── 1. PRODUCTION TARGET REJECTION ─────────────────────────────────────
    test('1. StagingCleanupTool strictly rejects production target URLs', () {
      expect(
        () => StagingCleanupTool.buildSafeCleanupQuery(
          testRunId: 'run_999',
          targetDatabaseUrl: 'https://prod.belagaviproperty.com/db',
        ),
        throwsA(isA<SecurityException>()),
      );

      expect(
        () => StagingCleanupTool.buildSafeCleanupQuery(
          testRunId: 'run_999',
          targetDatabaseUrl: 'https://production-cluster.supabase.co',
        ),
        throwsA(isA<SecurityException>()),
      );

      // Safe staging target
      final safeSql = StagingCleanupTool.buildSafeCleanupQuery(
        testRunId: 'run_staging_101',
        targetDatabaseUrl: 'https://staging-project.supabase.co',
        isStagingFlag: true,
      );
      expect(safeSql, contains("test_run_id = 'run_staging_101'"));
    });

    // ── 2. WORKER JOB LEASE LOCKING & CONCURRENCY ──────────────────────────
    test(
      '2. DatabaseAsyncJobExecutor acquires atomic lease and prevents double claim',
      () async {
        final executor = DatabaseAsyncJobExecutor();

        final job = AsyncJobEntity(
          id: 'job_lease_test_1',
          type: JobType.imageProcessing,
          payload: {'media_id': 'med_123'},
          createdAt: DateTime.now(),
        );

        await executor.submitJob(job);

        // Worker A claims job
        final claimedByA = await executor.claimNextJob(
          workerId: 'worker_node_alpha',
        );
        expect(claimedByA, isNotNull);
        expect(claimedByA!.id, 'job_lease_test_1');
        expect(claimedByA.status, JobStatus.processing);

        // Worker B attempts to claim same job -> should get null (already leased)
        final claimedByB = await executor.claimNextJob(
          workerId: 'worker_node_beta',
        );
        expect(claimedByB, isNull);
      },
    );

    // ── 3. WORKER IDEMPOTENCY ──────────────────────────────────────────────
    test(
      '3. DatabaseAsyncJobExecutor is idempotent on duplicate submissions',
      () async {
        final executor = DatabaseAsyncJobExecutor();

        final job = AsyncJobEntity(
          id: 'job_idempotent_1',
          type: JobType.searchIndex,
          payload: {'property_id': 'prop_abc'},
          createdAt: DateTime.now(),
        );

        final firstSubmission = await executor.submitJob(job);
        final duplicateSubmission = await executor.submitJob(job);

        expect(firstSubmission.id, duplicateSubmission.id);
      },
    );

    // ── 4. RETRY BOUNDED & EXPONENTIAL BACKOFF ─────────────────────────────
    test('4. AsyncJobEntity calculates exponential backoff retry delays', () {
      final attempt0 = AsyncJobEntity(
        id: 'j0',
        type: JobType.analyticsFlush,
        payload: const {},
        attemptCount: 0,
        createdAt: DateTime.now(),
      );
      final attempt1 = AsyncJobEntity(
        id: 'j1',
        type: JobType.analyticsFlush,
        payload: const {},
        attemptCount: 1,
        createdAt: DateTime.now(),
      );
      final attempt2 = AsyncJobEntity(
        id: 'j2',
        type: JobType.analyticsFlush,
        payload: const {},
        attemptCount: 2,
        createdAt: DateTime.now(),
      );
      final attempt3 = AsyncJobEntity(
        id: 'j3',
        type: JobType.analyticsFlush,
        payload: const {},
        attemptCount: 3,
        createdAt: DateTime.now(),
      );

      expect(attempt0.retryDelay.inSeconds, 1); // 2^0 = 1s
      expect(attempt1.retryDelay.inSeconds, 2); // 2^1 = 2s
      expect(attempt2.retryDelay.inSeconds, 4); // 2^2 = 4s
      expect(attempt3.retryDelay.inSeconds, 8); // 2^3 = 8s
    });

    // ── 5. DEAD-LETTER QUEUE TRANSITION ────────────────────────────────────
    test(
      '5. DatabaseAsyncJobExecutor transitions exhausted jobs to deadLetter',
      () async {
        final executor = DatabaseAsyncJobExecutor();

        executor.registerWorker(JobType.fraudScan, (job) async {
          throw Exception('Simulated AI model timeout');
        });

        final job = AsyncJobEntity(
          id: 'job_deadletter_test',
          type: JobType.fraudScan,
          payload: {'property_id': 'prop_fail'},
          maxAttempts: 2,
          createdAt: DateTime.now(),
        );

        await executor.submitJob(job);

        // Attempt 1: fails, re-queued
        final claim1 = await executor.claimNextJob(workerId: 'worker_1');
        await executor.executeJob(claim1!, workerId: 'worker_1');
        expect(
          executor.getJob('job_deadletter_test')!.status,
          JobStatus.queued,
        );

        // Attempt 2: fails -> maxAttempts (2) reached -> deadLetter
        final claim2 = await executor.claimNextJob(workerId: 'worker_1');
        await executor.executeJob(claim2!, workerId: 'worker_1');

        final finalJob = executor.getJob('job_deadletter_test');
        expect(finalJob!.status, JobStatus.deadLetter);
        expect(finalJob.lastError, contains('Dead letter after 2 attempts'));
      },
    );

    // ── 6. MEDIA DERIVATIVE METADATA ───────────────────────────────────────
    test(
      '6. PropertyMediaEntity encapsulates derivative dimensions and processing status',
      () {
        const media = PropertyMediaEntity(
          id: 'med_derivative_1',
          propertyId: 'prop_deriv_100',
          mediaUrl: 'https://storage.example.com/raw/p100.jpg',
          thumbnailUrl: 'https://cdn.example.com/thumb/p100_300x200.webp',
          mediumUrl: 'https://cdn.example.com/med/p100_800x600.webp',
          width: 1920,
          height: 1080,
          fileSize: 245000,
          mimeType: 'image/webp',
          processingStatus: MediaProcessingStatus.ready,
          type: MediaType.image,
        );

        expect(media.thumbnailUrl, contains('300x200.webp'));
        expect(media.mediumUrl, contains('800x600.webp'));
        expect(media.processingStatus, MediaProcessingStatus.ready);
        expect(media.width, 1920);
        expect(media.height, 1080);
      },
    );

    // ── 7. SEARCH INDEXING ON PUBLISH ──────────────────────────────────────
    test(
      '7. SearchIndexingService compiles public index document on publish',
      () async {
        final indexer = SearchIndexingService();
        final property = PropertyEntity(
          id: 'prop_index_pub',
          ownerId: 'usr_pub_1',
          title: '3 BHK Modern Flat in Camp',
          description: 'Excellent residential unit',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.published,
          price: 7200000,
          specifications: const PropertySpecificationsEntity(bedrooms: 3),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Camp',
          address: 'Camp Bazar',
          pincode: '590001',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await indexer.indexProperty(property);
        expect(indexer.indexedDocuments.containsKey('prop_index_pub'), isTrue);
        expect(
          indexer.indexedDocuments['prop_index_pub']!.title,
          '3 BHK Modern Flat in Camp',
        );
      },
    );

    // ── 8. SEARCH INDEXING ON UPDATE ───────────────────────────────────────
    test(
      '8. SearchIndexingService updates search document on modification',
      () async {
        final indexer = SearchIndexingService();
        final original = PropertyEntity(
          id: 'prop_index_up',
          ownerId: 'usr_up_1',
          title: 'Initial Title',
          description: 'Desc',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.published,
          price: 5000000,
          specifications: const PropertySpecificationsEntity(),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Addr',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await indexer.indexProperty(original);
        final updated = original.copyWith(
          title: 'Revised 2 BHK Flat',
          price: 5400000,
        );
        await indexer.updatePropertyIndex(updated);

        expect(
          indexer.indexedDocuments['prop_index_up']!.title,
          'Revised 2 BHK Flat',
        );
        expect(indexer.indexedDocuments['prop_index_up']!.price, 5400000);
      },
    );

    // ── 9. SEARCH INDEXING ON UNPUBLISH / DELETE ───────────────────────────
    test(
      '9. SearchIndexingService unpublishes document when status becomes draft or archived',
      () async {
        final indexer = SearchIndexingService();
        final property = PropertyEntity(
          id: 'prop_index_del',
          ownerId: 'usr_del_1',
          title: 'Listed Property',
          description: 'Desc',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.published,
          price: 4000000,
          specifications: const PropertySpecificationsEntity(),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Addr',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await indexer.indexProperty(property);
        expect(indexer.indexedDocuments.containsKey('prop_index_del'), isTrue);

        // Status changed to draft -> automatically unindexed
        final unpub = property.copyWith(status: ListingStatus.draft);
        await indexer.updatePropertyIndex(unpub);
        expect(indexer.indexedDocuments.containsKey('prop_index_del'), isFalse);
      },
    );

    // ── 10. OBSERVABILITY INSTRUMENTATION ──────────────────────────────────
    test(
      '10. MarketplaceObservabilityService records real latency percentiles',
      () {
        final obs = MarketplaceObservabilityService();

        for (int i = 1; i <= 50; i++) {
          obs.recordLatency('property_write', (i * 10)); // 10ms to 500ms
        }

        final percentiles = obs.calculatePercentiles('property_write');
        expect(percentiles.sampleCount, 50);
        expect(percentiles.p50, closeTo(250.0, 15.0));
        expect(percentiles.p95, closeTo(470.0, 20.0));
      },
    );

    // ── 11. SYNTHETIC DATA TAGGING ─────────────────────────────────────────
    test(
      '11. StagingDataGenerator creates synthetic records tagged with test_run_id',
      () {
        final batch = StagingDataGenerator.generateBatch(
          testRunId: 'benchmark_run_2026_08',
          count: 25,
        );

        expect(batch.length, 25);
        for (final record in batch) {
          expect(record.testRunId, 'benchmark_run_2026_08');
          expect(record.property.id, contains('synth_benchmark_run_2026_08_'));
          expect(
            record.toDatabaseRow()['test_run_id'],
            'benchmark_run_2026_08',
          );
        }
      },
    );

    // ── 12. CLEANUP RESTRICTED TO TEST_RUN_ID ──────────────────────────────
    test(
      '12. StagingCleanupTool scopes deletion queries strictly to test_run_id',
      () {
        final sql = StagingCleanupTool.buildSafeCleanupQuery(
          testRunId: 'perf_run_42',
          targetDatabaseUrl: 'https://staging.belagaviproperty.com/db',
          isStagingFlag: true,
        );

        expect(sql, contains("WHERE test_run_id = 'perf_run_42'"));
        expect(sql, isNot(contains("TRUNCATE TABLE")));
        expect(sql, isNot(contains("DROP TABLE")));
      },
    );
  });
}
