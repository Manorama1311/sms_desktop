import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sms/constants/colors.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _fruits = [];
  List? filteredContacts =[];
  var items = [];
  List contact_list = [
    "(682) 220-0875",
    "(682) 110-0875",
    "(346) 528-8872",
    "(346) 658-8872",
    "(346) 528-8867",
    "(832) 725-9078",
    "(832) 625-9078",
    "(832) 795-9078",
    "(832) 725-0078"
  ];

  void _addFruit(String fruit) {
    setState(() {
      _fruits.add(fruit);
    });
  }

  void _removeFruit(String fruit) {
    setState(() {
      _fruits.remove(fruit);
    });
  }

  void filterContacts(String value) {
    setState(() {
    List  items = contact_list
          .where((item) => item.toLowerCase().contains(value.toLowerCase()))
          .toList();

      setState(() {
        filteredContacts = items;
        print(filteredContacts);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: new PreferredSize(
          child: Container(
            padding:
                new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: new Padding(
                padding:
                    const EdgeInsets.only(left: 0.0, top: 10.0, bottom: 0.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => ChatPage()),
                        // );
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    Text("Send New Message" , style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),)
                  ],
                )),
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
            60.0,
          ),
        ),
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child:
                ListView(children: [
              Text(
                'Search Contact to Message',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
                  SizedBox(
                    height: 10,
                  ),
              Wrap(
                spacing: 8.0,
                children: _fruits.map((fruit) {
                  return Chip(
                    backgroundColor: Color(0xffE3F4F4),
                    label: Text(fruit.replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "").replaceAll("-", "")),
                    onDeleted: () => _removeFruit(fruit),
                  );
                }).toList(),
              ),
              SizedBox(height: 26.0),
              SafeArea(
                child: Container(
                  child: TextFormField(
                    controller: _controller,

                    onChanged: (v) {
                   setState(() {
                     v.length < 2?filteredContacts=[]:
                     filterContacts(v);
                   });
                    },
                    onFieldSubmitted: (value) {
                      _addFruit(value);
                      _controller.clear();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search contact',
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search,color: Color(0xFF006064),),
                        onPressed: () {
                          _addFruit(_controller.text);
                          _controller.clear();
                        },
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: const BorderSide(color: Color(0xFF006064), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: const BorderSide(color: Color(0xFF006064), width:1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: const BorderSide(color:Color(0xFF006064), width: 1),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),

              filteredContacts != null
                  ? Container(
                      child: StaggeredGridView.countBuilder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          crossAxisCount: 1,
                          controller:
                              new ScrollController(keepScrollOffset: false),
                          staggeredTileBuilder: (int index) =>
                              new StaggeredTile.fit(4),
                          itemCount: filteredContacts!.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: GestureDetector(
                                  onTap: () {
                                  setState(() {
                                    _addFruit(filteredContacts![index]);
                                    _controller.clear();
                                    filteredContacts =[];
                                  });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Color(0xffE3F4F4),
                                    ),

                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 10),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  filteredContacts![index]
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),

                                            ])),
                                  )),
                            );
                          }))
                  : Container(),


            ])),


    bottomNavigationBar: Padding(
      padding: EdgeInsets.symmetric(
          vertical: height * .01, horizontal: 16),
      child: MaterialButton(
        onPressed: () async {},
        minWidth: MediaQuery.of(context).size.width,
        height: 45,
        //  padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            30.0,
          ),
        ),
        color: FzColors.btnColor,
        child: Text(
          "Send Message",
          style: TextStyle(
            fontSize: width * .05,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ) ,
    );
  }
}
