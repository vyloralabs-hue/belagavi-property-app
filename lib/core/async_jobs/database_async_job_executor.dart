import 'dart:async';
import 'async_job_engine.dart';

class JobLeaseLock {
  final String jobId;
  final String workerId;
  final DateTime acquiredAt;
  final DateTime expiresAt;

  const JobLeaseLock({
    required this.jobId,
    required this.workerId,
    required this.acquiredAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Production-ready backend Async Job Executor supporting concurrency locks and lease timeouts
class DatabaseAsyncJobExecutor {
  final Map<String, AsyncJobEntity> _persistentJobStore = {};
  final Map<String, JobLeaseLock> _activeLeases = {};
  final Map<JobType, JobHandler> _registeredWorkers = {};
  final Duration defaultLeaseDuration;

  DatabaseAsyncJobExecutor({
    this.defaultLeaseDuration = const Duration(seconds: 30),
  });

  void registerWorker(JobType type, JobHandler handler) {
    _registeredWorkers[type] = handler;
  }

  /// Atomically submit a job
  Future<AsyncJobEntity> submitJob(AsyncJobEntity job) async {
    // Idempotency: if job ID exists and is completed or leased, return existing record
    if (_persistentJobStore.containsKey(job.id)) {
      final existing = _persistentJobStore[job.id]!;
      if (existing.status == JobStatus.completed || existing.status == JobStatus.processing) {
        return existing;
      }
    }

    _persistentJobStore[job.id] = job;
    return job;
  }

  /// Atomically claim a pending job with a lease lock
  Future<AsyncJobEntity?> claimNextJob({
    required String workerId,
    JobType? preferredType,
  }) async {
    final now = DateTime.now();

    for (final entry in _persistentJobStore.entries) {
      final job = entry.value;

      // Filter by type if specified
      if (preferredType != null && job.type != preferredType) continue;

      // Check if job is eligible: queued OR (processing with expired lease)
      final existingLease = _activeLeases[job.id];
      final isAvailable = job.status == JobStatus.queued ||
          (job.status == JobStatus.processing && existingLease != null && existingLease.isExpired);

      if (isAvailable) {
        // Atomic Lease Acquisition
        final lease = JobLeaseLock(
          jobId: job.id,
          workerId: workerId,
          acquiredAt: now,
          expiresAt: now.add(defaultLeaseDuration),
        );
        _activeLeases[job.id] = lease;

        final claimedJob = job.copyWith(
          status: JobStatus.processing,
          startedAt: now,
          attemptCount: job.attemptCount + 1,
        );
        _persistentJobStore[job.id] = claimedJob;
        return claimedJob;
      }
    }

    return null; // No available jobs
  }

  /// Execute a claimed job with error capture, bounded retry, and lease release
  Future<void> executeJob(AsyncJobEntity job, {required String workerId}) async {
    final lease = _activeLeases[job.id];
    if (lease == null || lease.workerId != workerId) {
      throw StateError('Worker $workerId does not hold a valid lease for job ${job.id}');
    }

    final handler = _registeredWorkers[job.type];
    if (handler == null) {
      _persistentJobStore[job.id] = job.copyWith(
        status: JobStatus.failed,
        lastError: 'No worker registered for ${job.type.name}',
        completedAt: DateTime.now(),
      );
      _activeLeases.remove(job.id);
      return;
    }

    try {
      await handler(job);
      _persistentJobStore[job.id] = job.copyWith(
        status: JobStatus.completed,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      final canRetry = job.attemptCount < job.maxAttempts;
      if (canRetry) {
        _persistentJobStore[job.id] = job.copyWith(
          status: JobStatus.queued,
          lastError: e.toString(),
        );
      } else {
        _persistentJobStore[job.id] = job.copyWith(
          status: JobStatus.deadLetter,
          lastError: 'Dead letter after ${job.maxAttempts} attempts: $e',
          completedAt: DateTime.now(),
        );
      }
    } finally {
      _activeLeases.remove(job.id);
    }
  }

  AsyncJobEntity? getJob(String jobId) => _persistentJobStore[jobId];
}
