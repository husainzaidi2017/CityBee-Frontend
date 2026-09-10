import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/search_bar.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/business.dart';
import '../../../providers/app_providers.dart';

/// Full search screen: live results across businesses with a filter chip
/// row and recent-searches/trending content when the query is empty.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String _filter = 'All';

  static const _filters = ['All', 'Restaurants', 'Doctors', 'Hotels', 'Salons'];
  static const _trending = [
    'Biryani near me',
    'Brass shops',
    'Dentist in Civil Lines',
    'Banquet halls',
    'Pure veg restaurants',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider(_query));
    final location = ref.watch(selectedLocationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: AppSearchBar(
                      hint: 'Search businesses, cuisines, places…',
                      controller: _controller,
                      onChanged: (value) => setState(() => _query = value),
                      autofocus: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) => _FilterChip(
                  label: _filters[index],
                  selected: _filters[index] == _filter,
                  onTap: () => setState(() => _filter = _filters[index]),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: _query.trim().isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      children: [
                        Text('Trending in ${location.displayName}', style: AppTypography.titleSm),
                        const SizedBox(height: 10),
                        ..._trending.map((term) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: const Icon(Icons.trending_up_rounded,
                                  size: 18, color: AppColors.primary),
                              title: Text(term, style: AppTypography.body),
                              onTap: () {
                                _controller.text = term;
                                setState(() => _query = term);
                              },
                            )),
                      ],
                    )
                  : results.when(
                      data: (list) {
                        if (list.isEmpty) {
                          return StatesView.empty(
                            message: 'No results for "$_query". Try a different search.',
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: list.length,
                          itemBuilder: (context, index) =>
                              _SearchResultTile(business: list[index]),
                        );
                      },
                      loading: () => StatesView.loading(),
                      error: (e, _) => StatesView.error(
                        message: 'Search failed. Please retry.',
                        onRetry: () => ref.invalidate(searchResultsProvider(_query)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.chipDark : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.chipDark : AppColors.border,
            width: 1.1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.chipDarkText : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/business/${business.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppImage(url: business.images.firstOrNull ?? '', width: 58, height: 58),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          business.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyStrong,
                        ),
                      ),
                      if (business.isVerified)
                        const Icon(Icons.verified, size: 14, color: AppColors.verifiedGreen),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    business.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: business.rating >= 4.0
                            ? AppColors.starAmber
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        business.ratingLabel,
                        style: AppTypography.label.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: business.isOpen
                              ? AppColors.openGreen
                              : AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${business.area.isEmpty ? business.cityName : business.area} · ${business.distanceLabel} km',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
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
