import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:google_fonts/google_fonts.dart';
import 'package:sms/constants/api_constants.dart';
import 'package:sms/screens/forgot/otp_verify.dart';
import 'package:sms/utils/constants.dart';
import 'package:toastification/toastification.dart';

import '../../constants/colors.dart';
import 'package:http/http.dart' as http;




class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var email;
  final _emailController = TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _authenticateWithEmail(context) async {
    if (validateAndSave()) {
      setState(() {
        isLoading = true;
      });
      submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FzColors.bgcolor,
      appBar: AppBar(
        elevation: 0.0,titleSpacing: 0,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff2E8A99),
        title: Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          //  color: Color(0xffb2d8d8)
          gradient: LinearGradient(
            colors: [Color(0xff2E8A99), Color(0xffE3F4F4), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          width: width * 0.4,
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Center(
                    child: Container(
                   child: Image.asset(
                        'assets/logo.png',height: 100,width: 150,fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 60.0,
                  ),
                  Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 6.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Enter emailID to get the reset link.',
                      // style: GoogleFonts.openSans(
                      //   fontSize: 14,
                      //   fontWeight: FontWeight.bold,
                      //   color: FzColors.lightText,
                      // ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: Container(
                      width: width * 0.4,
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Email",
                          // style: GoogleFonts.openSans(
                          //     fontSize: 14,
                          //     color: FzColors.lightText,
                          //     fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                    child: Container(
                      width: width * 0.4,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(14.0),
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
                          isDense: true,
                          hintText: "Enter email",
                          //filled: true,
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: FzColors.lightText,
                          ),
                        ),
                        // style: GoogleFonts.openSans(
                        //   fontSize: 14,
                        //   color: Colors.black,
                        // ),
                        //controller: emailController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@') ||
                              !value.contains('.')) {
                            return 'Email is not valid';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) {
                          setState(() {
                            email = _emailController.text;
                            _authenticateWithEmail(context);
                          });

                          // SystemChannels.textInput.invokeMethod('TextInput.hide');
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: width * 0.4,
                    child: MaterialButton(
                      onPressed: () {
                        // SystemChannels.textInput.invokeMethod('TextInput.hide');
                  _authenticateWithEmail(context);

                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => OTPVerify(_emailController.text)),
                        // );
                      },
                      minWidth: MediaQuery.of(context).size.width,
                      height: 45,
                      //  padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30.0,
                        ),
                      ),
                      color: FzColors.btnColor,
                      child: isLoading
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
                              "Submit",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<http.Response> submit() async {
    setState(() {
      isLoading = true;
    });
    var body = json.encode({
      "email": _emailController.text,
    });

    var headers = {
      'Content-Type': 'application/json',
    };

    var url = Uri.parse(localurlLogin + "/user/resetUserApp");
    http.Response response = await http.post(url, headers: headers, body: body);

    print(response.body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body)["success"];
      toastification.show(
        context: context, // optional if you use ToastificationWrapper
        title:  json.decode(response.body)["success"],
        autoCloseDuration: const Duration(seconds: 5),
        icon: const Icon(Icons.check),
        backgroundColor: Colors.green,
        padding:const EdgeInsets.only(
          bottom: 6,
          right: 6,
          left: 2,
        ),
      );



      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTPVerify(_emailController.text)),
      );
    } else {
      setState(() {
        isLoading = false;
      });



      toastification.show(
        context: context, // optional if you use ToastificationWrapper
        title: json.decode(response.body)["error"],
        autoCloseDuration: const Duration(seconds: 5),

        backgroundColor: Colors.red,
        padding:const EdgeInsets.only(
          bottom: 6,
          right: 6,
          left: 2,
        ),
      );

    }

    return response;
  }
}
