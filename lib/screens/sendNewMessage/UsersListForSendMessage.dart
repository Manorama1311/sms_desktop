

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/models/chat.dart';
import 'package:http/http.dart' as http;
import 'package:sms/screens/chatDetailPage.dart';
import 'package:sms/screens/chatPageApiWorking.dart';
import 'package:sms/screens/sendNewMessage/usersListWidget.dart';
import 'package:sms/utils/constants.dart';
import 'package:sms/widgets/conversationListAPI.dart';

class NewMessageForUserList extends StatefulWidget {
  const NewMessageForUserList({Key? key}) : super(key: key);

  @override
  State<NewMessageForUserList> createState() => _NewMessageForUserListState();
}

class _NewMessageForUserListState extends State<NewMessageForUserList> {
  //late Future<List<Countuser>> countuser;
  List<dynamic>? messages = [];
  // List<Countuser>? chatUsers = [];
  // List<Countuser>? filterUsers = [];
  // List<Countuser>? allUsers = [];
  List? chatUsers = [];
  List? filterUsers = [];
  List? allUsers = [];
  bool isLoading = false;
  dynamic newtoken = "";
  dynamic user;
  var uuid;
  List? UserList;
  var id;
  String? _value;
  var timer;
  bool show = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  var company_logo;
  final msgcontroller = TextEditingController();

