import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
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
                icon: Icons.notifications_none_rounded,
                title: 'Push Notifications',
                subtitle: 'Deals, updates & city news',
                value: _notificationsOn,
                onChanged: (value) => setState(() => _notificationsOn = value),
              ),
              _SwitchTile(
                icon: Icons.local_offer_outlined,
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
                icon: Icons.near_me_outlined,
                title: 'Personalize by Location',
                subtitle: 'Show businesses nearest to you first',
                value: _locationPersonalization,
                onChanged: (value) =>
                    setState(() => _locationPersonalization = value),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 13),
                leading: _IconBox(
                  icon: Icons.location_city_outlined,
                  color: AppColors.primary,
                  bg: AppColors.primarySoft,
                ),
                title: Text('Current City', style: AppTypography.bodyStrong),
                subtitle: Text('${location.displayName}, ${location.state ?? ""}',
                    style: AppTypography.label.copyWith(fontSize: 10)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 19, color: AppColors.textMuted),
                onTap: () => showCityPickerSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'About',
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 13),
                leading: _IconBox(
                  icon: Icons.info_outline_rounded,
                  color: AppColors.catDoctor,
                  bg: AppColors.catDoctorSoft,
                ),
                title: Text('App Version', style: AppTypography.bodyStrong),
                trailing: Text('1.0.0', style: AppTypography.label),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 13),
                leading: _IconBox(
                  icon: Icons.link_rounded,
                  color: AppColors.catHotel,
                  bg: AppColors.catHotelSoft,
                ),
                title: Text('Website', style: AppTypography.bodyStrong),
                subtitle: Text(AppConfig.appUrl,
                    style: AppTypography.label.copyWith(fontSize: 10)),
                onTap: () => AppLauncher.openWebsite(AppConfig.appUrl),
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
  const _IconBox({required this.icon, required this.color, required this.bg});

  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 17),
    );
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

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 13),
      secondary: _IconBox(
        icon: icon,
        color: AppColors.primary,
        bg: AppColors.primarySoft,
      ),
      title: Text(title, style: AppTypography.bodyStrong),
      subtitle: Text(subtitle, style: AppTypography.label.copyWith(fontSize: 10)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
    );
  }
}
