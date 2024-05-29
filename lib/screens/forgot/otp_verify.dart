import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sms/screens/forgot/set_password.dart';
import 'package:sms/utils/constants.dart';
import 'package:toastification/toastification.dart';
import '../../constants/api_constants.dart';
import '../../constants/colors.dart';
import 'package:http/http.dart' as http;


class OTPVerify extends StatefulWidget {
   OTPVerify(this.email);
var email;
  @override
  State<OTPVerify> createState() => _OTPVerifyState();
}

class _OTPVerifyState extends State<OTPVerify> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController otpController = TextEditingController();
var otp;
  bool isLoading = false;

  int _counter = 0;
  AnimationController ?controller;

  Duration get duration => controller!.duration! * controller!.value;

  bool get expired => duration.inSeconds == 0;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    );
    setState(() {

      controller!.reverse(from: 1).then((value){
        setState(() {

        });
      });
    });
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
        title: Text("OTP Verify",style: TextStyle(color: Colors.white),),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height ,
        width: MediaQuery.of(context).size.width ,
        decoration: const BoxDecoration(
          //  color: Color(0xffb2d8d8)
          gradient: LinearGradient(
            colors: [Color(0xff2E8A99),Color(0xffE3F4F4),Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:  Container(
          width: width * 0.4,
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
                Container(
                  width: width * 0.4,
                  child: Text(
                    'OTP Verify',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(
                  height: 6.0,
                ),
                Container(
                  width: width * 0.4,
                  child: Text(
                    'Enter OTP  (One Time Password) for emailid verification',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: FzColors.lightText,
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Container(
                    width: width * 0.4,
                    child: Text(
                      "OTP",
                      style: TextStyle(
                          fontSize: 14,
                          color: FzColors.lightText,fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 6),
                  child: Container(
                    width: width * 0.4,
                    child:TextFormField(
                      controller: otpController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
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
                        hintText: "Enter OTP",
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

                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (input) {
                        if (input!.isEmpty) return 'OTP Field can\'t be empty';
                        return null;
                      },
                      textInputAction: TextInputAction.go,
                      onFieldSubmitted: (value) {
                        setState(() {
                          otp = otpController.text;
                          _authenticateWithEmail(context);
                        });
                        // SystemChannels.textInput.invokeMethod('TextInput.hide');

                      },
                    ),
                  ),
                ),
                SizedBox(height: 30,),




                Container(
                  width: width * 0.4,
                  child: MaterialButton(
                    onPressed: () {
                     // SystemChannels.textInput.invokeMethod('TextInput.hide');
                     _authenticateWithEmail(context);

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => SetForgotPassword(widget.email)),
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
                    child: isLoading?Center(child: Container(
                      height: 35,width: 35,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )):Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                duration.inSeconds != 0?
                Container(
                  width: width * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Didn't receive the code? resend after ",
                            style: TextStyle(
                                fontSize: 14,
                                color: FzColors.btnColor,fontWeight: FontWeight.bold
                            ),
                          ),
                          Row(
                            children: [
                              AnimatedBuilder(
                                  animation: controller!,
                                  builder: (BuildContext context, Widget ?child) {
                                    return new Text(
                                      '${duration.inSeconds}',
                                      style:TextStyle(
                                          fontSize: 18,
                                          color: FzColors.btnColor,fontWeight: FontWeight.bold
                                      ),
                                    );
                                  }),
                              Text(" seconds",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: FzColors.btnColor,fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),



                    ],
                  ),
                ):
                GestureDetector(
                  onTap: (){
                    clearresend();
                  },
                  child: Container(
                    width: width * 0.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Resend",
                          style: TextStyle(
                          fontSize: 14,
                            color: FzColors.btnColor,fontWeight: FontWeight.bold
                        ),
                        ),


                      ],
                    ),
                  ),
                )

              ],
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
    var body = json.encode(

        {

          "email":widget.email,
          "otp":otpController.text



        });


    var headers = {
      'Content-Type': 'application/json',
    };
    var url = Uri.parse(localurlLogin+"/user/resetUserApp");
    http.Response response = await http.post(url,headers: headers, body: body);

    print(response.body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final responseJson =
      json.decode(response.body)["success"];
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
        MaterialPageRoute(builder: (context) => SetForgotPassword(widget.email)),
      );


    } else {
      setState(() {
        otp;
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


  Future<http.Response> clearresend() async {


    var headers = {
      'Content-Type': 'application/json',
    };

    var url = Uri.parse(localurlLogin+"/user/otpEmailexpire/${widget.email}");
    http.Response response = await http.get(url,headers: headers);

    print(response.body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
     resend();





    } else {

      setState(() {
        otp;
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

  Future<http.Response> resend() async {
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    );
    setState(() {

      controller!.reverse(from: 1).then((value){
        setState(() {

        });
      });
    });

    var body = json.encode(

        {

          "email":widget.email,



        });

    var headers = {
      'Content-Type': 'application/json',
    };

    var url = Uri.parse(localurlLogin+"/user/resetUserApp");
    http.Response response = await http.post(url,headers: headers, body: body);

    print(response.body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final responseJson =
      json.decode(response.body)["success"];
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





    } else {
      setState(() {
        otp;
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
