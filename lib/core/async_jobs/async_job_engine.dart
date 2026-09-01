import 'dart:async';
import 'dart:math';
import 'package:equatable/equatable.dart';

enum JobType {
  imageProcessing,
  searchIndex,
  savedSearchMatch,
  notificationDispatch,
  analyticsFlush,
  translation,
  fraudScan,
  bulkImport,
}

enum JobStatus {
  queued,
  processing,
  completed,
  failed,
  deadLetter,
}

class AsyncJobEntity extends Equatable {
  final String id;
  final JobType type;
  final Map<String, dynamic> payload;
  final JobStatus status;
  final int attemptCount;
  final int maxAttempts;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? lastError;

  const AsyncJobEntity({
    required this.id,
    required this.type,
    required this.payload,
    this.status = JobStatus.queued,
    this.attemptCount = 0,
    this.maxAttempts = 3,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.lastError,
  });

  /// Calculates exponential backoff duration based on attempt count
  Duration get retryDelay {
    final seconds = pow(2, attemptCount.clamp(0, 6)).toInt();
    return Duration(seconds: seconds);
  }

  AsyncJobEntity copyWith({
    JobStatus? status,
    int? attemptCount,
    DateTime? startedAt,
    DateTime? completedAt,
    String? lastError,
  }) {
    return AsyncJobEntity(
      id: id,
      type: type,
      payload: payload,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      maxAttempts: maxAttempts,
      createdAt: createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        attemptCount,
        maxAttempts,
        createdAt,
        startedAt,
        completedAt,
        lastError,
      ];
}

typedef JobHandler = Future<void> Function(AsyncJobEntity job);

/// Lightweight asynchronous job queue and dispatcher
class AsyncJobQueueService {
  final Map<String, AsyncJobEntity> _jobRegistry = {};
  final List<String> _queue = [];
  final Map<JobType, JobHandler> _handlers = {};
  bool _isProcessing = false;

  int get queueDepth => _queue.length;
  List<AsyncJobEntity> get allJobs => _jobRegistry.values.toList();

  void registerHandler(JobType type, JobHandler handler) {
    _handlers[type] = handler;
  }

  /// Enqueue an asynchronous background job idempotently
  Future<AsyncJobEntity> enqueue({
    required String jobId,
    required JobType type,
    required Map<String, dynamic> payload,
    int maxAttempts = 3,
  }) async {
    // Idempotency: if job already exists and is completed/processing, return existing
    if (_jobRegistry.containsKey(jobId)) {
      final existing = _jobRegistry[jobId]!;
      if (existing.status == JobStatus.completed || existing.status == JobStatus.processing) {
        return existing;
      }
    }

    final job = AsyncJobEntity(
      id: jobId,
      type: type,
      payload: payload,
      status: JobStatus.queued,
      maxAttempts: maxAttempts,
      createdAt: DateTime.now(),
    );

    _jobRegistry[jobId] = job;
    _queue.add(jobId);

    // Trigger queue processing asynchronously
    scheduleMicrotask(() => processNext());

    return job;
  }

  /// Process next item in the queue with bounded retry and backoff
  Future<void> processNext() async {
    if (_isProcessing || _queue.isEmpty) return;
    _isProcessing = true;

    try {
      final jobId = _queue.removeAt(0);
      final job = _jobRegistry[jobId];
      if (job == null) return;

      final updatedJob = job.copyWith(
        status: JobStatus.processing,
        startedAt: DateTime.now(),
        attemptCount: job.attemptCount + 1,
      );
      _jobRegistry[jobId] = updatedJob;

      final handler = _handlers[job.type];
      if (handler == null) {
        _jobRegistry[jobId] = updatedJob.copyWith(
          status: JobStatus.failed,
          lastError: 'No registered handler for job type ${job.type.name}',
          completedAt: DateTime.now(),
        );
        return;
      }

      try {
        await handler(updatedJob);
        _jobRegistry[jobId] = updatedJob.copyWith(
          status: JobStatus.completed,
          completedAt: DateTime.now(),
        );
      } catch (e) {
        final hasRetriesLeft = updatedJob.attemptCount < updatedJob.maxAttempts;
        if (hasRetriesLeft) {
          _jobRegistry[jobId] = updatedJob.copyWith(
            status: JobStatus.queued,
            lastError: e.toString(),
          );
          // Re-queue for retry
          _queue.add(jobId);
        } else {
          _jobRegistry[jobId] = updatedJob.copyWith(
            status: JobStatus.deadLetter,
            lastError: 'Max retry attempts (${updatedJob.maxAttempts}) reached: $e',
            completedAt: DateTime.now(),
          );
        }
      }
    } finally {
      _isProcessing = false;
      if (_queue.isNotEmpty) {
        scheduleMicrotask(() => processNext());
      }
    }
  }
}
