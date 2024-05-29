

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/constants/colors.dart';
import 'package:sms/models/chat.dart';
import 'package:sms/screens/Menu.dart';
import 'package:sms/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:sms/utils/constants.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  get height =>
      MediaQuery
          .of(context)
          .size
          .height;

  get width =>
      MediaQuery
          .of(context)
          .size
          .width;
  dynamic user;
  var imageFile;
  static UserDetails userData = UserDetails();

  AuthService authservice = AuthService();
  var firstname;
  var latname;
  var address1;
  var address2;
  var city;
  var state;
  var zipcode;
  var images;
  bool isLoading = false;
bool Loading = false;
  @override
  void initState() {
    super.initState();

    getdata();
   // getuserDetails();
  }

  Future<void> getuserDetails() async {
    try {
      String token = await authservice.getPrefs();
      String accessToken = await authservice.getAccessToken();
      dynamic url;
      user = await authservice.getUserDetails(token);
      userData = UserDetails.fromJson(user);

      setState(() {

        firstname = userData.data!.firstName!;
        latname = userData.data!.lastName!;
        address1 =
        userData.data!.address1 != null ? userData.data!.address1! : null;
        address2 =
        userData.data!.address2 != null ? userData.data!.address2! : null;
        city = userData.data!.city != null ? userData.data!.city! : null;
        state = userData.data!.state != null ? userData.data!.state! : null;
        zipcode =
        userData.data!.zipcode != null ? userData.data!.zipcode! : null;
        images = userData.data!.image;
      });
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Edit Profile Details',
          style: TextStyle(

            color: Colors.white,
          ),
        ),

      ),

      body: isLoading != true ?
      SafeArea(
        child: Center(
          child: Container(
            width: width * 0.8,
            color: Colors.white,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
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
                        child: Stack(
                          clipBehavior: Clip.none,
                          fit: StackFit.expand,
                          children: [
                        ClipRRect(
                        borderRadius:BorderRadius.circular(60),
                    child:  imageFile == null
                        ? userData.data!.image!=""?
                    Image.network(localurlLogin +userData.data!.image.toString(),height: 115,width: 115,
                      fit: BoxFit.cover,):Image.network(
                      'https://messaging.care/assets/media/avatars/blank.png',height: 115,width: 115,
                      fit: BoxFit.cover,)
                        : Image.file(File(imageFile!.path),height: 115,width: 115,
                      fit: BoxFit.cover,),
                        ),

                            Positioned(
                                bottom: 0,
                                right: -25,
                                child: RawMaterialButton(
                                  onPressed: () async {
                                    final ImagePicker picker = ImagePicker();

                                              final XFile? images =
                                              await picker.pickImage(
                                                  source: ImageSource.gallery);
                                              if (images != null) {
                                                setState(() {
                                                  imageFile = File(images.path);
                                                });
                                              }
                                  },
                                  elevation: 2.0,
                                  fillColor: Color(0xFFF5F6F9),
                                  child: Icon(Icons.camera_alt_outlined, color: Colors.black,),
                                  padding: EdgeInsets.all(8.0),
                                  shape: CircleBorder(),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30,),





                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: RichText(
                            text: TextSpan(
                                text: 'Name',
                                style: TextStyle(color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14))
                                ]),

                          ),


                        ),
                      ),


                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: TextFormField(
                            initialValue: firstname,
                            onChanged: (v) {
                              setState(() {
                                firstname = v;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(12.0),
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
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              fillColor: FzColors.textBoxColor,
                              hoverColor: FzColors.textBoxColor,
                              focusColor: FzColors.textBoxColor,
                              hintText: "First name",

                              // hintStyle: GoogleFonts.openSans(
                              //   fontSize: 14,
                              //   color: FzColors.lightText,
                              // ),
                            ),
                            // style: GoogleFonts.openSans(
                            //   fontSize: 14,
                            //   color: Colors.black,
                            // ),

                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: TextFormField(
                            initialValue: latname,
                            onFieldSubmitted: (v) {
                              setState(() {
                                latname = v;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(12.0),
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
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              fillColor: FzColors.textBoxColor,
                              hoverColor: FzColors.textBoxColor,
                              focusColor: FzColors.textBoxColor,
                              hintText: "Last name",
                              //filled: true,
                              // hintStyle: GoogleFonts.openSans(
                              //   fontSize: 14,
                              //   color: FzColors.lightText,
                              // ),
                            ),
                            // style: GoogleFonts.openSans(
                            //   fontSize: 14,
                            //   color: Colors.black,
                            // ),

                          ),
                        ),
                      ),
                    ],
                  ),




                  SizedBox(height: 20,),

                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: RichText(
                            text: TextSpan(
                                text: 'Email',
                                style: TextStyle(color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14))
                                ]),

                          ),


                        ),),
                      SizedBox(width: 10,),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: RichText(
                            text: TextSpan(
                                text: 'Mobile Number',
                                style: TextStyle(color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14))
                                ]),

                          ),


                        ),),


                    ],
                  ),
                  SizedBox(height: 10,),


                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: TextFormField(
                            readOnly: true,
                            initialValue: userData.data!.email,

                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(12.0),
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
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              fillColor: FzColors.textBoxColor,
                              hoverColor: FzColors.textBoxColor,
                              focusColor: FzColors.textBoxColor,
                              hintText: "Email",
                              //filled: true,
                              // hintStyle: GoogleFonts.openSans(
                              //   fontSize: 14,
                              //   color: FzColors.lightText,
                              // ),
                            ),
                            // style: GoogleFonts.openSans(
                            //   fontSize: 14,
                            //   color: Colors.black,
                            // ),

                          ),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: TextFormField(
                            initialValue: userData.data!.contactPhone,

                            readOnly: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(12.0),
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
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              fillColor: FzColors.textBoxColor,
                              hoverColor: FzColors.textBoxColor,
                              focusColor: FzColors.textBoxColor,
                              hintText: "Contact number",
                              //filled: true,
                              // hintStyle: GoogleFonts.openSans(
                              //   fontSize: 14,
                              //   color: FzColors.lightText,
                              // ),
                            ),
                            // style: GoogleFonts.openSans(
                            //   fontSize: 14,
                            //   color: Colors.black,
                            // ),

                          ),
                        ),
                      ),
                    ],
                  ),




                  SizedBox(height: 10,),




                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: RichText(
                            text: TextSpan(
                              text: 'Address',
                              style: TextStyle(color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),

                          ),


                        ),),

                    ],
                  ),
                  SizedBox(height: 10,),


               Row(
                 children: [

                   Expanded(
                     child: Padding(
                       padding: const EdgeInsets.symmetric(
                           horizontal: 10, vertical: 2),
                       child: TextFormField(
                         initialValue: address1,
                         onChanged: (v) {
                           setState(() {
                             address1 = v;
                           });
                         },
                         decoration: InputDecoration(
                           contentPadding: const EdgeInsets.all(12.0),
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
                               width: 1.0,
                             ),
                             borderRadius: BorderRadius.all(
                               Radius.circular(4.0),
                             ),
                           ),
                           fillColor: FzColors.textBoxColor,
                           hoverColor: FzColors.textBoxColor,
                           focusColor: FzColors.textBoxColor,
                           hintText: "Please Enter Address",
                           //filled: true,
                           // hintStyle: GoogleFonts.openSans(
                           //   fontSize: 14,
                           //   color: FzColors.lightText,
                           // ),
                         ),
                         // style: GoogleFonts.openSans(
                         //   fontSize: 14,
                         //   color: Colors.black,
                         // ),

                       ),
                     ),
                   ),
                   SizedBox(width: 10,),

                   Expanded(
                     child: Padding(
                       padding: const EdgeInsets.symmetric(
                           horizontal: 10, vertical: 2),
                       child: TextFormField(
                         initialValue: address2,
                         onChanged: (v) {
                           setState(() {
                             address2 = v;
                           });
                         },
                         decoration: InputDecoration(
                           contentPadding: const EdgeInsets.all(12.0),
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
                               width: 1.0,
                             ),
                             borderRadius: BorderRadius.all(
                               Radius.circular(4.0),
                             ),
                           ),
                           fillColor: FzColors.textBoxColor,
                           hoverColor: FzColors.textBoxColor,
                           focusColor: FzColors.textBoxColor,
                           hintText: "Please Enter Address1",
                           //filled: true,
                           // hintStyle: GoogleFonts.openSans(
                           //   fontSize: 14,
                           //   color: FzColors.lightText,
                           // ),
                         ),
                         // style: GoogleFonts.openSans(
                         //   fontSize: 14,
                         //   color: Colors.black,
                         // ),

                       ),
                     ),
                   ),
                 ],
               ),



                  SizedBox(height: 20,),

                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: RichText(
                            text: TextSpan(
                              text: 'City',
                              style: TextStyle(color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),

                          ),


                        ),



                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: RichText(
                            text: TextSpan(
                              text: 'State',
                              style: TextStyle(color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),

                          ),


                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: RichText(
                            text: TextSpan(
                              text: 'Zipcode',
                              style: TextStyle(color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),

                          ),


                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 10,),
                  Row(
                    children: [

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: TextFormField(
                            initialValue: city,
                            onChanged: (v) {
                              setState(() {
                                city = v;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(12.0),
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
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              fillColor: FzColors.textBoxColor,
                              hoverColor: FzColors.textBoxColor,
                              focusColor: FzColors.textBoxColor,
                              hintText: "Enter city",
                              //filled: true,
                              // hintStyle: GoogleFonts.openSans(
                              //   fontSize: 14,
                              //   color: FzColors.lightText,
                              // ),
                            ),
                            // style: GoogleFonts.openSans(
                            //   fontSize: 14,
                            //   color: Colors.black,
                            // ),

                          ),
                        ),
                      ),

                      SizedBox(width: 10,),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: TextFormField(
                            initialValue: state,
                            onChanged: (v) {
                              setState(() {
                                state = v;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(12.0),
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
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              fillColor: FzColors.textBoxColor,
                              hoverColor: FzColors.textBoxColor,
                              focusColor: FzColors.textBoxColor,
                              hintText: "Select state",
                              //filled: true,
                              // hintStyle: GoogleFonts.openSans(
                              //   fontSize: 14,
                              //   color: FzColors.lightText,
                              // ),
                            ),
                            // style: GoogleFonts.openSans(
                            //   fontSize: 14,
                            //   color: Colors.black,
                            // ),

                          ),
                        ),
                      ),

                      SizedBox(width: 10,),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: TextFormField(
                            initialValue: zipcode,
                            onChanged: (v) {
                              setState(() {
                                zipcode = v;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(12.0),
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
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4.0),
                                ),
                              ),
                              fillColor: FzColors.textBoxColor,
                              hoverColor: FzColors.textBoxColor,
                              focusColor: FzColors.textBoxColor,
                              hintText: "Enter zipcode",
                              //filled: true,
                              // hintStyle: GoogleFonts.openSans(
                              //   fontSize: 14,
                              //   color: FzColors.lightText,
                              // ),
                            ),
                            // style: GoogleFonts.openSans(
                            //   fontSize: 14,
                            //   color: Colors.black,
                            // ),

                          ),
                        ),
                      ),
                    ],
                  ),




                  SizedBox(height: 30,),


                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: MaterialButton(
                      onPressed: () {
                        imageFile!=null?
                        submit(imageFile):submit1();
                      },
                      minWidth:  width * 0.4,
                      height: 45,
                      //  padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30.0,
                        ),
                      ),
                      color: FzColors.btnColor,
                      child: Loading
                          ? Center(
                          child: Container(
                            height: 35,
                            width: 35,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ))
                          : Text(
                        "Update Profile",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ) : Center(child: CircularProgressIndicator()),
    );
  }

  submit(File imageFile) async {
    setState(() {
      Loading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString("accessToken");
    var uuid = prefs.getString("token");
    var request = http.MultipartRequest(
        'POST', Uri.parse(localurlLogin+"/user/AppEditUser")

    );
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['id'] = userData.data!.uuid.toString();
    request.fields['firstName'] = firstname;
    request.fields['lastName'] = latname;
    request.fields['address1'] = address1!=""?address1:"";
    request.fields['address2'] = address2!=null?address2:"";
    request.fields['zipcode'] = zipcode!=null?zipcode:"";
    request.fields['is_active'] = "True";
    request.fields['city'] = city;
    request.fields['state'] = state.toString();

    request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path
    )
    );
    var response = await request.send();



    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "Profile Updated Successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          timeInSecForIosWeb: 1000);
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SMSMenu()),
      ).then((value){

      });
    } else {
      final res = await http.Response.fromStream(response);

      setState(() {

      });
      Fluttertoast.showToast(
          msg: json.decode(res.body)["error"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          timeInSecForIosWeb: 1000);
    }
    setState(() {
      Loading = true;
    });
  }

  submit1() async {

    setState(() {
      Loading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString("accessToken");
    var uuid = prefs.getString("token");
    var request = http.MultipartRequest(
        'POST', Uri.parse(localurlLogin+"/user/AppEditUser")

    );
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['id'] = userData.data!.uuid.toString();
    request.fields['firstName'] = firstname;
    request.fields['lastName'] = latname;
    request.fields['address1'] = address1!=""?address1:"";
    request.fields['address2'] = address2!=""?address2:"";
    request.fields['zipcode'] = zipcode!=null?zipcode:"";
    request.fields['is_active'] = "True";
    request.fields['city'] = city;
    request.fields['state'] = state.toString();


    var response = await request.send();


    //final res = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
     // final res = await http.Response.fromStream(response);

      Fluttertoast.showToast(
          msg: "Profile Updated Successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          timeInSecForIosWeb: 1000);
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SMSMenu()),
      ).then((value){

      });
    } else {
      final res = await http.Response.fromStream(response);

      setState(() {

      });
      Fluttertoast.showToast(
          msg: json.decode(res.body)["error"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          timeInSecForIosWeb: 1000);
    }
    setState(() {
      Loading = false;
    });
  }


  Future<http.Response> getdata() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
  var token =  await prefs.getString('token');
    var accesstoken =  await prefs.getString('accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };

    var url = Uri.parse(localurlLogin + "/user/getUserAppDetails/$token");
    http.Response response = await http.get(url, headers: headers);



    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      userData = UserDetails.fromJson(responseJson);

      setState(() {
        firstname = userData.data!.firstName!;
        latname = userData.data!.lastName!;
        address1 =
        userData.data!.address1 != null ? userData.data!.address1! : null;
        address2 =
        userData.data!.address2 != null ? userData.data!.address2! : null;
        city = userData.data!.city != null ? userData.data!.city! : null;
        state = userData.data!.state != null ? userData.data!.state! : null;
        zipcode =
        userData.data!.zipcode != null ? userData.data!.zipcode! : null;
images = userData.data!.image;
      });
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });


      return response;
    }

    return response;
  }
}