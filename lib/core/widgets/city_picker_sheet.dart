import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/city.dart';
import '../../domain/models/citybee_location.dart';
import '../../data/repositories/city_repository.dart';
import '../../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'app_icons.dart';
import 'skeleton.dart';

/// Bottom sheet for choosing the discovery location.
///
/// Primary flow: Google Places search (anywhere worldwide) → tap a
/// suggestion → resolve → selected. Selecting a location NEVER creates a
/// CityBee city; the `cities` list below is CityBee reference data
/// ("Popular on CityBee") loaded from the backend.
Future<void> showCityPickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _CityPickerSheet(),
  );
}

class _CityPickerSheet extends ConsumerStatefulWidget {
  const _CityPickerSheet();

  @override
  ConsumerState<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends ConsumerState<_CityPickerSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String? _resolving;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  Future<void> _selectSuggestion(CitySuggestion suggestion) async {
    setState(() => _resolving = suggestion.placeId);
    try {
      final location =
          await ref.read(cityRepositoryProvider).resolveLocation(suggestion.placeId);
      if (!mounted) return;
      if (location != null && location.displayName.isNotEmpty) {
        await ref.read(selectedLocationProvider.notifier).select(location);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Now exploring ${location.displayName}')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _resolving = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not select that location. Try again.')),
        );
      }
    }
  }

  Future<void> _selectCityBeeCity(City city) async {
    // A CityBee city row already exists — build a location from it.
    await ref.read(selectedLocationProvider.notifier).select(CityBeeLocation(
          displayName: city.name,
          state: city.state,
          latitude: city.latitude,
          longitude: city.longitude,
          locality: city.name,
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedLocationProvider);
    final searching = _query.length >= 2;
    final suggestions = searching ? ref.watch(citySearchProvider(_query)) : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose your location', style: AppTypography.title),
            const SizedBox(height: 4),
            Text('Results around your location, anywhere in the world.',
                style: AppTypography.caption),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search city, area or locality…',
                prefixIcon: Iconify(AppUiIcons.magnify, size: 17),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (searching)
              Flexible(
                child: suggestions == null
                    ? const SizedBox.shrink()
                    : suggestions.when(
                        data: (list) => list.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text('No locations found. Try another spelling.',
                                    style: AppTypography.caption),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: list.length,
                                itemBuilder: (_, index) {
                                  final s = list[index];
                                  final busy = _resolving == s.placeId;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    leading: Iconify(AppUiIcons.map_marker_outline,
                                        size: 17, color: AppColors.primary),
                                    title: Text(s.mainText, style: AppTypography.bodyStrong),
                                    subtitle:
                                        Text(s.secondaryText, style: AppTypography.label),
                                    trailing: busy
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Iconify(AppUiIcons.chevron_right,
                                            size: 17, color: AppColors.textMuted),
                                    onTap: busy ? null : () => _selectSuggestion(s),
                                  );
                                },
                              ),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              _SkeletonRow(),
                              SizedBox(height: 10),
                              _SkeletonRow(),
                              SizedBox(height: 10),
                              _SkeletonRow(),
                            ],
                          ),
                        ),
                        error: (_, __) => const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Search unavailable right now. Try again in a moment.',
                              style: AppTypography.caption),
                        ),
                      ),
              )
            else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Iconify(AppUiIcons.crosshairs_gps, color: AppColors.primary, size: 20),
                title: Text('Use my current location', style: AppTypography.bodyStrong),
                subtitle:
                    Text('Detects your area via GPS', style: AppTypography.label),
                onTap: () async {
                  final ok = await ref.read(selectedLocationProvider.notifier).useMyLocation();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'Using your current location'
                          : 'Location unavailable — search for a place instead'),
                    ));
                    if (ok) Navigator.of(context).pop();
                  }
                },
              ),
              const Divider(),
              _PopularCityTiles(
                selectedName: selected.displayName,
                onSelect: _selectCityBeeCity,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// CityBee cities with real content — dynamic from the backend, never a
/// hardcoded Flutter list.
class _PopularCityTiles extends ConsumerWidget {
  const _PopularCityTiles({required this.selectedName, required this.onSelect});

  final String selectedName;
  final Future<void> Function(City city) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(citiesProvider);

    return cities.when(
      data: (list) {
        // Only cities that actually have CityBee content are "popular".
        final popular = list.where((c) => c.hasContent).toList();
        if (popular.isEmpty) return const SizedBox.shrink();
        return Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('Popular on CityBee', style: AppTypography.label),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: popular.length,
                itemBuilder: (_, index) {
                  final city = popular[index];
                  final selected = city.name == selectedName;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Iconify(AppUiIcons.city_variant_outline,
                          color: selected ? Colors.white : AppColors.textSecondary,
                          size: 17),
                    ),
                    title: Text('${city.name}, ${city.state}',
                        style: AppTypography.bodyStrong),
                    subtitle: Text(city.nickname, style: AppTypography.label),
                    trailing: selected
                        ? Iconify(AppUiIcons.check_circle,
                            color: AppColors.primary, size: 17)
                        : Iconify(AppUiIcons.chevron_right,
                            color: AppColors.textMuted, size: 17),
                    onTap: () => onSelect(city),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Search-results loading placeholder: avatar-ish circle + two text lines.
class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(width: 36, height: 36, radius: 12),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 140, height: 12, radius: 6),
              SizedBox(height: 6),
              SkeletonBox(width: 90, height: 9, radius: 5),
            ],
          ),
        ),
      ],
    );
  }
}
