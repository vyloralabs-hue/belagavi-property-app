import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/support_entities.dart';
import '../providers/support_ticket_notifier.dart';
import '../widgets/support_ticket_status_badge.dart';

/// My Tickets Screen — list and submit support tickets
class SupportMyTicketsView extends ConsumerStatefulWidget {
  const SupportMyTicketsView({super.key});

  @override
  ConsumerState<SupportMyTicketsView> createState() =>
      _SupportMyTicketsViewState();
}

class _SupportMyTicketsViewState extends ConsumerState<SupportMyTicketsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(
      () => ref
          .read(supportTicketNotifierProvider.notifier)
          .loadMyTickets('usr_current'),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(supportTicketNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'My Tickets',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
            fontSize: 17,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppDesignSystem.textPrimary,
            size: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppDesignSystem.primaryNavy,
          unselectedLabelColor: AppDesignSystem.textSecondary,
          indicatorColor: AppDesignSystem.primaryNavy,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'My Tickets'),
            Tab(text: 'New Ticket'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTicketsList(ticketState),
          _buildNewTicketForm(context),
        ],
      ),
    );
  }

  Widget _buildTicketsList(SupportTicketState state) {
    return switch (state) {
      SupportTicketInitial() || SupportTicketSubmitting() => const Center(
        child: CircularProgressIndicator(color: AppDesignSystem.primaryNavy),
      ),
      SupportTicketError(message: final msg) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppDesignSystem.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load tickets: $msg',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppDesignSystem.textSecondary),
            ),
          ],
        ),
      ),
      SupportTicketSubmitted() => const Center(
        child: Text(
          'Ticket submitted! Reload to see your tickets.',
          style: TextStyle(color: AppDesignSystem.textSecondary),
        ),
      ),
      SupportTicketListLoaded(tickets: final tickets) =>
        tickets.isEmpty
            ? _buildEmptyTickets()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: tickets.length,
                itemBuilder: (_, i) => _buildTicketCard(tickets[i]),
              ),
    };
  }

  Widget _buildTicketCard(SupportTicketEntity ticket) {
    final categoryLabels = {
      SupportCategory.documentation: 'Documentation',
      SupportCategory.verification: 'Verification',
      SupportCategory.consultation: 'Consultation',
      SupportCategory.registration: 'Registration',
      SupportCategory.whatsapp: 'WhatsApp',
      SupportCategory.call: 'Call Support',
      SupportCategory.general: 'General',
      SupportCategory.liveChat: 'Live Chat',
      SupportCategory.aiAssistant: 'AI Support',
      SupportCategory.homeLoan: 'Home Loan',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesignSystem.cardWhite,
        borderRadius: AppDesignSystem.borderRadiusL,
        boxShadow: AppDesignSystem.softShadow,
        border: Border.all(color: AppDesignSystem.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppDesignSystem.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SupportTicketStatusBadge(status: ticket.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.message,
            style: const TextStyle(
              fontSize: 12,
              color: AppDesignSystem.textSecondary,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: AppDesignSystem.borderRadiusPill,
                ),
                child: Text(
                  categoryLabels[ticket.category] ?? 'General',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(ticket.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
            ],
          ),
          if (ticket.agentNote != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: AppDesignSystem.borderRadiusM,
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.support_agent_rounded,
                    size: 14,
                    color: AppDesignSystem.accentEmerald,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Agent: ${ticket.agentNote!}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppDesignSystem.accentEmerald,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyTickets() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_rounded,
            size: 64,
            color: AppDesignSystem.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tickets yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Have a question? Submit a support ticket.',
            style: TextStyle(
              color: AppDesignSystem.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _tabController.animateTo(1),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.primaryNavy,
            ),
            child: const Text(
              'Submit a Ticket',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewTicketForm(BuildContext context) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    SupportCategory selectedCategory = SupportCategory.general;

    final categoryOptions = [
      SupportCategory.general,
      SupportCategory.documentation,
      SupportCategory.verification,
      SupportCategory.consultation,
      SupportCategory.registration,
    ];

    final categoryLabels = {
      SupportCategory.general: 'General Enquiry',
      SupportCategory.documentation: 'Documentation Help',
      SupportCategory.verification: 'Property Verification',
      SupportCategory.consultation: 'Consultation Request',
      SupportCategory.registration: 'Registration Guidance',
    };

    return StatefulBuilder(
      builder: (context, setFormState) {
        final ticketState = ref.watch(supportTicketNotifierProvider);
        final isSubmitting = ticketState is SupportTicketSubmitting;
        final isSubmitted = ticketState is SupportTicketSubmitted;

        if (isSubmitted) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 40,
                    color: AppDesignSystem.accentEmerald,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ticket Submitted!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We\'ll get back to you within 24 hours.',
                  style: TextStyle(
                    color: AppDesignSystem.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(supportTicketNotifierProvider.notifier)
                        .loadMyTickets('usr_current');
                    _tabController.animateTo(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.primaryNavy,
                  ),
                  child: const Text(
                    'View My Tickets',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            const Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoryOptions.map((cat) {
                final isSelected = selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setFormState(() => selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppDesignSystem.primaryNavy
                          : Colors.white,
                      borderRadius: AppDesignSystem.borderRadiusPill,
                      border: Border.all(
                        color: isSelected
                            ? AppDesignSystem.primaryNavy
                            : AppDesignSystem.borderSubtle,
                      ),
                    ),
                    child: Text(
                      categoryLabels[cat] ?? cat.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppDesignSystem.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Subject',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                hintText: 'Brief subject of your query',
                hintStyle: TextStyle(
                  color: AppDesignSystem.textSecondary,
                  fontSize: 13,
                ),
                border: const OutlineInputBorder(
                  borderRadius: AppDesignSystem.borderRadiusM,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppDesignSystem.borderRadiusM,
                  borderSide: BorderSide(color: AppDesignSystem.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppDesignSystem.borderRadiusM,
                  borderSide: BorderSide(
                    color: AppDesignSystem.primaryNavy,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Message',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe your issue or query in detail…',
                hintStyle: TextStyle(
                  color: AppDesignSystem.textSecondary,
                  fontSize: 13,
                ),
                border: const OutlineInputBorder(
                  borderRadius: AppDesignSystem.borderRadiusM,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppDesignSystem.borderRadiusM,
                  borderSide: BorderSide(color: AppDesignSystem.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppDesignSystem.borderRadiusM,
                  borderSide: BorderSide(
                    color: AppDesignSystem.primaryNavy,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        if (subjectController.text.trim().isEmpty ||
                            messageController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please fill in subject and message.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        ref
                            .read(supportTicketNotifierProvider.notifier)
                            .submitTicket(
                              userId: 'usr_current',
                              category: selectedCategory,
                              subject: subjectController.text.trim(),
                              message: messageController.text.trim(),
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDesignSystem.borderRadiusL,
                  ),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Ticket',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
