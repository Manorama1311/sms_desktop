import 'dart:io';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class NotificationService {
  NotificationService();
  final text = Platform.isIOS;
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  Future<void> initializePlatformNotifications() async {


    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
     );




    final InitializationSettings initializationSettings =
        InitializationSettings(

          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,

        );




    tz.initializeTimeZones();


    await _localNotifications.initialize(
      initializationSettings,
    //  onSelectNotification: selectNotification,
    );
  }

  Future<NotificationDetails> _notificationDetails() async {




    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {}
    );






    final details = await _localNotifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
     // behaviorSubject.add(details.payload!);
    }

    NotificationDetails platformChannelSpecifics = NotificationDetails(

//iOS: initializationSettingsDarwin,
    );

    return platformChannelSpecifics;
  }


  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }



  void cancelAllNotifications() => _localNotifications.cancelAll();
}
