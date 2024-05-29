// ignore: file_names
import 'dart:async';
import 'dart:convert';
import 'dart:io';
// ignore: unused_import
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/constants/colors.dart';
import 'package:sms/models/chat.dart';
import 'package:sms/screens/new_message/contactList.dart';
import 'package:sms/screens/photoview.dart';
import 'package:sms/utils/constants.dart' as contants;
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class ChatDetailPage extends StatefulWidget {
  ChatDetailPage({Key? key, required this.room, required this.contact, this.firstName,this.lastName, this.isgroup,this.image, required this.finalvalues})
      : super(key: key);
  final String room;
  String? firstName;
  String? lastName;
  String? contact;
  bool? isgroup;
  String? image;


var finalvalues;
  @override

  _ChatDetailPageState createState() => _ChatDetailPageState(room: room);
}

class _ChatDetailPageState extends State<ChatDetailPage> {
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
  bool isLoading = false;
  static UserDetails userDetails = UserDetails();
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
    getwallpaper();

    getRoomUserMessages(room);
    getUserDetails();
    getMediaList();
    super.initState();
    if (room.isNotEmpty) {
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
        getRoomUserMessages(room);
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


  int present = 0;
  int perPage = 5;

  var originalItems;
  var items = [];







  @override
  void dispose() {
    timer.cancel();
    timer;
    super.dispose();
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
var imgss = msgImage!=null?convertToBase64(msgImage):null;

    Constants.websocket!.sink.add(
      widget.isgroup==true?  jsonEncode({
        'type': 'chat_message',
        'userid': token,
        'image': imgss!=null?imgss:"",
        'imageName': imgss!=null?"image.png":"",
        'message': message.trim(),
        'phone': '',
        'contacts': widget.finalvalues,
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

  _ChatDetailPageState({required this.room});

  final String room;
var wallpapers;
  var imageFile;
  var msgImage;
  bool showsearchbar= false;
  late final ScrollController scrollController = ScrollController();
  TextEditingController _searchmsgController = TextEditingController();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  getMediaList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString("accessToken");
    var uuid = prefs.getString("token");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
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
     mediaattachments = json.decode(response.body)["send"];
     originalItems = json.decode(response.body)["send"];
     setState(() {
       items.addAll(originalItems.getRange(present, present + perPage));
       present = present + perPage;
     });
      setState(() {

      });
    } else {}
  }

  savewallpaper(img) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallpaper', img.toString());
  wallpapers =  await prefs.getString('wallpaper');
    Navigator.pop(context);

  }
  getwallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    wallpapers =  await prefs.getString('wallpaper');
   // Navigator.pop(context);

  }


  dynamic convertToBase64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    return 'data:image/jpeg;base64,$base64Image';
  }


