

//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sms/screens/chatPageApiWorking.dart';

class LocalNotificationService {


  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize() {
    // initializationSettings  for Android
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );





    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (r){

      }
      // onSelectNotification: (String? id) async {
      //   print("onSelectNotification");
      //   if (id!.isNotEmpty) {
      //     print("Router Value1234 $id");
      //
      //     // Navigator.of(context).push(
      //     //   MaterialPageRoute(
      //     //     builder: (context) => DemoScreen(
      //     //       id: id,
      //     //     ),
      //     //   ),
      //     // );
      //
      //
      //   }
      // },
    );
  }
  // static void createanddisplaynotification(RemoteMessage message) async {
  //   try {
  //     final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  //     const NotificationDetails notificationDetails = NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         "pushnotificationapp",
  //         "pushnotificationappchannel",
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //       iOS: DarwinNotificationDetails(
  //
  //       ),
  //         macOS: DarwinNotificationDetails(
  //
  //         )
  //     );
  //
  //
  //
  //
  //     await _notificationsPlugin.show(
  //       id,
  //       message.notification!.title,
  //       message.notification!.body,
  //       notificationDetails,
  //       payload: message.data['_id'],
  //     );
  //   } on Exception catch (e) {
  //     print(e);
  //   }
  // }

}