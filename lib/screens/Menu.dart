import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sms/constants/colors.dart';
import 'package:sms/screens/login_screen.dart';
import 'package:sms/screens/profiles/edit_profiles.dart';
import '../models/chat.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class SMSMenu extends StatefulWidget {
  static var tag = "/SMSMenu";

  @override
  _SMSMenuState createState() => _SMSMenuState();
}

class _SMSMenuState extends State<SMSMenu> {
  get height => MediaQuery.of(context).size.height;
  get width => MediaQuery.of(context).size.width;
  dynamic user;

  static UserDetails userData = UserDetails();

  AuthService authservice = AuthService();

  @override
  void initState() {
    super.initState();
    getuserDetails();
  }

  Future<void> getuserDetails() async {
    try {
      String token = await authservice.getPrefs();
      String accessToken = await authservice.getAccessToken();
      dynamic url;
      user = await authservice.getUserDetails(token);
      userData = UserDetails.fromJson(user);
      setState(() {});
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,

      appBar: AppBar(
        elevation: 0,titleSpacing: 0,
        iconTheme: IconThemeData(color: Colors.white),

        flexibleSpace: Container(
          decoration:  BoxDecoration(
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
          'My Profile',
          style: TextStyle(

            color: Colors.white,
          ),
        ),

      ),
      body: userData.data!=null?
      Center(
        child: Container(
          width: width * 0.5,
          child: Column(

            children: [
              SizedBox(height: 40,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  // Text(
                  //   'Profile Picture',
                  //   style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                  //
                  // ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  EditProfile()),
                      );
                    },
                    child: Icon(Icons.edit)
                  ),
                ],
              ),
              SizedBox(height: 40,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 115,
                    width: 115,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: Colors.black26,
                    ),
                    child: ClipRRect(
                      borderRadius:BorderRadius.circular(60),

                      child: Image.network(localurlLogin +userData.data!.image.toString(),height: 115,width: 115,
                        fit: BoxFit.cover,),
                    ),
                  ),
                ],
              ),
              SizedBox(height:40,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Basic info',
                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                  ),

                ],
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                            height: 45,width: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color(0xffE3F4F4)
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.account_circle,size: 30,),
                              ),
                            )),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                userData.data!.firstName!=null?
                                Text(
                                  userData.data!.firstName! + " "+userData.data!.lastName!,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black),
                                ): Text(
                                  userData.data!.contactPhone.toString(),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.verified,color: Colors.green,)
                              ],
                            ),
                            SizedBox(height: 2),

                            Text(
                              'Full Name',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                            height: 45,width: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color(0xffE3F4F4)
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:  Image.network(localurlLogin +
                                    userData
                                        .data!.company!.image
                                        .toString()),
                              ),
                            )),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  userData.data!.company!.companyName.toString(),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black),
                                ),
                                SizedBox(width: 6,),
                                Text(
                                  userData.data!.primaryNumber!,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),

                            Text(
                              'Company',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),


              Row(
                children: [


                  Expanded(
                    child: Row(
                      children: [
                        Container(
                            height: 45,width: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color(0xffE3F4F4)
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.call,size: 30,),
                              ),
                            )),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData.data!.contactPhone.toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                            SizedBox(height: 2),

                            Text(
                              'Mobile',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                            height: 45,width: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color(0xffE3F4F4)
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.email,size: 30,),
                              ),
                            )),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(

                              child: Text(
                                userData.data!.email.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),
                            ),
                            SizedBox(height: 2),

                            Text(
                              'Email',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                            height: 45,width: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color(0xffE3F4F4)
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.mobile_friendly,size: 30,),
                              ),
                            )),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'v1.0.20',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                            SizedBox(height: 2),

                            Text(
                              'Version',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),


                  Expanded(child:

                  GestureDetector(
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => CustomDialog(),
                      );
                    },
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: (){

                          },
                          child: Container(
                              height: 45,width: 45,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color(0xffE3F4F4)
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.login,size: 30,),
                                ),
                              )),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Logout',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),

                          ],
                        )
                      ],
                    ),
                  ),

                  )


                ],
              ),



            ],
          ),
        ),
      ):Center(child: CircularProgressIndicator()),
    );
  }
}



/* showDialog(
                          context: context,
                          builder: (BuildContext context) => CustomDialog(),
                        );*/
class CustomDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
    //  backgroundColor: Color(0xffE3F4F4),
      child: dialogContent(context),
    );
  }
}

dialogContent(BuildContext context) {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> removePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (Constants.websocket != null) {
      Constants.websocket!.sink.close();

    }
    Constants.websocketconnection = false;
  }
  final mq = MediaQuery.of(context);
  final width = mq.size.width;
  return Container(
    width: width * 0.3,
    decoration: BoxDecoration(
    color:Color(0xFF006064),
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        const BoxShadow(
            color: Colors.black26, blurRadius: 10.0, offset: Offset(0.0, 10.0)),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        16.height,
        Text("Confirm Log Out ?", style: TextStyle(fontSize: 18,color: Colors.white)).onTap(() {
          finish(context);
        }).paddingOnly(top: 8, bottom: 8),
        const Divider(height: 10, thickness: 1.0, color: Colors.white),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Cancel", style: TextStyle(fontSize: 18,color: Colors.white)).onTap(
              () {
                finish(context);
              },
            ).paddingRight(16),
            Container(width: 1.0, height: 40, color:  Colors.white).center(),
            Text("Logout",
                    style: primaryTextStyle(size: 18, color: Colors.redAccent))
                .onTap(
              () {
                removePrefs();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ).paddingLeft(16)
          ],
        ),
        16.height,
      ],
    ),
  );
}


