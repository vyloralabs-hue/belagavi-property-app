import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/investment/domain/entities/investment_entities.dart';
import 'package:belagavi_property/features/investment/presentation/providers/investment_notifier.dart';
import '../../theme/app_design_system.dart';

class FounderInvestmentLeadsView extends ConsumerStatefulWidget {
  final String authenticatedUserId;
  final UserRole userRole;

  const FounderInvestmentLeadsView({
    super.key,
    required this.authenticatedUserId,
    required this.userRole,
  });

  @override
  ConsumerState<FounderInvestmentLeadsView> createState() =>
      _FounderInvestmentLeadsViewState();
}

class _FounderInvestmentLeadsViewState
    extends ConsumerState<FounderInvestmentLeadsView> {
  String _selectedTimeframe = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.userRole == UserRole.founder ||
          widget.userRole == UserRole.admin) {
        ref
            .read(investmentNotifierProvider.notifier)
            .fetchFounderInvestmentLeads(
              authenticatedUserId: widget.authenticatedUserId,
              role: widget.userRole,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Security check: ONLY Founder or Admin can access
    if (widget.userRole != UserRole.founder &&
        widget.userRole != UserRole.admin) {
      return Scaffold(
        backgroundColor: AppDesignSystem.backgroundWhite,
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text(
            'Access Denied: Investment leads dashboard is restricted to Founder/Admin.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final state = ref.watch(investmentNotifierProvider);
    final leads = state.leads;

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppDesignSystem.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Investment Leads Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            Text(
              state.config.legalEntityName,
              style: const TextStyle(
                fontSize: 11,
                color: AppDesignSystem.accentGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FOUNDER GOVERNANCE',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppDesignSystem.textSecondary,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedTimeframe,
                        isDense: true,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text(
                              'All Leads',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Today',
                            child: Text(
                              'Today',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DropdownMenuItem(
                            value: '7D',
                            child: Text(
                              'Last 7 Days',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DropdownMenuItem(
                            value: '30D',
                            child: Text(
                              'Last 30 Days',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null)
                            setState(() => _selectedTimeframe = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetricTile(
                        'Total Leads',
                        '${leads.length}',
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricTile(
                        'New',
                        '${leads.where((l) => l.status == InvestmentLeadStatus.newLead).length}',
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricTile(
                        'In Discussion',
                        '${leads.where((l) => l.status == InvestmentLeadStatus.inDiscussion).length}',
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Leads List View
            Expanded(
              child: leads.isEmpty
                  ? const Center(
                      child: Text('No investment interest leads registered.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: leads.length,
                      itemBuilder: (context, index) {
                        final lead = leads[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppDesignSystem.borderSubtle,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lead.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppDesignSystem.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      lead.status.name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Phone: ${lead.phone} • Preferred: ${lead.preferredContactMethod}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppDesignSystem.primaryNavy,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (lead.email != null)
                                Text(
                                  'Email: ${lead.email}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppDesignSystem.textSecondary,
                                  ),
                                ),
                              Text(
                                'Location: ${lead.city}, ${lead.state}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppDesignSystem.textSecondary,
                                ),
                              ),
                              if (lead.indicativeInterestAmount != null)
                                Text(
                                  'Indicative Interest: ₹${lead.indicativeInterestAmount!.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              if (lead.message != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Note: "${lead.message}"',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppDesignSystem.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
