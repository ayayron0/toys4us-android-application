import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class LocalNotificationService {
  static const String orderChannelKey = 'order_updates';

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: orderChannelKey,
        channelName: 'Order updates',
        channelDescription: 'Notifications for Toys 4 Us order activity',
        defaultColor: const Color(0xFF7B1FA2),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ]);
  }

  static Future<void> showOrderConfirmedNotification({
    required double total,
  }) async {
    final allowed = await AwesomeNotifications().isNotificationAllowed();

    if (!allowed) {
      final accepted = await AwesomeNotifications()
          .requestPermissionToSendNotifications();

      if (!accepted) {
        return;
      }
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: orderChannelKey,
        title: 'Order confirmed',
        body:
            'Thanks for shopping at Toys 4 Us. Your order total was \$${total.toStringAsFixed(2)}.',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
