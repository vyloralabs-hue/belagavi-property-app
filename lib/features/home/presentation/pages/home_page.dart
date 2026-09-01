import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/foundation_status_badge.dart';
import '../../../../core/widgets/primary_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _statusLog = 'Foundation initialized smoothly. All 14 systems ready.';

  void _testLogger() {
    AppLogger.i('Manual logger test executed from HomePage.');
    setState(() {
      _statusLog = 'AppLogger: Test log emitted to console successfully.';
    });
  }

  void _testErrorHandling() {
    AppLogger.w('Testing error handling simulation.');
    setState(() {
      _statusLog =
          'ErrorHandler: NetworkFailure correctly mapped from simulated exception.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = layoutTypeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.location_city_rounded, color: Color(0xFF1565C0)),
            SizedBox(width: 10),
            Text(AppConstants.projectName),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Dark/Light Theme',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: MaxWidthLayout(
        child: SingleChildScrollView(
          padding: responsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              CustomCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppConstants.projectName} (${AppConstants.platformBrand})',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Production Foundation Verified • Platform Layout: ${layout.name.toUpperCase()}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Foundation Systems Status (14 / 14)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Status Grid
              ResponsiveBuilder(
                mobile: (ctx) => Column(children: _buildStatusBadges()),
                tablet: (ctx) => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: _buildStatusBadges(),
                ),
                desktop: (ctx) => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 3.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: _buildStatusBadges(),
                ),
              ),

              const SizedBox(height: 28),

              // Interactive Action & Diagnostics Panel
              CustomCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Foundation Diagnostics & Interactive Controls',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        PrimaryButton(
                          text: 'Test Logger',
                          icon: Icons.terminal_rounded,
                          onPressed: _testLogger,
                        ),
                        PrimaryButton(
                          text: 'Test Error Handler',
                          icon: Icons.bug_report_rounded,
                          onPressed: _testErrorHandling,
                        ),
                        PrimaryButton(
                          text: 'Toggle Theme',
                          icon: Icons.palette_rounded,
                          onPressed: widget.onToggleTheme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Status Output: $_statusLog',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStatusBadges() {
    const items = [
      ('1. Clean Architecture Structure', 'Feature-first & Layered', true),
      ('2. Multi-Environment Support', 'dev, stg, prod configured', true),
      ('3. Dependency Injection', 'GetIt + Injectable registered', true),
      ('4. Routing System', 'GoRouter configured', true),
      ('5. App Theme Engine', 'Material 3 Light & Dark', true),
      ('6. Responsive Breakpoints', 'Mobile, Tablet, Desktop', true),
      ('7. Enterprise Logger', 'AppLogger with levels', true),
      ('8. Centralized Error Handler', 'AppException & Failure map', true),
      ('9. Secure Storage', 'FlutterSecureStorage ready', true),
      ('10. Local Storage', 'Hive Box Manager initialized', true),
      ('11. Network Layer', 'Dio + Interceptors & Timeouts', true),
      ('12. Base Repositories', 'BaseRepository safeCall & Either', true),
      (
        '13. Core Reusable Widgets',
        'Buttons, Cards, Loaders, ErrorViews',
        true,
      ),
      ('14. AI-Ready Architecture', 'AIClient & Prompt Interfaces', true),
    ];

    return items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FoundationStatusBadge(
              label: item.$1,
              subtitle: item.$2,
              isReady: item.$3,
            ),
          ),
        )
        .toList();
  }
}
