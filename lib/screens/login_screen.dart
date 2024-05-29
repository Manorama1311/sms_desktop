import 'dart:convert';
//import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:toastification/toastification.dart';

import '../utils/constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/constants/colors.dart';
import 'package:sms/screens/chatPageApiWorking.dart';
import 'package:sms/screens/forgot/forgot.dart';

import '../models/auth.dart';

import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Auth authService = Auth();

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var email;
  var password;
  var error;
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

  Future<void> _authenticateWithEmailAndPassword(context) async {
    if (validateAndSave()) {
      setState(() {
        isLoading = true;
      });
      var res = await authService.login(
          _emailController.text, _passwordController.text);
      // print("res" + res.toString());

      // var ress = await authService.getLoginUser();
      switch (res.statusCode) {
        case 200:
          var data = jsonDecode(res.body);

         // print('API Token = ' + data['data']['uuid']);
          await savePrefs(
              data['data']['uuid'],
              data['data']['accessToken'],
              data['data']['firstName'],
              data['data']['lastName'],
              data['data']["contactPhone"],data['data']["company_id"].toString(),

              data['data']["company_image"].toString()
          );
          String token = await getPrefs();

          setState(() {
            isLoading = false;
          });
         submit(data['data']);
          if (data.runtimeType == String) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //         content: Text(data),
            //         backgroundColor: Colors.red));
            break;
          }
          // print("data['error'] :: ${data?['error'] ?? ''}");
          if (data['error'] != '' && data['error'] != null) {
          //  print("error");
            var ans = data?['error'];
            setState(() {
              isLoading = false;
              error = json.decode(res.body)["error"];
            });
            toastification.show(
              context: context, // optional if you use ToastificationWrapper
              title: ans,
              autoCloseDuration: const Duration(seconds: 5),
              padding:const EdgeInsets.only(
                bottom: 6,
                right: 6,
                left: 2,
              ),
              backgroundColor: Colors.red,
            );
          } else {
            var daa = data!['data'];

            setState(() {
              isLoading = false;
              error = json.decode(res.body)["error"];
            });



          }
          break;
        case 201:

          var data = jsonDecode(res.body);

          if (data['error'] != '' && data['error'] != null) {
            var ans = data?['error'];
            setState(() {
              isLoading = false;
              error = json.decode(res.body)["error"];
            });
            toastification.show(
              context: context, // optional if you use ToastificationWrapper
              title: json.decode(res.body)["error"],
              autoCloseDuration: const Duration(seconds: 5),
              padding:const EdgeInsets.only(
                bottom: 6,
                right: 6,
                left: 2,
              ),
              backgroundColor: Colors.red,
            );
          }
          break;
        default:
          setState(() {
            isLoading = false;
            error = json.decode(res.body)["error"];
          });
          toastification.show(
            context: context, // optional if you use ToastificationWrapper
            title: json.decode(res.body)["error"],
            autoCloseDuration: const Duration(seconds: 5),

            backgroundColor: Colors.red,
            padding:const EdgeInsets.only(
              bottom: 6,
              right: 6,
              left: 2,
            ),
          );

          break;
      }
    }
  }

  var defaultponbool = true;

  Future<void> savePrefs(String token, String accessToken, String firstname,
      String lastname, String contactnumber,String companyid, String company_image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('company_id', companyid);
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('firstname', firstname);
    await prefs.setString('lastname', lastname);
    await prefs.setString('number', contactnumber);
    await prefs.setString('company_logo', company_image);
  }

  Future<String> getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token')!;
  }

  Future<String> getaccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken')!;
  }

  Future<String> getCompanyid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('company_id')!;
  }

  Future<http.Response> submit(daa) async {
    print("hgfhfghfghfhg");
   //  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
   // var fcmToken = await _fcm.getAPNSToken();
   // print(fcmToken);
    setState(() {
      isLoading = true;
    });
    var body = json.encode({
      "id": daa["uuid"],
      "is_active": true,
    //  "deviceToken":fcmToken

    });

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${daa["accessToken"]}'
    };

    var url = Uri.parse(localurlLogin + "/user/AppEditUser");
    http.Response response = await http.post(url, headers: headers, body: body);