  onSearchTextChanged(String text) async {

    filterChatMessage.clear();
    for (var i = 0; i < messages!.length; i++) {
      if ((
          messages![i]['text'].toString().toLowerCase().contains(text.toLowerCase())))
      filterChatMessage!.add(messages![i]);
    }



    setState(() {});
  }


  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.white,
      child: Stack(
        children: [


          imageFile == null
              ? wallpapers==null?
          Container(

            decoration: new BoxDecoration(
              //color: Colors.white,
              image: new DecorationImage(
                image:
                AssetImage(
                    "assets/wallpapers.jpeg"),


                fit: BoxFit.cover,
              ),
            ),
          ):Container(
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
            endDrawer: Drawer(
              child: ListView(
                children: [
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                        onTap: () async {
                          // final ImagePicker picker = ImagePicker();
                          //
                          // final XFile? images =
                          //     await picker.pickImage(
                          //     source: ImageSource.gallery);
                          // if (images != null) {
                          //   setState(() {
                          //     imageFile = File(images.path);
                          //     savewallpaper(imageFile.path);
                          //   });
                          // }

                        },
                        child: Text("Change Wallpaper",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();

                            final XFile? images =
                                await picker.pickImage(
                                source: ImageSource.gallery);
                            if (images != null) {
                              setState(() {
                                imageFile = File(images.path);
                                savewallpaper(imageFile.path);
                              });
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(0xFF006064)
                              ),
                              child: Center(child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 6),
                                child: Text("Select Image",style: TextStyle(color: Colors.white),),
                              ))),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [



                        Text("Media Attachment",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                     GestureDetector(
                         onTap: (){
                           Navigator.pop(context);
                         },
                         child: Icon(Icons.cancel_outlined))
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  originalItems!=null?
                  StaggeredGridView.countBuilder(
                                    controller: ScrollController(keepScrollOffset: false),
                                    shrinkWrap: true,
                                    crossAxisCount: 3,
                                    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                                    itemCount:  (present <= originalItems.length) ? items.length + 1 : items.length,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                    scrollDirection: Axis.vertical,

                                    itemBuilder: (BuildContext context, int index) {

                      return originalItems.length!=0? (index == items.length ) ?
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 30),
                        child: Container(
decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: Color(0xFF006064)
),
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                if((present + perPage )> originalItems.length) {
                                  items.addAll(
                                      originalItems.getRange(present, originalItems.length));
                                } else {
                                  items.addAll(
                                      originalItems.getRange(present, present + perPage));
                                }
                                present = present + perPage;
                              });
                            },
                            child: Center(child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text("Load More",style: TextStyle(color: Colors.white,fontSize: 10),),
                            )),

                          ),
                        ),
                      )
                          :
                      GestureDetector(
                                                onTap: (){
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => PhotoViewPage(
                                                            photos: items, index: index),
                                                      ));
                                                },
                                                child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                height:80,width: 60,
                                color: Colors.black12,
                                child: Image.network(localurlLogin +items[index]["url"],
                                height: 80,width: 60,fit: BoxFit.fill,
                                ),
                              ),
                            ),
                                              ):Container();
                    },
                  ):Container(),

      //             mediaattachments!=null?
      //
      //             Padding(
      //               padding: const EdgeInsets.symmetric(horizontal: 10),
      //               child: Container(
      //                 child:   StaggeredGridView.countBuilder(
      //                   controller: ScrollController(keepScrollOffset: false),
      //                   shrinkWrap: true,
      //                   crossAxisCount: 3,
      //                   staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
      //                   itemCount: mediaattachments.length,
      //                   mainAxisSpacing: 4,
      //                   crossAxisSpacing: 4,
      //                   scrollDirection: Axis.vertical,
      //
      //                   itemBuilder: (BuildContext context, int index) {
      //                     return
      //
      //                       GestureDetector(
      //                       onTap: (){
      //                         Navigator.push(
      //                             context,
      //                             MaterialPageRoute(
      //                               builder: (_) => PhotoViewPage(
      //                                   photos: mediaattachments, index: index),
      //                             ));
      //                       },
      //                       child: Padding(
      //     padding: const EdgeInsets.all(2.0),
      //     child: Container(
      //       height:80,width: 60,
      //       color: Colors.black12,
      //       child: Image.network(localurlLogin +mediaattachments[index]["url"],
      //       height: 80,width: 60,fit: BoxFit.fill,
      //       ),
      //     ),
      //   ),
      //                     );
      // },
      //               )
      //               ),
      //             )
      //
      //                 :Center(child: CircularProgressIndicator())
                ],
              ),
            ),
            appBar:AppBar(
              titleSpacing: 0,
              flexibleSpace: Container(
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

            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [


              widget.image != ""
                  ? CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: widget.image!=""
                    ? localurlLogin +widget.image!
                    : 'https://appprivacy.messaging.care/media/blank.png',
                placeholder: (context, url) =>
                    CircleAvatar(
                      backgroundColor: Colors.orange,
                      minRadius: 16.0,
                      maxRadius: 20.0,
                    ),
                imageBuilder: (context, image) =>
                    CircleAvatar(
                      backgroundColor:
                      Colors.transparent,
                      backgroundImage: image,
                      minRadius: 16.0,
                      maxRadius: 20.0,
                    ),
              )
                  :   Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.image !=
                      ""
                      ? CachedNetworkImage(
                    fit: BoxFit
                        .cover,
                    imageUrl: widget.image !=
                        ""
                        ? localurlLogin +
                        widget.image!
                        : 'https://appprivacy.messaging.care/media/blank.png',
                    placeholder: (context,
                        url) =>
                        CircleAvatar(
                          backgroundColor:
                          Colors
                              .orange,
                          minRadius:
                          20.0,
                          maxRadius:
                          22.0,
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
                          20.0,
                          maxRadius:
                          22.0,
                        ),
                  )
                      : Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                    children: [
                      widget.firstName ==
                          ""
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
                            color: widget.firstName.toString().substring(0, 1).toUpperCase() == "A"
                                ? Color(0xFFFF0000)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "B"
                                ? Color(0xFF2b2b40)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "D"
                                ? Color(0xFF50cd89)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "E"
                                ? Color(0xFFe033c3)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "F"
                                ? Color(0xFF00FFFF)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "G"
                                ? Color(0xFF800000)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "H"
                                ? Color(0xFF008000)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "I"
                                ? Color(0xFF000080)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "J"
                                ? Color(0xFF808000)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "K"
                                ? Color(0xFF800080)
                                :widget.firstName.toString().substring(0, 1).toUpperCase() == "L"
                                ? Color(0xFF008080)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "M"
                                ? Color(0xFFa24c7d)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "N"
                                ? Color(0xFF613f3f)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "O"
                                ? Color(0xFFFFA500)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "P"
                                ? Color(0xFFb96969)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "Q"
                                ? Color(0xFF7e00e3)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "R"
                                ? Color(0xFFf1416c)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "S"
                                ? Color(0xFFff4a00)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "T"
                                ? Color(0xFF87CEEB)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "U"
                                ? Color(0xFF9370DB)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "V"
                                ? Color(0xFFFF1493)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "W"
                                ? Color(0xFF48D1CC)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "X"
                                ? Color(0xFF20B2AA)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "Y"
                                ? Color(0xFFB0E0E6)
                                : widget.firstName.toString().substring(0, 1).toUpperCase() == "Z"
                                ? Color(0xFFdf8fdf)
                                : Color(0xFF0072ff)),
                        child:
                        Center(
                          child:
                          Text(
                            widget.firstName.toString().substring(0, 1).toUpperCase() + "" + widget.firstName.toString().replaceAll("(", "").replaceAll(")", "").substring(0, 1).toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                  widget.firstName==""
                      ?
                 Padding(
                   padding: const EdgeInsets.only(top: 0),
                   child: Container(
                       width: 220,alignment: Alignment.centerLeft,
                       child: Text(
                         widget.contact!.toString().replaceAll("]", "").replaceAll("[", "").replaceAll("-", "").replaceAll(" ", ""),
                         overflow: TextOverflow.ellipsis,
                         maxLines: 2,
                         style: TextStyle(
                             fontSize: 14,
                             color: Colors.white,
                             fontWeight:
                             FontWeight.w500),
                       ),
                     )

                 ): Container(),


                  widget.firstName!=""
                      ?
                     Text(
                    widget.firstName! + ' ' + widget.lastName!,
                    style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight:
                            FontWeight.w500),
                  ):Container(),
                  widget.firstName!=""
                      ?
                          Text(
                            widget.contact!.toString().replaceAll("]", "").replaceAll("[", ""),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight:
                                FontWeight.w400),
                          ):Container(),



                ],
              ),








  ],
  ),

            actions: [
              GestureDetector(
                  onTap: (){
                    setState(() {
                      showsearchbar = true;
                    });
                  },
                  child: Icon(Icons.search)),
              GestureDetector(
                  onTap: (){
                    if(scaffoldKey.currentState!.isDrawerOpen){
                      scaffoldKey.currentState!.closeEndDrawer();


                    }else{
                      scaffoldKey.currentState!.openEndDrawer();


                      //open drawer, if drawer is closed
                    }
                  },
                  child: Icon(Icons.more_vert)),

            ],
  //           bottom:
  // PreferredSize(
  // preferredSize:Size.fromHeight(isopened ? 60 : 0),
  // child: isopened?GestureDetector(
  //     onTap: (){
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => ContactList(  isMultiSelection: true,
  //
  //             userLists: List.of(widget.userLists!),userDetails:userDetails)),
  //       );
  //     },
  //     child: Container(
  //     height: 60,
  //     child: Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: <Widget>[
  //     Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Container(
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(30),
  //             color: Colors.white
  //           ),
  //           child: Center(
  //             child: Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 70,vertical: 8),
  //               child: new Text(
  //               'Add Contact',
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //     ],
  //     ),
  //     ),
  // ) : Container(),
  // )





            ),










            body: userDetails.data!=null?
            messages!.length != 0
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
                                                  fit: BoxFit.cover,
                                                  imageUrl: localurlLogin +
                                                      filterChatMessage![index]
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
                                                    filterChatMessage![index]["contact"]["firstName"]==null
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
                                                Column(
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

                                                          style: TextStyle(color: Color(0xffB7FFFF),fontWeight:FontWeight.bold,fontSize: 14),

                                                        ):
                                                        Container(),
                                                        SizedBox(
                                                          width: 4,
                                                        ),
                                                        filterChatMessage![index]["contact"]["primaryNumber"]!=null?
                                                        Text(filterChatMessage![index]["contact"]["primaryNumber"],

                                                          style: TextStyle(color: Color(0xffB7FFFF),fontWeight: FontWeight.bold,fontSize: 11),

                                                        ):Text(filterChatMessage![index]["contact"]["contactPhone"].toString(),

                                                          style: TextStyle(color: Color(0xffB7FFFF),fontWeight: FontWeight.bold,fontSize: 11),

                                                        ),
                                                      ],
                                                    ):
                                                    Row(
                                                      children: [
                                                        filterChatMessage![index]["sender"]["firstName"]!=null?
                                                        Text(filterChatMessage![index]["sender"]["firstName"]+" "+filterChatMessage![index]["sender"]["lastName"],

                                                          style: TextStyle(color: Color(0xff3ddcd8),fontWeight: FontWeight.bold,fontSize: 14),

                                                        ):
                                                        Container(),
                                                        SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(filterChatMessage![index]["sender"]["primaryNumber"],

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
                                                          filterChatMessage![index]['sender'] != null
                                                              ? Colors.white
                                                              : Color(0xffE3F4F4),
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
                                                              fontSize: 13,
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
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                              filterChatMessage![index]['sender'] != null
                                                                  ?
                                                              filterChatMessage![index]["content_type"].toString() != "delivered"?
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
                                                fit: BoxFit.cover,
                                                imageUrl: localurlLogin +
                                                    filterChatMessage![index]
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
                                                  filterChatMessage![index]["contact"]["firstName"]==null
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
                                              Column(
                                                crossAxisAlignment:
                                                filterChatMessage![index]['sender'] == null
                                                    ?
                                                CrossAxisAlignment.start:CrossAxisAlignment.end,
                                                children: [
                                                  SizedBox(
                                                    height: 14,
                                                  ),
                                                  filterChatMessage![index]['sender'] == null
                                                      ?
                                                  Row(
                                                    children: [
                                                      filterChatMessage![index]["contact"]["firstName"]!=null?
                                                      Text(filterChatMessage![index]["contact"]["firstName"]+" "+filterChatMessage![index]["contact"]["lastName"],

                                                        style: TextStyle(color: Color(0xffB7FFFF),fontWeight:FontWeight.bold,fontSize: 14),

                                                      ):
                                                      Container(),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      Text(filterChatMessage![index]["contact"]["contactPhone"],

                                                        style: TextStyle(color: Color(0xffB7FFFF),fontWeight: FontWeight.bold,fontSize: 11),

                                                      ),
                                                    ],
                                                  ):
                                                  Row(
                                                    children: [
                                                      filterChatMessage![index]["sender"]["firstName"]!=null?
                                                      Text(filterChatMessage![index]["sender"]["firstName"]+" "+filterChatMessage![index]["sender"]["lastName"],

                                                        style: TextStyle(color: Color(0xff3ddcd8),fontWeight: FontWeight.bold,fontSize: 14),

                                                      ):
                                                      Container(),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      Text(

                                                        filterChatMessage![index]["sender"]["primaryNumber"],

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
                                                        filterChatMessage![index]['sender'] != null
                                                            ? Colors.white
                                                            : Color(0xffE3F4F4),
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
                                                            fontSize: 13,
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
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                            filterChatMessage![index]['sender'] != null
                                                                ? filterChatMessage![index]["content_type"].toString() != "delivered"?
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
                                                maxRadius: 15,
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
                                          child: Icon(Icons.cancel_outlined,color: Colors.white,)))
                                ],
                              ):Container(),
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
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.image),
                                                onPressed: () {

                                                  showModalBottomSheet(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (builder) =>
                                                          bottomSheet());
                                                },
                                              ),
                                            ],
                                          ),
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




                                            SystemChannels.textInput
                                                .invokeMethod('TextInput.hide');
                                            if (msgcontroller.text.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                      content: Text('Message is Required'),
                                                      backgroundColor: Colors.orange));
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
                              Navigator.pop(context);
                            }
                            return Future.value(false);
                          },
                        ),
                      ),

showsearchbar==true?
                    Positioned(
                        top: 0,
                        child:
                        Container(
                        width: MediaQuery.of(context).size.width,
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
                                  onSearchTextChanged(v);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search message',
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
                                      onSearchTextChanged(_searchmsgController.text);
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

