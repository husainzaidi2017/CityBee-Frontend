import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/city.dart';
import '../../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Bottom sheet for switching the active city. All content providers
/// re-scope automatically when the selection changes.
Future<void> showCityPickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _CityPickerSheet(),
  );
}

class _CityPickerSheet extends ConsumerWidget {
  const _CityPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(citiesProvider);
    final selected = ref.watch(selectedCityProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose your city', style: AppTypography.title),
            const SizedBox(height: 4),
            Text('Offers, businesses and places update instantly.',
                style: AppTypography.caption),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.my_location, color: AppColors.primary, size: 20),
              ),
              title: Text('Use my current location', style: AppTypography.bodyStrong),
              subtitle: Text('Detects the nearest CityBee city', style: AppTypography.label),
              onTap: () async {
                final ok = await ref.read(selectedCityProvider.notifier).useMyLocation();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok
                        ? 'Location updated'
                        : 'Location unavailable — pick a city manually'),
                  ));
                  Navigator.of(context).pop();
                }
              },
            ),
            const Divider(),
            cities.when(
              data: (list) => Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (_, index) {
                    final city = list[index];
                    return _CityTile(
                      city: city,
                      selected: city.id == selected.id,
                      onTap: () {
                        ref.read(selectedCityProvider.notifier).select(city);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Could not load cities. Check your connection.',
                    style: AppTypography.caption),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({required this.city, required this.selected, required this.onTap});

  final City city;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.location_city_outlined,
            color: selected ? Colors.white : AppColors.textSecondary, size: 20),
      ),
      title: Text('${city.name}, ${city.state}', style: AppTypography.bodyStrong),
      subtitle: Text(city.nickname, style: AppTypography.label),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
          : const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
