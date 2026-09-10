import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_notification.dart';
import '../../providers/app_providers.dart';
import '../services/notification_navigator.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Notification inbox sheet behind the bell icon. Every row carries a
/// deep-link payload and navigates to its own destination on tap.
///
/// Signed-in users see their API inbox; guests see an honest empty state
/// (sign-in prompt) — no demo data.
Future<void> showNotificationsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (_) => const _NotificationsSheet(),
  );
}

class _NotificationsSheet extends ConsumerWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(authStateProvider);
    final notifications = signedIn ? ref.watch(notificationsProvider) : null;
    final rows = notifications?.valueOrNull ?? const <AppNotification>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications', style: AppTypography.title),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_none_rounded,
                          size: 26, color: AppColors.primary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      signedIn
                          ? 'You are all caught up.'
                          : 'Sign in to see deal alerts and updates.',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              )
            else
              ...rows.map(
                (n) => _NotificationRow(
                  notification: n,
                  onTap: () =>
                      NotificationNavigator.handleNotificationTap(context, n.payload),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(notification.colorValue);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(notification.icon, color: color, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notification.title, style: AppTypography.bodyStrong),
                      ),
                      Text(notification.time, style: AppTypography.label),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(notification.body, style: AppTypography.caption),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
