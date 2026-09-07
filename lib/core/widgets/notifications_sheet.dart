import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class _Notification {
  const _Notification(this.icon, this.color, this.title, this.body, this.time);

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
}

const _mockNotifications = [
  _Notification(Icons.local_offer_rounded, AppColors.accent, 'New deal near you',
      'Royal Mughal: Flat 20% OFF on orders above ₹500', '2h ago'),
  _Notification(Icons.verified, AppColors.primary, 'Booking confirmed',
      'Your table at Royal Restaurant & Banquet is set for 8 PM', '5h ago'),
  _Notification(Icons.location_on_outlined, AppColors.badgeRed, 'City helpline',
      '112 Police and 1912 Bijli Board are now one tap away on Services', '1d ago'),
];

/// Simple notification inbox sheet behind the bell icon.
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
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: n.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(n.icon, color: n.color, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(n.title, style: AppTypography.bodyStrong),
                              ),
                              Text(n.time, style: AppTypography.label),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(n.body, style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
