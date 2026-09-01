import 'package:flutter/material.dart';
import '../../../presentation_ui/theme/app_design_system.dart';

/// Animated expandable FAQ accordion tile
class FAQAccordionItem extends StatefulWidget {
  final String question;
  final String answer;
  final int helpfulCount;
  final bool isPinned;

  const FAQAccordionItem({
    super.key,
    required this.question,
    required this.answer,
    this.helpfulCount = 0,
    this.isPinned = false,
  });

  @override
  State<FAQAccordionItem> createState() => _FAQAccordionItemState();
}

class _FAQAccordionItemState extends State<FAQAccordionItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppDesignSystem.cardWhite,
          borderRadius: AppDesignSystem.borderRadiusL,
          boxShadow: AppDesignSystem.softShadow,
          border: Border.all(
            color: _expanded ? AppDesignSystem.primaryNavy.withAlpha(60) : AppDesignSystem.borderSubtle,
            width: _expanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(right: 8, top: 2),
                      child: Icon(Icons.push_pin_rounded, size: 14, color: AppDesignSystem.primaryNavy),
                    ),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _expanded ? AppDesignSystem.primaryNavy : AppDesignSystem.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 280),
                    child: const Icon(Icons.expand_more_rounded,
                        size: 22, color: AppDesignSystem.textSecondary),
                  ),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1, color: AppDesignSystem.borderSubtle),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Text(
                      widget.answer,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppDesignSystem.textSecondary,
                          height: 1.6),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.thumb_up_outlined,
                            size: 14, color: AppDesignSystem.textSecondary),
                        const SizedBox(width: 5),
                        Text('${widget.helpfulCount} found this helpful',
                            style: const TextStyle(
                                fontSize: 11, color: AppDesignSystem.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
