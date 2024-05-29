//ignore_for_file: library_private_types_in_public_api, prefer_interpolation_to_compose_strings, avoid_print

import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:convert';
import 'package:badges/badges.dart' as badges;

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/Notification/notification.dart';
import 'package:sms/Notification/notifications.dart';
import 'package:sms/constants/colors.dart';
import 'package:sms/models/chatusersmodels.dart';

import 'package:sms/screens/Menu.dart';
import 'package:sms/screens/chatDetailPage.dart';
import 'package:sms/screens/new_message/contactList.dart';
import 'package:sms/screens/photoview.dart';
import 'package:sms/screens/sendNewMessage/UsersListForSendMessage.dart';
import 'package:sms/screens/sendNewMessage/new_message.dart';
import 'package:sms/services/auth_service.dart';
import 'package:sms/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

import '../models/chat.dart';

import '../widgets/conversationListAPI.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'NewMessageScreen.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Future<List<Countuser>> countuser;
  List<Countuser>? chatUsers = [];
  List<Countuser>? filterUsers = [];
  bool isLoading = false;
  dynamic newtoken = "";
  dynamic user;
  var uuid;
  List ?UserList;
  var id;
  String? _value;
  static UserDetails userDetails = UserDetails();
  //var _channel;
  TextEditingController _searchController = TextEditingController();
  final _channel = WebSocketChannel.connect(
    // ignore: prefer_interpolation_to_compose_strings
    Uri.parse(wsprotocol +
        '://' +
        wsdomain +
        wsurlchat +
        "${Constants.user_uii}/${Constants.companyid}/"),
  );

  final AuthService authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  late final NotificationService notificationService;
  String ?formattedDate;
  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    var formatter = DateFormat('MMMM dd');
    formattedDate = formatter.format(now);

   // // notificationService = NotificationService();
   //  FirebaseMessaging.instance.getInitialMessage().then(
   //        (message) {
   //      print("FirebaseMessaging.instance.getInitialMessage");
   //      if (message != null) {
   //        print("New Notification");
   //        // if (message.data['_id'] != null) {
   //        Navigator.of(context)
   //            .push(MaterialPageRoute(builder: (ctx) => ChatPage()));
   //      }
   //    },
   //  );
   //  // 2. This method only call when App in forground it mean app must be opened
   //  FirebaseMessaging.onMessage.listen(
   //        (message) {
   //      print("FirebaseMessaging.onMessage.listen");
   //      if (message.notification != null) {
   //        print(message.notification!.title);
   //        print(message.notification!.body);
   //        print("message.data11 ${message.data}");
   //        LocalNotificationService.createanddisplaynotification(message);
   //      }
   //    },
   //  );
   //
   //  // 3. This method only call when App in background and not terminated(not closed)
   //  FirebaseMessaging.onMessageOpenedApp.listen(
   //        (message) {
   //      print("FirebaseMessaging.onMessageOpenedApp.listen");
   //      if (message.notification != null) {
   //        print(message.notification!.title);
   //        print(message.notification!.body);
   //
   //        //  print("message.data22 ${message.data['_id']}");
   //      }
   //    },
   //  );
    getUserDetails();
    getEmployeeList1();
    websocket();
  }

  onSearchTextChanged(String text) async {
    chatUsers!.clear();
    if (text.isEmpty) {
      chatUsers = [...filterUsers!];
      setState(() {});
      return;
    }
    for (var userDetail in filterUsers!) {
      if ((userDetail.firstName != null &&
              userDetail.firstName!
                  .toLowerCase()
                  .contains(text.toLowerCase())) ||
          (userDetail.lastName != null &&
              userDetail.lastName!.contains(text)) ||
          (userDetail.contact != null &&
              userDetail.contact!
                  .toString()
                  .replaceAll("(", "")
                  .replaceAll(")", "")
                  .replaceAll("-", "")
                  .replaceAll(" ", "")
                  .contains(text
                      .replaceAll("(", "")
                      .replaceAll(")", "")
                      .replaceAll("-", "")
                      .replaceAll(" ", "")))) {
        chatUsers!.add(userDetail);
      }
    }
    setState(() {});
  }

  // getDeviceToken() async {
  //   String? deviceToken = await FCMPushNotifications().getDeviceToken();
  //   print("deviceToken" + deviceToken.toString());
  // }
  submit1() async {
    setState(() {
      Loading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString("accessToken");
    var uuid = prefs.getString("token");
    var request = http.MultipartRequest(
        'POST', Uri.parse(localurlLogin + "/user/AppEditUser"));
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['id'] = userDetails.data!.uuid.toString();
    request.fields['primaryNumber'] = selectedValue.toString();
    request.fields['is_active'] = "True";

    var response = await request.send();

    final res = await http.Response.fromStream(response);
    print(res);
    if (response.statusCode == 200) {
      // final res = await http.Response.fromStream(response);
      toastification.show(
        context: context, // optional if you use ToastificationWrapper
        title:  "Number Updated Successfully!",
        autoCloseDuration: const Duration(seconds: 5),
 
        backgroundColor: Colors.green,
        padding:const EdgeInsets.all(0)
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatPage()),
      ).then((value) {});
    } else {
      //final res = await http.Response.fromStream(response);

      setState(() {});
      toastification.show(
        context: context, // optional if you use ToastificationWrapper
        title:  "Something Wrong!!",
        autoCloseDuration: const Duration(seconds: 5),

        backgroundColor: Colors.red,
          padding:const EdgeInsets.all(0)
      );

    }
    setState(() {
      Loading = false;
    });
  }
  websocket() async {
    if (Constants.websocketconnection == false) {
      print("Web Socket Connected");
      Constants.websocket = _channel;
      _channel.stream.listen((message) {
        print(message.runtimeType);
        var msg = jsonDecode(message);
        // var title = jsonDecode(message[0]["message"].toString());
        // print(title);

        print("msg ${msg.runtimeType}");
        print(msg);
        print("msg new${msg['message']}");

        if (Constants.roomid != '') {
          print("okay roomid received" + Constants.roomid.toString());

          Constants.websocketController.add(msg);
          toastification.show(
            context: context, // optional if you use ToastificationWrapper
            title:  "Message received " + msg.toString(),
            autoCloseDuration: const Duration(seconds: 5),
            icon: const Icon(Icons.message,size: 18,),
            backgroundColor: Colors.green,
              padding:const EdgeInsets.all(0)
          );
        } else {
          toastification.show(
            context: context, // optional if you use ToastificationWrapper
            title:  "Message received " + msg.toString(),
            autoCloseDuration: const Duration(seconds: 5),
            icon: const Icon(Icons.message,size: 18,),
            backgroundColor: Colors.green,
              padding:const EdgeInsets.all(0)
          );
          print("okay msg received" + msg.toString());
        }

        // notificationService.showLocalNotification(
        //     id: 0,
        //     title: "New Message Arrived  " +
        //         msg["message"] +
        //         " from " +
        //         msg["phone"],
        //     body: "",
        //     payload: "");

        getEmployeeList();
      });
      Constants.websocketconnection = true;
    }
  }

  @override
  void dispose() {
    timer.cancel();
    timer;
    super.dispose();
  }

  getEmployeeList1() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString("accessToken");
    var uuid = prefs.getString("token");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var url = Uri.parse(localurlLogin + "/getSideListInfo/$uuid");
    http.Response response = await http.get(url, headers: headers);

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      UserList = json.decode(response.body)["countuser"];

      final chatData = Chat.fromJson(json.decode(response.body));
      chatUsers = chatData.countuser!;
      newMessageUser = chatData.countuser!;
      filterUsers = [...chatData.countuser!];
      setState(() {
        selectedIndex = 0;
      });
      dynamic test = chatUsers![0].date!.toLocal();
      setState(() {
        Constants.roomid = chatUsers![0].room!;
        contact=
            chatUsers![0].contact.toString();
        date= DateFormat('MMM d  h:mm a')
            .format(test);
        firstName=
        chatUsers![0].firstName != null
            ? chatUsers![0].firstName!
            : '';
        id= chatUsers![0].id;
        image= chatUsers![0].image!;
        lastName= chatUsers![0].lastName != null
            ? chatUsers![0].lastName!
            : '';
        room= chatUsers![0].room;
        total= chatUsers![0].total;
        unread= chatUsers![0].unread;
        isgroup= chatUsers![0].group;
        finalvalue= chatUsers![0].finalval;
        userLists=UserList!;
      });

      getwallpaper();

      getRoomUserMessages(room);
      getUserDetails();
      getMediaList();


      Constants.websocketController.listen((latestEvent) {

        if (latestEvent['room'] == Constants.roomid) {
          getRoomUserMessages(room);
        }

      });

      setState(() {});

      setState(() {
        chatUsers;
      });
    } else {}
  }

  getEmployeeList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString("accessToken");
    var uuid = prefs.getString("token");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var url = Uri.parse(localurlLogin + "/getSideListInfo/$uuid");
    http.Response response = await http.get(url, headers: headers);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      UserList = json.decode(response.body)["countuser"];
      final chatData = Chat.fromJson(responseJson);
      chatUsers = chatData.countuser!;
      filterUsers = [...chatData.countuser!];


      setState(() {
        chatUsers;
      });
    } else {}
  }

  getUserDetails() async {
    setState(() {
      Loading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString("accessToken");
    uuid = prefs.getString("token");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var url = Uri.parse(localurlLogin + "/user/getUserAppDetails/$uuid");
    http.Response response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      setState(() {
        isLoading = false;
      });
      setState(() {
        Loading = true;
      });
      setState(() {
        userDetails = UserDetails.fromJson(responseJson);
        selectedValue = userDetails.data!.primaryNumber;
      });
    } else {}
    setState(() {
      isLoading = false;
    });
    setState(() {
      Loading = true;
    });
  }

  String? selectedValue;
  bool Loading = false;
  int? unread;
  int? total;
  String? contact;
  String? firstName;
  String? lastName;
  String? image;
  String? date;
  int? ids;
  String? room;
  bool? isgroup;
  var finalvalue;
  List userLists =[];
bool ishsownewMessage = false;
  int ? selectedIndex;
var selectedchatdata;
bool isshowmessage = false;



  TextEditingController _tocontroller = TextEditingController();

  List<Countuser>?  TofilteredEmails = [];


  List toList = [];


  void TofilterEmails(String query) {
    TofilteredEmails = [];


    setState(() {
      for (var userDetail in newMessageUser!) {
        if ((userDetail.firstName != null &&
            userDetail.firstName!
                .toLowerCase()
                .contains(query.toLowerCase())) ||
            (userDetail.lastName != null &&
                userDetail.lastName!.contains(query)) ||
            (userDetail.contact != null &&
                userDetail.contact!
                    .toString()
                    .replaceAll("(", "")
                    .replaceAll(")", "")
                    .replaceAll("-", "")
                    .replaceAll(" ", "")
                    .contains(query
                    .replaceAll("(", "")
                    .replaceAll(")", "")
                    .replaceAll("-", "")
                    .replaceAll(" ", "")))) {
          TofilteredEmails!.add(userDetail);



        }
      }
    });
  }

  void _ToremoveChip(String chip) {
    setState(() {
      toList.remove(chip);
      messages = [];
    });
  }






  var newMessageUser =[];

  bool isClicked = false;
  var email;
  var subjecttext;
  var bodytext;


  final _formKey = GlobalKey<FormState>();



  @override
  Widget build(BuildContext context) {

    List contactList = userDetails.data != null
        ? [
            userDetails.data!.contactPhone,
            userDetails.data!.contactPhone1,
            userDetails.data!.contactPhone2,
            userDetails.data!.contactPhone3
          ]
        : [];
    contactList.removeWhere((item) => item == null || item == "");

    return Scaffold(
      backgroundColor:  Colors.grey.shade50,
      appBar: PreferredSize(
        child: userDetails.data != null
            ? Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, top: 10.0, bottom: 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: CachedNetworkImage(
                                      height: 35,width: 35,
                                      fit: BoxFit.contain,
                                      imageUrl: userDetails.data!.image != null
                                          ? localurlLogin + userDetails.data!.image!
                                          : 'https://appprivacy.messaging.care/media/blank.png',
                                      placeholder: (context, url) =>
                                          CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        minRadius: 20.0,
                                        maxRadius: 25.0,
                                      ),
                                      imageBuilder: (context, image) =>
                                          CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: image,
                                        minRadius: 20.0,
                                        maxRadius: 25.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  isLoading != true
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 4),
                                              child: Text(
                                                "Hi, " +
                                                    userDetails.data!.firstName! +
                                                    ' ' +
                                                    userDetails.data!.lastName!,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            isLoading != true
                                                ?   userDetails.data!.contactPhone1!=null?

                                            Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      userDetails.data!.company!
                                                                  .contactPhone ==
                                                              userDetails.data!
                                                                  .primaryNumber
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3.0),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    "Company : ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3.0),
                                                              child: Text(
                                                                "Personal : ",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 4,top: 4,right: 4),
                                                        child: Container(

                                                          child: Text(
                                                            userDetails.data!.company!.companyName!,
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.w400),
                                                          ),
                                                        ),
                                                      ),

                                                      DropdownButton(
                                                        value: selectedValue,
                                                        isDense: true,
                                                        iconEnabledColor:
                                                            Colors.white,
                                                        dropdownColor:
                                                            Color(0xFF006064),
                                                        underline: SizedBox(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            selectedValue =
                                                                newValue!;
                                                            submit1();
                                                          });
                                                        },
                                                        items: contactList.map<
                                                                DropdownMenuItem>(
                                                            (value) {
                                                          return DropdownMenuItem(
                                                            value: value,
                                                            child: Text(
                                                              value,
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),

                                                    ],
                                                  ):
                                            Padding(
                                              padding:
                                              const EdgeInsets
                                                  .all(3.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Company : ",
                                                    style: TextStyle(
                                                        fontSize:
                                                        14,
                                                        color: Colors
                                                            .white,
                                                        fontWeight:
                                                        FontWeight.w400),
                                                  ),

                                                  Text(
                                                    userDetails.data!.primaryNumber.toString(),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors
                                                            .white,
                                                        fontWeight:
                                                        FontWeight
                                                            .w400),
                                                  ),

                                                ],
                                              ),
                                            )
                                                : Center(
                                                    child: Container(
                                                        height: 22,
                                                        width: 22,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ))),

                                          ],
                                        )
                                      : Center(
                                          child: Container(
                                              height: 22,
                                              width: 22,
                                              // child: CircularProgressIndicator(
                                              //   color: Colors.white,
                                              // )
                                          )),
                                  Spacer(),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                              builder: (ctx) => SMSMenu()))
                                              .then((value) {
                                            getUserDetails();
                                            // getEmployeeList1();
                                            // websocket();

                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Icon(
                                            Icons.settings,
                                            size: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                                          color:   Color(0xFF0C1446),
                                          ),

                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 6),
                                            child: Text("Today "+formattedDate.toString(),style: TextStyle(fontSize: 13,color: Colors.white),),
                                          )),
