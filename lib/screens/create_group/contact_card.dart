import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({Key? key, required this.contact}) : super(key: key);
  final ChatModel contact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 53,
        child: Stack(
          children: [
            contact.status==""
                ? Container(
              height: 44,
              width: 44,
              child: ClipRRect(
                borderRadius:BorderRadius.circular(60),
                child: Image.network("https://appprivacy.messaging.care/media/blank.png",height: 44,width: 44,
                  fit: BoxFit.cover,),
              ),
            ):
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color:  Color(0xFF006064)
              ),
              child: Center(child: Text(contact.name.toString().substring(0,1).toUpperCase(),
                style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),
              ),


              ),


            ),
            contact.select
                ? Positioned(
              bottom: 4,
              right: 5,
              child: CircleAvatar(
                backgroundColor: Colors.teal,
                radius: 11,
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            )
                : Container(),
          ],
        ),
      ),
      title: Text(
        contact.name!,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: contact.status!!=null?Text(
        contact.status!,
        style: TextStyle(
          fontSize: 13,
        ),
      ):Text(""),
    );
  }
}


class ChatModel {
  String ?name;
  String ?icon;


  String ?status;
  bool select = false;
  int ?id;
  ChatModel({
    this.name,
    this.icon,


    this.status,
    this.select = false,
    this.id,
  });
}