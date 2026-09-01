/// Standardized Telemetry Event Constants for Closed-Beta Monitoring
class TelemetryEvents {
  // Auth Events
  static const String appOpen = 'app_open';
  static const String loginSuccess = 'login_success';
  static const String loginFailed = 'login_failed';
  static const String guestLogin = 'guest_login';
  static const String logout = 'logout';

  // Property Discovery Events
  static const String categoryOpen = 'category_open';
  static const String searchStarted = 'search_started';
  static const String searchCompleted = 'search_completed';
  static const String propertyOpened = 'property_opened';
  static const String propertyShared = 'property_shared';
  static const String propertyFavorited = 'property_favorited';

  // Listing Lifecycle Events
  static const String listingStarted = 'listing_started';
  static const String listingDraftSaved = 'listing_draft_saved';
  static const String listingSubmitted = 'listing_submitted';
  static const String listingEdited = 'listing_edited';
  static const String listingPaused = 'listing_paused';
  static const String listingResumed = 'listing_resumed';
  static const String listingDuplicated = 'listing_duplicated';
  static const String listingArchived = 'listing_archived';
  static const String listingDeleted = 'listing_deleted';

  // Moderation Events
  static const String listingApproved = 'listing_approved';
  static const String listingRejected = 'listing_rejected';
  static const String changesRequested = 'changes_requested';
  static const String listingHeld = 'listing_held';
  static const String listingRestored = 'listing_restored';

  // Dispute Events
  static const String propertyReported = 'property_reported';
  static const String disputeConfirmed = 'dispute_confirmed';
  static const String disputeResolved = 'dispute_resolved';

  // Contact & Lead Events
  static const String enquiryStarted = 'enquiry_started';
  static const String callAction = 'call_action';
  static const String contactAction = 'contact_action';

  // Error Events
  static const String searchError = 'search_error';
  static const String listingError = 'listing_error';
  static const String imageLoadError = 'image_load_error';
  static const String networkError = 'network_error';
  static const String authenticationError = 'authentication_error';

  // Feedback Events
  static const String feedbackOpened = 'feedback_opened';
  static const String feedbackSubmitted = 'feedback_submitted';
  static const String feedbackSubmissionFailed = 'feedback_submission_failed';
  static const String feedbackViewedByFounder = 'feedback_viewed_by_founder';
  static const String feedbackStatusChanged = 'feedback_status_changed';
  static const String feedbackResolved = 'feedback_resolved';
}
