
/// Where a notification should take the user when tapped.
enum NotificationTarget { offer, business, place, offersTab, exploreTab, moreTab }

/// Deep-link payload attached to every notification.
///
/// Mirrors the structure real FCM data messages will carry
/// (`{"type": "offer", "id": "123"}`), so the same navigation layer works
/// for pushes once Firebase is connected.
class NotificationPayload {
  const NotificationPayload({
    required this.target,
    this.entityId,
  });

  final NotificationTarget target;

  /// Id of the offer/business/place to open (absent for tab targets).
  final String? entityId;

  /// Builds a payload from an FCM-style data map, e.g.
  /// `{"type": "offer", "id": "royal-mughal-offer"}`.
  factory NotificationPayload.fromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;
    return NotificationPayload(
      target: switch (type) {
        'offer' => NotificationTarget.offer,
        'business' => NotificationTarget.business,
        'place' => NotificationTarget.place,
        'explore' => NotificationTarget.exploreTab,
        'more' => NotificationTarget.moreTab,
        _ => NotificationTarget.offersTab,
      },
      entityId: id,
    );
  }
}

/// In-app notification item shown in the notifications sheet.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.icon,
    required this.colorValue,
    required this.title,
    required this.body,
    required this.time,
    required this.payload,
  });

  final String id;
  final String icon;
  final int colorValue;
  final String title;
  final String body;
  final String time;
  final NotificationPayload payload;
}