print("hgfhfhfhfhfhfhg");
    print(response.body);
    setState(() {
      isLoading = false;
    });
    setState(() {
      Constants.user_uii =  daa["uuid"];
      Constants.companyid =  daa["company_id"].toString();
    });
    if (response.statusCode == 200) {
      toastification.show(
        context: context, // optional if you use ToastificationWrapper
        title:  "Login Successfully ${daa['firstName']} ${daa['lastName']}",
        autoCloseDuration: const Duration(seconds: 5),
        icon: const Icon(Icons.check),
        backgroundColor: Colors.green,
        padding:const EdgeInsets.only(
          bottom: 6,
          right: 6,
          left: 2,
        ),
      );



Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
        builder: (context) => ChatPage()),
        (route) => false
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
      //
      // Fluttertoast.showToast(
      //     msg: json.decode(response.body)["error"],
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     backgroundColor: Colors.red,
      //     timeInSecForIosWeb: 1000);
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;
    return Scaffold(
      key: _scaffoldKey,
      //backgroundColor: FzColors.bgcolor,
      body: GestureDetector(
        onTap: () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
        child: Container(
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
          child:


          Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  width: width * 0.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: height * .1,
                      ),
                      Center(
                        child: Container(
                          //height: width * .5,
                          child: Image.asset(
                            'assets/logo.png',
                            height: 100,
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 6.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Please fill in the form to continue',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: FzColors.lightText,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * .05,
                      ),
                      Container(
                        width: width * 0.4,
                        child: GestureDetector(
                          onTap: () {
                            // context.router.push(ForgotRouter());
                          },
                          child: Text(
                            "Email",
                            style: TextStyle(
                                fontSize: 14,
                                color: FzColors.lightText,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 6,),
                      Container(
                        width: width * 0.4,
                        child: Center(
                          child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(16.0),
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
                                hintText: "email",
                                isDense: true,
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: FzColors.lightText,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),

                              // validator: (value) =>
                              //     FzValidation.emailValidator(value),
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
                              onChanged: (value) {
                                setState(() {
                                  email = _emailController.text;
                                });
                              }),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: width * 0.4,
                        child: Text(
                          "Password",
                          style: TextStyle(
                              fontSize: 14,
                              color: FzColors.lightText,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 6,),
                      Container(
                        width: width * 0.4,
                        child:  TextFormField(
                            controller: _passwordController,
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
                              hintText: "Password",
                              isDense: true,
                              // filled: true,
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: FzColors.lightText,
                              ),
                              suffixIcon: IconButton(
                                splashColor: FzColors.lightText,
                                splashRadius: 5.0,
                                icon: Icon(
                                  // Based on passwordVisible state choose the icon
                                passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  // Update the state i.e. toogle the state of passwordVisible variable
                                  setState(() {
                                  passwordVisible =
                                        !passwordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !passwordVisible,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (input) {
                              if (input!.isEmpty) return 'Password can\'t be empty';
                              return null;
                            },
                            textInputAction: TextInputAction.go,
                            onFieldSubmitted: (value) {
                              setState(() {
                                password = _passwordController.text;
                              });
                              if (validateAndSave()) {
                                _authenticateWithEmailAndPassword(context);
                              }
                            }
                            // validator: (value) =>
                            //     FzValidation.passwordValidator(value),
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 0.0),
                        child: Container(
                          width: width * 0.4,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Forgot()),
                                );
                              },
                              child: Text(
                                "Forgot Password",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: FzColors.btnColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      error != null
                          ? Padding(
                              padding: EdgeInsets.only(top: height * .02, left: 16),
                              child: Container(
                                width: width * 0.4,
                                child: Text(
                                  error.toString(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: FzColors.errColor,
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: height * .04, horizontal: 0),
                        child: Container(
                          width: width * 0.4,
                          child: MaterialButton(
                            onPressed: () async {
                              SystemChannels.textInput.invokeMethod('TextInput.hide');
                              if (validateAndSave()) {
                                _authenticateWithEmailAndPassword(context);
                              }

                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) =>  OTPVerify("hghgfhg")),
                              // );

                              // context.router.push(UsersRouter());
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
                                   "Login",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
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
        ),
      ),
    );


  }
}
