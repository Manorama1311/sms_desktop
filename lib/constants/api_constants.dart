import 'package:web_socket_channel/web_socket_channel.dart';

class FzAPIConstants {

  // static const String baseUrl = 'https://8916-203-88-133-202.ngrok-free.app/';
  // static const String baseUrl1 = 'https://appprivacy.messaging.care/';
  static const String login = '/user/userlogin';
  static String getMessages = '/getuserMsgApp/';
  static String userid = '';
  static String roomid = '';
  static String companyid = '';
  static WebSocketChannel? websocket;
  static String accessToken = '';
  static String wsEndpoint = '/ws/chat/';
  static String getMessagesRoomID = '/getRoomChats/';
  static const String profile = '/user/getUserAppDetails/';
 // static String updateProfile = '/user/AppEditUser';

}
