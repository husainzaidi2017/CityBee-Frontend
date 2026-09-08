import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/states_view.dart';
import '../../../data/repositories/business_repository.dart';
import '../../../domain/models/business.dart';
import '../../../providers/app_providers.dart';
import 'widgets/listing_business_card.dart';

enum _SortOption { relevance, rating, distance }

/// Category listing screen (e.g. "Restaurants & Dining"): search, list/map
/// toggle, removable filter chips, sort row and result cards.
class BusinessListingScreen extends ConsumerStatefulWidget {
  const BusinessListingScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<BusinessListingScreen> createState() =>
      _BusinessListingScreenState();
}

class _BusinessListingScreenState extends ConsumerState<BusinessListingScreen> {
  bool _showMap = false;
  _SortOption _sort = _SortOption.relevance;
  final Set<String> _filters = {'Dine-in', 'Pure Veg'};

  static const _availableFilters = [
    'Dine-in',
    'Pure Veg',
    'Banquet',
    'Rating 4.0+',
    'Open Now',
  ];

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(selectedCityProvider);
    final categories = ref.watch(categoriesProvider);
    final category = categories.valueOrNull
        ?.where((c) => c.id == widget.categoryId)
        .firstOrNull;
    final title = category?.listingTitle ?? 'All Businesses';
    final businessesAsync = widget.categoryId == 'all'
        ? ref.watch(popularBusinessesProvider(PopularFilter.all))
        : ref.watch(businessesByCategoryProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App bar row: back, title, list/map toggle ───────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(fontSize: 16),
                    ),
                  ),
                  _ListMapToggle(isMap: _showMap, onToggle: () => setState(() => _showMap = !_showMap)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${city.name} · ${businessesAsync.valueOrNull?.length ?? 0} places',
                style: AppTypography.caption,
              ),
            ),
            const SizedBox(height: 10),

            // ── Applied filters + sort ──────────────────────────────
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final filter in _filters)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: RemovableFilterChip(
                        label: filter,
                        onRemoved: () => setState(() => _filters.remove(filter)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 5),
                  for (final option in _SortOption.values) ...[
                    if (option != _SortOption.values.first) ...[
                      Text('  ·  ', style: AppTypography.label),
                    ],
                    GestureDetector(
                      onTap: () => setState(() => _sort = option),
                      child: Text(
                        switch (option) {
                          _SortOption.relevance => 'Relevance',
                          _SortOption.rating => 'Rating',
                          _SortOption.distance => 'Nearest',
                        },
                        style: AppTypography.label.copyWith(
                          color: option == _sort ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: option == _sort ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showFilterSheet(),
                    child: Text('Filters',
                        style:
                            AppTypography.label.copyWith(color: AppColors.primary)),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Results ─────────────────────────────────────────────
            Expanded(
              child: businessesAsync.when(
                data: (businesses) {
                  if (businesses.isEmpty) {
                    return StatesView.empty(
                      icon: Icons.storefront_outlined,
                      message: 'No businesses found here yet.',
                    );
                  }
                  final sorted = _applySort(businesses, _sort);
                  if (_showMap) {
                    return BusinessesMapPage(businesses: sorted);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) =>
                        ListingBusinessCard(business: sorted[index]),
                  );
                },
                loading: () => StatesView.loading(message: 'Finding places…'),
                error: (e, _) => StatesView.error(
                  message: 'Could not load businesses.',
                  onRetry: () => ref.invalidate(
                    businessesByCategoryProvider(widget.categoryId),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Business> _applySort(List<Business> businesses, _SortOption sort) {
    final list = [...businesses];
    switch (sort) {
      case _SortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case _SortOption.distance:
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      case _SortOption.relevance:
        break;
    }
    return list;
  }

  Future<void> _showFilterSheet() {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filter results', style: AppTypography.title),
                const SizedBox(height: 4),
                Text('Tap to apply or remove filters',
                    style: AppTypography.caption),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final filter in _availableFilters)
                      SelectChip(
                        label: filter,
                        selected: _filters.contains(filter),
                        showCheck: true,
                        onTap: () => setSheetState(
                          () => _filters.contains(filter)
                              ? _filters.remove(filter)
                              : _filters.add(filter),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => setState(() {}));
  }
}

/// Pill toggle switching between list and map results.
class _ListMapToggle extends StatelessWidget {
  const _ListMapToggle({required this.isMap, required this.onToggle});

  final bool isMap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMap ? Icons.list_rounded : Icons.map_outlined,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 5),
            Text(
              isMap ? 'List' : 'Map',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