SizedBox(width: 10,)
                                    ],
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      ],
                    )),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0C1446),

                        Color(0xFF006064),
                        Color(0xFF1F6E8C),
                        // Color(0xffE3F4F4)
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 20.0,
                        spreadRadius: 1.0,
                      )
                    ]),
              )
            : Container(),
        preferredSize: Size(
          MediaQuery.of(context).size.width,
          65.0,
        ),
      ),



      body: userDetails.data != null
          ?


      Row(
        children: <Widget>[

          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child:

                        ListView(
                          children: [

SizedBox(height: 6,),
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 10),
                       child:
                       GestureDetector(
                         onTap: (){
                           setState(() {
                             isshowmessage = true;
                             messages = [];
                             toList =[];
                           });
                         },
                         child: Container(
                           height: 35,
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(4),
                             color: Color(0xFF006064)
                           ),
                           child:
                          Center(child: Text("+ Send New Message",style: TextStyle(color: Colors.white,fontSize: 13),),
                          ) ),
                       ),
                     ),

                            SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (v) {
                                      onSearchTextChanged(v);
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search by name and number'
                                        ,hintStyle: TextStyle(color: Colors.black54,fontSize: 13),
                                      // Add a clear button to the search bar
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                            chatUsers = [...filterUsers!];
                                          });
                                        },
                                      ),
                                      // Add a search icon or button to the search bar
                                      prefixIcon: IconButton(
                                        icon: Icon(Icons.search),
                                        onPressed: () {
                                          onSearchTextChanged(_searchController.text);
                                        },
                                      ),
                                      contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6.0),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF006064), width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6.0),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF006064), width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6.0),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF006064), width: 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),


                        isLoading
                            ? Padding(
                          padding: const EdgeInsets.only(top: 200),
                          child: Center(

                          ),
                        )
                            : chatUsers != 0
                            ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: StaggeredGridView.countBuilder(
                          controller: ScrollController(keepScrollOffset: false),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          crossAxisCount: 1,
                          staggeredTileBuilder: (int index) =>
                                StaggeredTile.fit(4),
                          itemCount: chatUsers!.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                              dynamic test = chatUsers![index].date!.toLocal();
                              return Column(
                                children: [
                                  GestureDetector(

                                    onTap: () {

                                      setState(() {
                                        isshowmessage = false;

                                        selectedIndex = index;
                                      });

                                      setState(() {
                                        Constants.roomid = chatUsers![index].room!;
                                        contact=
                                            chatUsers![index].contact.toString();
                                        date= DateFormat('MMM d  h:mm a')
                                            .format(test);
                                        firstName=
                                        chatUsers![index].firstName != null
                                            ? chatUsers![index].firstName!
                                            : '';
                                        id= chatUsers![index].id;
                                        image= chatUsers![index].image!;
                                        lastName= chatUsers![index].lastName != null
                                            ? chatUsers![index].lastName!
                                            : '';
                                        room= chatUsers![index].room;

                                        total= chatUsers![index].total;
                                        unread= chatUsers![index].unread;
                                        isgroup= chatUsers![index].group;
                                        finalvalue= chatUsers![index].finalval;
                                        userLists=UserList!;



                                      });

                                      getwallpaper();

                                      getRoomUserMessages(room);
                                      getUserDetails();
                                      getMediaList();


                                      Constants.websocketController.listen((latestEvent) {

                                        if (latestEvent['room'] == Constants.roomid) {
                                          getRoomUserMessages(room);
                                        }

                                      });

                                      setState(() {});



                                    },
                                    child:

                                    Container(

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color:isshowmessage == false?
                                        selectedIndex != index ? Colors.white :  Colors.black12:Colors.white,
                                      ),
                                      child:
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[

                                                  (chatUsers![index].image != "" && chatUsers![index].image != null )
                                                      ? CachedNetworkImage(
                                                    height: 24,width: 24,
                                                    fit: BoxFit.contain,
                                                    imageUrl: chatUsers![index].image!=""
                                                        ? localurlLogin + chatUsers![index].image!
                                                        : 'https://appprivacy.messaging.care/media/blank.png',
                                                    placeholder: (context, url) =>
                                                        CircleAvatar(
                                                          backgroundColor: Colors.orange,
                                                          minRadius: 16.0,
                                                          maxRadius: 16.0,
                                                        ),
                                                    imageBuilder: (context, image) =>
                                                        CircleAvatar(
                                                          backgroundColor:
                                                          Colors.transparent,
                                                          backgroundImage: image,
                                                          minRadius: 16.0,
                                                          maxRadius: 16.0,
                                                        ),
                                                  )
                                                      :   Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                     ( chatUsers![index].firstName == "" || chatUsers![index].firstName == null)
                                                          ? Container(
                                                        height: 24,
                                                        width: 24,
                                                        child: ClipRRect(
                                                          borderRadius:BorderRadius.circular(60),
                                                          child: Image.network("https://appprivacy.messaging.care/media/blank.png"    ,height: 24,
                                                            width: 24,
                                                            fit: BoxFit.contain,),
                                                        ),
                                                      ):
                                                      Container(
                                                        height: 24,
                                                        width: 24,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(30),
                                                            color: chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="A"?
                                                            Color(0xFFFF0000):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="B"?
                                                            Color(0xFF2b2b40):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="D"?
                                                            Color(0xFF50cd89):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="E"?
                                                            Color(0xFFe033c3):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="F"?
                                                            Color(0xFF00FFFF):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="G"?
                                                            Color(0xFF800000):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="H"?
                                                            Color(0xFF008000):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="I"?
                                                            Color(0xFF000080):
                                                            chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="J"?
                                                            Color(0xFF808000):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="K"?
                                                            Color(0xFF800080):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="L"?
                                                            Color(0xFF008080):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="M"?
                                                            Color(0xFFa24c7d):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="N"?
                                                            Color(0xFF613f3f):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="O"?
                                                            Color(0xFFFFA500):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="P"?
                                                            Color(0xFFb96969):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="Q"?
                                                            Color(0xFF7e00e3):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="R"?
                                                            Color(0xFFf1416c):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="S"?
                                                            Color(0xFFff4a00):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="T"?
                                                            Color(0xFF87CEEB):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="U"?
                                                            Color(0xFF9370DB):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="V"?
                                                            Color(0xFFFF1493):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="W"?
                                                            Color(0xFF48D1CC):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="X"?
                                                            Color(0xFF20B2AA):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="Y"?
                                                            Color(0xFFB0E0E6):chatUsers![index].firstName.toString().substring(0,1).toUpperCase()=="Z"?
                                                            Color(0xFFdf8fdf):Color(0xFF0072ff)
                                                        ),
                                                        child: Center(child: Text(chatUsers![index].firstName.toString().substring(0,1).toUpperCase()+""+
                                                            chatUsers![index].lastName.toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                                          style: TextStyle(color: Colors.white,fontSize: 10),
                                                        ),


                                                        ),


                                                      ),

                                                    ],
                                                  ),



                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                         (chatUsers![index].firstName==null || chatUsers![index].firstName== "")
                                                              ? Container(
                                                                width: 180,

                                                                child: Text(
                                                                  chatUsers![index].contact!.toString().replaceAll("]", "").replaceAll("[", "").replaceAll("-", ""),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 3,
                                                                  style: TextStyle(
                                                                      fontSize: 11,
                                                                      color: Colors.black,
                                                                      fontWeight:
                                                                      FontWeight.w500),
                                                                ),
                                                              ):
                                                          Container(
                                                            width: 200,
                                                            child: Text(
                                                              chatUsers![index].firstName! + ' ' + chatUsers![index].lastName!,
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors.black,
                                                                  fontWeight:
                                                                  FontWeight.w500),
                                                            ),
                                                          ),



                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  chatUsers![index].date!.toString()
                                                      .substring(0,16),
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(fontSize: 9,color: Colors.black54),
                                                ),

                                                chatUsers![index].unread! != 0
                                                    ? Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 4, vertical: 2),
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF006064)),
                                                  // alignment: Alignment.center,
                                                  child: Text(
                                                    chatUsers![index].unread.toString(),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                                    : Container(),

                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                          },
                        ),
                            )
                            : Text("user not found")
                      ]),
                    ),
Container(width: 1,color: Colors.black26,),



          isshowmessage == false?

          Flexible(
            flex: 5,
            fit: FlexFit.tight,
            child:  buildchats()
          ):
          Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child:



              Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,titleSpacing: 10,
                  elevation: 0.6,
                  backgroundColor: Colors.white,
                  title: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 0,vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: TextField(
                            controller: _tocontroller,
                            onChanged: (value) {
                              setState(() {
                                _tocontroller.text.length > 1
                                    ? TofilterEmails(_tocontroller.text)
                                    : null;

                                if (_tocontroller.text.length == 0) {
                                  TofilteredEmails = [];
                                  messages = [];
                                }
                              });
                            },
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search contact to message',
                              // Add a clear button to the search bar
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _tocontroller.clear();
                                    TofilteredEmails = [];
                                    messages = [];
                                  });
                                },
                              ),
                              // Add a search icon or button to the search bar
                              prefixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  setState(() {
                                    _tocontroller.text.length > 1
                                        ? TofilterEmails(_tocontroller.text)
                                        : null;

                                    if (_tocontroller.text.length == 0) {
                                      TofilteredEmails = [];
                                      messages = [];
                                    }
                                  });
                                },
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: const BorderSide(
                                    color: Color(0xFF006064), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: const BorderSide(
                                    color: Color(0xFF006064), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: const BorderSide(
                                    color: Color(0xFF006064), width: 1),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),

                        Flexible(
                            flex: 1,
                            child:

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                                 Text(
                                  "Group",
                                  style: TextStyle(color: Colors.black,fontSize: 14),
                                ),
                                toList!.length < 2
                                    ? Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Colors.blueAccent,
                                  value: false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      // first = value!;
                                    });
                                  },
                                )
                                    : Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Colors.blueAccent,
                                  value: true,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      // first = value!;
                                    });
                                  },
                                ),

// SizedBox(width: 20,),
//                             Icon(Icons.more_horiz,color: Colors.black,)
                          ],
                        )
                      )
                      ],
                    ),
                  ),
                ),

                body:
                Container(
                  decoration: new BoxDecoration(
                    color:  Colors.white),
                  child: ListView(
                    children: [

                      SizedBox(height: 10,),

                      Align(
                        alignment: Alignment.topLeft,
                        child:
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16,),
                          child: Wrap(
                            spacing: 1.0, // Spacing between chips
                            runSpacing: 3.0,
                            children: toList!.map((chip) {
                              return InputChip(


                                label: Text(
                                  chip.toString().split("@").first,
                                  style: TextStyle(fontSize: 14),
                                ),
                                materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,

                                onDeleted: () => _ToremoveChip(chip.toString()),
                                deleteIcon: Container(
                                    height: 15,
                                    width: 15,
                                    decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(30)),
                                    child: Center(
                                        child: Icon(
                                          Icons.clear,
                                          color: Colors.black,
                                          size: 10,
                                        ))),
                                deleteIconColor: Colors.black,
                                // You can add more styling to the chips here
                              );
                            }).toList(),
                          ),
                        ),

                      ),
                      _tocontroller.text.length != 0
                          ?
                      TofilteredEmails!.length == 0
                          ? GestureDetector(
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Icon(
                                Icons.account_circle_outlined,
                                color: Colors.white,
                              ),
                              radius: 16.0,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add contact",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _tocontroller.text,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          if (_tocontroller.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Contact is required",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                timeInSecForIosWeb: 10);
                          }

                         if( _tocontroller.text.length != 10){
                           toastification.show(
                               context: context, // optional if you use ToastificationWrapper

                               autoCloseDuration: const Duration(seconds: 5),
                               title: 'Invalid Contact Number!',
                               backgroundColor: Colors.red



                           );

                         }else {
                           toList.add(_tocontroller.text);
                           setState(() {
                             toList = toList.toSet().toList();
                             messages = [];
                             TofilteredEmails = [];
                             _tocontroller.clear();
                           });
                         }
                        },
                      ): Container(): Container(),
