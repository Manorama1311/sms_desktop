import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sms/screens/chatPageApiWorking.dart';
import 'package:sms/utils/constants.dart';

import '../screens/chatDetailPage.dart';

class ConversationAPIList extends StatefulWidget {
  int? unread;
  int? total;
  String? contact;
  String? firstName;
  String? lastName;
  String? image;
  String? date;
  int? id;
  String? room;
  bool? isgroup;
  var finalvalue;
  List userLists;
  ConversationAPIList({
    @required this.unread,
    @required this.total,
    @required this.contact,
    @required this.firstName,
    @required this.lastName,
    @required this.image,
    @required this.date,
    @required this.id,
    @required this.room,this.isgroup, required this.finalvalue, required this.userLists,
  });
  @override
  _ConversationAPIList createState() => _ConversationAPIList();
}

class _ConversationAPIList extends State<ConversationAPIList> {
  get width => MediaQuery.of(context).size.width;
  get height => MediaQuery.of(context).size.height;
  @override
  Widget build(BuildContext context) {



    return GestureDetector(
      onTap: () {

        Constants.roomid = widget.room!;


        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(room: widget.room!,contact:widget.contact,firstName:widget.firstName,lastName:widget.lastName,isgroup:widget.isgroup,image:widget.image,finalvalues:widget.finalvalue),
          ),
        )
            .then((_) {
          Constants.roomid = "";
          print("back called so refresh again");
          // Navigator.of(context)
          //     .push(
          //   MaterialPageRoute(
          //     builder: (context) => ChatPage(),
          //   ),
          // );
        });
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return ChatDetailPage(room: widget.room!);
        // })
        // );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 6),
        child: Container(
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[

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
                            widget.firstName!.isEmpty || widget.lastName!.isEmpty
                                ? Container(
                        height: 34,
                          width: 34,
                          child: ClipRRect(
                            borderRadius:BorderRadius.circular(60),
                            child: Image.network("https://appprivacy.messaging.care/media/blank.png"    ,height: 34,
                              width: 34,
                              fit: BoxFit.cover,),
                          ),
                        ):
                            Container(
                              height: 34,
                              width: 34,
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
                                style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),
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
                            widget.firstName!.isEmpty || widget.lastName!.isEmpty
                                ? Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Container(
                                    width: 220,

                                    child: Text(
                                        widget.contact!.toString().replaceAll("]", "").replaceAll("[", "").replaceAll("-", ""),
                                      overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight:
                                      FontWeight.w500),
                                      ),
                                  ),
                                )
                                : Text(
                                    widget.firstName! + ' ' + widget.lastName!,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight:
                                  FontWeight.w500),
                                  ),
                            widget.firstName!.isEmpty || widget.lastName!.isEmpty
                                ?
                          Container() : SizedBox(height: 6,),
                            widget.firstName!.isEmpty
                                ?Text(" "):
                            Text(
                              widget.contact!.toString().replaceAll("]", "").replaceAll("[", ""),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight:
                                  FontWeight.w400),
                            )

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
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      widget.date!,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400,color: Colors.black54),
                    ),
                  ),
                  SizedBox(height: 6,),
                  widget.unread! != 0
                      ? Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF006064)),
                    // alignment: Alignment.center,
                    child: Text(
                      widget.unread!.toString(),
                      style: TextStyle(
                        fontSize: 11,
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
    );
  }
}
