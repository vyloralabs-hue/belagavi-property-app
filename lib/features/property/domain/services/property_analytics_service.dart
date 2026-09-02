import 'dart:async';
import 'package:equatable/equatable.dart';

enum PropertyAnalyticsEventType {
  view,
  uniqueView,
  favoriteAdd,
  favoriteRemove,
  enquirySubmit,
  siteVisitRequest,
  offerSubmit,
  phoneReveal,
  share,
}

class PropertyAnalyticsEvent extends Equatable {
  final String id;
  final String propertyId;
  final String? userId;
  final String sessionId;
  final PropertyAnalyticsEventType eventType;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  const PropertyAnalyticsEvent({
    required this.id,
    required this.propertyId,
    this.userId,
    required this.sessionId,
    required this.eventType,
    this.metadata = const {},
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    propertyId,
    userId,
    sessionId,
    eventType,
    timestamp,
  ];
}

class PropertyPerformanceSummary extends Equatable {
  final String propertyId;
  final int totalViews;
  final int uniqueVisitors;
  final int totalFavorites;
  final int totalEnquiries;
  final int siteVisitRequests;
  final int offersSubmitted;
  final int phoneReveals;
  final double conversionRate; // (enquiries / views) * 100

  const PropertyPerformanceSummary({
    required this.propertyId,
    this.totalViews = 0,
    this.uniqueVisitors = 0,
    this.totalFavorites = 0,
    this.totalEnquiries = 0,
    this.siteVisitRequests = 0,
    this.offersSubmitted = 0,
    this.phoneReveals = 0,
    this.conversionRate = 0.0,
  });

  @override
  List<Object?> get props => [
    propertyId,
    totalViews,
    uniqueVisitors,
    totalFavorites,
    totalEnquiries,
    siteVisitRequests,
    offersSubmitted,
    phoneReveals,
    conversionRate,
  ];
}

/// Scalable, buffered property event ingestion service
class PropertyAnalyticsService {
  final List<PropertyAnalyticsEvent> _eventBuffer = [];
  final int _bufferCapacity;
  final Future<void> Function(List<PropertyAnalyticsEvent>)? _batchFlushHandler;

  PropertyAnalyticsService({
    int bufferCapacity = 50,
    Future<void> Function(List<PropertyAnalyticsEvent>)? batchFlushHandler,
  })  : _bufferCapacity = bufferCapacity,
        _batchFlushHandler = batchFlushHandler;

  List<PropertyAnalyticsEvent> get bufferedEvents =>
      List.unmodifiable(_eventBuffer);

  /// Track a real analytics event with buffering
  Future<void> trackEvent(PropertyAnalyticsEvent event) async {
    _eventBuffer.add(event);
    if (_eventBuffer.length >= _bufferCapacity) {
      await flush();
    }
  }

  /// Flush buffer to backend queue or persistent telemetry
  Future<void> flush() async {
    if (_eventBuffer.isEmpty) return;
    final batch = List<PropertyAnalyticsEvent>.from(_eventBuffer);
    _eventBuffer.clear();

    if (_batchFlushHandler != null) {
      try {
        await _batchFlushHandler(batch);
      } catch (_) {
        // Re-queue on failure if within limits
        if (_eventBuffer.length < _bufferCapacity * 2) {
          _eventBuffer.insertAll(0, batch);
        }
      }
    }
  }

  /// Aggregate event list into a structured performance funnel
  static PropertyPerformanceSummary aggregate(
    String propertyId,
    List<PropertyAnalyticsEvent> events,
  ) {
    final propertyEvents = events
        .where((e) => e.propertyId == propertyId)
        .toList();

    final totalViews = propertyEvents
        .where((e) => e.eventType == PropertyAnalyticsEventType.view)
        .length;
    final uniqueSessions = propertyEvents
        .map((e) => e.sessionId)
        .toSet()
        .length;
    final favorites = propertyEvents
        .where((e) => e.eventType == PropertyAnalyticsEventType.favoriteAdd)
        .length;
    final enquiries = propertyEvents
        .where((e) => e.eventType == PropertyAnalyticsEventType.enquirySubmit)
        .length;
    final visits = propertyEvents
        .where(
          (e) => e.eventType == PropertyAnalyticsEventType.siteVisitRequest,
        )
        .length;
    final offers = propertyEvents
        .where((e) => e.eventType == PropertyAnalyticsEventType.offerSubmit)
        .length;
    final phoneReveals = propertyEvents
        .where((e) => e.eventType == PropertyAnalyticsEventType.phoneReveal)
        .length;

    final conversionRate = totalViews > 0
        ? (enquiries / totalViews) * 100.0
        : 0.0;

    return PropertyPerformanceSummary(
      propertyId: propertyId,
      totalViews: totalViews,
      uniqueVisitors: uniqueSessions,
      totalFavorites: favorites,
      totalEnquiries: enquiries,
      siteVisitRequests: visits,
      offersSubmitted: offers,
      phoneReveals: phoneReveals,
      conversionRate: double.parse(conversionRate.toStringAsFixed(2)),
    );
  }
}
