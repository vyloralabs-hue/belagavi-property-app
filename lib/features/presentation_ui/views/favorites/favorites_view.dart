import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';
import '../../../property/presentation/providers/favorites_notifier.dart';
import '../../../property/domain/entities/property_entities.dart';
import '../../../property/utils/location_privacy_helper.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/localization/language_selector_modal.dart';

class FavoritesView extends ConsumerWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesNotifierProvider);
    final localizations = ref.watch(appLocalizationsProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: Text(
          'Favorite Properties (${state.favorites.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.language_rounded,
              color: AppDesignSystem.primaryNavy,
            ),
            tooltip: 'Change Language',
            onPressed: () => LanguageSelectorModal.show(context),
          ),
          if (state.favorites.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Colors.redAccent,
              ),
              tooltip: 'Clear All Favorites',
              onPressed: () {
                ref.read(favoritesNotifierProvider.notifier).clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All favorites cleared')),
                );
              },
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.favorites.isEmpty
          ? _buildEmptyState(context)
          : _buildFavoritesList(context, ref, state.favorites),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 64,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Favorite Properties Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Save properties you like to access them quickly later.',
            style: TextStyle(color: AppDesignSystem.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
    BuildContext context,
    WidgetRef ref,
    List favorites,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final fav = favorites[index];
        final rawProp = fav.property;
        final isPublic =
            rawProp.status == ListingStatus.published ||
            rawProp.status == ListingStatus.approved ||
            rawProp.status == ListingStatus.active;

        if (!isPublic) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: const RoundedRectangleBorder(
              borderRadius: AppDesignSystem.borderRadiusL,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Property currently unavailable',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      ref
                          .read(favoritesNotifierProvider.notifier)
                          .removeFavorite(fav.propertyId);
                    },
                  ),
                ],
              ),
            ),
          );
        }

        final publicProp = LocationPrivacyHelper.toPublicPropertyEntity(
          rawProp,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDesignSystem.borderRadiusL,
          ),
          elevation: 2,
          child: InkWell(
            onTap: () => context.push('/property/${publicProp.id}'),
            borderRadius: AppDesignSystem.borderRadiusL,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: AppDesignSystem.borderRadiusM,
                    ),
                    child: const Icon(
                      Icons.home_outlined,
                      size: 40,
                      color: AppDesignSystem.primaryNavy,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          publicProp.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppDesignSystem.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${publicProp.locality}, ${publicProp.city}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppDesignSystem.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${publicProp.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppDesignSystem.accentEmerald,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.redAccent),
                    onPressed: () {
                      ref
                          .read(favoritesNotifierProvider.notifier)
                          .removeFavorite(fav.propertyId);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
