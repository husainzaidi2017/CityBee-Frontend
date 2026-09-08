import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/app_notification.dart';

/// Maps notification payloads to routes.
///
/// Single entry point for notification navigation: the in-app sheet, FCM
/// foreground messages and cold-start launches all funnel through
/// [handleNotificationTap] so behaviour stays consistent.
abstract final class NotificationNavigator {
  static String routeFor(NotificationPayload payload) => switch (payload.target) {
        NotificationTarget.offer when payload.entityId != null =>
          '/offer/${payload.entityId}',
        NotificationTarget.business when payload.entityId != null =>
          '/business/${payload.entityId}',
        NotificationTarget.place when payload.entityId != null =>
          '/place/${payload.entityId}',
        NotificationTarget.offersTab => '/offers',
        NotificationTarget.exploreTab => '/explore',
        NotificationTarget.moreTab => '/more',
        _ => '/offers',
      };

  static void handleNotificationTap(BuildContext context, NotificationPayload payload) {
    Navigator.of(context).maybePop(); // dismiss the sheet first
    context.push(routeFor(payload));
  }
}
