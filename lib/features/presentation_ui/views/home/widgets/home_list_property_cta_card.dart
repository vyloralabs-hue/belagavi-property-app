import 'package:flutter/material.dart';
import '../../../theme/app_design_system.dart';
import '../../property/widgets/category_selection_modal.dart';

/// List Your Property CTA Card — Master Design Blueprint
/// Prominent Gold Action Card for property owners & sellers to list their property
class HomeListPropertyCtaCard extends StatelessWidget {
  const HomeListPropertyCtaCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: GestureDetector(
        onTap: () => CategorySelectionModal.show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderCol,
              width: 1.2,
            ),
            boxShadow: AppDesignSystem.cardShadow,
          ),
          child: Row(
            children: [
              // Gold '+' Circle Icon
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppDesignSystem.brandGold,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'List Your Property',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textP,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Post your residential, plot, commercial or land listing',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 11,
                        color: AppDesignSystem.textS(context),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Gold "List Now" Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x30B39037),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'List Now',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
