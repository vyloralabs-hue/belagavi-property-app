import 'package:flutter/material.dart';
import '../../theme/app_design_system.dart';
import 'seller_dashboard_view.dart';
import 'broker_dashboard_view.dart';
import 'builder_dashboard_view.dart';

/// User role enum for dashboard routing
enum DashboardUserRole {
  seller,
  broker,
  brokerTeamMember,
  builder,
  builderTeamMember,
}

/// Smart router: dispatches to the correct role-specific dashboard
/// based on [userRole]. Replaces the old [BrokerBuilderCRMDashboardView].
class CRMDashboardRouter extends StatelessWidget {
  final String userId;
  final String userName;
  final DashboardUserRole userRole;
  final String? projectId; // for builder context

  const CRMDashboardRouter({
    super.key,
    required this.userId,
    required this.userName,
    required this.userRole,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return switch (userRole) {
      DashboardUserRole.seller => SellerDashboardView(
          userId: userId,
          userName: userName,
        ),
      DashboardUserRole.broker => BrokerDashboardView(
          userId: userId,
          userName: userName,
        ),
      DashboardUserRole.brokerTeamMember => BrokerDashboardView(
          userId: userId,
          userName: userName,
          isTeamMember: true,
        ),
      DashboardUserRole.builder => BuilderDashboardView(
          userId: userId,
          builderName: userName,
          projectId: projectId,
        ),
      DashboardUserRole.builderTeamMember => BuilderDashboardView(
          userId: userId,
          builderName: userName,
          projectId: projectId,
          isTeamMember: true,
        ),
    };
  }
}

/// Legacy compatibility shim — kept for any existing route references
@Deprecated('Use CRMDashboardRouter instead')
class BrokerBuilderCRMDashboardView extends StatelessWidget {
  final String userId;

  const BrokerBuilderCRMDashboardView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text('CRM Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard_rounded, size: 60, color: AppDesignSystem.primaryNavy),
            const SizedBox(height: 16),
            const Text(
              'Use CRMDashboardRouter\nwith your user role',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppDesignSystem.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CRMDashboardRouter(
                    userId: userId,
                    userName: 'User',
                    userRole: DashboardUserRole.broker,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: AppDesignSystem.primaryNavy),
              child: const Text('Open Broker Demo', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
