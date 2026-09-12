import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/utils/fuzzy_search.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/search_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../data/mock/mock_services.dart';
import '../../../domain/models/service_item.dart';
import '../../../providers/app_providers.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../../../core/widgets/app_icons.dart';

/// Icon for each trade category tile.
String _categoryIcon(String id) => switch (id) {
      'electrician' => AppUiIcons.flash,
      'plumber' => AppUiIcons.pipe,
      'carpenter' => AppUiIcons.hammer,
      'ac-fridge' => AppUiIcons.snowflake,
      'mechanic' => AppUiIcons.tools,
      'painter' => AppUiIcons.format_paint,
      'cleaning' => AppUiIcons.spray_bottle,
      'pest' => AppUiIcons.bug_outline,
      _ => AppUiIcons.toolbox_outline,
    };

/// Services tab — the simple Indian-market home-services hub:
/// emergency helplines, a trade category grid (Electrician, Plumber,
/// Carpenter, Mechanic, …), top experts, occasions and legal help.
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  /// Selected trade filter (null = show all experts).
  String? _category;

  /// Live search query for the experts list.
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesQuery(ServiceItem s) => FuzzySearch.matches(
        _query,
        [
          s.name,
          if (s.category != null) s.category!,
          s.servicesSummary,
          s.trustNote,
        ].join(' '),
      );

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(selectedLocationProvider);
    final services = ref.watch(servicesProvider);
    final events = ref.watch(eventServicesProvider);
    final legal = ref.watch(legalServiceProvider);
    final searching = _query.trim().isNotEmpty;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${location.displayName} Services',
                      style: AppTypography.headline),
                  const SizedBox(height: 3),
                  Text(
                    'Trusted local experts — at your home in 60 minutes',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSearchBar(
                hint: 'Search electrician, plumber, carpenter…',
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                trailing: searching
                    ? IconButton(
                        icon: Iconify(AppUiIcons.close,
                            size: 15, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // ── Scroll body ────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  // ── Search results (replaces grid + experts) ───────
                  if (searching)
                    services.when(
                      data: (list) {
                        final results =
                            list.where(_matchesQuery).toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Results for "$_query"',
                                    style: AppTypography.title,
                                  ),
                                ),
                                Text(
                                  '${results.length} found',
                                  style: AppTypography.label,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (results.isEmpty)
                              _InlineEmpty(
                                icon: AppUiIcons.magnify,
                                message:
                                    'No experts match "$_query". Try "electrician", "plumber", "AC"…',
                              )
                            else
                              ...results.map((s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _SpecialistCard(service: s),
                                  )),
                          ],
                        );
                      },
                      loading: () => const _SectionSkeleton(),
                      error: (e, _) => _InlineError(
                          onRetry: () => ref.invalidate(servicesProvider)),
                    )
                  else ...[
                    // ── Trade category grid ────────────────────────────
                    const SectionHeader(title: 'Book a Service'),
                    const SizedBox(height: 10),
                    _CategoryGrid(
                      selected: _category,
                      onTap: (id) => setState(
                          () => _category = _category == id ? null : id),
                    ),
                    const SizedBox(height: 18),

                    // ── Experts (filtered by selected trade) ───────────
                    services.when(
                      data: (list) {
                        final selectedLabel = _category == null
                            ? null
                            : serviceCategories
                                .firstWhere((c) => c.id == _category)
                                .label;
                        final experts = _category == null
                            ? list
                            : list
                                .where((s) => s.category == _category)
                                .toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedLabel == null
                                        ? 'Top Experts Near You'
                                        : '$selectedLabel Experts',
                                    style: AppTypography.title,
                                  ),
                                ),
                                if (selectedLabel != null)
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _category = null),
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Iconify(AppUiIcons.close,
                                            size: 12,
                                            color: AppColors.primary),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Clear',
                                          style: AppTypography.label.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (experts.isEmpty)
                              _InlineEmpty(
                                icon: AppUiIcons.magnify,
                                message:
                                    'No $selectedLabel experts listed here yet — check back soon.',
                              )
                            else
                              ...experts.map((s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _SpecialistCard(service: s),
                                  )),
                          ],
                        );
                      },
                      loading: () => const _SectionSkeleton(),
                      error: (e, _) => _InlineError(
                          onRetry: () => ref.invalidate(servicesProvider)),
                    ),
                    const SizedBox(height: 8),

                    // Pandit, mehndi & occasions
                    const SectionHeader(title: 'Pandit, Mehndi & Occasions'),
                    const SizedBox(height: 10),
                    events.when(
                      data: (list) => Row(
                        children: [
                          for (var i = 0; i < list.length; i++) ...[
                            Expanded(child: _EventCard(service: list[i])),
                            if (i < list.length - 1)
                              const SizedBox(width: 10),
                          ],
                        ],
                      ),
                      loading: () => const _SectionSkeleton(),
                      error: (e, _) => _InlineError(
                          onRetry: () => ref.invalidate(eventServicesProvider)),
                    ),
                    const SizedBox(height: 18),

                    // Legal & documentation
                    const SectionHeader(title: 'Legal & Documentation'),
                    const SizedBox(height: 10),
                    legal.when(
                      data: (service) => _LegalAidCard(service: service),
                      loading: () => const _SectionSkeleton(),
                      error: (e, _) => _InlineError(
                          onRetry: () => ref.invalidate(legalServiceProvider)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Trade category grid: 4×2 tiles, named for the Indian market ────────
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.selected, required this.onTap});

  final String? selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.94,
      ),
      itemCount: serviceCategories.length,
      itemBuilder: (context, index) {
        final cat = serviceCategories[index];
        final isSelected = cat.id == selected;
        return GestureDetector(
          onTap: () => onTap(cat.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.card,
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Iconify(
                  _categoryIcon(cat.id),
                  size: 20,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    cat.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Compact inline empty state for a filtered expert list.
class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.icon, required this.message});

  final String icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Iconify(icon, size: 22, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: AppTypography.caption),
        ],
      ),
    );
  }
}
class _SpecialistCard extends StatelessWidget {
  const _SpecialistCard({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            height: 92,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppImage(url: service.image, width: 74, height: 92),
                ),
                Positioned(
                  top: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: service.citySpecialty ? const Color(0xFF8A5A00) : AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      service.badge,
                      style: const TextStyle(
                          fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
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
                        service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSm,
                      ),
                    ),
                    Iconify(AppUiIcons.star, size: 12, color: AppColors.starAmber),
                    const SizedBox(width: 2),
                    Text(service.rating, style: AppTypography.bodyStrong.copyWith(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  service.servicesSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(service.priceText,
                        style: AppTypography.bodyStrong
                            .copyWith(color: AppColors.primaryDark, fontSize: 12)),
                    const SizedBox(width: 8),
                    Text(service.etaText,
                        style: AppTypography.label.copyWith(fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${service.statsText} · ${service.trustNote}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label.copyWith(fontSize: 10.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => AppLauncher.call(service.phone),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          service.actionLabel,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Event mini card (2-column grid) ────────────────────────────────────
class _EventCard extends StatelessWidget {
  const _EventCard({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 76,
            width: double.infinity,
            child: AppImage(url: service.image, fallbackIcon: AppUiIcons.party_popper),
          ),
          Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSm.copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '${service.priceText} · ${service.etaText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(fontSize: 10.5),
                ),
                const SizedBox(height: 7),
                GestureDetector(
                  onTap: () => AppLauncher.call(service.phone),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      service.actionLabel,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Legal aid wide card ────────────────────────────────────────────────
class _LegalAidCard extends StatelessWidget {
  const _LegalAidCard({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Iconify(AppUiIcons.gavel, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: AppTypography.titleSm.copyWith(fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(service.servicesSummary, style: AppTypography.caption),
                const SizedBox(height: 3),
                Text(
                  '${service.priceText} · ${service.etaText}',
                  style: AppTypography.label.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => AppLauncher.call(service.phone),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                service.actionLabel,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: const [
          SkeletonBox(width: 92, height: double.infinity, radius: 12),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(width: 150, height: 13, radius: 6),
                SizedBox(height: 9),
                SkeletonBox(width: 200, height: 10, radius: 5),
                SizedBox(height: 9),
                SkeletonBox(width: 120, height: 10, radius: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Compact single-row error card — the big centered StatesView.error
    // needs ~180px and overflows this 90px section slot.
    return Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Iconify(
            AppUiIcons.wifi_strength_off_outline,
            color: AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Could not load this section.',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
