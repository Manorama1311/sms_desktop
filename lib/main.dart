
import 'dart:io';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sms/Notification/notification.dart';
import 'package:sms/screens/splash.dart';
import 'package:toastification/toastification.dart';


// Future<void> backgroundHandler(RemoteMessage message) async {
//   print(message.data.toString());
//   print(message.notification!.title);
// }


 void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isMacOS) {
  //   await Firebase.initializeApp(
  //       options: FirebaseOptions(
  //           apiKey: 'AIzaSyDLNYFY8RJeLMfas2OhlzHjYqsQlxfy2gQ',
  //           appId: '1:218038339031:ios:cd23ec01e746212e5a3792',
  //           messagingSenderId: 'G-N267PNFZPT',
  //           projectId: 'python-412bf'));
  //
  // } else {
  //   await Firebase.initializeApp();
  // }
  //
  // FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  // LocalNotificationService.initialize();
  runApp( RunMyApp());
}

class RunMyApp extends StatefulWidget {
  const RunMyApp({super.key});

  @override
  State<RunMyApp> createState() => _RunMyAppState();
}

class _RunMyAppState extends State<RunMyApp> {
  ThemeMode _themeMode = ThemeMode.system;


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme:AppBarTheme(
          backgroundColor: Color(0xFF006064),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),

      // standard dark theme
  //    darkTheme: ThemeData.l(),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
    home: Splash()



    );
  }
}

class MYAPPPP extends StatefulWidget {
  const MYAPPPP({Key? key}) : super(key: key);

  @override
  State<MYAPPPP> createState() => _MYAPPPPState();
}

class _MYAPPPPState extends State<MYAPPPP> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar
        (),
      body: GestureDetector(
          onTap: (){
            toastification.show(
              context: context, // optional if you use ToastificationWrapper

              autoCloseDuration: const Duration(seconds: 5),
              title: 'Hello, World!',




            );
          },
          child: Text("dfghfdgjdfgjdg")),
    );
  }
}





//
// import 'dart:async';
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:sms/Notification/notification.dart';
// import 'package:sms/screens/sendNewMessage/UsersListForSendMessage.dart';
// import 'package:sms/screens/sendNewMessage/new_message.dart';
// import 'package:sms/screens/splash.dart';
//
//
//
// Future<void> backgroundHandler(RemoteMessage message) async {
//   print(message.data.toString());
//   print(message.notification!.title);
// }
//
//
//  void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   if (Platform.isMacOS) {
//     await Firebase.initializeApp(
//         options: FirebaseOptions(
//             apiKey: 'AIzaSyDLNYFY8RJeLMfas2OhlzHjYqsQlxfy2gQ',
//             appId: '1:218038339031:ios:cd23ec01e746212e5a3792',
//             messagingSenderId: 'G-N267PNFZPT',
//             projectId: 'python-412bf'));
//
//   } else {
//     await Firebase.initializeApp();
//   }
//
//   FirebaseMessaging.onBackgroundMessage(backgroundHandler);
//   LocalNotificationService.initialize();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SMS',
//       debugShowCheckedModeBanner: false,
//
//       theme: ThemeData(
//
//        // scaffoldBackgroundColor: kBackgroundColor,
//         // textTheme: Theme.of(context).textTheme.apply(
//         //       bodyColor: kPrimaryColor,
//         //       fontFamily: 'Montserrat',
//         //     ),
//       ),
//       home:
//      Splash(),
//     );
//   }
// }