SizedBox(height: 10,),
                      TofilteredEmails!.length != 0
                          ?  Container(

                        child: StaggeredGridView.countBuilder(
                          controller: ScrollController(keepScrollOffset: false),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          crossAxisCount: 1,
                          staggeredTileBuilder: (int index) =>
                              StaggeredTile.fit(4),
                          itemCount: TofilteredEmails!.length,
                          scrollDirection: Axis.vertical,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          itemBuilder: (BuildContext context, int index) {
                            dynamic test = TofilteredEmails![index].date!.toLocal();
                            var s = TofilteredEmails![index].group;
                            return TofilteredEmails![index].group==false?

                            GestureDetector(
                              onTap: () {

                                setState(() {
                                  messages = [];
                                  toList.add(
                                      TofilteredEmails![index]
                                          .contact
                                          .toString()
                                          .replaceAll("(", "")
                                          .replaceAll(")", "")
                                          .replaceAll("-", "")
                                          .replaceAll(
                                          " ", ""));

                                });
                                var duplicateElement =
                                toList
                                    .where((item) =>
                                toList
                                    .indexOf(
                                    item) !=
                                    toList
                                        .lastIndexOf(
                                        item))
                                    .toList();

                                setState(() {
                                  if (duplicateElement
                                      .length >
                                      0) {
                                    toList.remove(
                                        duplicateElement[0]);
                                    print(
                                        "Same Number Repeated " +
                                            duplicateElement[
                                            0]);
                                  }
                                });

                                var sortedNumbersFalse = [...toList]
                                  ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
                                var combinedNumbers = sortedNumbersFalse.join('');
                                var phoneNumDigits =
                                userDetails.data!.primaryNumber!.replaceAll(RegExp(r'\D'), '');
                                var finalroom = phoneNumDigits + combinedNumbers;


                                getRoomUserMessages(finalroom);
                                setState(() {
                                  _searchController.clear();
                                  TofilteredEmails!.clear();
                                  _tocontroller.clear();
                                });




                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[

                                          TofilteredEmails![index].image != ""
                                              ? CachedNetworkImage(
                                            fit: BoxFit.contain,
                                            height: 24,width: 24,
                                            imageUrl: TofilteredEmails![index].image!=""
                                                ? localurlLogin +TofilteredEmails![index].image!
                                                : 'https://appprivacy.messaging.care/media/blank.png',
                                            placeholder: (context, url) =>
                                                CircleAvatar(
                                                  backgroundColor: Colors.orange,
                                                  minRadius: 20.0,
                                                  maxRadius: 20.0,
                                                ),
                                            imageBuilder: (context, image) =>
                                                CircleAvatar(
                                                  backgroundColor:
                                                  Colors.transparent,
                                                  backgroundImage: image,
                                                  minRadius: 20.0,
                                                  maxRadius: 20.0,
                                                ),
                                          )
                                              :   Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              (TofilteredEmails![index].firstName==null || TofilteredEmails![index].firstName=="")
                                                  ? Container(
                                                height: 24,
                                                width: 24,
                                                child: ClipRRect(
                                                  borderRadius:BorderRadius.circular(60),
                                                  child: Image.network("https://appprivacy.messaging.care/media/blank.png"    ,height: 24,
                                                    width: 24,
                                                    fit: BoxFit.cover,),
                                                ),
                                              ):
                                              Container(
                                                height: 24,
                                                width: 24,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(30),
                                                    color: TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="A"?
                                                    Color(0xFFFF0000):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="B"?
                                                    Color(0xFF2b2b40):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="D"?
                                                    Color(0xFF50cd89):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="E"?
                                                    Color(0xFFe033c3):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="F"?
                                                    Color(0xFF00FFFF):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="G"?
                                                    Color(0xFF800000):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="H"?
                                                    Color(0xFF008000):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="I"?
                                                    Color(0xFF000080):
                                                    TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="J"?
                                                    Color(0xFF808000):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="K"?
                                                    Color(0xFF800080):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="L"?
                                                    Color(0xFF008080):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="M"?
                                                    Color(0xFFa24c7d):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="N"?
                                                    Color(0xFF613f3f):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="O"?
                                                    Color(0xFFFFA500):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="P"?
                                                    Color(0xFFb96969):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="Q"?
                                                    Color(0xFF7e00e3):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="R"?
                                                    Color(0xFFf1416c):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="S"?
                                                    Color(0xFFff4a00):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="T"?
                                                    Color(0xFF87CEEB):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="U"?
                                                    Color(0xFF9370DB):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="V"?
                                                    Color(0xFFFF1493):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="W"?
                                                    Color(0xFF48D1CC):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="X"?
                                                    Color(0xFF20B2AA):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="Y"?
                                                    Color(0xFFB0E0E6):TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()=="Z"?
                                                    Color(0xFFdf8fdf):Color(0xFF0072ff)
                                                ),
                                                child: Center(child: Text(TofilteredEmails![index].firstName.toString().substring(0,1).toUpperCase()+""+
                                                    TofilteredEmails![index].lastName.toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                                  style: TextStyle(color: Colors.white,fontSize: 10,fontWeight: FontWeight.bold),
                                                ),


                                                ),


                                              ),

                                            ],
                                          ),



                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Container(
                                              color: Colors.transparent,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  TofilteredEmails![index].firstName== ""
                                                      ? Padding(
                                                    padding: const EdgeInsets.only(top: 10),
                                                    child: Container(
                                                      width: 200,

                                                      child: Text(
                                                        TofilteredEmails![index].contact!.toString().replaceAll("]", "").replaceAll("[", "").replaceAll("-", ""),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.black,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                    ),
                                                  )
                                                      : TofilteredEmails![index].firstName==null
                                                      ? Padding(
                                                    padding: const EdgeInsets.only(top: 6),
                                                    child: Container(
                                                      width: 200,

                                                      child: Text(
                                                        TofilteredEmails![index].contact!.toString().replaceAll("]", "").replaceAll("[", "").replaceAll("-", ""),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.black,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                    ),
                                                  ):
                                                  Container(
                                                    width: 200,
                                                    child: Text(
                                                      TofilteredEmails![index].firstName! + ' ' + TofilteredEmails![index].lastName!,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.black,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                  ),



                                                  (TofilteredEmails![index].firstName== "" || TofilteredEmails![index].firstName== null)
                                                      ?
                                                  Container() : SizedBox(height: 6,),
                                                  (TofilteredEmails![index].firstName== "" || TofilteredEmails![index].firstName== null)
                                                      ?Text(" ")
                                                      :
                                                  Container(
                                                    width: 200,
                                                    child: Text(
                                                      TofilteredEmails![index].contact!.toString().replaceAll("]", "").replaceAll("[", ""),
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.black54,
                                                          fontWeight:
                                                          FontWeight.w400),
                                                    ),
                                                  )

                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ):Container();
                          },
                        ),
                      )

                          : Container(),

                      messages!=null?
                      messages!.length!=0?
                      Row(
                        children: [
                          Expanded(

                            child:

                            ListView.builder(
                                itemCount: messages!.length,
                                shrinkWrap: true,
                                controller: _scrollController,
                                itemBuilder: (_, index) {





                                  bool isSameDate = true;
                                  var date =
                                  DateTime.parse(messages![index]['created_at']);
                                  var formattedDate =
                                  DateFormat('h:mm a').format(date);
                                  final String dateString = messages![index]['created_at'];
                                  final DateTime date1 = DateTime.parse(dateString);
                                  final item = messages![index];
                                  if (index == 0) {
                                    isSameDate = false;
                                  } else {
                                    final String prevDateString = messages![index - 1]['created_at'];
                                    final DateTime prevDate = DateTime.parse(prevDateString);
                                    isSameDate = date1.isSameDate(prevDate);
                                  }
                                  if (index == 0 || !(isSameDate)) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width /5,
                                      child: Column(children: [
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),
                                                      color: Colors.blueAccent

                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                                    child: Center(child: Text(date1.formatDate(),style: TextStyle(color: Colors.white,fontSize: 12),)),
                                                  )),
                                            ],
                                          ),
                                        ),

                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(

                                          margin:
                                          EdgeInsets.only(right: 10, left: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                            messages![index]['sender'] != null
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [



                                              messages![index]['sender'] == null
                                                  ?
                                              messages![index]
                                              ['contact']
                                                  .isNotEmpty &&
                                                  messages![index]['contact']
                                                  ['image'] !=
                                                      null
                                                  ? CachedNetworkImage(
                                                height: 20,width: 20,
                                                fit: BoxFit.contain,
                                                imageUrl: localurlLogin +
                                                    messages![index]
                                                    ['contact']['image'],
                                                placeholder: (context, url) =>
                                                    CircleAvatar(
                                                      backgroundColor: Colors.orange,
                                                      minRadius: 16.0,
                                                      maxRadius: 16.0,
                                                    ),
                                                imageBuilder: (context, image) =>
                                                    CircleAvatar(
                                                      backgroundColor:
                                                      Colors.transparent,
                                                      backgroundImage: image,
                                                      minRadius: 16.0,
                                                      maxRadius: 16.0,
                                                    ),
                                              )
                                                  :   Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  messages![index]["contact"]["firstName"]==null
                                                      ? Container(
                                                    height: 20,
                                                    width: 20,
                                                    child: ClipRRect(
                                                      borderRadius:BorderRadius.circular(60),
                                                      child: Image.network("https://appprivacy.messaging.care/media/blank.png",height: 20,width: 20,
                                                        fit: BoxFit.cover,),
                                                    ),
                                                  ):
                                                  Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(30),
                                                        color: messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="A"?
                                                        Color(0xFFFF0000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="B"?
                                                        Color(0xFF2b2b40):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="D"?
                                                        Color(0xFF50cd89):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="E"?
                                                        Color(0xFFe033c3):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="F"?
                                                        Color(0xFF00FFFF):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="G"?
                                                        Color(0xFF800000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="H"?
                                                        Color(0xFF008000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="I"?
                                                        Color(0xFF000080):
                                                        messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="J"?
                                                        Color(0xFF808000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="K"?
                                                        Color(0xFF800080):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="L"?
                                                        Color(0xFF008080):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="M"?
                                                        Color(0xFFa24c7d):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="N"?
                                                        Color(0xFF613f3f):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="O"?
                                                        Color(0xFFFFA500):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="P"?
                                                        Color(0xFFb96969):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Q"?
                                                        Color(0xFF7e00e3):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="R"?
                                                        Color(0xFFf1416c):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="S"?
                                                        Color(0xFFff4a00):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="T"?
                                                        Color(0xFF87CEEB):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="U"?
                                                        Color(0xFF9370DB):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="V"?
                                                        Color(0xFFFF1493):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="W"?
                                                        Color(0xFF48D1CC):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="X"?
                                                        Color(0xFF20B2AA):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Y"?
                                                        Color(0xFFB0E0E6):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Z"?
                                                        Color(0xFFdf8fdf):Color(0xFF0072ff)
                                                    ),
                                                    child: Center(child: Text(messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()+""+
                                                        messages![index]["contact"]["lastName"].toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                                      style: TextStyle(color: Colors.white,fontSize: 10,fontWeight: FontWeight.bold),
                                                    ),


                                                    ),


                                                  ),

                                                ],
                                              ):Container(),

                                              SizedBox(
                                                width: 4,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                messages![index]['sender'] == null
                                                    ?
                                                CrossAxisAlignment.start:CrossAxisAlignment.end,
                                                children: [

                                                  messages![index]['sender'] == null
                                                      ?
                                                  Row(
                                                    children: [
                                                      messages![index]["contact"]["firstName"]!=null?
                                                      Text(messages![index]["contact"]["firstName"]+" "+messages![index]["contact"]["lastName"],

                                                        style: TextStyle(color: Colors.black45,fontWeight:FontWeight.bold,fontSize: 10),

                                                      ):
                                                      Container(),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      messages![index]["contact"]["primaryNumber"]!=null?
                                                      Text(messages![index]["contact"]["primaryNumber"],

                                                        style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 8),

                                                      ):Text(messages![index]["contact"]["contactPhone"].toString(),

                                                        style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 8),

                                                      ),
                                                    ],
                                                  ):
                                                  Row(
                                                    children: [
                                                      messages![index]["sender"]["firstName"]!=null?
                                                      Text(messages![index]["sender"]["firstName"]+" "+messages![index]["sender"]["lastName"],

                                                        style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 10),

                                                      ):
                                                      Container(),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      Text(messages![index]["sender"]["primaryNumber"],

                                                        style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 8),

                                                      ),
                                                    ],
                                                  ),

                                                  Container(
                                                    width: MediaQuery.of(context).size.width /5,
                                                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 6),
                                                    constraints: BoxConstraints(
                                                        minWidth: 20,
                                                        maxWidth:
                                                        MediaQuery.of(context).size.width *
                                                            0.6),
                                                    decoration: BoxDecoration(
                                                        color:
                                                        messages![index]['sender'] != null
                                                            ? Colors.white
                                                            : Colors.grey.shade300,
                                                        borderRadius: BorderRadius.only(
                                                          bottomLeft: Radius.circular(
                                                              messages![index]['sender'] == null
                                                                  ? 0
                                                                  : 12),
                                                          topLeft: Radius.circular(16),

                                                          bottomRight: Radius.circular(
                                                              messages![index]['sender'] == null
                                                                  ? 12
                                                                  : 0),
                                                          topRight: Radius.circular(12),
                                                        )),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [

                                                        Text(
                                                          utf8convert( messages![index]['text'])
                                                          ,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.w400,fontFamily: 'NotoEmoji',
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4,),
                                                        messages![index]['file']!=null?

                                                        Image.network( localurlLogin+ messages![index]['file']):
                                                        Container(),
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              formattedDate,
                                                              style: const TextStyle(
                                                                color: Colors.black54,
                                                                fontSize: 8,
                                                              ),
                                                            ),
                                                            messages![index]['sender'] != null
                                                                ?
                                                            messages![index]["content_type"].toString() != "delivered"?
                                                            Image.asset("assets/tick.png",height: 14,fit: BoxFit.contain,):
                                                            Image.asset("assets/dtick.png",height: 14,fit: BoxFit.contain,):Container(),
                                                            // Text(messages![index]["content_type"].toString()),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(
                                                width: 4,
                                              ),
                                              messages![index]['sender'] != null
                                                  ? CircleAvatar(
                                                backgroundImage: messages![index]
                                                ['sender']
                                                    .isNotEmpty &&
                                                    messages![index]['sender']
                                                    ['image'] !=
                                                        null
                                                    ? NetworkImage(
                                                  localurlLogin +
                                                      messages![index]['sender']
                                                      ['image'],

                                                )
                                                    : NetworkImage(localurlLogin +
                                                    userDetails
                                                        .data!.company!.image
                                                        .toString())
                                                as ImageProvider,
                                                backgroundColor: Colors.transparent,
                                                maxRadius: 12,
                                              )
                                                  : Container(),

                                            ],
                                          ),
                                        )
                                      ]),
                                    );
                                  } else {
                                    return   Container(

                                      margin:
                                      EdgeInsets.only(top: 10, right: 10, left: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                        messages![index]['sender'] != null
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          messages![index]['sender'] == null
                                              ?
                                          messages![index]
                                          ['contact']
                                              .isNotEmpty &&
                                              messages![index]['contact']
                                              ['image'] !=
                                                  null
                                              ? CachedNetworkImage(
                                            height: 20,width: 20,
                                            fit: BoxFit.contain,
                                            imageUrl: localurlLogin +
                                                messages![index]
                                                ['contact']['image'],
                                            placeholder: (context, url) =>
                                                CircleAvatar(
                                                  backgroundColor: Colors.orange,
                                                  minRadius: 16.0,
                                                  maxRadius: 16.0,
                                                ),
                                            imageBuilder: (context, image) =>
                                                CircleAvatar(
                                                  backgroundColor:
                                                  Colors.transparent,
                                                  backgroundImage: image,
                                                  minRadius: 16.0,
                                                  maxRadius: 16.0,
                                                ),
                                          )
                                              :   Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              messages![index]["contact"]["firstName"]==null
                                                  ? Container(
                                                height: 20,
                                                width: 20,
                                                child: ClipRRect(
                                                  borderRadius:BorderRadius.circular(60),
                                                  child: Image.network("https://appprivacy.messaging.care/media/blank.png",height: 20,width: 20,
                                                    fit: BoxFit.cover,),
                                                ),
                                              ):
                                              Container(
                                                height: 20,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(30),
                                                    color: messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="A"?
                                                    Color(0xFFFF0000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="B"?
                                                    Color(0xFF2b2b40):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="D"?
                                                    Color(0xFF50cd89):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="E"?
                                                    Color(0xFFe033c3):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="F"?
                                                    Color(0xFF00FFFF):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="G"?
                                                    Color(0xFF800000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="H"?
                                                    Color(0xFF008000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="I"?
                                                    Color(0xFF000080):
                                                    messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="J"?
                                                    Color(0xFF808000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="K"?
                                                    Color(0xFF800080):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="L"?
                                                    Color(0xFF008080):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="M"?
                                                    Color(0xFFa24c7d):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="N"?
                                                    Color(0xFF613f3f):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="O"?
                                                    Color(0xFFFFA500):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="P"?
                                                    Color(0xFFb96969):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Q"?
                                                    Color(0xFF7e00e3):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="R"?
                                                    Color(0xFFf1416c):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="S"?
                                                    Color(0xFFff4a00):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="T"?
                                                    Color(0xFF87CEEB):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="U"?
                                                    Color(0xFF9370DB):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="V"?
                                                    Color(0xFFFF1493):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="W"?
                                                    Color(0xFF48D1CC):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="X"?
                                                    Color(0xFF20B2AA):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Y"?
                                                    Color(0xFFB0E0E6):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Z"?
                                                    Color(0xFFdf8fdf):Color(0xFF0072ff)
                                                ),
                                                child: Center(child: Text(messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()+""+
                                                    messages![index]["contact"]["lastName"].toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                                  style: TextStyle(color: Colors.white,fontSize: 10,fontWeight: FontWeight.bold),
                                                ),


                                                ),


                                              ),

                                            ],
                                          ):Container(),







                                          SizedBox(
                                            width: 4,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width /5,
                                            child: Column(
                                              crossAxisAlignment:
                                              messages![index]['sender'] == null
                                                  ?
                                              CrossAxisAlignment.start:CrossAxisAlignment.end,
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                messages![index]['sender'] == null
                                                    ?
                                                Row(
                                                  children: [
                                                    messages![index]["contact"]["firstName"]!=null?
                                                    Text(messages![index]["contact"]["firstName"]+" "+messages![index]["contact"]["lastName"],

                                                      style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 10),

                                                    ):
                                                    Container(),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(messages![index]["contact"]["contactPhone"],

                                                      style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 8),

                                                    ),
                                                  ],
                                                ):
                                                Row(
                                                  children: [
                                                    messages![index]["sender"]["firstName"]!=null?
                                                    Text(messages![index]["sender"]["firstName"]+" "+messages![index]["sender"]["lastName"],

                                                      style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 10),

                                                    ):
                                                    Container(),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(

                                                      messages![index]["sender"]["primaryNumber"],

                                                      style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 8),

                                                    ),
                                                  ],
                                                ),

                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                  constraints: BoxConstraints(
                                                      minWidth: 20,
                                                      maxWidth:
                                                      MediaQuery.of(context).size.width *
                                                          0.6),
                                                  decoration: BoxDecoration(
                                                      color:
                                                      messages![index]['sender'] != null
                                                          ? Colors.white
                                                          : Colors.grey.shade300,
                                                      borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius.circular(
                                                            messages![index]['sender'] == null
                                                                ? 0
                                                                : 12),
                                                        topRight: Radius.circular(16),
                                                        bottomRight: Radius.circular(
                                                            messages![index]['sender'] == null
                                                                ? 12
                                                                : 0),
                                                        topLeft: Radius.circular(
                                                            12),
                                                      )),
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width /5,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [

                                                        Text(
                                                          utf8convert( messages![index]['text'])
                                                          ,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.w400,fontFamily: 'NotoEmoji',
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        SizedBox(height: 2,),
                                                        messages![index]['file']!=null?

                                                        Image.network( localurlLogin+ messages![index]['file'],
                                                          fit: BoxFit.contain,
                                                        ):
                                                        Container(),

                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              formattedDate,
                                                              style: const TextStyle(
                                                                color: Colors.black54,
                                                                fontSize: 9,
                                                              ),
                                                            ),
                                                            messages![index]['sender'] != null
                                                                ? messages![index]["content_type"].toString() != "delivered"?
                                                            Image.asset("assets/tick.png",height: 14,fit: BoxFit.contain,):
                                                            Image.asset("assets/dtick.png",height: 14,fit: BoxFit.contain,):Container(),



                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),


                                          SizedBox(
                                            width: 4,
                                          ),
                                          messages![index]['sender'] != null
                                              ? CircleAvatar(
                                            backgroundImage: messages![index]
                                            ['sender']
                                                .isNotEmpty &&
                                                messages![index]['sender']
                                                ['image'] !=
                                                    null
                                                ? NetworkImage(
                                              localurlLogin +
                                                  messages![index]['sender']
                                                  ['image'],
                                            )
                                                :NetworkImage(localurlLogin +
                                                userDetails
                                                    .data!.company!.image
                                                    .toString())
                                            as ImageProvider,
                                            backgroundColor: Colors.transparent,
                                            maxRadius: 12,
                                          )
                                              : Container(),

                                        ],
                                      ),
                                    );
                                  }
                                }),
                          ),
                        ],
                      ):Container():Container(),









                    ],
                  ),
                ),
                bottomNavigationBar:
                Container(
                  height: 50,color:   Colors.white,
                  child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width /2,

                        child: Card(
                          elevation: 2,
                          margin: EdgeInsets.only(
                              left: 16, right: 16, bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextFormField(
                            controller: msgcontroller,
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            minLines: 1,
                            onChanged: (value) {
                              if (value.length > 0) {
                                setState(() {
                                  sendButton = true;
                                });
                              } else {
                                setState(() {
                                  sendButton = false;
                                });
                              }

                            },

                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF006064), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF006064), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF006064), width: 1),
                                ),
                                hintText: "Type a message",
                                hintStyle: TextStyle(color: Colors.grey,fontSize: 14),


                            ),
                          ),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: (){
                        SystemChannels.textInput
                            .invokeMethod('TextInput.hide');
                        if (msgcontroller.text.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                              content: Text(
                                  'Message is Required'),
                              backgroundColor:
                              Colors.orange));
                          return;
                        }
                        sendWebSocketMessage1(
                            msgcontroller.text);
                      },
                      child: Padding(
                        padding:  EdgeInsets.only(
                            right: 16, bottom: 8),
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.blueAccent,
                            ),
                            child: Center(child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Icon(Icons.send,color: Colors.white,size: 20,),
                            ))),
                      ),
                    ),


                  ],
                ),
                )
              ),





          ),











          Container(width: 1,color: Colors.black26,),
          isshowmessage == false?
          room!=null?

          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child:    Padding(
              padding: const EdgeInsets.only(left: 10),
              child:
              messages!.length!=0?
              ListView(
                children: [

                  SizedBox(height: 10,),
                  messages![0]["allcontact"].length ==0?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Text("Profile Information",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                  ): Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Text("Members",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                  ),

                  SizedBox(height: 20,),
                  messages![0]["allcontact"].length ==0?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              (image != "" && image != null )
                                  ? CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: image!=""
                                    ? localurlLogin + image!
                                    : 'https://appprivacy.messaging.care/media/blank.png',
                                placeholder: (context, url) =>
                                    CircleAvatar(
                                      backgroundColor: Colors.orange,
                                      minRadius: 16.0,
                                      maxRadius: 16.0,
                                    ),
                                imageBuilder: (context, image) =>
                                    CircleAvatar(
                                      backgroundColor:
                                      Colors.transparent,
                                      backgroundImage: image,
                                      minRadius: 16.0,
                                      maxRadius: 16.0,
                                    ),
                              )
                                  :   Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ( firstName == "" || firstName == null)
                                      ? Container(
                                    height: 24,
                                    width: 24,
                                    child: ClipRRect(
                                      borderRadius:BorderRadius.circular(60),
                                      child: Image.network("https://appprivacy.messaging.care/media/blank.png"    ,height: 24,
                                        width: 24,
                                        fit: BoxFit.cover,),
                                    ),
                                  ):
                                  Container(
                                    height: 24,
                                    width: 24,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: firstName.toString().substring(0,1).toUpperCase()=="A"?
                                        Color(0xFFFF0000):firstName.toString().substring(0,1).toUpperCase()=="B"?
                                        Color(0xFF2b2b40):firstName.toString().substring(0,1).toUpperCase()=="D"?
                                        Color(0xFF50cd89):firstName.toString().substring(0,1).toUpperCase()=="E"?
                                        Color(0xFFe033c3):firstName.toString().substring(0,1).toUpperCase()=="F"?
                                        Color(0xFF00FFFF):firstName.toString().substring(0,1).toUpperCase()=="G"?
                                        Color(0xFF800000):firstName.toString().substring(0,1).toUpperCase()=="H"?
                                        Color(0xFF008000):firstName.toString().substring(0,1).toUpperCase()=="I"?
                                        Color(0xFF000080):
                                        firstName.toString().substring(0,1).toUpperCase()=="J"?
                                        Color(0xFF808000):firstName.toString().substring(0,1).toUpperCase()=="K"?
                                        Color(0xFF800080):firstName.toString().substring(0,1).toUpperCase()=="L"?
                                        Color(0xFF008080):firstName.toString().substring(0,1).toUpperCase()=="M"?
                                        Color(0xFFa24c7d):firstName.toString().substring(0,1).toUpperCase()=="N"?
                                        Color(0xFF613f3f):firstName.toString().substring(0,1).toUpperCase()=="O"?
                                        Color(0xFFFFA500):firstName.toString().substring(0,1).toUpperCase()=="P"?
                                        Color(0xFFb96969):firstName.toString().substring(0,1).toUpperCase()=="Q"?
                                        Color(0xFF7e00e3):firstName.toString().substring(0,1).toUpperCase()=="R"?
                                        Color(0xFFf1416c):firstName.toString().substring(0,1).toUpperCase()=="S"?
                                        Color(0xFFff4a00):firstName.toString().substring(0,1).toUpperCase()=="T"?
                                        Color(0xFF87CEEB):firstName.toString().substring(0,1).toUpperCase()=="U"?
                                        Color(0xFF9370DB):firstName.toString().substring(0,1).toUpperCase()=="V"?
                                        Color(0xFFFF1493):firstName.toString().substring(0,1).toUpperCase()=="W"?
                                        Color(0xFF48D1CC):firstName.toString().substring(0,1).toUpperCase()=="X"?
                                        Color(0xFF20B2AA):firstName.toString().substring(0,1).toUpperCase()=="Y"?
                                        Color(0xFFB0E0E6):firstName.toString().substring(0,1).toUpperCase()=="Z"?
                                        Color(0xFFdf8fdf):Color(0xFF0072ff)
                                    ),
                                    child: Center(child: Text(firstName.toString().substring(0,1).toUpperCase()+""+
                                        lastName.toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                      style: TextStyle(color: Colors.white,fontSize: 10),
                                    ),


                                    ),


                                  ),

                                ],
                              ),



                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  color: Colors.transparent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      (firstName==null || firstName== "")
                                          ? Container(
                                        width: 200,

                                        child: Text(
                                         contact!.toString().replaceAll("]", "").replaceAll("[", "").replaceAll("-", ""),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                      ):
                                      Container(
                                        width: 200,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              firstName! + ' ' + lastName!,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                  fontWeight:
                                                  FontWeight.bold),
                                            ),
                                            Text(
                                              contact.toString(),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black45,
                                                 ),
                                            ),
                                          ],
                                        ),
                                      ),



                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),




                              Container(
                                  height: 20,
                                  width: 20,
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                      onTap: () async {
                                        await showDialog<void>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(20.0))
                                              ),
                                              content: Stack(
                                                clipBehavior: Clip.none,
                                                children: <Widget>[
                                                  Positioned(
                                                    right: -40,
                                                    top: -40,
                                                    child: InkResponse(
                                                      onTap: () {
                                                     setState(() {
                                                       Navigator.of(context).pop();
                                                     });
                                                      },
                                                      child: const CircleAvatar(
                                                        backgroundColor: Colors.red,
                                                        child: Icon(Icons.close),
                                                      ),
                                                    ),
                                                  ),
                                                  Form(
                                                    key: _formKey,
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                    Text(
                                                    'Profile Details',
                                                      style: TextStyle(color: Colors.black,
                                                          fontWeight: FontWeight.bold,fontSize: 14)),
                                                        SizedBox(height: 20,),

                                                        ( firstName == "" || firstName == null)
                                                            ? Center(
                                                              child: Container(
                                                          height: 24,
                                                          width: 24,
                                                          child: ClipRRect(
                                                              borderRadius:BorderRadius.circular(60),
                                                              child: Image.network("https://appprivacy.messaging.care/media/blank.png"    ,height: 24,
                                                                width: 24,
                                                                fit: BoxFit.cover,),
                                                          ),
                                                        ),
                                                            ):
                                                        Center(
                                                          child: Container(
                                                            height: 44,
                                                            width: 44,
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(30),
                                                                color: firstName.toString().substring(0,1).toUpperCase()=="A"?
                                                                Color(0xFFFF0000):firstName.toString().substring(0,1).toUpperCase()=="B"?
                                                                Color(0xFF2b2b40):firstName.toString().substring(0,1).toUpperCase()=="D"?
                                                                Color(0xFF50cd89):firstName.toString().substring(0,1).toUpperCase()=="E"?
                                                                Color(0xFFe033c3):firstName.toString().substring(0,1).toUpperCase()=="F"?
                                                                Color(0xFF00FFFF):firstName.toString().substring(0,1).toUpperCase()=="G"?
                                                                Color(0xFF800000):firstName.toString().substring(0,1).toUpperCase()=="H"?
                                                                Color(0xFF008000):firstName.toString().substring(0,1).toUpperCase()=="I"?
                                                                Color(0xFF000080):
                                                                firstName.toString().substring(0,1).toUpperCase()=="J"?
                                                                Color(0xFF808000):firstName.toString().substring(0,1).toUpperCase()=="K"?
                                                                Color(0xFF800080):firstName.toString().substring(0,1).toUpperCase()=="L"?
                                                                Color(0xFF008080):firstName.toString().substring(0,1).toUpperCase()=="M"?
                                                                Color(0xFFa24c7d):firstName.toString().substring(0,1).toUpperCase()=="N"?
                                                                Color(0xFF613f3f):firstName.toString().substring(0,1).toUpperCase()=="O"?
                                                                Color(0xFFFFA500):firstName.toString().substring(0,1).toUpperCase()=="P"?
                                                                Color(0xFFb96969):firstName.toString().substring(0,1).toUpperCase()=="Q"?
                                                                Color(0xFF7e00e3):firstName.toString().substring(0,1).toUpperCase()=="R"?
                                                                Color(0xFFf1416c):firstName.toString().substring(0,1).toUpperCase()=="S"?
                                                                Color(0xFFff4a00):firstName.toString().substring(0,1).toUpperCase()=="T"?
                                                                Color(0xFF87CEEB):firstName.toString().substring(0,1).toUpperCase()=="U"?
                                                                Color(0xFF9370DB):firstName.toString().substring(0,1).toUpperCase()=="V"?
                                                                Color(0xFFFF1493):firstName.toString().substring(0,1).toUpperCase()=="W"?
                                                                Color(0xFF48D1CC):firstName.toString().substring(0,1).toUpperCase()=="X"?
                                                                Color(0xFF20B2AA):firstName.toString().substring(0,1).toUpperCase()=="Y"?
                                                                Color(0xFFB0E0E6):firstName.toString().substring(0,1).toUpperCase()=="Z"?
                                                                Color(0xFFdf8fdf):Color(0xFF0072ff)
                                                            ),
                                                            child: Center(child: Text(firstName.toString().substring(0,1).toUpperCase()+""+
                                                                lastName.toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                                              style: TextStyle(color: Colors.white,fontSize: 20),
                                                            ),


                                                            ),


                                                          ),
                                                        ),
                                                        SizedBox(height: 20,),
                                                        RichText(
                                                          text: TextSpan(
                                                              text: 'First Name',
                                                              style: TextStyle(color: Colors.black,
                                                                  fontWeight: FontWeight.bold),
                                                              children: [
                                                                TextSpan(
                                                                    text: ' *',
                                                                    style: TextStyle(
                                                                        color: Colors.red,
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 12))
                                                              ]),

                                                        ),
                                                        SizedBox(height: 2,),
                                                        TextFormField(
                                                          initialValue: firstName,
                                                          onChanged: (v) {
                                                            setState(() {
                                                              firstName = v;
                                                            });
                                                          },
                                                          decoration: InputDecoration(
                                                            contentPadding: const EdgeInsets.symmetric(horizontal: 6,vertical: 8),
                                                            isDense: true,
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                              borderSide: BorderSide(
                                                                color: FzColors.textBoxColor,
                                                              ),
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                              borderSide: BorderSide(
                                                                color: FzColors.textBoxColor,
                                                              ),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: FzColors.btnColor,

                                                              ),
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                            ),
                                                            fillColor: FzColors.textBoxColor,
                                                            hoverColor: FzColors.textBoxColor,
                                                            focusColor: FzColors.textBoxColor,
                                                            hintText: "First name",

                                                            hintStyle:  TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                          ),

                                                        ),
                                                        SizedBox(height: 8,),
                                                        RichText(
                                                          text: TextSpan(
                                                              text: 'Last Name',
                                                              style: TextStyle(color: Colors.black,
                                                                  fontWeight: FontWeight.bold),
                                                              children: [
                                                                TextSpan(
                                                                    text: ' *',
                                                                    style: TextStyle(
                                                                        color: Colors.red,
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 12))
                                                              ]),

                                                        ),
                                                        SizedBox(height: 2,),
                                                        TextFormField(
                                                          initialValue: lastName,
                                                          onChanged: (v) {
                                                            setState(() {
                                                              lastName = v;
                                                            });
                                                          },
                                                          decoration: InputDecoration(
                                                            contentPadding: const EdgeInsets.symmetric(horizontal: 6,vertical: 8),
                                                            isDense: true,
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                              borderSide: BorderSide(
                                                                color: FzColors.textBoxColor,
                                                              ),
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                              borderSide: BorderSide(
                                                                color: FzColors.textBoxColor,
                                                              ),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: FzColors.btnColor,

                                                              ),
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                            ),
                                                            fillColor: FzColors.textBoxColor,
                                                            hoverColor: FzColors.textBoxColor,
                                                            focusColor: FzColors.textBoxColor,
                                                            hintText: "First name",

                                                            hintStyle:  TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                          ),

                                                        ),
                                                        SizedBox(height: 8,),
                                                        RichText(
                                                          text: TextSpan(
                                                              text: 'Email',
                                                              style: TextStyle(color: Colors.black,
                                                                  fontWeight: FontWeight.bold),
                                                              children: [
                                                                TextSpan(
                                                                    text: ' ',
                                                                    style: TextStyle(
                                                                        color: Colors.red,
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 12))
                                                              ]),

                                                        ),
                                                        SizedBox(height: 2,),
                                                        TextFormField(
                                                          initialValue: email,
                                                          onChanged: (v) {
                                                            setState(() {
                                                              email = v;
                                                            });
                                                          },
                                                          decoration: InputDecoration(
                                                            contentPadding: const EdgeInsets.symmetric(horizontal: 6,vertical: 8),
                                                            isDense: true,
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                              borderSide: BorderSide(
                                                                color: FzColors.textBoxColor,
                                                              ),
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                              borderSide: BorderSide(
                                                                color: FzColors.textBoxColor,
                                                              ),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: FzColors.btnColor,

                                                              ),
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                            ),
                                                            fillColor: FzColors.textBoxColor,
                                                            hoverColor: FzColors.textBoxColor,
                                                            focusColor: FzColors.textBoxColor,
                                                            hintText: "First name",

                                                            hintStyle:  TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                          ),

                                                        ),
                                                        SizedBox(height: 8,),
                                                        RichText(
                                                          text: TextSpan(
                                                              text: 'Contact number',
                                                              style: TextStyle(color: Colors.black,
                                                                  fontWeight: FontWeight.bold),
                                                              children: [
                                                                TextSpan(
                                                                    text: ' *',
                                                                    style: TextStyle(
                                                                        color: Colors.red,
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 12))
                                                              ]),

                                                        ),
                                                        SizedBox(height: 2,),
                                                        TextFormField(
                                                          initialValue: contact,
                                                          onChanged: (v) {
                                                            setState(() {
                                                              contact = v;
                                                            });
                                                          },
                                                          decoration: InputDecoration(
                                                            contentPadding: const EdgeInsets.symmetric(horizontal: 6,vertical: 8),
                                                            isDense: true,
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                              borderSide: BorderSide(
                                                                color: FzColors.textBoxColor,
                                                              ),
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                              borderSide: BorderSide(
                                                                color: FzColors.textBoxColor,
                                                              ),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: FzColors.btnColor,

                                                              ),
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(4.0),
                                                              ),
                                                            ),
                                                            fillColor: FzColors.textBoxColor,
                                                            hoverColor: FzColors.textBoxColor,
                                                            focusColor: FzColors.textBoxColor,
                                                            hintText: "First name",

                                                            hintStyle:  TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                          ),

                                                        ),
                                                        // Padding(
                                                        //   padding: const EdgeInsets.all(8),
                                                        //   child: ElevatedButton(
                                                        //     child: const Text('Submit'),
                                                        //     onPressed: () {
                                                        //       if (_formKey.currentState!.validate()) {
                                                        //         _formKey.currentState!.save();
                                                        //       }
                                                        //     },
                                                        //   ),
                                                        // )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ));
                                      },
                                      child: Icon(Icons.edit,color: Colors.amber,size: 18,))
                              ),




                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),

                      ),

                    ],
                  ):


                  StaggeredGridView.countBuilder(
                      controller: ScrollController(keepScrollOffset: false),
                      shrinkWrap: true,
                      crossAxisCount: 1,
                      staggeredTileBuilder: (int index) => StaggeredTile.fit(4),
                      itemCount:  messages![0]["allcontact"].length,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      scrollDirection: Axis.vertical,

                      itemBuilder: (BuildContext context, int index) {

                        return

                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[

                                      (messages![0]["allcontact"][index]["image"] !=
                                          "" &&
                                          messages![0]["allcontact"][index]["image"] !=
                                              null)
                                          ? CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: messages![0]["allcontact"][index]["image"] !=
                                            ""
                                            ? localurlLogin +
                                            messages![0]["allcontact"][index]["image"]!
                                            : 'https://appprivacy.messaging.care/media/blank.png',
                                        placeholder: (context, url) =>
                                            CircleAvatar(
                                              backgroundColor: Colors.orange,
                                              minRadius: 16.0,
                                              maxRadius: 16.0,
                                            ),
                                        imageBuilder: (context, image) =>
                                            CircleAvatar(
                                              backgroundColor:
                                              Colors.transparent,
                                              backgroundImage: image,
                                              minRadius: 12.0,
                                              maxRadius: 12.0,
                                            ),
                                      )
                                          : Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          (messages![0]["allcontact"][index]["firstName"] ==
                                              "" ||
                                              messages![0]["allcontact"][index]["firstName"] ==
                                                  null)
                                              ? Container(
                                            height: 24,
                                            width: 24,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(
                                                  60),
                                              child: Image.network(
                                                "https://appprivacy.messaging.care/media/blank.png",
                                                height: 24,
                                                width: 24,
                                                fit: BoxFit.cover,),
                                            ),
                                          ) :
                                          Container(
                                            height: 24,
                                            width: 24,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius
                                                    .circular(30),
                                                color: messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "A"
                                                    ?
                                                Color(0xFFFF0000)
                                                    :messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "B"
                                                    ?
                                                Color(0xFF2b2b40)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "D"
                                                    ?
                                                Color(0xFF50cd89)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "E"
                                                    ?
                                                Color(0xFFe033c3)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "F"
                                                    ?
                                                Color(0xFF00FFFF)
                                                    :messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "G"
                                                    ?
                                                Color(0xFF800000)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "H"
                                                    ?
                                                Color(0xFF008000)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "I" ?
                                                Color(0xFF000080) :
                                                messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "J"
                                                    ?
                                                Color(0xFF808000)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "K"
                                                    ?
                                                Color(0xFF800080)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "L"
                                                    ?
                                                Color(0xFF008080)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "M"
                                                    ?
                                                Color(0xFFa24c7d)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "N"
                                                    ?
                                                Color(0xFF613f3f)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "O"
                                                    ?
                                                Color(0xFFFFA500)
                                                    :messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "P"
                                                    ?
                                                Color(0xFFb96969)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "Q"
                                                    ?
                                                Color(0xFF7e00e3)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "R"
                                                    ?
                                                Color(0xFFf1416c)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "S"
                                                    ?
                                                Color(0xFFff4a00)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "T"
                                                    ?
                                                Color(0xFF87CEEB)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "U"
                                                    ?
                                                Color(0xFF9370DB)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "V"
                                                    ?
                                                Color(0xFFFF1493)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "W"
                                                    ?
                                                Color(0xFF48D1CC)
                                                    :messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "X"
                                                    ?
                                                Color(0xFF20B2AA)
                                                    : messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "Y"
                                                    ?
                                                Color(0xFFB0E0E6)
                                                    :messages![0]["allcontact"][index]["firstName"]
                                                    .toString().substring(0, 1)
                                                    .toUpperCase() == "Z" ?
                                                Color(0xFFdf8fdf) : Color(
                                                    0xFF0072ff)
                                            ),
                                            child: Center(child: Text(
                                              messages![0]["allcontact"][index]["firstName"]
                                                  .toString().substring(0, 1)
                                                  .toUpperCase() + "" +
                                                  messages![0]["allcontact"][index]["firstName"]
                                                      .toString().replaceAll(
                                                      "(", "").replaceAll(")", "")
                                                      .substring(0, 1)
                                                      .toUpperCase(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10),
                                            ),


                                            ),


                                          ),

                                        ],
                                      ),


                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .start,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: <Widget>[
                                              (messages![0]["allcontact"][index]["firstName"] ==
                                                  null ||
                                                  messages![0]["allcontact"][index]["firstName"] ==
                                                      "")
                                                  ? Container(
                                                width: 200,

                                                child: Text(
                                                  messages![0]["allcontact"][index]["contactPhone"]!
                                                      .toString().replaceAll(
                                                      "]", "")
                                                      .replaceAll("[", "")
                                                      .replaceAll("-", ""),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 3,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              ) :
                                              Container(
                                                width: 200,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      messages![0]["allcontact"][index]["firstName"]! +
                                                          ' ' +
                                                          messages![0]["allcontact"][index]["lastName"]!,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    Text( messages![0]["allcontact"][index]["contactPhone"],
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black45,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),


                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),

                                      Container(
                                          height: 20,
                                          width: 20,
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                              onTap: () async {
                                                await showDialog<void>(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(20.0))
                                                      ),
                                                      content: Stack(
                                                        clipBehavior: Clip.none,
                                                        children: <Widget>[
                                                          Positioned(
                                                            right: -40,
                                                            top: -40,
                                                            child: InkResponse(
                                                              onTap: () {
                                                                setState(() {
                                                                  Navigator.of(context).pop();
                                                                });
                                                              },
                                                              child: const CircleAvatar(
                                                                backgroundColor: Colors.red,
                                                                child: Icon(Icons.close),
                                                              ),
                                                            ),
                                                          ),
                                                          Form(
                                                            key: _formKey,
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Text(
                                                                    'Profile Details',
                                                                    style: TextStyle(color: Colors.black,
                                                                        fontWeight: FontWeight.bold,fontSize: 14)),
                                                                SizedBox(height: 20,),

                                                                ( messages![0]["allcontact"][index]["firstName"] == "" || messages![0]["allcontact"][index]["firstName"] == null)
                                                                    ? Center(
                                                                  child: Container(
                                                                    height: 44,
                                                                    width: 44,
                                                                    child: ClipRRect(
                                                                      borderRadius:BorderRadius.circular(60),
                                                                      child: Image.network("https://appprivacy.messaging.care/media/blank.png"    ,height: 44,
                                                                        width: 44,
                                                                        fit: BoxFit.cover,),
                                                                    ),
                                                                  ),
                                                                ):
                                                                Center(
                                                                  child: Container(
                                                                    height: 44,
                                                                    width: 44,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(30),
                                                                        color: messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="A"?
                                                                        Color(0xFFFF0000):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="B"?
                                                                        Color(0xFF2b2b40):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="D"?
                                                                        Color(0xFF50cd89):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="E"?
                                                                        Color(0xFFe033c3):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="F"?
                                                                        Color(0xFF00FFFF):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="G"?
                                                                        Color(0xFF800000):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="H"?
                                                                        Color(0xFF008000):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="I"?
                                                                        Color(0xFF000080):
                                                                        messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="J"?
                                                                        Color(0xFF808000):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="K"?
                                                                        Color(0xFF800080):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="L"?
                                                                        Color(0xFF008080):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="M"?
                                                                        Color(0xFFa24c7d):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="N"?
                                                                        Color(0xFF613f3f):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="O"?
                                                                        Color(0xFFFFA500):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="P"?
                                                                        Color(0xFFb96969):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="Q"?
                                                                        Color(0xFF7e00e3):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="R"?
                                                                        Color(0xFFf1416c):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="S"?
                                                                        Color(0xFFff4a00):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="T"?
                                                                        Color(0xFF87CEEB):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="U"?
                                                                        Color(0xFF9370DB):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="V"?
                                                                        Color(0xFFFF1493):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="W"?
                                                                        Color(0xFF48D1CC):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="X"?
                                                                        Color(0xFF20B2AA):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="Y"?
                                                                        Color(0xFFB0E0E6):messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()=="Z"?
                                                                        Color(0xFFdf8fdf):Color(0xFF0072ff)
                                                                    ),
                                                                    child: Center(child: Text(messages![0]["allcontact"][index]["firstName"].toString().substring(0,1).toUpperCase()+""+
                                                                        messages![0]["allcontact"][index]["lastName"].toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                                                      style: TextStyle(color: Colors.white,fontSize: 20),
                                                                    ),


                                                                    ),


                                                                  ),
                                                                ),
                                                                SizedBox(height: 20,),
                                                                RichText(
                                                                  text: TextSpan(
                                                                      text: 'First Name',
                                                                      style: TextStyle(color: Colors.black,
                                                                          fontWeight: FontWeight.bold),
                                                                      children: [
                                                                        TextSpan(
                                                                            text: ' *',
                                                                            style: TextStyle(
                                                                                color: Colors.red,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 12))
                                                                      ]),

                                                                ),
                                                                SizedBox(height: 2,),
                                                                TextFormField(
                                                                  initialValue: messages![0]["allcontact"][index]["firstName"]!=""?messages![0]["allcontact"][index]["firstName"]:"",
                                                                  onChanged: (v) {
                                                                    setState(() {
                                                                     // firstName = v;
                                                                    });
                                                                  },
                                                                  decoration: InputDecoration(
                                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 6,vertical: 8),
                                                                    isDense: true,
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(4.0),
                                                                      ),
                                                                      borderSide: BorderSide(
                                                                        color: FzColors.textBoxColor,
                                                                      ),
                                                                    ),
                                                                    enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(4.0),
                                                                      ),
                                                                      borderSide: BorderSide(
                                                                        color: FzColors.textBoxColor,
                                                                      ),
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                        color: FzColors.btnColor,

                                                                      ),
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(4.0),
                                                                      ),
                                                                    ),
                                                                    fillColor: FzColors.textBoxColor,
                                                                    hoverColor: FzColors.textBoxColor,
                                                                    focusColor: FzColors.textBoxColor,
                                                                    hintText: "First name",

                                                                    hintStyle:  TextStyle(
                                                                      fontSize: 12,
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors.black,
                                                                  ),

                                                                ),
                                                                SizedBox(height: 8,),
                                                                RichText(
                                                                  text: TextSpan(
                                                                      text: 'Last Name',
                                                                      style: TextStyle(color: Colors.black,
                                                                          fontWeight: FontWeight.bold),
                                                                      children: [
                                                                        TextSpan(
                                                                            text: ' *',
                                                                            style: TextStyle(
                                                                                color: Colors.red,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 12))
                                                                      ]),

                                                                ),
                                                                SizedBox(height: 2,),
                                                                TextFormField(
                                                                  initialValue: messages![0]["allcontact"][index]["lastName"]!=""?messages![0]["allcontact"][index]["lastName"]:"",
                                                                  onChanged: (v) {
                                                                    setState(() {
                                                                      //lastName = v;
                                                                    });
                                                                  },
                                                                  decoration: InputDecoration(
                                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 6,vertical: 8),
                                                                    isDense: true,
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(4.0),
                                                                      ),
                                                                      borderSide: BorderSide(
                                                                        color: FzColors.textBoxColor,
                                                                      ),
                                                                    ),
                                                                    enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(4.0),
                                                                      ),
                                                                      borderSide: BorderSide(
                                                                        color: FzColors.textBoxColor,
                                                                      ),
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                        color: FzColors.btnColor,

                                                                      ),
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(4.0),
                                                                      ),
                                                                    ),
                                                                    fillColor: FzColors.textBoxColor,
                                                                    hoverColor: FzColors.textBoxColor,
                                                                    focusColor: FzColors.textBoxColor,
                                                                    hintText: "Last name",

                                                                    hintStyle:  TextStyle(
                                                                      fontSize: 12,
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors.black,
                                                                  ),

                                                                ),
                                                                SizedBox(height: 8,),
                                                                RichText(
                                                                  text: TextSpan(
                                                                      text: 'Email',
                                                                      style: TextStyle(color: Colors.black,
                                                                          fontWeight: FontWeight.bold),
                                                                      children: [
                                                                        TextSpan(
                                                                            text: ' ',
                                                                            style: TextStyle(
                                                                                color: Colors.red,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 12))
                                                                      ]),

                                                                ),
                                                                SizedBox(height: 2,),
                                                                TextFormField(
                                                                  initialValue: messages![0]["allcontact"][index]["email"]!=""?messages![0]["allcontact"][index]["email"]:"",
                                                                  onChanged: (v) {
                                                                    setState(() {
                                                                     // email = v;
                                                                    });
                                                                  },
                                                                  decoration: InputDecoration(
                                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 6,vertical: 8),
                                                                    isDense: true,
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(4.0),
                                                                      ),
                                                                      borderSide: BorderSide(
                                                                        color: FzColors.textBoxColor,
                                                                      ),
                                                                    ),
                                                                    enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(4.0),
                                                                      ),
                                                                      borderSide: BorderSide(
                                                                        color: FzColors.textBoxColor,
                                                                      ),
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                        color: FzColors.btnColor,

                                                                      ),
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(4.0),
                                                                      ),
                                                                    ),
                                                                    fillColor: FzColors.textBoxColor,
                                                                    hoverColor: FzColors.textBoxColor,
                                                                    focusColor: FzColors.textBoxColor,
                                                                    hintText: "email",

                                                                    hintStyle:  TextStyle(
                                                                      fontSize: 12,
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors.black,
                                                                  ),

                                                                ),
                                                                SizedBox(height: 8,),
                                                                RichText(
                                                                  text: TextSpan(
                                                                      text: 'Contact number',
                                                                      style: TextStyle(color: Colors.black,
                                                                          fontWeight: FontWeight.bold),
                                                                      children: [
                                                                        TextSpan(
                                                                            text: ' *',
                                                                            style: TextStyle(
                                                                                color: Colors.red,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 12))
                                                                      ]),

                                                                ),
                                                                SizedBox(height: 2,),
                                                                TextFormField(
                                                                  initialValue: messages![0]["allcontact"][index]["contactPhone"],
                                                                  onChanged: (v) {
                                                                    setState(() {
                                                                     // contact = v;
                                                                    });
                                                                  },
                                                                  decoration: InputDecoration(
                                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 6,vertical: 8),
                                                                    isDense: true,
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(4.0),
                                                                      ),
                                                                      borderSide: BorderSide(
                                                                        color: FzColors.textBoxColor,
                                                                      ),
                                                                    ),
                                                                    enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(4.0),
                                                                      ),
                                                                      borderSide: BorderSide(
                                                                        color: FzColors.textBoxColor,
                                                                      ),
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                        color: FzColors.btnColor,

                                                                      ),
                                                                      borderRadius: BorderRadius.all(
                                                                        Radius.circular(4.0),
                                                                      ),
                                                                    ),
                                                                    fillColor: FzColors.textBoxColor,
                                                                    hoverColor: FzColors.textBoxColor,
                                                                    focusColor: FzColors.textBoxColor,
                                                                    hintText: "",

                                                                    hintStyle:  TextStyle(
                                                                      fontSize: 12,
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors.black,
                                                                  ),

                                                                ),
                                                                // Padding(
                                                                //   padding: const EdgeInsets.all(8),
                                                                //   child: ElevatedButton(
                                                                //     child: const Text('Submit'),
                                                                //     onPressed: () {
                                                                //       if (_formKey.currentState!.validate()) {
                                                                //         _formKey.currentState!.save();
                                                                //       }
                                                                //     },
                                                                //   ),
                                                                // )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ));
                                              },
                                              child: Icon(Icons.edit,color: Colors.amber,size: 18,))
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          );
                      }),





                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Text("Change Wallpaper",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [

                      GestureDetector(
                        onTap: () async {



                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                          );

                          if (result != null) {
                            File file = File(result.files.single.path!);
                            savewallpaper(result.files.single.path!);
                          } else {
                            // User canceled the picker
                          }

                          // final ImagePicker picker = ImagePicker();
                          //
                          // final XFile? images =
                          // await picker.pickImage(
                          //     source: ImageSource.gallery);
                          // if (images != null) {
                          //   setState(() {
                          //     imageFile = File(images.path);
                          //     //savewallpaper(imageFile.path);
                          //   });
                          // }
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all()
                            ),
                            child: Center(child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                              child: Text("Select Image",style: TextStyle(color: Colors.black,fontSize: 13),),
                            ))),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Divider(),

                  originalItems.length!=0?
                  Text("Media Attachment",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),)
                  :Container(),
                  SizedBox(height: 10,),
                  originalItems!=null?
                  originalItems.length!=0?
                  StaggeredGridView.countBuilder(
                    controller: ScrollController(keepScrollOffset: false),
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    itemCount:originalItems.length,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    scrollDirection: Axis.vertical,

                    itemBuilder: (BuildContext context, int index) {

                      return
                           (originalItems[index]["url"]
                              .split('.')
                              .last
                              .toLowerCase() ==
                              'jpg' ||
                              originalItems[index]["url"]
                                  .split('.')
                                  .last
                                  .toLowerCase() ==
                                  'jfif' ||
                              originalItems[index]["url"]
                                  .split('.')
                                  .last
                                  .toLowerCase() ==
                                  'jpeg' ||
                              originalItems[index]["url"]
                                  .split('.')
                                  .last
                                  .toLowerCase() ==
                                  'png' ||
                              originalItems[index]["url"]
                                  .split('.')
                                  .last
                                  .toLowerCase() ==
                                  'gif' ||
                              originalItems[index]["url"]
                                  .split('.')
                                  .last
                                  .toLowerCase() ==
                                  'bmp')?
                            GestureDetector(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PhotoViewPage(
                                          photos: originalItems, index: index),
                                    ));
                              },
                              child: Container(
                                height:40,
                                color: Colors.black12,
                                child: CachedNetworkImage(
                                  imageUrl:localurlLogin +originalItems[index]["url"],
                                  height: 40,fit: BoxFit.fill,
                                  memCacheHeight: 40, //add this line

                                ),
                              ),
                            ):

                      (originalItems[index]["url"]
                         .split('.')
                         .last
                         .toLowerCase() ==
                         'pdf')?
                       Container(
                         height:40,
                         color: Colors.black12,
                         child: Icon(
                           Icons.picture_as_pdf_outlined,
                           color: Colors.red,

                         ),
                       )
                          :
                       (originalItems[index]["url"]
                         .split('.')
                         .last
                         .toLowerCase() ==
                         'csv' ||
                         originalItems[index]["url"]
                             .split('.')
                             .last
                             .toLowerCase() ==
                             'doc' ||
                         originalItems[index]["url"]
                             .split('.')
                             .last
                             .toLowerCase() ==
                             'docx' ||
                         originalItems[index]["url"]
                             .split('.')
                             .last
                             .toLowerCase() ==
                             'txt' ||
                         originalItems[index]["url"]
                             .split('.')
                             .last
                             .toLowerCase() ==
                             'xls' ||
                         originalItems[index]["url"]
                             .split('.')
                             .last
                             .toLowerCase() ==
                             'xlsx' ||
                         originalItems[index]["url"]
                             .split('.')
                             .last
                             .toLowerCase() ==
                             'mp4' ||
                         originalItems[index]["url"]
                             .split('.')
                             .last
                             .toLowerCase() ==
                             'mp3' ||
                         originalItems[index]["url"]
                             .split('.')
                             .last
                             .toLowerCase() ==
                             'zip' ||
                         originalItems[index]["url"]
                             .split('.')
                             .last
                             .toLowerCase() ==
                             'rar' ||
                         originalItems[index]["url"]
                             .split('.')
                             .last
                             .toLowerCase() ==
                             'mov')?

                       Container(
                         height:40,
                         color: Colors.black12,
                         child: Icon(
                           Icons.file_present_outlined,
                           color: Colors.red,

                         ),
                       ):Container(height: 40,)
                      ;

                           // (originalItems[index]["url"]
                           //    .split('.')
                           //    .last
                           //    .toLowerCase() ==
                           //    'pdf')?
                           //  Container(
                           //    height:40,
                           //    color: Colors.black12,
                           //    child: Icon(
                           //      Icons.picture_as_pdf_outlined,
                           //      color: Colors.red,
                           //
                           //    ),
                           //  ):
                      //  (originalItems[index]["url"]
                           //    .split('.')
                           //    .last
                           //    .toLowerCase() ==
                           //    'csv' ||
                           //    originalItems[index]["url"]
                           //        .split('.')
                           //        .last
                           //        .toLowerCase() ==
                           //        'doc' ||
                           //    originalItems[index]["url"]
                           //        .split('.')
                           //        .last
                           //        .toLowerCase() ==
                           //        'docx' ||
                           //    originalItems[index]["url"]
                           //        .split('.')
                           //        .last
                           //        .toLowerCase() ==
                           //        'txt' ||
                           //    originalItems[index]["url"]
                           //        .split('.')
                           //        .last
                           //        .toLowerCase() ==
                           //        'xls' ||
                           //    originalItems[index]["url"]
                           //        .split('.')
                           //        .last
                           //        .toLowerCase() ==
                           //        'xlsx' ||
                           //    originalItems[index]["url"]
                           //        .split('.')
                           //        .last
                           //        .toLowerCase() ==
                           //        'mp4' ||
                           //    originalItems[index]["url"]
                           //        .split('.')
                           //        .last
                           //        .toLowerCase() ==
                           //        'mp3' ||
                           //    originalItems[index]["url"]
                           //        .split('.')
                           //        .last
                           //        .toLowerCase() ==
                           //        'zip' ||
                           //    originalItems[index]["url"]
                           //        .split('.')
                           //        .last
                           //        .toLowerCase() ==
                           //        'rar' ||
                           //    originalItems[index]["url"]
                           //        .split('.')
                           //        .last
                           //        .toLowerCase() ==
                           //        'mov')?
                           //  Container(
                           //    height:40,
                           //    color: Colors.black12,
                           //    child: Icon(
                           //      Icons.file_present_outlined,
                           //      color: Colors.red,
                           //
                           //    ),
                           //  ):Container(),




                    },
                  ):Container():Container(),
                  originalItems.length!=0?
                  Divider():Container(),

                ],
              ):Container(),
            ),
          ):Container():



          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Container(),
          ),

        ],
      ) : Container(
        width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.grey.shade50,
            child: Center(
              child: Image.network(
                  "https://cdn.dribbble.com/users/2973561/screenshots/5757826/loading__.gif",
                  height: 350,
                  width: 350,
                  fit: BoxFit.contain,
                ),
            ),
          ),
    );
  }


  buildchats(){
    return  room!=null?
    Container(
      color: Colors.white,
      child: Stack(
        children: [


          imageFile == null
              ? wallpapers==null?
          Container(

            decoration: new BoxDecoration(
              color: Colors.white,

            ),
          )

                :Container(
            child: Image.file(File(wallpapers),
              fit: BoxFit.cover,height: MediaQuery.of(context).size.height,

              width: MediaQuery.of(context).size.width,
            ),
          )
              : Image.file(File(imageFile!.path),
            fit: BoxFit.cover,height: MediaQuery.of(context).size.height,

            width: MediaQuery.of(context).size.width,),



          Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.transparent,

            appBar:AppBar(
              titleSpacing: 10,elevation: 0.6,
             backgroundColor: Colors.white,
automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [


                 image != ""
                      ? CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: image!=""
                        ? localurlLogin +image!
                        : 'https://appprivacy.messaging.care/media/blank.png',
                    placeholder: (context, url) =>
                        CircleAvatar(
                          backgroundColor: Colors.orange,
                          minRadius: 16.0,
                          maxRadius: 16.0,
                        ),
                    imageBuilder: (context, image) =>
                        CircleAvatar(
                          backgroundColor:
                          Colors.transparent,
                          backgroundImage: image,
                          minRadius: 16.0,
                          maxRadius: 16.0,
                        ),
                  )
                      :   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     image !=
                          ""
                          ? CachedNetworkImage(
                       height: 24,width: 24,
                        fit: BoxFit
                            .cover,
                        imageUrl: image !=
                            ""
                            ? localurlLogin +
                            image!
                            : 'https://appprivacy.messaging.care/media/blank.png',
                        placeholder: (context,
                            url) =>
                            CircleAvatar(
                              backgroundColor:
                              Colors
                                  .orange,
                              minRadius:
                              16.0,
                              maxRadius:
                              16.0,
                            ),
                        imageBuilder: (context,
                            image) =>
                            CircleAvatar(
                              backgroundColor:
                              Colors
                                  .transparent,
                              backgroundImage:
                              image,
                              minRadius:
                              16.0,
                              maxRadius:
                              16.0,
                            ),
                      )
                          : Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          firstName ==
                              ""
                              ? Container(
                            height:
                            24,
                            width:
                            24,
                            child:
                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(60),
                              child:
                              Image.network(
                                "https://appprivacy.messaging.care/media/blank.png",
                                height: 24,
                                width: 24,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                              : Container(
                            height:
                            24,
                            width:
                            24,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: firstName.toString().substring(0, 1).toUpperCase() == "A"
                                    ? Color(0xFFFF0000)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "B"
                                    ? Color(0xFF2b2b40)
                                    :firstName.toString().substring(0, 1).toUpperCase() == "D"
                                    ? Color(0xFF50cd89)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "E"
                                    ? Color(0xFFe033c3)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "F"
                                    ? Color(0xFF00FFFF)
                                    :firstName.toString().substring(0, 1).toUpperCase() == "G"
                                    ? Color(0xFF800000)
                                    :firstName.toString().substring(0, 1).toUpperCase() == "H"
                                    ? Color(0xFF008000)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "I"
                                    ? Color(0xFF000080)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "J"
                                    ? Color(0xFF808000)
                                    :firstName.toString().substring(0, 1).toUpperCase() == "K"
                                    ? Color(0xFF800080)
                                    :firstName.toString().substring(0, 1).toUpperCase() == "L"
                                    ? Color(0xFF008080)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "M"
                                    ? Color(0xFFa24c7d)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "N"
                                    ? Color(0xFF613f3f)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "O"
                                    ? Color(0xFFFFA500)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "P"
                                    ? Color(0xFFb96969)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "Q"
                                    ? Color(0xFF7e00e3)
                                    :firstName.toString().substring(0, 1).toUpperCase() == "R"
                                    ? Color(0xFFf1416c)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "S"
                                    ? Color(0xFFff4a00)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "T"
                                    ? Color(0xFF87CEEB)
                                    :firstName.toString().substring(0, 1).toUpperCase() == "U"
                                    ? Color(0xFF9370DB)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "V"
                                    ? Color(0xFFFF1493)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "W"
                                    ? Color(0xFF48D1CC)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "X"
                                    ? Color(0xFF20B2AA)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "Y"
                                    ? Color(0xFFB0E0E6)
                                    : firstName.toString().substring(0, 1).toUpperCase() == "Z"
                                    ? Color(0xFFdf8fdf)
                                    : Color(0xFF0072ff)),
                            child:
                            Center(
                              child:
                              Text(
                                firstName.toString().substring(0, 1).toUpperCase() + "" + lastName.toString().replaceAll("(", "").replaceAll(")", "").substring(0, 1).toUpperCase(),
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                  SizedBox(width: 8,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                     firstName==""
                          ?
                      Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Container(
                            width: 220,alignment: Alignment.centerLeft,
                            child: Text(
                              contact!.toString().replaceAll("]", "").replaceAll("[", "").replaceAll("-", "").replaceAll(" ", ""),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight:
                                  FontWeight.w500),
                            ),
                          )

                      ): Container(),


                    firstName!=""
                          ?
                      Text(
                       firstName! + ' ' + lastName!,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight:
                            FontWeight.w500),
                      ):Container(),
                    firstName!=""
                          ?
                      Text(
                       contact!.toString().replaceAll("]", "").replaceAll("[", ""),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight:
                            FontWeight.w500),
                      ):Container(),



                    ],
                  ),








                ],
              ),

              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                      onTap: (){
                        setState(() {
                          showsearchbar = true;
                        });
                      },
                      child: Icon(Icons.search,color: Colors.black,)),
                ),


              ],






            ),










            body: userDetails.data!=null?
           ( messages!.length != 0 ||  messages!.length != null)
                ? Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: WillPopScope(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        filterChatMessage.length==0?
                        Expanded(

                          child:

                          ListView.builder(
                              itemCount: messages!.length,
                              shrinkWrap: true,
                              controller: _scrollController,
                              itemBuilder: (_, index) {





                                bool isSameDate = true;
                                var date =
                                DateTime.parse(messages![index]['created_at']);
                                var formattedDate =
                                DateFormat('h:mm a').format(date);
                                final String dateString = messages![index]['created_at'];
                                final DateTime date1 = DateTime.parse(dateString);
                                final item = messages![index];
                                if (index == 0) {
                                  isSameDate = false;
                                } else {
                                  final String prevDateString = messages![index - 1]['created_at'];
                                  final DateTime prevDate = DateTime.parse(prevDateString);
                                  isSameDate = date1.isSameDate(prevDate);
                                }
                                if (index == 0 || !(isSameDate)) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width /5,
                                    child: Column(children: [
                                      SizedBox(
                                        height: 14,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),
                                                    color: Colors.blueAccent

                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                                  child: Center(child: Text(date1.formatDate(),style: TextStyle(color: Colors.white,fontSize: 12),)),
                                                )),
                                          ],
                                        ),
                                      ),

                                      SizedBox(
                                        height: 14,
                                      ),
                                      Container(

                                        margin:
                                        EdgeInsets.only(right: 10, left: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                          messages![index]['sender'] != null
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [



                                            messages![index]['sender'] == null
                                                ?
                                            messages![index]
                                            ['contact']
                                                .isNotEmpty &&
                                                messages![index]['contact']
                                                ['image'] !=
                                                    null
                                                ? CachedNetworkImage(
                                              height: 20,width: 20,
                                              fit: BoxFit.contain,
                                              imageUrl: localurlLogin +
                                                  messages![index]
                                                  ['contact']['image'],
                                              placeholder: (context, url) =>
                                                  CircleAvatar(
                                                    backgroundColor: Colors.orange,
                                                    minRadius: 16.0,
                                                    maxRadius: 16.0,
                                                  ),
                                              imageBuilder: (context, image) =>
                                                  CircleAvatar(
                                                    backgroundColor:
                                                    Colors.transparent,
                                                    backgroundImage: image,
                                                    minRadius: 16.0,
                                                    maxRadius: 16.0,
                                                  ),
                                            )
                                                :   Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                messages![index]["contact"]["firstName"]==null
                                                    ? Container(
                                                  height: 20,
                                                  width: 20,
                                                  child: ClipRRect(
                                                    borderRadius:BorderRadius.circular(60),
                                                    child: Image.network("https://appprivacy.messaging.care/media/blank.png",height: 20,width: 20,
                                                      fit: BoxFit.cover,),
                                                  ),
                                                ):
                                                Container(
                                                  height: 20,
                                                  width: 20,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(30),
                                                      color: messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="A"?
                                                      Color(0xFFFF0000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="B"?
                                                      Color(0xFF2b2b40):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="D"?
                                                      Color(0xFF50cd89):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="E"?
                                                      Color(0xFFe033c3):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="F"?
                                                      Color(0xFF00FFFF):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="G"?
                                                      Color(0xFF800000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="H"?
                                                      Color(0xFF008000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="I"?
                                                      Color(0xFF000080):
                                                      messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="J"?
                                                      Color(0xFF808000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="K"?
                                                      Color(0xFF800080):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="L"?
                                                      Color(0xFF008080):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="M"?
                                                      Color(0xFFa24c7d):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="N"?
                                                      Color(0xFF613f3f):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="O"?
                                                      Color(0xFFFFA500):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="P"?
                                                      Color(0xFFb96969):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Q"?
                                                      Color(0xFF7e00e3):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="R"?
                                                      Color(0xFFf1416c):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="S"?
                                                      Color(0xFFff4a00):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="T"?
                                                      Color(0xFF87CEEB):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="U"?
                                                      Color(0xFF9370DB):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="V"?
                                                      Color(0xFFFF1493):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="W"?
                                                      Color(0xFF48D1CC):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="X"?
                                                      Color(0xFF20B2AA):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Y"?
                                                      Color(0xFFB0E0E6):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Z"?
                                                      Color(0xFFdf8fdf):Color(0xFF0072ff)
                                                  ),
                                                  child: Center(child: Text(messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()+""+
                                                      messages![index]["contact"]["lastName"].toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                                    style: TextStyle(color: Colors.white,fontSize: 10,fontWeight: FontWeight.bold),
                                                  ),


                                                  ),


                                                ),

                                              ],
                                            ):Container(),

                                            SizedBox(
                                              width: 4,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                              messages![index]['sender'] == null
                                                  ?
                                              CrossAxisAlignment.start:CrossAxisAlignment.end,
                                              children: [

                                                messages![index]['sender'] == null
                                                    ?
                                                Row(
                                                  children: [
                                                    messages![index]["contact"]["firstName"]!=null?
                                                    Text(messages![index]["contact"]["firstName"]+" "+messages![index]["contact"]["lastName"],

                                                      style: TextStyle(color: Colors.black45,fontWeight:FontWeight.bold,fontSize: 10),

                                                    ):
                                                    Container(),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    messages![index]["contact"]["primaryNumber"]!=null?
                                                    Text(messages![index]["contact"]["primaryNumber"],

                                                      style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 8),

                                                    ):Text(messages![index]["contact"]["contactPhone"].toString(),

                                                      style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 8),

                                                    ),
                                                  ],
                                                ):
                                                Row(
                                                  children: [
                                                    messages![index]["sender"]["firstName"]!=null?
                                                    Text(messages![index]["sender"]["firstName"]+" "+messages![index]["sender"]["lastName"],

                                                      style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 10),

                                                    ):
                                                    Container(),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(messages![index]["sender"]["primaryNumber"],

                                                      style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 8),

                                                    ),
                                                  ],
                                                ),

                                                Container(
                                                  width: MediaQuery.of(context).size.width /5,
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 6),
                                                  constraints: BoxConstraints(
                                                      minWidth: 20,
                                                      maxWidth:
                                                      MediaQuery.of(context).size.width *
                                                          0.6),
                                                  decoration: BoxDecoration(
                                                      color:
                                                      messages![index]['sender'] != null
                                                          ? Colors.greenAccent.shade100
                                                          : Colors.grey.shade300,
                                                      borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius.circular(
                                                            messages![index]['sender'] == null
                                                                ? 0
                                                                : 12),
                                                        topLeft: Radius.circular(16),

                                                        bottomRight: Radius.circular(
                                                            messages![index]['sender'] == null
                                                                ? 12
                                                                : 0),
                                                        topRight: Radius.circular(12),
                                                      )),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [

                                                      Text(
                                                        utf8convert( messages![index]['text'])
                                                        ,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w400,fontFamily: 'NotoEmoji',
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4,),



                                                      messages![index]['file']!=null?

                                                      Image.network( localurlLogin+ messages![index]['file'],
                                                      height: 100,width: 100,fit: BoxFit.contain,
                                                      ):



                                                      Container(),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            formattedDate,
                                                            style: const TextStyle(
                                                              color: Colors.black54,
                                                              fontSize: 8,
                                                            ),
                                                          ),
                                                          messages![index]['sender'] != null
                                                              ?
                                                          messages![index]["content_type"].toString() != "delivered"?
                                                          Image.asset("assets/tick.png",height: 14,fit: BoxFit.contain,):
                                                          Image.asset("assets/dtick.png",height: 14,fit: BoxFit.contain,):Container(),
                                                          // Text(messages![index]["content_type"].toString()),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              width: 4,
                                            ),
                                            messages![index]['sender'] != null
                                                ? CircleAvatar(
                                              backgroundImage: messages![index]
                                              ['sender']
                                                  .isNotEmpty &&
                                                  messages![index]['sender']
                                                  ['image'] !=
                                                      null
                                                  ? NetworkImage(
                                                localurlLogin +
                                                    messages![index]['sender']
                                                    ['image'],

                                              )
                                                  : NetworkImage(localurlLogin +
                                                  userDetails
                                                      .data!.company!.image
                                                      .toString())
                                              as ImageProvider,
                                              backgroundColor: Colors.transparent,
                                              maxRadius: 12,
                                            )
                                                : Container(),

                                          ],
                                        ),
                                      )
                                    ]),
                                  );
                                } else {
                                  return   Container(

                                    margin:
                                    EdgeInsets.only(top: 10, right: 10, left: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                      messages![index]['sender'] != null
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        messages![index]['sender'] == null
                                            ?
                                        messages![index]
                                        ['contact']
                                            .isNotEmpty &&
                                            messages![index]['contact']
                                            ['image'] !=
                                                null
                                            ? CachedNetworkImage(
                                          height: 20,width: 20,
                                          fit: BoxFit.contain,
                                          imageUrl: localurlLogin +
                                              messages![index]
                                              ['contact']['image'],
                                          placeholder: (context, url) =>
                                              CircleAvatar(
                                                backgroundColor: Colors.orange,
                                                minRadius: 16.0,
                                                maxRadius: 16.0,
                                              ),
                                          imageBuilder: (context, image) =>
                                              CircleAvatar(
                                                backgroundColor:
                                                Colors.transparent,
                                                backgroundImage: image,
                                                minRadius: 16.0,
                                                maxRadius: 16.0,
                                              ),
                                        )
                                            :   Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            messages![index]["contact"]["firstName"]==null
                                                ? Container(
                                              height: 20,
                                              width: 20,
                                              child: ClipRRect(
                                                borderRadius:BorderRadius.circular(60),
                                                child: Image.network("https://appprivacy.messaging.care/media/blank.png",height: 20,width: 20,
                                                  fit: BoxFit.cover,),
                                              ),
                                            ):
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30),
                                                  color: messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="A"?
                                                  Color(0xFFFF0000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="B"?
                                                  Color(0xFF2b2b40):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="D"?
                                                  Color(0xFF50cd89):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="E"?
                                                  Color(0xFFe033c3):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="F"?
                                                  Color(0xFF00FFFF):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="G"?
                                                  Color(0xFF800000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="H"?
                                                  Color(0xFF008000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="I"?
                                                  Color(0xFF000080):
                                                  messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="J"?
                                                  Color(0xFF808000):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="K"?
                                                  Color(0xFF800080):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="L"?
                                                  Color(0xFF008080):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="M"?
                                                  Color(0xFFa24c7d):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="N"?
                                                  Color(0xFF613f3f):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="O"?
                                                  Color(0xFFFFA500):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="P"?
                                                  Color(0xFFb96969):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Q"?
                                                  Color(0xFF7e00e3):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="R"?
                                                  Color(0xFFf1416c):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="S"?
                                                  Color(0xFFff4a00):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="T"?
                                                  Color(0xFF87CEEB):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="U"?
                                                  Color(0xFF9370DB):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="V"?
                                                  Color(0xFFFF1493):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="W"?
                                                  Color(0xFF48D1CC):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="X"?
                                                  Color(0xFF20B2AA):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Y"?
                                                  Color(0xFFB0E0E6):messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Z"?
                                                  Color(0xFFdf8fdf):Color(0xFF0072ff)
                                              ),
                                              child: Center(child: Text(messages![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()+""+
                                                  messages![index]["contact"]["lastName"].toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                                style: TextStyle(color: Colors.white,fontSize: 10,fontWeight: FontWeight.bold),
                                              ),


                                              ),


                                            ),

                                          ],
                                        ):Container(),







                                        SizedBox(
                                          width: 4,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width /5,
                                          child: Column(
                                            crossAxisAlignment:
                                            messages![index]['sender'] == null
                                                ?
                                            CrossAxisAlignment.start:CrossAxisAlignment.end,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              messages![index]['sender'] == null
                                                  ?
                                              Row(
                                                children: [
                                                  messages![index]["contact"]["firstName"]!=null?
                                                  Text(messages![index]["contact"]["firstName"]+" "+messages![index]["contact"]["lastName"],

                                                    style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 10),

                                                  ):
                                                  Container(),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(messages![index]["contact"]["contactPhone"],

                                                    style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 8),

                                                  ),
                                                ],
                                              ):
                                              Row(
                                                children: [
                                                  messages![index]["sender"]["firstName"]!=null?
                                                  Text(messages![index]["sender"]["firstName"]+" "+messages![index]["sender"]["lastName"],

                                                    style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 10),

                                                  ):
                                                  Container(),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(

                                                    messages![index]["sender"]["primaryNumber"],

                                                    style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 8),

                                                  ),
                                                ],
                                              ),

                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                constraints: BoxConstraints(
                                                    minWidth: 20,
                                                    maxWidth:
                                                    MediaQuery.of(context).size.width *
                                                        0.6),
                                                decoration: BoxDecoration(
                                                    color:
                                                    messages![index]['sender'] != null
                                                        ? Colors.greenAccent.shade100
                                                        : Colors.grey.shade300,
                                                    borderRadius: BorderRadius.only(
                                                      bottomLeft: Radius.circular(
                                                          messages![index]['sender'] == null
                                                              ? 0
                                                              : 12),
                                                      topRight: Radius.circular(16),
                                                      bottomRight: Radius.circular(
                                                          messages![index]['sender'] == null
                                                              ? 12
                                                              : 0),
                                                      topLeft: Radius.circular(
                                                          12),
                                                    )),
                                                child: Container(
                                width: MediaQuery.of(context).size.width /5,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [

                                                      Text(
                                                        utf8convert( messages![index]['text'])
                                                        ,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w400,fontFamily: 'NotoEmoji',
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      SizedBox(height: 2,),

                                                      messages![index]["file"]!=null?
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          if (messages![index]["file"]
                                                              .split('.')
                                                              .last
                                                              .toLowerCase() ==
                                                              'jpg' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'jfif' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'jpeg' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'png' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'gif' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'bmp')
                                                          //   ClipRRect(
                                                          //       borderRadius: BorderRadius.circular(2),
                                                          //       child: Image.network(
                                                          //         widget.attachment[index]["file"],
                                                          //         height: 20,
                                                          //         width: 20,
                                                          //         fit: BoxFit.fill,
                                                          //       )),
                                                          //
                                                            Image.network( localurlLogin+ messages![index]['file'],
                                                              height: 100,width: 100,fit: BoxFit.fill,
                                                            ),
                                                          if (messages![index]["file"]
                                                              .split('.')
                                                              .last
                                                              .toLowerCase() ==
                                                              'pdf')
                                                            Icon(
                                                              Icons.picture_as_pdf_outlined,
                                                              color: Colors.red,
                                                              size: 18,
                                                            ),

                                                          if (messages![index]["file"]
                                                              .split('.')
                                                              .last
                                                              .toLowerCase() ==
                                                              'csv' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'doc' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'docx' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'txt' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'xls' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'xlsx' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'mp4' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'mp3' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'zip' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'rar' ||
                                                              messages![index]["file"]
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase() ==
                                                                  'mov')
                                                            Icon(
                                                              Icons.file_present_outlined,
                                                              color: Colors.red,
                                                              size: 18,
                                                            ),

                                                        ],
                                                      ):Container(),



                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            formattedDate,
                                                            style: const TextStyle(
                                                              color: Colors.black54,
                                                              fontSize: 9,
                                                            ),
                                                          ),
                                                          messages![index]['sender'] != null
                                                              ? messages![index]["content_type"].toString() != "delivered"?
                                                          Image.asset("assets/tick.png",height: 14,fit: BoxFit.contain,):
                                                          Image.asset("assets/dtick.png",height: 14,fit: BoxFit.contain,):Container(),



                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),


                                        SizedBox(
                                          width: 4,
                                        ),
                                        messages![index]['sender'] != null
                                            ? CircleAvatar(
                                          backgroundImage: messages![index]
                                          ['sender']
                                              .isNotEmpty &&
                                              messages![index]['sender']
                                              ['image'] !=
                                                  null
                                              ? NetworkImage(
                                            localurlLogin +
                                                messages![index]['sender']
                                                ['image'],
                                          )
                                              :NetworkImage(localurlLogin +
                                              userDetails
                                                  .data!.company!.image
                                                  .toString())
                                          as ImageProvider,
                                          backgroundColor: Colors.transparent,
                                          maxRadius: 12,
                                        )
                                            : Container(),

                                      ],
                                    ),
                                  );
                                }
                              }),
                        ):


                        Expanded(

                          child:

                          ListView.builder(
                              itemCount: filterChatMessage!.length,
                              shrinkWrap: true,
                              controller: _scrollController,
                              itemBuilder: (_, index) {




                                bool isSameDate = true;
                                var date =
                                DateTime.parse(filterChatMessage![index]['created_at']);
                                var formattedDate =
                                DateFormat('h:mm a').format(date);
                                final String dateString = filterChatMessage![index]['created_at'];
                                final DateTime date1 = DateTime.parse(dateString);
                                final item = filterChatMessage![index];
                                if (index == 0) {
                                  isSameDate = false;
                                } else {
                                  final String prevDateString = filterChatMessage![index - 1]['created_at'];
                                  final DateTime prevDate = DateTime.parse(prevDateString);
                                  isSameDate = date1.isSameDate(prevDate);
                                }
                                if (index == 0 || !(isSameDate)) {
                                  return Column(children: [
                                    SizedBox(
                                      height: 14,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),
                                                  color: Colors.blueAccent

                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                                child: Center(child: Text(date1.formatDate(),style: TextStyle(color: Colors.white),)),
                                              )),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(

                                      margin:
                                      EdgeInsets.only(top: 10, right: 10, left: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                        filterChatMessage![index]['sender'] != null
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [



                                          filterChatMessage![index]['sender'] == null
                                              ?
                                          filterChatMessage![index]
                                          ['contact']
                                              .isNotEmpty &&
                                              filterChatMessage![index]['contact']
                                              ['image'] !=
                                                  null
                                              ? CachedNetworkImage(
                                            height: 20,width: 20,
                                            fit: BoxFit.contain,
                                            imageUrl: localurlLogin +
                                                filterChatMessage![index]
                                                ['contact']['image'],
                                            placeholder: (context, url) =>
                                                CircleAvatar(
                                                  backgroundColor: Colors.orange,
                                                  minRadius: 16.0,
                                                  maxRadius: 16.0,
                                                ),
                                            imageBuilder: (context, image) =>
                                                CircleAvatar(
                                                  backgroundColor:
                                                  Colors.transparent,
                                                  backgroundImage: image,
                                                  minRadius: 16.0,
                                                  maxRadius: 16.0,
                                                ),
                                          )
                                              :   Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              filterChatMessage![index]["contact"]["firstName"]==null
                                                  ? Container(
                                                height: 20,width: 20,

                                                child: ClipRRect(
                                                  borderRadius:BorderRadius.circular(60),
                                                  child: Image.network("https://appprivacy.messaging.care/media/blank.png", height: 20,width: 20,
                                                      fit: BoxFit.contain,),
                                                ),
                                              ):
                                              Container(
                                                height: 20,width: 20,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(30),
                                                    color: filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="A"?
                                                    Color(0xFFFF0000):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="B"?
                                                    Color(0xFF2b2b40):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="D"?
                                                    Color(0xFF50cd89):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="E"?
                                                    Color(0xFFe033c3):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="F"?
                                                    Color(0xFF00FFFF):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="G"?
                                                    Color(0xFF800000):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="H"?
                                                    Color(0xFF008000):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="I"?
                                                    Color(0xFF000080):
                                                    filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="J"?
                                                    Color(0xFF808000):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="K"?
                                                    Color(0xFF800080):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="L"?
                                                    Color(0xFF008080):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="M"?
                                                    Color(0xFFa24c7d):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="N"?
                                                    Color(0xFF613f3f):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="O"?
                                                    Color(0xFFFFA500):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="P"?
                                                    Color(0xFFb96969):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Q"?
                                                    Color(0xFF7e00e3):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="R"?
                                                    Color(0xFFf1416c):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="S"?
                                                    Color(0xFFff4a00):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="T"?
                                                    Color(0xFF87CEEB):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="U"?
                                                    Color(0xFF9370DB):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="V"?
                                                    Color(0xFFFF1493):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="W"?
                                                    Color(0xFF48D1CC):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="X"?
                                                    Color(0xFF20B2AA):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Y"?
                                                    Color(0xFFB0E0E6):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Z"?
                                                    Color(0xFFdf8fdf):Color(0xFF0072ff)
                                                ),
                                                child: Center(child: Text(filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()+""+
                                                    filterChatMessage![index]["contact"]["lastName"].toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                                  style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),
                                                ),


                                                ),


                                              ),

                                            ],
                                          ):Container(),

                                          SizedBox(
                                            width: 4,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width /5,
                                            child: Column(
                                              crossAxisAlignment:
                                              filterChatMessage![index]['sender'] == null
                                                  ?
                                              CrossAxisAlignment.start:CrossAxisAlignment.end,
                                              children: [

                                                filterChatMessage![index]['sender'] == null
                                                    ?
                                                Row(
                                                  children: [
                                                    filterChatMessage![index]["contact"]["firstName"]!=null?
                                                    Text(filterChatMessage![index]["contact"]["firstName"]+" "+filterChatMessage![index]["contact"]["lastName"],

                                                      style: TextStyle(color: Colors.black45,fontWeight:FontWeight.bold,fontSize: 10),

                                                    ):
                                                    Container(),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    filterChatMessage![index]["contact"]["primaryNumber"]!=null?
                                                    Text(filterChatMessage![index]["contact"]["primaryNumber"],

                                                      style: TextStyle(color: Colors.black45,fontWeight:FontWeight.bold,fontSize: 8),

                                                    ):Text(filterChatMessage![index]["contact"]["contactPhone"].toString(),

                                                      style: TextStyle(color: Colors.black45,fontWeight:FontWeight.bold,fontSize: 8),

                                                    ),
                                                  ],
                                                ):
                                                Row(
                                                  children: [
                                                    filterChatMessage![index]["sender"]["firstName"]!=null?
                                                    Text(filterChatMessage![index]["sender"]["firstName"]+" "+filterChatMessage![index]["sender"]["lastName"],

                                                      style: TextStyle(color: Colors.black45,fontWeight:FontWeight.bold,fontSize: 10),

                                                    ):
                                                    Container(),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(filterChatMessage![index]["sender"]["primaryNumber"],

                                                      style: TextStyle(color: Colors.black45,fontWeight:FontWeight.bold,fontSize: 8),

                                                    ),
                                                  ],
                                                ),

                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  constraints: BoxConstraints(
                                                      minWidth: 20,
                                                      maxWidth:
                                                      MediaQuery.of(context).size.width *
                                                          0.6),
                                                  decoration: BoxDecoration(
                                                      color:
                                                      filterChatMessage![index]['sender'] != null
                                                          ? Colors.greenAccent.shade100
                                                          : Colors.grey.shade300,
                                                      borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius.circular(
                                                            filterChatMessage![index]['sender'] == null
                                                                ? 0
                                                                : 12),
                                                        topLeft: Radius.circular(16),

                                                        bottomRight: Radius.circular(
                                                            filterChatMessage![index]['sender'] == null
                                                                ? 12
                                                                : 0),
                                                        topRight: Radius.circular(12),
                                                      )),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [

                                                      Text(
                                                        utf8convert( filterChatMessage![index]['text'])
                                                        ,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w400,fontFamily: 'NotoEmoji',
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      SizedBox(height: 2,),
                                                      filterChatMessage![index]['file']!=null?

                                                      Image.network( localurlLogin+ filterChatMessage![index]['file']):
                                                      Container(),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            formattedDate,
                                                            style: const TextStyle(
                                                              color: Colors.black54,
                                                              fontSize: 9,
                                                            ),
                                                          ),
                                                          filterChatMessage![index]['sender'] != null
                                                              ?
                                                          filterChatMessage![index]["content_type"].toString() != "delivered"?
                                                          Image.asset("assets/tick.png",height: 14,fit: BoxFit.contain,):
                                                          Image.asset("assets/dtick.png",height: 14,fit: BoxFit.contain,):Container(),
                                                          // Text(messages![index]["content_type"].toString()),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          SizedBox(
                                            width: 4,
                                          ),
                                          filterChatMessage![index]['sender'] != null
                                              ? CircleAvatar(
                                            backgroundImage: filterChatMessage![index]
                                            ['sender']
                                                .isNotEmpty &&
                                                filterChatMessage![index]['sender']
                                                ['image'] !=
                                                    null
                                                ? NetworkImage(
                                              localurlLogin +
                                                  filterChatMessage![index]['sender']
                                                  ['image'],
                                            )
                                                : NetworkImage(localurlLogin +
                                                userDetails
                                                    .data!.company!.image
                                                    .toString())
                                            as ImageProvider,
                                            backgroundColor: Colors.transparent,
                                            maxRadius: 12,
                                          )
                                              : Container(),

                                        ],
                                      ),
                                    )
                                  ]);
                                } else {
                                  return   Container(

                                    margin:
                                    EdgeInsets.only(top: 10, right: 10, left: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                      filterChatMessage![index]['sender'] != null
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        filterChatMessage![index]['sender'] == null
                                            ?
                                        filterChatMessage![index]
                                        ['contact']
                                            .isNotEmpty &&
                                            filterChatMessage![index]['contact']
                                            ['image'] !=
                                                null
                                            ? CachedNetworkImage(
                                         height: 20,width: 20,fit: BoxFit.contain,
                                          imageUrl: localurlLogin +
                                              filterChatMessage![index]
                                              ['contact']['image'],
                                          placeholder: (context, url) =>
                                              CircleAvatar(
                                                backgroundColor: Colors.orange,
                                                minRadius: 16.0,
                                                maxRadius: 16.0,
                                              ),
                                          imageBuilder: (context, image) =>
                                              CircleAvatar(
                                                backgroundColor:
                                                Colors.transparent,
                                                backgroundImage: image,
                                                minRadius: 16.0,
                                                maxRadius: 16.0,
                                              ),
                                        )
                                            :   Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            filterChatMessage![index]["contact"]["firstName"]==null
                                                ? Container(
                                              height: 20,width: 20,
                                              child: ClipRRect(
                                                borderRadius:BorderRadius.circular(60),
                                                child: Image.network("https://appprivacy.messaging.care/media/blank.png",  height: 20,width: 20,fit: BoxFit.contain,),
                                              ),
                                            ):
                                            Container(
                                              height: 20,width: 20,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30),
                                                  color: filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="A"?
                                                  Color(0xFFFF0000):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="B"?
                                                  Color(0xFF2b2b40):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="D"?
                                                  Color(0xFF50cd89):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="E"?
                                                  Color(0xFFe033c3):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="F"?
                                                  Color(0xFF00FFFF):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="G"?
                                                  Color(0xFF800000):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="H"?
                                                  Color(0xFF008000):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="I"?
                                                  Color(0xFF000080):
                                                  filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="J"?
                                                  Color(0xFF808000):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="K"?
                                                  Color(0xFF800080):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="L"?
                                                  Color(0xFF008080):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="M"?
                                                  Color(0xFFa24c7d):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="N"?
                                                  Color(0xFF613f3f):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="O"?
                                                  Color(0xFFFFA500):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="P"?
                                                  Color(0xFFb96969):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Q"?
                                                  Color(0xFF7e00e3):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="R"?
                                                  Color(0xFFf1416c):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="S"?
                                                  Color(0xFFff4a00):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="T"?
                                                  Color(0xFF87CEEB):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="U"?
                                                  Color(0xFF9370DB):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="V"?
                                                  Color(0xFFFF1493):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="W"?
                                                  Color(0xFF48D1CC):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="X"?
                                                  Color(0xFF20B2AA):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Y"?
                                                  Color(0xFFB0E0E6):filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()=="Z"?
                                                  Color(0xFFdf8fdf):Color(0xFF0072ff)
                                              ),
                                              child: Center(child: Text(filterChatMessage![index]["contact"]["firstName"].toString().substring(0,1).toUpperCase()+""+
                                                  filterChatMessage![index]["contact"]["lastName"].toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                                style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),
                                              ),


                                              ),


                                            ),

                                          ],
                                        ):Container(),







                                        SizedBox(
                                          width: 4,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width /5,
                                          child: Column(
                                            crossAxisAlignment:
                                            filterChatMessage![index]['sender'] == null
                                                ?
                                            CrossAxisAlignment.start:CrossAxisAlignment.end,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              filterChatMessage![index]['sender'] == null
                                                  ?
                                              Row(
                                                children: [
                                                  filterChatMessage![index]["contact"]["firstName"]!=null?
                                                  Text(filterChatMessage![index]["contact"]["firstName"]+" "+filterChatMessage![index]["contact"]["lastName"],

                                                    style: TextStyle(color: Colors.black45,fontWeight:FontWeight.bold,fontSize: 10),

                                                  ):
                                                  Container(),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(filterChatMessage![index]["contact"]["contactPhone"],

                                                    style: TextStyle(color: Colors.black45,fontWeight:FontWeight.bold,fontSize: 8),

                                                  ),
                                                ],
                                              ):
                                              Row(
                                                children: [
                                                  filterChatMessage![index]["sender"]["firstName"]!=null?
                                                  Text(filterChatMessage![index]["sender"]["firstName"]+" "+filterChatMessage![index]["sender"]["lastName"],

                                                    style: TextStyle(color: Colors.black45,fontWeight:FontWeight.bold,fontSize: 10),

                                                  ):
                                                  Container(),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(

                                                    filterChatMessage![index]["sender"]["primaryNumber"],

                                                    style: TextStyle(color: Colors.black45,fontWeight:FontWeight.bold,fontSize: 8),

                                                  ),
                                                ],
                                              ),

                                              Container(
                                                padding: EdgeInsets.all(10),
                                                constraints: BoxConstraints(
                                                    minWidth: 20,
                                                    maxWidth:
                                                    MediaQuery.of(context).size.width *
                                                        0.6),
                                                decoration: BoxDecoration(
                                                    color:
                                                    filterChatMessage![index]['sender'] != null
                                                        ? Colors.greenAccent.shade100
                                                        : Colors.grey.shade300,
                                                    borderRadius: BorderRadius.only(
                                                      bottomLeft: Radius.circular(
                                                          filterChatMessage![index]['sender'] == null
                                                              ? 0
                                                              : 12),
                                                      topRight: Radius.circular(16),
                                                      bottomRight: Radius.circular(
                                                          filterChatMessage![index]['sender'] == null
                                                              ? 12
                                                              : 0),
                                                      topLeft: Radius.circular(
                                                          12),
                                                    )),
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [

                                                    Text(
                                                      utf8convert( filterChatMessage![index]['text'])
                                                      ,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w400,fontFamily: 'NotoEmoji',
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4,),
                                                    filterChatMessage![index]['file']!=null?

                                                    Image.network( localurlLogin+ filterChatMessage![index]['file']):
                                                    Container(),

                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          formattedDate,
                                                          style: const TextStyle(
                                                            color: Colors.black54,
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                        filterChatMessage![index]['sender'] != null
                                                            ? filterChatMessage![index]["content_type"].toString() != "delivered"?
                                                        Image.asset("assets/tick.png",height: 14,fit: BoxFit.contain,):
                                                        Image.asset("assets/dtick.png",height: 14,fit: BoxFit.contain,):Container(),



                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),


                                        SizedBox(
                                          width: 4,
                                        ),
                                        filterChatMessage![index]['sender'] != null
                                            ? CircleAvatar(
                                          backgroundImage: filterChatMessage![index]
                                          ['sender']
                                              .isNotEmpty &&
                                              filterChatMessage![index]['sender']
                                              ['image'] !=
                                                  null
                                              ? NetworkImage(
                                            localurlLogin +
                                                filterChatMessage![index]['sender']
                                                ['image'],
                                          )
                                              :NetworkImage(localurlLogin +
                                              userDetails
                                                  .data!.company!.image
                                                  .toString())
                                          as ImageProvider,
                                          backgroundColor: Colors.transparent,
                                          maxRadius: 12,
                                        )
                                            : Container(),

                                      ],
                                    ),
                                  );
                                }
                              }),
                        )
                        ,





                        msgImage!=null?
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 4),
                              child: Container(
                                height: 50,

                                width: 60,
                                child: Image.file(File(msgImage!.path),
                                    fit: BoxFit.cover,height: 50,

                                    width: 60),
                              ),
                            ),
                            Positioned(
                                right: 0,top: 0,
                                child: GestureDetector(

                                    onTap: (){
                                      setState(() {
                                        msgImage =null;
                                      });
                                    },
                                    child: Icon(Icons.cancel_outlined,color: Colors.black,)))
                          ],
                        ):Container(),
                        Row(
                          children: [
                            Container(
                             // width: MediaQuery.of(context).size.width - 60,
                              child: Expanded(
                                child: Card(
                                  margin: EdgeInsets.only(
                                      left: 6, right: 6, bottom: 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: TextFormField(
                                    controller: msgcontroller,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    minLines: 1,
                                    onChanged: (value) {
                                      if (value.length > 0) {
                                        setState(() {
                                          sendButton = true;
                                        });
                                      } else {
                                        setState(() {
                                          sendButton = false;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
    contentPadding: EdgeInsets.all(0),
    isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6.0),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF006064), width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6.0),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF006064), width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6.0),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF006064), width: 1),
                                        ),
                                      hintText: "Type a message",
                                      hintStyle: TextStyle(fontSize: 12),
                                      prefixIcon: IconButton(
                                        icon: Icon(
                                          show
                                              ? Icons.keyboard
                                              : Icons.emoji_emotions_outlined,size: 18,
                                        ),
                                        onPressed: () {
                                          if (!show) {
                                            focusNode.unfocus();
                                            focusNode.canRequestFocus = false;
                                          }
                                          setState(() {
                                            show = !show;
                                          });
                                        },
                                      ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.image,size: 18,),
                                            onPressed: () async {
                                              final ImagePicker picker = ImagePicker();

                                              final XFile? images =
                                                  await picker.pickImage(
                                                  source: ImageSource.gallery);
                                              if (images != null) {
                                                setState(() {
                                                  msgImage = File(images.path);

                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),

                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(

                                right: 6,
                                left: 2,
                              ),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.blueAccent,
                                child: IconButton(
                                    icon: Icon(
                                      Icons.send,
                                      color: Colors.white,size: 18,
                                    ),
                                    onPressed: () {




                                      SystemChannels.textInput
                                          .invokeMethod('TextInput.hide');
                                      if (msgcontroller.text.isEmpty) {
                                        toastification.show(
                                          context: context, // optional if you use ToastificationWrapper
                                          title: "Message is Required",
                                          autoCloseDuration: const Duration(seconds: 5),
padding:const EdgeInsets.only(
                                          bottom: 6,
                                          right: 6,
                                          left: 2,
                                        ),
                                          backgroundColor: Colors.red,
                                        );

                                        return;
                                      }
                                      sendWebSocketMessage(msgcontroller.text).then((value) {
                                        setState(() {
                                          msgcontroller.clear();
                                        });
                                      });
                                      setState(() {
                                        msgcontroller.clear();
                                      });
                                      setState(() {
                                        sendButton = false;
                                      });
                                    }

                                ),
                              ),
                            ),
                          ],
                        ),
                        show ? emojiSelect() : Container(),
                      ],
                    ),
                    onWillPop: () {
                      if (show) {
                        setState(() {
                          show = false;
                        });
                      } else {
                      setState(() {
                        Navigator.pop(context);
                      });
                      }
                      return Future.value(false);
                    },
                  ),
                ),

                showsearchbar==true?
                Positioned(
                   left : 0, //Add this to centre your text
                    right : 0,
                    child:
                    Container(
                    width: MediaQuery.of(context).size.width /2,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.transparent
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          color: Colors.white,
                          child: TextField(
                            controller: _searchmsgController,

                            onChanged: (v) {
                              onSearchTextChanged1(v);
                            },
                            decoration: InputDecoration(
                              hintText: 'Search message',
hintStyle: TextStyle(fontSize: 12),
                              // Add a clear button to the search bar
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchmsgController.clear();
                                    filterChatMessage.clear();
                                    showsearchbar = false;
                                  });
                                },
                              ),
                              // Add a search icon or button to the search bar
                              prefixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  onSearchTextChanged1(_searchmsgController.text);
                                },
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.0),
                                borderSide: const BorderSide(
                                    color: Color(0xFF006064), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.0),
                                borderSide: const BorderSide(
                                    color: Color(0xFF006064), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.0),
                                borderSide: const BorderSide(
                                    color: Color(0xFF006064), width: 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                ):Positioned(child: SizedBox())



              ],
            )
                :Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                )): Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                )),
          ),
        ],
      ),
    ):Container();
  }




  List<dynamic>? messages = [];
  var timer;
  var mediaattachments;
  bool isopened = false;
  final ScrollController _scrollController =
  ScrollController(initialScrollOffset: 500 * 100.0);
  ScrollController _controller = ScrollController();
  bool showbtn = false;
  AuthService authservice = AuthService();
  final msgcontroller = TextEditingController();
  bool show = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;

  var company_logo;
  late Map<String, dynamic> answer;
  List filterChatMessage =[];
  _scrollToEnd() {
    setState(() {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 300,
        ),
        curve: Curves.easeOut,
      );
    });
  }




  int present = 0;
  int perPage = 5;

  var originalItems;
  var items = [];


  Future<void> sendWebSocketMessage1(String message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    uuid = prefs.getString("token");

    var sortedNumbersFalse = [...toList]
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    var combinedNumbers = sortedNumbersFalse.join('');
    var phoneNumDigits =
    userDetails.data!.primaryNumber!.replaceAll(RegExp(r'\D'), '');
    var finalroom = phoneNumDigits + combinedNumbers;

    Constants.websocket!.sink.add(toList.length == 1
        ? jsonEncode({
      'type': 'chat_message',
      'userid': uuid,
      'image': "",
      'imageName': "",
      'message': message.trim(),
      'phone': toList[0],
      'contacts': '',
      'room': finalroom,
    })
        : jsonEncode({
      'type': 'chat_message',
      'userid': uuid,
      'image': "",
      'imageName': "",
      'message': message.trim(),
      'phone': '',
      'contacts': toList,
      'room': finalroom,
      "msgtype": "group",
    }));

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ChatPage()));
    setState(() {
      msgcontroller.clear();
    });
  }



  getMediaList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString("accessToken");
    var uuid = prefs.getString("token");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    print(room);
    var body = json.encode({
      "userid": uuid,
      "room": room
    });
    var url = Uri.parse(localurlLogin + "/getAllMedia");
    http.Response response = await http.post(url, headers: headers, body: body);

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {

      setState(() {

        mediaattachments = json.decode(response.body)["send"];
       originalItems = json.decode(response.body)["send"];

        // items.addAll(originalItems.getRange(present, present + perPage));
        // present = present + perPage;

      });
      setState(() {

      });
    } else {}
  }

  savewallpaper(img) async {
    print(img);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallpaper', img.toString());
    wallpapers =  await prefs.getString('wallpaper');
   // Navigator.pop(context);

  }
  getwallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    wallpapers =  await prefs.getString('wallpaper');
    setState(() {

    });
    // Navigator.pop(context);

  }


  Future<void> getRoomUserMessages(room) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    company_logo = prefs.getString("company_logo");

    try {

      String accessToken = await authservice.getAccessToken();

      var url = Uri.parse(
          localurlLogin + "/SuperAdminMsgWithCustomRoom/$room");

      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $accessToken'});

      //  print(response.body);
      var data = jsonDecode(response.body);

      messages = data['chats'];
      if (mounted) {
        setState(() {
          messages = data['chats'];
        });
      }



      timer = Timer(
          const Duration(
            seconds: 1,
          ), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeOut,
          );
        }
      });

      // return data['chats'];
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<void> sendWebSocketMessage(String message) async {
    String token = await authservice.getPrefs();
    var imgss = msgImage!=null?convertToBase64(msgImage):null;

    Constants.websocket!.sink.add(
       isgroup==true?  jsonEncode({
          'type': 'chat_message',
          'userid': token,
          'image': imgss!=null?imgss:"",
          'imageName': imgss!=null?"image.png":"",
          'message': message.trim(),
          'phone': '',
          'contacts': finalvalue,
          'room': room,
          "msgtype": "group",
        }):
        jsonEncode({
          'type': 'chat_message',
          'userid': token,
          'image': imgss!=null?imgss:"",
          'imageName': imgss!=null?"image.png":"",
          'message': message.trim(),
          'phone': messages![0]['contact']['formatcontact'],
          'contacts': '',
          'room': room,
        })
    );

    getRoomUserMessages(room);
    setState(() {
      msgImage =null;
      msgcontroller.clear();
    });
    Timer(Duration(microseconds: 100),
            () {
          if (!_scrollController.hasClients) {
            _controller.jumpTo(_controller.position.maxScrollExtent);
          }

        });

    setState(() {});

  }


  var wallpapers;
  var imageFile;
  var msgImage;
  bool showsearchbar= false;
  late final ScrollController scrollController = ScrollController();
  TextEditingController _searchmsgController = TextEditingController();

  final scaffoldKey = GlobalKey<ScaffoldState>();


  dynamic convertToBase64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    return 'data:image/jpeg;base64,$base64Image';
  }


  onSearchTextChanged1(String text) async {

    filterChatMessage.clear();
    bool count = false;

    print(messages!.length);

    for (var i = 0; i < messages!.length; i++) {
      if ((
          messages![i]['text'].toString().toLowerCase().contains(text.toLowerCase()))){
        filterChatMessage!.add(messages![i]);
      }else{


      }


    }
    if (filterChatMessage.length==0){

      toastification.show(
        context: context, // optional if you use ToastificationWrapper
        title:  "No Message Found",
        autoCloseDuration: const Duration(seconds: 5),
        icon: const Icon(Icons.message),
        backgroundColor: Colors.red,
          padding:const EdgeInsets.all(0)
      );


    }




    setState(() {});
  }




  String utf8convert(String text) {
    List<int> bytes = text.toString().codeUnits;
    return utf8.decode(bytes);
  }



  Widget bottomSheet() {
    return Container(
      height: 158,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();

                        final XFile? images =
                        await picker.pickImage(
                            source: ImageSource.camera);
                        if (images != null) {
                          setState(() {
                            msgImage = File(images.path);
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.pink,
                            child: Icon(
                              Icons.camera_alt,
                              // semanticLabel: "Help",
                              size: 29,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Camera",
                            style: TextStyle(
                              fontSize: 12,
                              // fontWeight: FontWeight.w100,
                            ),
                          )
                        ],
                      )),
                  SizedBox(
                    width: 40,
                  ),
                  GestureDetector(
                      onTap: () async {
                        print("jhjfhgfgh");
                        final ImagePicker picker = ImagePicker();

                        final XFile? images =
                        await picker.pickImage(
                            source: ImageSource.gallery);
                        if (images != null) {
                          setState(() {
                            msgImage = File(images.path);
                            Navigator.of(context).pop();
                          });
                        }
                      },

                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.teal,
                            child: Icon(
                              Icons.insert_photo,
                              // semanticLabel: "Help",
                              size: 29,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Gallery",
                            style: TextStyle(
                              fontSize: 12,
                              // fontWeight: FontWeight.w100,
                            ),
                          )
                        ],
                      )

                  )

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return
      InkWell(
        onTap: () {},
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(
                icons,
                // semanticLabel: "Help",
                size: 29,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                // fontWeight: FontWeight.w100,
              ),
            )
          ],
        ),
      );
  }

  Widget emojiSelect() {
    return Container(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          setState(() {
            msgcontroller.text = msgcontroller.text + emoji.emoji;
          });
        },
        config: Config(
            columns: 7,
            emojiSizeMax: 32.0,
            verticalSpacing: 0,
            horizontalSpacing: 0,
            initCategory: Category.RECENT,
            bgColor: Color(0xFFF2F2F2),
            indicatorColor: Colors.blue,
            iconColor: Colors.grey,
            iconColorSelected: Colors.blue,
            recentsLimit: 28,
            categoryIcons: const CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL),
      ),
    );
  }
}









