import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/presentation_ui/navigation/main_navigation_shell.dart';
import '../../features/presentation_ui/views/auth/auth_screen.dart';
import '../../features/presentation_ui/views/auth/biometric_login_view.dart';
import '../../features/presentation_ui/views/auth/biometric_unlock_view.dart';
import '../../features/presentation_ui/views/auth/login_view.dart';
import '../../features/presentation_ui/views/auth/otp_verification_view.dart';
import '../../features/presentation_ui/views/auth/role_selection_view.dart';
import '../../features/presentation_ui/views/auth/welcome_view.dart';
import '../../features/presentation_ui/views/crm_dashboard/broker_builder_crm_dashboard_view.dart';
import '../../features/presentation_ui/views/favorites/favorites_view.dart';
import '../../features/presentation_ui/views/home/premium_home_view.dart';
import '../../features/presentation_ui/views/onboarding/location_permission_view.dart';
import '../../features/presentation_ui/views/onboarding/onboarding_view.dart';
import '../../features/presentation_ui/views/onboarding/theme_selection_view.dart';
import '../../features/presentation_ui/views/profile/user_profile_view.dart';
import '../../features/presentation_ui/views/property_details/property_details_view.dart';
import '../../features/presentation_ui/views/search/smart_property_search_view.dart';
import '../../features/presentation_ui/views/search/saved_searches_view.dart';
import '../../features/presentation_ui/views/splash/splash_view.dart';
import '../../features/support/presentation/screens/support_home_view.dart';
import '../../features/support/presentation/screens/support_faq_view.dart';
import '../../features/support/presentation/screens/support_documentation_view.dart';
import '../../features/support/presentation/screens/support_appointment_view.dart';
import '../../features/support/presentation/screens/support_verification_view.dart';
import '../../features/auth/utils/auth_session_storage_helper.dart';
import '../../features/support/presentation/screens/support_my_tickets_view.dart';
import '../../features/presentation_ui/views/builders/builders_view.dart';
import '../../features/presentation_ui/views/property/builder/builder_project_list_view.dart';
import '../../features/presentation_ui/views/property/builder/create_project_wizard_view.dart';
import '../../features/presentation_ui/views/projects/projects_view.dart';
import '../../features/presentation_ui/views/monetization/subscription_plans_view.dart';
import '../../features/presentation_ui/views/monetization/payment_gateway_view.dart';
import '../../features/presentation_ui/views/admin/ads_management_view.dart';
import '../../features/presentation_ui/views/admin/founder_dashboard_view.dart';
import '../../features/presentation_ui/views/admin/property_verification_queue_view.dart';
import '../../features/presentation_ui/views/property/add_property_wizard_view.dart';
import '../../features/presentation_ui/views/property/category_landing_view.dart';
import '../../features/presentation_ui/views/property/admin_property_management_view.dart';
import '../../features/presentation_ui/views/property/my_properties_list_view.dart';
import '../../features/presentation_ui/views/discovery/location_discovery_view.dart';
import '../../features/legal_dispute/presentation/views/disputed_properties_list_view.dart';
import '../../features/legal_dispute/presentation/views/disputed_property_detail_view.dart';
import '../../features/legal_dispute/presentation/views/add_disputed_property_view.dart';
import '../../features/legal_dispute/presentation/views/my_disputed_properties_view.dart';
import '../../features/legal_dispute/presentation/views/legal_notice_hub_view.dart';
import '../../features/legal_dispute/presentation/views/add_legal_notice_view.dart';
import '../../features/legal_dispute/presentation/views/legal_notice_detail_view.dart';
import '../../features/presentation_ui/views/notifications/notification_center_view.dart';
import '../../features/transaction/presentation/views/buyer_enquiries_view.dart';
import '../../features/transaction/presentation/views/seller_enquiries_view.dart';
import '../../features/transaction/presentation/views/enquiry_detail_workflow_view.dart';
import '../../features/property/presentation/views/property_documents_management_view.dart';
import '../../features/property/presentation/views/property_due_diligence_view.dart';
import '../../features/property/domain/entities/property_entities.dart';
import '../../features/presentation_ui/views/chat/chat_conversation_view.dart';
import '../../features/presentation_ui/views/chat/user_conversations_list_view.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Whitelisted unauthenticated authentication & onboarding routes
  const unprotectedRoutes = {
    '',
    '/',
    '/splash',
    '/welcome',
    '/auth',
    '/login',
    '/otp-verification',
    '/enable-biometric',
    '/biometric-unlock',
    '/onboarding',
    '/select-role',
    '/location-permission',
    '/theme-selection',
  };

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      try {
        final isLoggedIn = AuthSessionStorageHelper.isLoggedIn();
        final path = state.matchedLocation;
        final uriPath = state.uri.path;

        final isPublicAuthRoute =
            path.isEmpty ||
            path == '/' ||
            uriPath.isEmpty ||
            uriPath == '/' ||
            uriPath == '/splash' ||
            unprotectedRoutes.contains(path) ||
            unprotectedRoutes.contains(uriPath);

        if (!isLoggedIn && !isPublicAuthRoute) {
          final target = state.uri.toString();
          return '/auth?redirect=${Uri.encodeComponent(target)}';
        }
        return null;
      } catch (e) {
        debugPrint('GoRouter redirect exception caught: $e');
        return null;
      }
    },
    routes: [
      // ─── Root Route ───────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) => const SplashView(),
      ),

      // ─── Screen 1: Splash ────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashView(),
      ),

      // ─── Screen 2: Welcome ───────────────────────────────────────────────
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeView(),
      ),

      // ─── Screen 3: Authentication ─────────────────────────────────────────
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Mobile login sub-screen (phone number entry)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),

      // ─── Screen 4: OTP Verification ──────────────────────────────────────
      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpVerificationView(
            mobileNumber: phone.isNotEmpty ? phone : '+91 98765 43210',
          );
        },
      ),

      // Biometric quick unlock screen (Startup unlock)
      GoRoute(
        path: '/biometric-unlock',
        name: 'biometric-unlock',
        builder: (context, state) => const BiometricUnlockView(),
      ),

      // Biometric enable screen (Setup after login)
      GoRoute(
        path: '/enable-biometric',
        name: 'enable-biometric',
        builder: (context, state) => const BiometricLoginView(),
      ),

      // ─── Screen 5: User Type Selection ───────────────────────────────────
      GoRoute(
        path: '/select-role',
        name: 'select-role',
        builder: (context, state) => const RoleSelectionView(),
      ),

      // ─── Screen 6: Location Permission ───────────────────────────────────
      GoRoute(
        path: '/location-permission',
        name: 'location-permission',
        builder: (context, state) => const LocationPermissionView(),
      ),

      // ─── Screen 7: Theme Selection ────────────────────────────────────────
      GoRoute(
        path: '/theme-selection',
        name: 'theme-selection',
        builder: (context, state) => const ThemeSelectionView(),
      ),

      // Onboarding (legacy — kept for compatibility)
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingView(),
      ),

      // ─── CRM, Support, Builders, Projects, etc. ───────────────────────────
      GoRoute(
        path: '/crm',
        name: 'crm',
        builder: (context, state) =>
            const BrokerBuilderCRMDashboardView(userId: 'usr_broker_1'),
      ),
      GoRoute(
        path: AppRoutes.support,
        name: 'support',
        builder: (context, state) => const SupportHomeView(),
      ),
      GoRoute(
        path: AppRoutes.supportFaq,
        name: 'support-faq',
        builder: (context, state) => const SupportFAQView(),
      ),
      GoRoute(
        path: AppRoutes.supportDocs,
        name: 'support-docs',
        builder: (context, state) => const SupportDocumentationView(),
      ),
      GoRoute(
        path: AppRoutes.supportAppointment,
        name: 'support-appointment',
        builder: (context, state) => const SupportAppointmentView(),
      ),
      GoRoute(
        path: AppRoutes.supportVerification,
        name: 'support-verification',
        builder: (context, state) => const SupportVerificationView(),
      ),
      GoRoute(
        path: AppRoutes.supportTickets,
        name: 'support-tickets',
        builder: (context, state) => const SupportMyTicketsView(),
      ),
      GoRoute(
        path: AppRoutes.builders,
        name: 'builders',
        builder: (context, state) => const PremiumBuildersView(),
      ),
      GoRoute(
        path: AppRoutes.builderProjects,
        name: 'builder-projects',
        builder: (context, state) => const BuilderProjectListView(),
      ),
      GoRoute(
        path: AppRoutes.createProject,
        name: 'create-project',
        builder: (context, state) => const CreateProjectWizardView(),
      ),
      GoRoute(
        path: AppRoutes.projects,
        name: 'projects',
        builder: (context, state) => const PremiumProjectsView(),
      ),
      GoRoute(
        path: AppRoutes.subscriptions,
        name: 'subscriptions',
        builder: (context, state) => const SubscriptionPlansView(),
      ),
      GoRoute(
        path: AppRoutes.payment,
        name: 'payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentGatewayView(
            planName: extra?['planName'] as String? ?? 'Standard Plan',
            amount: extra?['amount'] as String? ?? '₹599',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adsManagement,
        name: 'ads-management',
        builder: (context, state) => const AdsManagementView(),
      ),
      GoRoute(
        path: AppRoutes.founderDashboard,
        name: 'founder-dashboard',
        builder: (context, state) => const FounderDashboardView(),
      ),
      GoRoute(
        path: '/admin/moderation',
        name: 'founder-moderation',
        builder: (context, state) => const PropertyVerificationQueueView(),
      ),
      GoRoute(
        path: '/category/:categoryKey',
        name: 'category-landing',
        builder: (context, state) {
          final catKey = state.pathParameters['categoryKey'] ?? 'residential';
          return CategoryLandingView(categoryKey: catKey);
        },
      ),
      GoRoute(
        path: AppRoutes.addProperty,
        name: 'add-property',
        builder: (context, state) {
          final catString = state.uri.queryParameters['category'];
          PropertyCategory? category;
          if (catString != null && catString.isNotEmpty) {
            category = PropertyCategory.values.firstWhere(
              (c) => c.name.toLowerCase() == catString.toLowerCase(),
              orElse: () => PropertyCategory.residential,
            );
          }
          final editProp = state.extra as PropertyEntity?;
          return AddPropertyWizardView(
            initialCategory: category,
            editProperty: editProp,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.disputedProperties,
        name: 'disputed-properties',
        builder: (context, state) => const DisputedPropertiesListView(),
      ),
      GoRoute(
        path: AppRoutes.myDisputedProperties,
        name: 'my-disputed-properties',
        builder: (context, state) => const MyDisputedPropertiesView(),
      ),
      GoRoute(
        path: AppRoutes.addDispute,
        name: 'add-dispute',
        builder: (context, state) => const AddDisputedPropertyView(),
      ),
      GoRoute(
        path: '/disputed-properties/:id',
        name: 'disputed-property-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'disp_101';
          return DisputedPropertyDetailView(disputeId: id);
        },
      ),
      GoRoute(
        path: '/dispute/:id',
        name: 'dispute-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'disp_101';
          return DisputedPropertyDetailView(disputeId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.legalNotices,
        name: 'legal-notices',
        builder: (context, state) => const LegalNoticeHubView(),
      ),
      GoRoute(
        path: AppRoutes.addLegalNotice,
        name: 'add-legal-notice',
        builder: (context, state) => const AddLegalNoticeView(),
      ),
      GoRoute(
        path: '/legal-notices/:id',
        name: 'legal-notices-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'not_201';
          return LegalNoticeDetailView(noticeId: id);
        },
      ),
      GoRoute(
        path: '/legal-notice/:id',
        name: 'legal-notice-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'not_201';
          return LegalNoticeDetailView(noticeId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.myProperties,
        name: 'my-properties',
        builder: (context, state) => const MyPropertiesListView(),
      ),
      GoRoute(
        path: AppRoutes.adminProperties,
        name: 'admin-properties',
        builder: (context, state) => const AdminPropertyManagementView(),
      ),
      GoRoute(
        path: AppRoutes.myEnquiries,
        name: 'my-enquiries',
        builder: (context, state) => const BuyerEnquiriesView(),
      ),
      GoRoute(
        path: AppRoutes.sellerEnquiries,
        name: 'seller-enquiries',
        builder: (context, state) => const SellerEnquiriesView(),
      ),
      GoRoute(
        path: '/enquiry/:id',
        name: 'enquiry-detail-workflow',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'enq_101';
          return EnquiryDetailWorkflowView(enquiryId: id);
        },
      ),
      GoRoute(
        path: '/property-documents/:propertyId',
        name: 'property-documents',
        builder: (context, state) {
          final propId = state.pathParameters['propertyId'] ?? 'prop_1';
          return PropertyDocumentsManagementView(propertyId: propId);
        },
      ),
      GoRoute(
        path: '/due-diligence/:propertyId',
        name: 'due-diligence',
        builder: (context, state) {
          final propId = state.pathParameters['propertyId'] ?? 'prop_1';
          return PropertyDueDiligenceView(propertyId: propId);
        },
      ),
      GoRoute(
        path: '/chat/:conversationId',
        name: 'chat-conversation',
        builder: (context, state) {
          final convId = state.pathParameters['conversationId'] ?? '';
          return ChatConversationView(conversationId: convId);
        },
      ),
      GoRoute(
        path: '/user-messages',
        name: 'user-messages',
        builder: (context, state) => const UserConversationsListView(),
      ),
      // ─── Phase 6: Location Discovery Route ───────────────────────────────
      // Dynamically handles any city/locality: /discover/Belagavi, /discover/Mumbai, etc.
      GoRoute(
        path: '/discover/:location',
        name: 'location-discovery',
        builder: (context, state) {
          final location = state.pathParameters['location'] ?? 'Belagavi';
          return LocationDiscoveryView(locationName: location);
        },
      ),

      GoRoute(
        path: '/property/:id',
        name: 'property-details',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'prop_1';
          return PropertyDetailsView(propertyId: id);
        },
      ),

      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationCenterView(),
      ),

      // ─── Screen 8: Premium Home Dashboard (tabbed shell) ─────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const PremiumHomeView(),
              ),
            ],
          ),
          // Branch 1: Search
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                builder: (context, state) {
                  final category = state.uri.queryParameters['category'];
                  return SmartPropertySearchView(initialCategory: category);
                },
              ),
              GoRoute(
                path: '/saved-searches',
                name: 'saved-searches',
                builder: (context, state) => const SavedSearchesView(),
              ),
            ],
          ),
          // Branch 2: Post Property
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/post-property-tab',
                name: 'post-property-tab',
                builder: (context, state) => const AddPropertyWizardView(),
              ),
            ],
          ),
          // Branch 3: Listings / My Properties
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/listings',
                name: 'listings',
                builder: (context, state) => const MyPropertiesListView(),
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const UserProfileView(),
              ),
            ],
          ),
        ],
      ),
      // Standalone Routes for Saved / Messages
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesView(),
      ),
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => const BuyerEnquiriesView(),
      ),
    ],
    errorBuilder: (context, state) => const WelcomeView(),
  );
});
