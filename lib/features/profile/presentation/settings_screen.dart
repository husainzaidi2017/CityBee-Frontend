import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/city_picker_sheet.dart';
import '../../../core/widgets/sub_page_scaffold.dart';
import '../../../providers/app_providers.dart';

/// Settings: notification & location preferences, city selection, cache and
/// version info.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsOn = true;
  bool _dealsAlertsOn = true;
  bool _locationPersonalization = true;

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(selectedLocationProvider);

    return SubPageScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _SettingsGroup(
            title: 'Notifications',
            children: [
              _SwitchTile(
                icon: AppUiIcons.bell,
                title: 'Push Notifications',
                subtitle: 'Deals, updates & city news',
                value: _notificationsOn,
                onChanged: (value) => setState(() => _notificationsOn = value),
              ),
              _SwitchTile(
                icon: AppUiIcons.tag,
                title: 'Lightning Deal Alerts',
                subtitle: 'Instant alerts for flash offers nearby',
                value: _dealsAlertsOn,
                onChanged: _notificationsOn
                    ? (value) => setState(() => _dealsAlertsOn = value)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Location',
            children: [
              _SwitchTile(
                icon: AppUiIcons.nearMe,
                title: 'Personalize by Location',
                subtitle: 'Show businesses nearest to you first',
                value: _locationPersonalization,
                onChanged: (value) =>
                    setState(() => _locationPersonalization = value),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 13),
                leading: _IconBox(icon: AppUiIcons.city),
                title: Text('Current City', style: AppTypography.bodyStrong),
                subtitle: Text('${location.displayName}, ${location.state ?? ""}',
                    style: AppTypography.label.copyWith(fontSize: 10)),
                trailing: AppUiIcons.show(AppUiIcons.forward, size: 16, color: AppColors.textMuted),
                onTap: () => showCityPickerSheet(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleSm),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.card,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Iconify(icon, color: AppColors.primary, size: 20);
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 13),
      secondary: _IconBox(icon: icon),
      title: Text(title, style: AppTypography.bodyStrong),
      subtitle: Text(subtitle, style: AppTypography.label.copyWith(fontSize: 10)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
    );
  }
}
