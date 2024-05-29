import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Colors
const kBackgroundColor = Color(0xFFD2FFF4);
const kPrimaryColor = Color(0xFF2D5D70);
const kSecondaryColor = Color(0xFF265DAB);

// TODO Implement this library.


const localurlLogin = "https://appprivacy.messaging.care";

 const wsdomain = "appprivacy.messaging.care";
// const wsprotocol = "wss";

// const localurlLogin = "https://313a-203-88-133-202.ngrok-free.app";
//
// const wsdomain = "313a-203-88-133-202.ngrok-free.app";
// const wsprotocol = "wss";


// const localurlLogin = "http://172.31.199.45:5000";
//
// const wsdomain = "172.31.199.45:5000";
const wsprotocol = "ws";


const apiKey = "hello";
 bool passwordVisible = false;
// routes

const usergetmsg = "/getuserMsgApp/";
const superAdminMsg = "/superAdminMsg/";
const accTokenuser = "/user/getUserAppDetails/";
const usergetroommsg = "/SuperAdminMsgWithCustomRoom/";
const websocket = "/getRoomChats/";


const wsurlchat = "/ws/chat/";
const wsurlnotify = "/ws/notify/";

class Constants {
  static String userid = '';
  static String roomid = '';
  static  String companyid = '';
  static String user_uii = '';
  static WebSocketChannel? websocket;
 // static final wsurlchat = "/ws/chat/$user_uii/2";
  static String accessToken = '';
  static const String profile = '/user/getUserAppDetails/';
  static String updateProfile = '/user/AppEditUser';
  static var websocketconnection = false;
  static var websocketController = BehaviorSubject<dynamic>();
  static int platform = 1; // Android = 1 && iOS = 2 && Web = 3

  static bool debugLabel = false;

  static String title = 'SMS';
  static bool passwordVisible = false;
  static String forgot = 'Forgot Password';
  static String login = 'Login';
  static String forgotPassword = 'Forgot Password?';
  static String password = 'Password';
  static String email = 'Email Address';


  static const String userTokenKey = 'token';
  static const String accessTokenKey = 'accesstoken';
  static const String darkModePref = 'darkModePref';
  static const String notificationPref = 'notificationPref';
  static String progressAlert = '';
  static bool darkModeOn = true;
  static bool notificationson = true;
  static bool websocketconnected = false;
}
