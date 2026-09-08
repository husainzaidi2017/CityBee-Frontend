import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_animation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/states_view.dart';
import '../../../data/repositories/business_repository.dart';
import '../../../domain/models/business.dart';
import '../../../providers/app_providers.dart';
import 'widgets/listing_business_card.dart';

enum _SortOption { relevance, rating, distance }

/// Filters offered per category — each category only shows options that
/// make sense for it (no "Dine-in" on a doctors listing).
const _categoryFilters = <String, List<String>>{
  'dining': ['Pure Veg', 'Open Now', 'Rating 4.0+', 'Banquet'],
  'doctors': ['Open Now', 'Rating 4.0+', 'Verified', 'Walk-ins'],
  'hotels': ['Open Now', 'Rating 4.0+', 'Wi-Fi', 'Parking'],
  'cinemas': ['Open Now', 'Rating 4.0+', 'Recliner Seats', 'Online Booking'],
};

/// Fallback for every other category (fashion, grocery, salons, …).
const _defaultFilters = ['Open Now', 'Rating 4.0+', 'Verified'];

/// Category listing screen (e.g. "Restaurants & Dining"): search, list/map
/// toggle, category-aware filters, sort row and result cards.
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

  /// Currently applied filters — empty by default so every listing opens
  /// unfiltered; options are scoped to the category.
  final Set<String> _filters = {};

  List<String> get _availableFilters =>
      _categoryFilters[widget.categoryId] ?? _defaultFilters;

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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
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
                  _ListMapToggle(
                      isMap: _showMap,
                      onToggle: () => setState(() => _showMap = !_showMap)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Applied filters (collapses away when none) ──────────
            AnimatedSize(
              duration: AppAnimation.normal,
              curve: AppAnimation.curve,
              alignment: Alignment.topLeft,
              child: _filters.isEmpty
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 8),
                      child: SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            for (final filter in _filters)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Center(
                                  child: RemovableFilterChip(
                                    label: filter,
                                    onRemoved: () =>
                                        setState(() => _filters.remove(filter)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded,
                      size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 5),
                  for (final option in _SortOption.values) ...[
                    if (option != _SortOption.values.first) ...[
                      Text('  ·  ', style: AppTypography.label),
                    ],
                    GestureDetector(
                      onTap: () => setState(() => _sort = option),
                      child: AnimatedDefaultTextStyle(
                        duration: AppAnimation.fast,
                        curve: AppAnimation.curve,
                        style: AppTypography.label.copyWith(
                          color: option == _sort
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: option == _sort
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                        child: Text(
                          switch (option) {
                            _SortOption.relevance => 'Relevance',
                            _SortOption.rating => 'Rating',
                            _SortOption.distance => 'Nearest',
                          },
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showFilterSheet(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _filters.isEmpty
                              ? 'Filters'
                              : 'Filters (${_filters.length})',
                          style: AppTypography.label.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.tune_rounded,
                            size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Results ─────────────────────────────────────────────
            Expanded(
              child: businessesAsync.when(
                data: (businesses) {
                  final filtered = _applyFilters(businesses, _filters);
                  if (filtered.isEmpty) {
                    return _filters.isEmpty
                        ? StatesView.empty(
                            icon: Icons.storefront_outlined,
                            message: 'No businesses found here yet.',
                          )
                        : StatesView.empty(
                            icon: Icons.filter_alt_off_outlined,
                            message: 'No places match your filters.',
                            actionLabel: 'Clear Filters',
                            onAction: () => setState(() => _filters.clear()),
                          );
                  }
                  final sorted = _applySort(filtered, _sort);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: Text(
                          '${city.name} · ${sorted.length} places',
                          style: AppTypography.caption,
                        ),
                      ),
                      Expanded(
                        child: _showMap
                            ? BusinessesMapPage(businesses: sorted)
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                                itemCount: sorted.length,
                                itemBuilder: (context, index) =>
                                    ListingBusinessCard(business: sorted[index]),
                              ),
                      ),
                    ],
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

  // ── Filtering & sorting ──────────────────────────────────────────────

  /// Filters actually reduce the result set:
  /// open-now, rating, verification and pure-veg map to model fields;
  /// everything else matches the business's feature chips / amenities.
  List<Business> _applyFilters(List<Business> businesses, Set<String> filters) {
    if (filters.isEmpty) return businesses;
    return businesses.where((b) => filters.every((f) => _matches(b, f))).toList();
  }

  bool _matches(Business b, String filter) {
    switch (filter) {
      case 'Open Now':
        return b.isOpen;
      case 'Rating 4.0+':
        return b.rating >= 4.0;
      case 'Verified':
        return b.isVerified;
      case 'Pure Veg':
        return b.isPureVeg;
      default:
        final tokens = {...b.featureChips, ...b.amenities}
            .map((chip) => chip.toLowerCase());
        return tokens.contains(filter.toLowerCase());
    }
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

  // ── Filter sheet ─────────────────────────────────────────────────────
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
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                    if (_filters.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          setSheetState(() => _filters.clear());
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ],
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
