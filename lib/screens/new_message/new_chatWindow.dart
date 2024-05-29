// ignore: file_names
import 'dart:async';
import 'dart:convert';
// ignore: unused_import
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/constants/colors.dart';
import 'package:sms/models/chat.dart';
import 'package:sms/services/auth_service.dart';
import 'package:sms/utils/constants.dart' as contants;
import 'package:sms/utils/constants.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';


class NewChatWindow extends StatefulWidget {
  NewChatWindow({Key? key, required this.room, required this.contact, this.firstName,this.lastName,this.image})
      : super(key: key);
  final String room;
  String? firstName;
  String? lastName;
  String? contact;

  String? image;

  @override

  _NewChatWindowState createState() => _NewChatWindowState();
}

class _NewChatWindowState extends State<NewChatWindow> {
  List<dynamic>? messages = [];
  var timer;
  final ScrollController _scrollController =
  ScrollController(initialScrollOffset: 500 * 100.0);
  ScrollController _controller = ScrollController();
  bool showbtn = false;

  final msgcontroller = TextEditingController();
  bool show = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  bool isLoading = false;
  static UserDetails userDetails = UserDetails();
  var company_logo;
  late Map<String, dynamic> answer;
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
  AuthService authservice = AuthService();
  getUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString("accessToken");
    var  uuid = prefs.getString("token");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var url = Uri.parse(localurlLogin + "/user/getUserAppDetails/$uuid");
    http.Response response = await http.get(url, headers: headers);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);

      setState(() {
        userDetails = UserDetails.fromJson(responseJson);
      });
    } else {}
  }
  @override
  void initState() {
    getRoomUserMessages( widget.room);
    getUserDetails();
    super.initState();
    if ( widget.room.isNotEmpty) {
      // Future.delayed(Duration.zero, () {
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     duration: Duration(seconds: 1),
      //     content: Text("Welcome"),
      //     backgroundColor: Colors.deepOrange,
      //   ));
      // });
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   content: Text("No Data Found"),
      //   backgroundColor: Colors.deepOrange,
      // ));
    }
    Constants.websocketController.listen((latestEvent) {
      // print("latestEvent for chat detail dart" + latestEvent.toString());
      // print("web socket room " + latestEvent['room'].toString());
      // print("current room " + room.toString());
      // print("Constants.roomid in listener " + Constants.roomid.toString());
      if (latestEvent['room'] == Constants.roomid) {
        getRoomUserMessages( widget.room);
      }
      // use latestEvent data here.
    });
    // scroll.addListener(() {
    //   double showoffset = 10.0;
    //   if (scroll.offset > showoffset) {
    //     showbtn = true;
    //   } else {
    //     showbtn = false;
    //     setState(() {});
    //   }
    // });
    setState(() {});
  }

  @override
  void dispose() {
    timer.cancel();
    timer;
    super.dispose();
  }

  Future<void> getRoomUserMessages(room) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    company_logo = prefs.getString("company_logo");
    print(company_logo);
    try {

      String accessToken = await authservice.getAccessToken();

      var url = Uri.parse(
          localurlLogin + "/SuperAdminMsgWithCustomRoom/$room");
      print(url);
      print(accessToken);
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

      // Future.delayed(Duration.zero, () {
      //   setState(() {
      //     if (scroll.hasClients) {
      //       scroll.animateTo(
      //         scroll.position.maxScrollExtent,
      //         duration: const Duration(
      //           milliseconds: 300,
      //         ),
      //         curve: Curves.easeOut,
      //       );
      //     }
      //   });
      // });

      timer = Timer(
          const Duration(
            seconds: 1,
          ), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 200,
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
    print("message" + message.toString());
    Constants.websocket!.sink.add(
       jsonEncode({
          'type': 'chat_message',
          'userid': token,
          'image': '',
          'imageName': '',
          'message': message.trim(),
          'phone': messages![0]['contact']['formatcontact'],
          'contacts': '',
          'room': widget.room,


        })
    );
    getRoomUserMessages( widget.room);
    Timer(Duration(microseconds: 10),
            () => _controller.jumpTo(_controller.position.maxScrollExtent));
    setState(() {});
  }


  late final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
print(widget.firstName);
    return Stack(
      children: [
        new Container(

          decoration: new BoxDecoration(
            color: Colors.white,
            image: new DecorationImage(
              image: new NetworkImage(
                  "https://i.pinimg.com/originals/49/7e/d7/497ed7a4365b807096b6badb0d597b4f.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar:
          new PreferredSize(
            child: Container(
              padding:
              new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () {

                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        widget.image != ""
                            ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: widget.image!=""
                              ? localurlLogin +widget.image!
                              : 'https://appprivacy.messaging.care/media/blank.png',
                          placeholder: (context, url) =>
                              CircleAvatar(
                                backgroundColor: Colors.orange,
                                minRadius: 20.0,
                                maxRadius: 22.0,
                              ),
                          imageBuilder: (context, image) =>
                              CircleAvatar(
                                backgroundColor:
                                Colors.transparent,
                                backgroundImage: image,
                                minRadius: 20.0,
                                maxRadius: 22.0,
                              ),
                        )
                            :   Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           widget.firstName==""
                                ? Container(
                              height: 35,
                              width: 35,
                              child: ClipRRect(
                                borderRadius:BorderRadius.circular(60),
                                child: Image.network("https://appprivacy.messaging.care/media/blank.png",height: 35,width: 35,
                                  fit: BoxFit.cover,),
                              ),
                            ):
                            Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: widget.firstName.toString().substring(0,1).toUpperCase()=="A"?
                                  Color(0xFFFF0000):widget.firstName.toString().substring(0,1).toUpperCase()=="B"?
                                  Color(0xFF2b2b40):widget.firstName.toString().substring(0,1).toUpperCase()=="D"?
                                  Color(0xFF50cd89):widget.firstName.toString().substring(0,1).toUpperCase()=="E"?
                                  Color(0xFFe033c3):widget.firstName.toString().substring(0,1).toUpperCase()=="F"?
                                  Color(0xFF00FFFF):widget.firstName.toString().substring(0,1).toUpperCase()=="G"?
                                  Color(0xFF800000):widget.firstName.toString().substring(0,1).toUpperCase()=="H"?
                                  Color(0xFF008000):widget.firstName.toString().substring(0,1).toUpperCase()=="I"?
                                  Color(0xFF000080):
                                  widget.firstName.toString().substring(0,1).toUpperCase()=="J"?
                                  Color(0xFF808000):widget.firstName.toString().substring(0,1).toUpperCase()=="K"?
                                  Color(0xFF800080):widget.firstName.toString().substring(0,1).toUpperCase()=="L"?
                                  Color(0xFF008080):widget.firstName.toString().substring(0,1).toUpperCase()=="M"?
                                  Color(0xFFa24c7d):widget.firstName.toString().substring(0,1).toUpperCase()=="N"?
                                  Color(0xFF613f3f):widget.firstName.toString().substring(0,1).toUpperCase()=="O"?
                                  Color(0xFFFFA500):widget.firstName.toString().substring(0,1).toUpperCase()=="P"?
                                  Color(0xFFb96969):widget.firstName.toString().substring(0,1).toUpperCase()=="Q"?
                                  Color(0xFF7e00e3):widget.firstName.toString().substring(0,1).toUpperCase()=="R"?
                                  Color(0xFFf1416c):widget.firstName.toString().substring(0,1).toUpperCase()=="S"?
                                  Color(0xFFff4a00):widget.firstName.toString().substring(0,1).toUpperCase()=="T"?
                                  Color(0xFF87CEEB):widget.firstName.toString().substring(0,1).toUpperCase()=="U"?
                                  Color(0xFF9370DB):widget.firstName.toString().substring(0,1).toUpperCase()=="V"?
                                  Color(0xFFFF1493):widget.firstName.toString().substring(0,1).toUpperCase()=="W"?
                                  Color(0xFF48D1CC):widget.firstName.toString().substring(0,1).toUpperCase()=="X"?
                                  Color(0xFF20B2AA):widget.firstName.toString().substring(0,1).toUpperCase()=="Y"?
                                  Color(0xFFB0E0E6):widget.firstName.toString().substring(0,1).toUpperCase()=="Z"?
                                  Color(0xFFdf8fdf):Color(0xFF0072ff)
                              ),
                              child: Center(child: Text(widget.firstName.toString().substring(0,1).toUpperCase()+""+
                                  widget.lastName.toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),
                              ),


                              ),


                            ),

                          ],
                        ),



                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            widget.firstName!=""
                                ? Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                width: 220,
                                child: Text(
                                  widget.contact!.toString().replaceAll("]", "").replaceAll("[", ""),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight:
                                      FontWeight.w500),
                                ),
                              ),
                            )
                                : Text(
                              widget.firstName! + ' ' + widget.lastName!,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.w500),
                            ),
                            SizedBox(height: 6,),
                            widget.firstName!=""
                                ?Text(" "):
                            Text(
                              widget.contact!.toString().replaceAll("]", "").replaceAll("[", ""),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.w400),
                            )

                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                    colors: [
                      Color(0xFF0C1446),

                      Color(0xFF006064),
                      Color(0xFF1F6E8C),
                      // Color(0xffE3F4F4)
                    ],
                  ),
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.grey,
                      blurRadius: 20.0,
                      spreadRadius: 1.0,
                    )
                  ]),
            ),
            preferredSize: new Size(
                MediaQuery.of(context).size.width,
                70
            ),
          ),

          body: userDetails.data!=null?messages!.length != 0
              ? Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: WillPopScope(
              child: Column(
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
                            return Column(children: [
                              SizedBox(
                                height: 14,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),
                                            color: Colors.blueAccent

                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(child: Text(date1.formatDate(),style: TextStyle(color: Colors.white),)),
                                        )),
                                  ],
                                ),
                              ),

                              SizedBox(
                                height: 14,
                              ),
                              Container(

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
                                      fit: BoxFit.cover,
                                      imageUrl: localurlLogin +
                                          messages![index]
                                          ['contact']['image'],
                                      placeholder: (context, url) =>
                                          CircleAvatar(
                                            backgroundColor: Colors.orange,
                                            minRadius: 20.0,
                                            maxRadius: 22.0,
                                          ),
                                      imageBuilder: (context, image) =>
                                          CircleAvatar(
                                            backgroundColor:
                                            Colors.transparent,
                                            backgroundImage: image,
                                            minRadius: 20.0,
                                            maxRadius: 22.0,
                                          ),
                                    )
                                        :   Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        messages![index]["contact"]["firstName"]==null
                                            ? Container(
                                          height: 30,
                                          width: 30,
                                          child: ClipRRect(
                                            borderRadius:BorderRadius.circular(60),
                                            child: Image.network("https://appprivacy.messaging.care/media/blank.png",height: 30,width: 30,
                                              fit: BoxFit.cover,),
                                          ),
                                        ):
                                        Container(
                                          height: 30,
                                          width: 30,
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
                                            style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),
                                          ),


                                          ),


                                        ),

                                      ],
                                    ):Container(),

                                    SizedBox(
                                      width: 4,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        messages![index]['sender'] == null
                                            ?
                                        Row(
                                          children: [
                                            messages![index]["contact"]["firstName"]!=null?
                                            Text(messages![index]["contact"]["firstName"]+" "+messages![index]["contact"]["lastName"],

                                              style: TextStyle(color: Color(0xffB7FFFF),fontWeight:FontWeight.bold,fontSize: 14),

                                            ):
                                            Container(),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(messages![index]["contact"]["contactPhone"],

                                              style: TextStyle(color: Color(0xffB7FFFF),fontWeight: FontWeight.bold,fontSize: 11),

                                            ),
                                          ],
                                        ):
                                        Row(
                                          children: [
                                            messages![index]["sender"]["firstName"]!=null?
                                            Text(messages![index]["sender"]["firstName"]+" "+messages![index]["sender"]["lastName"],

                                              style: TextStyle(color: Color(0xff3ddcd8),fontWeight: FontWeight.bold,fontSize: 14),

                                            ):
                                            Container(),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(messages![index]["sender"]["contactPhone"],

                                              style: TextStyle(color: Color(0xff3ddcd8),fontWeight: FontWeight.bold,fontSize: 11),

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
                                              messages![index]['sender'] != null
                                                  ? Colors.white
                                                  : Color(0xffE3F4F4),
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
                                                  fontSize: 13,
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
                                                      fontSize: 10,
                                                    ),
                                                  ),
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
                                      maxRadius: 15,
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
                                    fit: BoxFit.cover,
                                    imageUrl: localurlLogin +
                                        messages![index]
                                        ['contact']['image'],
                                    placeholder: (context, url) =>
                                        CircleAvatar(
                                          backgroundColor: Colors.orange,
                                          minRadius: 20.0,
                                          maxRadius: 22.0,
                                        ),
                                    imageBuilder: (context, image) =>
                                        CircleAvatar(
                                          backgroundColor:
                                          Colors.transparent,
                                          backgroundImage: image,
                                          minRadius: 20.0,
                                          maxRadius: 22.0,
                                        ),
                                  )
                                      :   Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      messages![index]["contact"]["firstName"]==null
                                          ? Container(
                                        height: 30,
                                        width: 30,
                                        child: ClipRRect(
                                          borderRadius:BorderRadius.circular(60),
                                          child: Image.network("https://appprivacy.messaging.care/media/blank.png",height: 30,width: 30,
                                            fit: BoxFit.cover,),
                                        ),
                                      ):
                                      Container(
                                        height: 30,
                                        width: 30,
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
                                          style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),
                                        ),


                                        ),


                                      ),

                                    ],
                                  ):Container(),



                                  // messages![index]['sender'] == null
                                  //     ? CircleAvatar(
                                  //   backgroundImage: messages![index]
                                  //   ['contact']
                                  //       .isNotEmpty &&
                                  //       messages![index]['contact']
                                  //       ['image'] !=
                                  //           null
                                  //       ? NetworkImage(
                                  //     contants.urlLogin +
                                  //         messages![index]
                                  //         ['contact']['image'],
                                  //   )
                                  //
                                  //
                                  //       : const NetworkImage(
                                  //       'https://appprivacy.messaging.care/media/blank.png')
                                  //   as ImageProvider,
                                  //   backgroundColor: Colors.transparent,
                                  //   maxRadius: 15,
                                  // )
                                  //     : Container(),



                                  SizedBox(
                                    width: 4,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    messages![index]['sender'] == null
                                        ?
                                    CrossAxisAlignment.start:CrossAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: 14,
                                      ),
                                      messages![index]['sender'] == null
                                          ?
                                      Row(
                                        children: [
                                          messages![index]["contact"]["firstName"]!=null?
                                          Text(messages![index]["contact"]["firstName"]+" "+messages![index]["contact"]["lastName"],

                                            style: TextStyle(color: Color(0xffB7FFFF),fontWeight:FontWeight.bold,fontSize: 14),

                                          ):
                                          Container(),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(messages![index]["contact"]["contactPhone"],

                                            style: TextStyle(color: Color(0xffB7FFFF),fontWeight: FontWeight.bold,fontSize: 11),

                                          ),
                                        ],
                                      ):
                                      Row(
                                        children: [
                                          messages![index]["sender"]["firstName"]!=null?
                                          Text(messages![index]["sender"]["firstName"]+" "+messages![index]["sender"]["lastName"],

                                            style: TextStyle(color: Color(0xff3ddcd8),fontWeight: FontWeight.bold,fontSize: 14),

                                          ):
                                          Container(),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(messages![index]["sender"]["contactPhone"],

                                            style: TextStyle(color: Color(0xff3ddcd8),fontWeight: FontWeight.bold,fontSize: 11),

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
                                            messages![index]['sender'] != null
                                                ? Colors.white
                                                : Color(0xffE3F4F4),
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
                                                fontSize: 13,
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
                                                    fontSize: 10,
                                                  ),
                                                ),
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
                                        :NetworkImage(localurlLogin +
                                        userDetails
                                            .data!.company!.image
                                            .toString())
                                    as ImageProvider,
                                    backgroundColor: Colors.transparent,
                                    maxRadius: 15,
                                  )
                                      : Container(),

                                ],
                              ),
                            );
                          }
                        }),
                  ),
                  SizedBox(height: 30,),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 60,
                        child: Card(
                          margin: EdgeInsets.only(
                              left: 6, right: 6, bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
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
                              border: InputBorder.none,
                              hintText: "Type a message",
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: IconButton(
                                icon: Icon(
                                  show
                                      ? Icons.keyboard
                                      : Icons.emoji_emotions_outlined,
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
                              // suffixIcon: Row(
                              //   mainAxisSize: MainAxisSize.min,
                              //   children: [
                              //     IconButton(
                              //       icon: Icon(Icons.image),
                              //       onPressed: () {
                              //         showModalBottomSheet(
                              //             backgroundColor:
                              //                 Colors.transparent,
                              //             context: context,
                              //             builder: (builder) =>
                              //                 bottomSheet());
                              //       },
                              //     ),
                              //   ],
                              // ),
                              contentPadding: EdgeInsets.all(5),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 6,
                          right: 6,
                          left: 2,
                        ),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blueAccent,
                          child: IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              SystemChannels.textInput.invokeMethod('TextInput.hide');
                              sendWebSocketMessage(msgcontroller.text);
                              msgcontroller.clear();
                              setState(() {
                                sendButton = false;
                              });
                              // if (sendButton) {
                              //   _scrollController.animateTo(
                              //       _scrollController.position.maxScrollExtent,
                              //       duration: Duration(milliseconds: 300),
                              //       curve: Curves.easeOut);
                              //   SystemChannels.textInput
                              //       .invokeMethod('TextInput.hide');
                              //   if (msgcontroller.text.isEmpty) {
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //         SnackBar(
                              //             content: Text('Message is Required'),
                              //             backgroundColor: Colors.orange));
                              //     return;
                              //   }
                              //   sendWebSocketMessage(msgcontroller.text);
                              //   msgcontroller.clear();
                              //   setState(() {
                              //     sendButton = false;
                              //   });
                              //  }
                            },
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
                  Navigator.pop(context);
                }
                return Future.value(false);
              },
            ),
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
    );
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
                  iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple, "Gallery"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
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

class MessageBubble extends CustomPainter {
  final Color bgColor;
  MessageBubble(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(-10, 0);
    path.lineTo(0, 15);
    path.lineTo(10, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
const String dateFormatter = 'MMMM dd, y';

extension DateHelper on DateTime {

  String formatDate() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}

