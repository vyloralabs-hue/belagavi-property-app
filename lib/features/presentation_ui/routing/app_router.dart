import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/home/premium_home_view.dart';
import '../views/search/smart_property_search_view.dart';
import '../views/crm_dashboard/broker_builder_crm_dashboard_view.dart';
import '../views/splash/splash_view.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashView();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return const PremiumHomeView();
        },
      ),
      GoRoute(
        path: '/search',
        builder: (BuildContext context, GoRouterState state) {
          return const SmartPropertySearchView();
        },
      ),
      GoRoute(
        path: '/crm',
        builder: (BuildContext context, GoRouterState state) {
          return const BrokerBuilderCRMDashboardView(userId: 'usr_broker_1');
        },
      ),
    ],
  );
}