  static UserDetails userDetails = UserDetails();
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 500 * 100.0);
  ScrollController _controller = ScrollController();
  //var _channel;
  TextEditingController _searchController = TextEditingController();

  final StreamController<bool> _checkBoxController = StreamController();

  Stream<bool> get _checkBoxStream => _checkBoxController.stream;

  @override
  void dispose() {
    _checkBoxController.close();
    timer.cancel();
    timer;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    getUserDetails();
    getEmployeeList1();
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

      allUsers = chatData.countuser!;
      filterUsers = [...chatData.countuser!];
      setState(() {
        chatUsers;
      });
    } else {}
  }




  Future<void> sendWebSocketMessage1(String message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    uuid = prefs.getString("token");

    var sortedNumbersFalse = [...addUsersinChat]
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    var combinedNumbers = sortedNumbersFalse.join('');
    var phoneNumDigits =
        userDetails.data!.primaryNumber!.replaceAll(RegExp(r'\D'), '');
    var finalroom = phoneNumDigits + combinedNumbers;

    Constants.websocket!.sink.add(addUsersinChat.length == 1
        ? jsonEncode({
            'type': 'chat_message',
            'userid': uuid,
            'image': "",
            'imageName': "",
            'message': message.trim(),
            'phone': addUsersinChat[0],
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
            'contacts': addUsersinChat,
            'room': finalroom,
            "msgtype": "group",
          }));

    sendmessgaes();
    setState(() {
      msgcontroller.clear();
    });
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


  Future<void> getRoomUserMessages(room) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString("accessToken");
    uuid = prefs.getString("token");

    try {


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


  String? selectedValue;
  bool Loading = false;
  List addUsersinChat = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [

          Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            titleSpacing: 0,
            iconTheme: IconThemeData(color: Colors.white),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  colors: [
                    Color(0xFF0C1446),

                    Color(0xFF006064),
                    Color(0xFF1F6E8C),
                    // Color(0xffE3F4F4)
                  ],
                ),
              ),
            ),
            title: Text(
              'New Message',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Group",
                    style: TextStyle(color: Colors.white),
                  ),
                  addUsersinChat.length < 2
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
                ],
              ),
            ],
          ),
          body: userDetails.data != null
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  color: chatUsers!.length != 0 ? Colors.black12 : Colors.white,
                  child:
                  Container(
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              "assets/wallpapers.jpeg",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child:


                        SingleChildScrollView(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [





                                Padding(
                                  padding: const EdgeInsets.only(left: 10, top: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width - 60,
                                        color: Colors.white,
                                        height: 40,
                                        child: TextField(
                                          // inputFormatters: [FilteringTextInputFormatter.digitsOnly,
                                          //   LengthLimitingTextInputFormatter(10),
                                          // ],
                                          controller: _searchController,
                                          onChanged: (v) {
                                            setState(() {
                                              onSearchTextChanged(v);
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Search by name and number',
                                            // Add a clear button to the search bar
                                            suffixIcon: IconButton(
                                              icon: Icon(Icons.clear),
                                              onPressed: () {
                                                setState(() {
                                                  _searchController.clear();
                                                  chatUsers!.clear();
                                                  //  chatUsers = [...filterUsers!];
                                                });
                                              },
                                            ),
                                            // Add a search icon or button to the search bar
                                            prefixIcon: IconButton(
                                              icon: Icon(Icons.search),
                                              onPressed: () {
                                                onSearchTextChanged(
                                                    _searchController.text);
                                              },
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
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
                                      IconButton(
                                          icon: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            if (_searchController.text.length == 10) {
                                              setState(() {
                                                addUsersinChat
                                                    .add(_searchController.text);
                                                _searchController.clear();
                                                var sortedNumbersFalse = [...addUsersinChat]
                                                  ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
                                                var combinedNumbers = sortedNumbersFalse.join('');
                                                var phoneNumDigits =
                                                userDetails.data!.primaryNumber!.replaceAll(RegExp(r'\D'), '');
                                                var finalroom = phoneNumDigits + combinedNumbers;


                                                getRoomUserMessages(finalroom);
                                              });
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: "Invalid Mobile Number!",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor: Colors.red,
                                                  timeInSecForIosWeb: 1000);
                                            }
                                          }),
                                    ],
                                  ),
                                ),


                                 addUsersinChat != null
                                ? Padding(
                              padding: const EdgeInsets.only(top: 0,left: 16,right: 16),
                              child: StaggeredGridView.countBuilder(
                                controller: ScrollController(
                                    keepScrollOffset: false),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 4,
                                staggeredTileBuilder: (int index) =>
                                    StaggeredTile.fit(1),
                                itemCount: addUsersinChat!.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        addUsersinChat.removeAt(index);
                                       // messages!.clear();
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    30),
                                                color: Colors.black38),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(2.0),
                                              child: Row(
                                                children: [
                                                  Center(
                                                      child: Text(
                                                        addUsersinChat[index]
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      )),
                                                  Icon(
                                                    Icons.cancel,
                                                    size: 20,color: Colors.white,
                                                  )
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                                : Container(),






                      Stack(
                          children: [
                            addUsersinChat != null
                                ?
                            Container(
                              height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,
                              child: messages!=null?  ListView.builder(
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

                                                        style: TextStyle(color: Color(0xffB7FFFF),fontWeight:FontWeight.bold,fontSize: 14),

                                                      ):
                                                      Container(),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      messages![index]["contact"]["primaryNumber"]!=null?
                                                      Text(messages![index]["contact"]["primaryNumber"],

                                                        style: TextStyle(color: Color(0xffB7FFFF),fontWeight: FontWeight.bold,fontSize: 11),

                                                      ):Text(messages![index]["contact"]["contactPhone"].toString(),

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
                                                      Text(messages![index]["sender"]["primaryNumber"],

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
                                                            messages![index]['sender'] != null
                                                                ?
                                                            messages![index]["content_type"].toString() != "delivered"?
                                                            Image.asset("assets/tick.png",height: 18,fit: BoxFit.contain,):
                                                            Image.asset("assets/dtick.png",height: 18,fit: BoxFit.contain,):Container(),
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
                                                    Text(

                                                      messages![index]["sender"]["primaryNumber"],

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
                                                          messages![index]['sender'] != null
                                                              ? messages![index]["content_type"].toString() != "delivered"?
                                                          Image.asset("assets/tick.png",height: 18,fit: BoxFit.contain,):
                                                          Image.asset("assets/dtick.png",height: 18,fit: BoxFit.contain,):Container(),



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
                                  }):
                                  Container()
                            ):  Container(),




                            Positioned(
top: 0,
                              child:
                            chatUsers!.length != 0
                                ? Container(
                              height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: StaggeredGridView.countBuilder(
                                  controller: ScrollController(
                                      keepScrollOffset: false),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  crossAxisCount: 1,
                                  staggeredTileBuilder: (int index) =>
                                      StaggeredTile.fit(4),
                                  itemCount: chatUsers!.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return chatUsers![index].group != true
                                        ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          addUsersinChat.add(
                                              chatUsers![index]
                                                  .contact
                                                  .toString()
                                                  .replaceAll("(", "")
                                                  .replaceAll(")", "")
                                                  .replaceAll("-", "")
                                                  .replaceAll(
                                                  " ", ""));

                                        });
                                        var duplicateElement =
                                        addUsersinChat
                                            .where((item) =>
                                        addUsersinChat
                                            .indexOf(
                                            item) !=
                                            addUsersinChat
                                                .lastIndexOf(
                                                item))
                                            .toList();

                                        setState(() {
                                          if (duplicateElement
                                              .length >
                                              0) {
                                            addUsersinChat.remove(
                                                duplicateElement[0]);
                                            print(
                                                "Same Number Repeated " +
                                                    duplicateElement[
                                                    0]);
                                          }
                                        });

                                        var sortedNumbersFalse = [...addUsersinChat]
                                          ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
                                        var combinedNumbers = sortedNumbersFalse.join('');
                                        var phoneNumDigits =
                                        userDetails.data!.primaryNumber!.replaceAll(RegExp(r'\D'), '');
                                        var finalroom = phoneNumDigits + combinedNumbers;


                                        getRoomUserMessages(finalroom);
                                        setState(() {
                                          _searchController.clear();
                                          chatUsers!.clear();
                                        });


                                      },
                                      child: Padding(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal: 16,
                                            vertical: 10),
                                        child: Container(
                                          child: Row(
                                            children: <Widget>[
                                              chatUsers![index]
                                                  .image !=
                                                  ""
                                                  ? CachedNetworkImage(
                                                fit: BoxFit
                                                    .cover,
                                                imageUrl: chatUsers![index]
                                                    .image !=
                                                    ""
                                                    ? localurlLogin +
                                                    chatUsers![index]
                                                        .image!
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
                                                      18.0,
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
                                                      18.0,
                                                    ),
                                              )
                                                  : Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                children: [
                                                  chatUsers![index]
                                                      .firstName ==
                                                      null
                                                      ? Container(
                                                    height:
                                                    34,
                                                    width:
                                                    34,
                                                    child:
                                                    ClipRRect(
                                                      borderRadius:
                                                      BorderRadius.circular(60),
                                                      child:
                                                      Image.network(
                                                        "https://appprivacy.messaging.care/media/blank.png",
                                                        height: 34,
                                                        width: 34,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  )
                                                      : Container(
                                                    height:
                                                    34,
                                                    width:
                                                    34,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(30),
                                                        color: chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "A"
                                                            ? Color(0xFFFF0000)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "B"
                                                            ? Color(0xFF2b2b40)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "D"
                                                            ? Color(0xFF50cd89)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "E"
                                                            ? Color(0xFFe033c3)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "F"
                                                            ? Color(0xFF00FFFF)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "G"
                                                            ? Color(0xFF800000)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "H"
                                                            ? Color(0xFF008000)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "I"
                                                            ? Color(0xFF000080)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "J"
                                                            ? Color(0xFF808000)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "K"
                                                            ? Color(0xFF800080)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "L"
                                                            ? Color(0xFF008080)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "M"
                                                            ? Color(0xFFa24c7d)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "N"
                                                            ? Color(0xFF613f3f)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "O"
                                                            ? Color(0xFFFFA500)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "P"
                                                            ? Color(0xFFb96969)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "Q"
                                                            ? Color(0xFF7e00e3)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "R"
                                                            ? Color(0xFFf1416c)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "S"
                                                            ? Color(0xFFff4a00)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "T"
                                                            ? Color(0xFF87CEEB)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "U"
                                                            ? Color(0xFF9370DB)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "V"
                                                            ? Color(0xFFFF1493)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "W"
                                                            ? Color(0xFF48D1CC)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "X"
                                                            ? Color(0xFF20B2AA)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "Y"
                                                            ? Color(0xFFB0E0E6)
                                                            : chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() == "Z"
                                                            ? Color(0xFFdf8fdf)
                                                            : Color(0xFF0072ff)),
                                                    child:
                                                    Center(
                                                      child:
                                                      Text(
                                                        chatUsers![index].firstName.toString().substring(0, 1).toUpperCase() + "" + chatUsers![index].lastName.toString().replaceAll("(", "").replaceAll(")", "").substring(0, 1).toUpperCase(),
                                                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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
                                                  color: Colors
                                                      .transparent,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: <Widget>[
                                                      chatUsers![index]
                                                          .firstName ==
                                                          null
                                                          ? Padding(
                                                        padding:
                                                        const EdgeInsets.only(top: 10),
                                                        child:
                                                        Container(
                                                          width:
                                                          220,
                                                          child:
                                                          Text(
                                                            chatUsers![index].contact!.toString().replaceAll("]", "").replaceAll("[",
                                                                ""),
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w500),
                                                          ),
                                                        ),
                                                      )
                                                          : Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            chatUsers![index].firstName! +
                                                                ' ' +
                                                                chatUsers![index].lastName!,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w500),
                                                          ),
                                                          Text(
                                                            chatUsers![index].contact!.toString().replaceAll("]", "").replaceAll("[",
                                                                ""),
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.grey,
                                                                fontWeight: FontWeight.w400),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                        : Container();
                                  }),
                            )
                                : Container(),
                            )

                          ],
                      ),
















                              ]),
                        )
                    ),
                  )
          )
              : Center(child: CircularProgressIndicator()),


      ),


          Positioned(
              bottom:0,child:
          Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 60,
                    //  color: chatUsers!.length != 0 ? Colors.black12 : Colors.white,
                    child: Card(
                      margin: EdgeInsets.only(
                          left: 16, right: 16, bottom: 8),
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
                          hintText: " Type a message",
                          hintStyle: TextStyle(color: Colors.grey),


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
                            child: Icon(Icons.send,color: Colors.white,),
                          ))),
                    ),
                  ),


                ],
              ))
      ])
    );
  }

  sendmessgaes() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ChatPage()));
  }

  String utf8convert(String text) {
    List<int> bytes = text.toString().codeUnits;
    return utf8.decode(bytes);
  }
}




