/// Centralized application route definitions for PropertyHub.
abstract class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String auth = '/auth';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String enableBiometric = '/enable-biometric';
  static const String biometricUnlock = '/biometric-unlock';
  static const String selectRole = '/select-role';
  static const String home = '/home';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String builders = '/builders';
  static const String projects = '/projects';
  static const String subscriptions = '/subscriptions';
  static const String payment = '/payment';
  static const String adsManagement = '/ads-management';
  static const String founderDashboard = '/founder-dashboard';
  static const String crm = '/crm';

  // Property Owner / Management routes
  static const String addProperty = '/add-property';
  static const String myProperties = '/my-properties';
  static const String adminProperties = '/admin-properties';

  // Builder Project Management routes
  static const String builderProjects = '/builder-projects';
  static const String createProject = '/create-project';

  // Support routes
  static const String support = '/support';
  static const String supportFaq = '/support/faq';
  static const String supportDocs = '/support/docs';
  static const String supportAppointment = '/support/appointment';
  static const String supportVerification = '/support/verification';
  static const String supportTickets = '/support/tickets';

  // Legal & Dispute routes
  static const String disputedProperties = '/disputed-properties';
  static const String myDisputedProperties = '/my-disputed-properties';
  static const String addDispute = '/dispute/add';
  static const String legalNotices = '/legal-notices';
  static const String addLegalNotice = '/legal-notice/add';

  // Transaction & Enquiry routes
  static const String myEnquiries = '/my-enquiries';
  static const String sellerEnquiries = '/seller-enquiries';

  // Document & Due Diligence routes
  static const String propertyDocuments = '/property-documents/:propertyId';
  static const String dueDiligence = '/due-diligence/:propertyId';

  // Notifications
  static const String notifications = '/notifications';

  // Real-Time Chat & Messages
  static const String messages = '/messages';
  static const String chat = '/chat/:conversationId';
}
