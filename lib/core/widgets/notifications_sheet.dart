import 'package:flutter/material.dart';

import '../../domain/models/app_notification.dart';
import '../services/notification_navigator.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

const _mockNotifications = <AppNotification>[
  AppNotification(
    id: 'n1',
    icon: Icons.local_offer_rounded,
    colorValue: 0xFFF4691F,
    title: 'New deal near you',
    body: 'Royal Mughal: Flat 20% OFF on orders above ₹500',
    time: '2h ago',
    payload: NotificationPayload(target: NotificationTarget.offer, entityId: 'royal-mughal-offer'),
  ),
  AppNotification(
    id: 'n2',
    icon: Icons.verified,
    colorValue: 0xFF0E6B4F,
    title: 'Booking confirmed',
    body: 'Your table at Royal Restaurant & Banquet is set for 8 PM',
    time: '5h ago',
    payload: NotificationPayload(target: NotificationTarget.business, entityId: 'royal-mughal'),
  ),
  AppNotification(
    id: 'n3',
    icon: Icons.location_on_outlined,
    colorValue: 0xFFE23A2E,
    title: 'Weekend explore ideas',
    body: 'Peetal Bazaar and Rudra Lake are trending this weekend',
    time: '1d ago',
    payload: NotificationPayload(target: NotificationTarget.exploreTab),
  ),
];

/// Notification inbox sheet behind the bell icon. Every row carries a
/// deep-link payload and navigates to its own destination on tap.
Future<void> showNotificationsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications', style: AppTypography.title),
            const SizedBox(height: 12),
            ..._mockNotifications.map(
              (n) => _NotificationRow(
                notification: n,
                onTap: () =>
                    NotificationNavigator.handleNotificationTap(context, n.payload),
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
