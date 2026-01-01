import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/session.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService() {
    _init();
  }

  void _init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);
  }

  Future<void> showSessionNotification(Session session) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'session_channel',
      'Sessions',
      channelDescription: 'Notifications for new sessions/orders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      session.id.hashCode,
      'New Session (${session.type.name})',
      'Created by ${session.createdBy}, Table: ${session.tableId}',
      details,
    );
  }
}
