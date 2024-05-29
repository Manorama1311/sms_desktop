import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sms/screens/chatPageApiWorking.dart';
import 'package:sms/screens/login_screen.dart';
import 'dart:io' show Platform;

import '../utils/constants.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

Future<String> getPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  // ignore: non_constant_identifier_names
  bool CheckValue = prefs.containsKey('token');
  var token = "";
  if (CheckValue == true) {
    token = prefs.getString('token')!;
  }
  return token;
}

Future<String> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  // ignore: non_constant_identifier_names
  bool CheckValue = prefs.containsKey('accessToken');
  var accessToken = "";
  if (CheckValue == true) {
    accessToken = prefs.getString('accessToken')!;
  }
  return accessToken;
}
Future<String> getCompanyId() async {
  final prefs = await SharedPreferences.getInstance();
  // ignore: non_constant_identifier_names
  bool CheckValue = prefs.containsKey('company_id');
  var companyid = "";
  if (CheckValue == true) {
    companyid = prefs.getString('company_id')!;
  }
  return companyid;
}
class _SplashState extends State<Splash> {
  dynamic newtoken = "";
  dynamic newaccessToken = "";
dynamic newcompanyid="";
  void checkToken() async {
    // if (Platform.isWindows) {
    // } else if (Platform.isIOS) {
    // }
  ;
    String tokens = await getPrefs();
    String accessToken = await getAccessToken();
  String companyid = await getCompanyId();
    // var tokens = await storage.read(key: "token");
    newtoken = tokens;
    newaccessToken = accessToken;
    newcompanyid = companyid;

  }


  @override
  void initState() {
    super.initState();
    checkToken();
    startTime();

  }

  startTime() async {
    var _duration = const Duration(seconds: 5);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {

    setState(
      () {
        if (newtoken == null ||
            newtoken == "" ||
            newaccessToken == null ||
            newaccessToken == "") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
          // LoginScreen().launch(context);
        } else {
        setState(() {
          Constants.user_uii =  newtoken;
          Constants.companyid =  newcompanyid;
        });

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) =>  ChatPage()));
          // const HomeScreen(errMsg: '').launch(context);
          // Dashboard().launch(context);
        }
        // finish(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;
    return

      Scaffold(
      backgroundColor: Color(0xff2E8A99),
      body:

      Center(
        child: Container(
          height: width * .5,child: Image.asset(
          'assets/logo.png',height: 100,width: 150,fit: BoxFit.contain,
        ),
        ),
      ),
    );
  }
}
