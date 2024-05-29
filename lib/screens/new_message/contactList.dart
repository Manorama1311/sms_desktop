
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:sms/models/chat.dart';
import 'package:sms/screens/new_message/new_chatWindow.dart';
import 'package:sms/utils/constants.dart';


class ContactList extends StatefulWidget {
  final bool isMultiSelection;
List userLists;
  UserDetails userDetails;
  ContactList({
    Key ?key,
    this.isMultiSelection = false, required this.userLists, required this.userDetails,

  }) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  String text = '';
  List selectedCountries = [];
  bool isNative = false;
var allCountries;
var countries;
  @override
  void initState() {
    super.initState();

  }

  bool containsSearchText( country) {
    final name = isNative ? country["contact"]:country["contact"];
    final textLower = text;
    final countryLower = name;

    return countryLower.contains(textLower);
  }

  List getPrioritizedCountries(countries) {
    final notSelectedCountries = List.of(countries)
      ..removeWhere((country) => selectedCountries.contains(country));

    return [
      ...List.of(selectedCountries),
      ...notSelectedCountries,
    ];
  }
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).primaryColor;
    allCountries = getPrioritizedCountries(widget.userLists);
    countries = allCountries.where(containsSearchText).toList();


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
          'Send New Message',
          style: TextStyle(

            color: Colors.white,
          ),
        ),

      ),
      body: ListView(
        children: <Widget>[
          selectedCountries.length!=0?
          SizedBox(
            height: 20,
          ):Container(),
          // selectedCountries.length!=0?
          // Padding(
          //   padding: const EdgeInsets.all(10.0),
          //   child: Text(
          //     'Selected Contacts',
          //     style: TextStyle(
          //       fontSize: 16,
          //
          //       color: Colors.black,
          //     ),
          //   ),
          // ):Container(),
          StaggeredGridView.countBuilder(
              controller: ScrollController(keepScrollOffset: false),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              crossAxisCount: 3,mainAxisSpacing: 10,
              staggeredTileBuilder: (int index) =>
                  StaggeredTile.fit(1),
              itemCount: selectedCountries.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Color(0xFFB0E0E6)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: selectedCountries[index]['firstName']== null?

                            Text(selectedCountries[index]['contact'].toString()): Text(selectedCountries[index]['firstName'].toString()+" "+ selectedCountries[index]['lastName'].toString()),
                          ))
                    ],
                  ),
                );
              }


          ),
          SizedBox(
            height: 10,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) {
                    setState(() {
                      text = v;
                      this.text = v;
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
text = "";
                          // allCountries = getPrioritizedCountries(widget.userLists);
                          // countries = allCountries.where(containsSearchText).toList();
                        });
                      },
                    ),
                    // Add a search icon or button to the search bar
                    prefixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          text = _searchController.text;
                          this.text = text;
                        });
                      },
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: const BorderSide(
                          color: Color(0xFF006064), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: const BorderSide(
                          color: Color(0xFF006064), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: const BorderSide(
                          color: Color(0xFF006064), width: 1),
                    ),
                  ),
                ),
              ),
            ),
          ),





          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Top Contacts',
              style: TextStyle(
                fontSize: 16,

                color: Colors.black,
              ),
            ),
          ),


        StaggeredGridView.countBuilder(
            controller: ScrollController(keepScrollOffset: false),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            crossAxisCount: 1,
            staggeredTileBuilder: (int index) =>
                StaggeredTile.fit(4),
            itemCount: countries.length,
            scrollDirection: Axis.vertical,mainAxisSpacing: 10,
            itemBuilder: (BuildContext context, int index) {
              final isSelected = selectedCountries.contains(countries[index]);

                    return
                      ListTile(
                      onTap: () {

                        selectCountry1(countries[index]);
                      },
                      //leading: FlagWidget(code: country.code),
                      title:

                      Row(
                        children: [

                          countries[index]["image"] != ""
                              ? CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: countries[index]["image"]!=""
                                ?localurlLogin +countries[index]["image"]!
                                : 'https://appprivacy.messaging.care/media/blank.png',
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
                              countries[index]["firstName"]!=""? Container(
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
                                    color: countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="A"?
                                    Color(0xFFFF0000):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="B"?
                                    Color(0xFF2b2b40):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="D"?
                                    Color(0xFF50cd89):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="E"?
                                    Color(0xFFe033c3):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="F"?
                                    Color(0xFF00FFFF):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="G"?
                                    Color(0xFF800000):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="H"?
                                    Color(0xFF008000):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="I"?
                                    Color(0xFF000080):
                                    countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="J"?
                                    Color(0xFF808000):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="K"?
                                    Color(0xFF800080):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="L"?
                                    Color(0xFF008080):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="M"?
                                    Color(0xFFa24c7d):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="N"?
                                    Color(0xFF613f3f):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="O"?
                                    Color(0xFFFFA500):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="P"?
                                    Color(0xFFb96969):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="Q"?
                                    Color(0xFF7e00e3):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="R"?
                                    Color(0xFFf1416c):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="S"?
                                    Color(0xFFff4a00):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="T"?
                                    Color(0xFF87CEEB):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="U"?
                                    Color(0xFF9370DB):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="V"?
                                    Color(0xFFFF1493):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="W"?
                                    Color(0xFF48D1CC):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="X"?
                                    Color(0xFF20B2AA):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="Y"?
                                    Color(0xFFB0E0E6):countries[index]["firstName"].toString().substring(0,1).toUpperCase()=="Z"?
                                    Color(0xFFdf8fdf):Color(0xFF0072ff)
                                ),
                                child: Center(child: Text(countries[index]["firstName"].toString().substring(0,1).toUpperCase()+""+
                                    countries[index]["lastName"].toString().replaceAll("(", "").replaceAll(")", "").substring(0,1).toUpperCase(),
                                  style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),
                                ),


                                ),


                              ),

                            ],
                          ),



                          SizedBox(
                            width: 20,
                          ),


                          Container(
                            color: Colors.transparent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                countries[index]["firstName"]==null
                                    ? Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Container(
                                    width: 220,
                                    child: Text(
                                      countries[index]["contact"].toString().replaceAll("]", "").replaceAll("[", ""),
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight:
                                          FontWeight.w500),
                                    ),
                                  ),
                                )
                                    : Text(
                                  countries[index]["firstName"].toString(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight:
                                      FontWeight.w500),
                                ),
                                countries[index]["firstName"]==null
                                    ?
                                Container() : SizedBox(height: 6,),
                                countries[index]["firstName"]==null
                                    ?Text(" "):

                                Text(
                                  countries[index]["contact"].toString().replaceAll("]", "").replaceAll("[", ""),
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      fontWeight:
                                      FontWeight.w400),
                                )

                              ],
                            ),
                          ),
                        ],
                      ),

                      // Text(
                      //   countries[index]['contact'],
                      //   style: isSelected? TextStyle(
                      //     fontSize: 18,
                      //     color: selectedColor,
                      //     fontWeight: FontWeight.bold,
                      //   )
                      //       : TextStyle(fontSize: 18),
                      // ),
                      trailing:
                      isSelected ? Icon(Icons.check, color: selectedColor, size: 26) : null,
                    );
            }
        )
          // Expanded(
          //   child: ListView(
          //     children: countries.map((country) {
          //       final isSelected = selectedCountries.contains(country);
          //
          //       return ListTile(
          //         onTap: () {
          //
          //           selectCountry1(country);
          //         },
          //         //leading: FlagWidget(code: country.code),
          //         title: Text(
          //           country['contact'],
          //           style: isSelected? TextStyle(
          //             fontSize: 18,
          //             color: selectedColor,
          //             fontWeight: FontWeight.bold,
          //           )
          //               : TextStyle(fontSize: 18),
          //         ),
          //         trailing:
          //         isSelected ? Icon(Icons.check, color: selectedColor, size: 26) : null,
          //       );
          //
          //     }).toList(),
          //   ),
          // ),



        ],
      ),
      bottomNavigationBar:  selectedCountries.length!=0?
      GestureDetector(
        onTap: (){

          Navigator.pop(context);

          // Navigator.of(context)
          //     .push(
          //   MaterialPageRoute(
          //     builder: (context) => NewChatWindow(room: "${widget.userDetails.data!.contactPhone.toString()
          //         .replaceAll("(", "")
          //         .replaceAll(")", "")
          //         .replaceAll("-", "")
          //         .replaceAll(" ", "")}${selectedCountries[0]["contact"].toString()
          //         .replaceAll("(", "")
          //         .replaceAll(")", "")
          //         .replaceAll("-", "")
          //         .replaceAll(" ", "")}",contact:selectedCountries[0]["contact"],firstName:selectedCountries[0]["firstName"],lastName:selectedCountries[0]["lastName"],image:selectedCountries[0]["image"]),
          //   ),
          // );
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 6),
                  child: Center(child: Text("Done",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),)),
                )
              ],
            ),
          ),
        ),
      ):Container(  height: 3,),


    );
  }



  Widget buildSelectButton(BuildContext context) {
    final label = widget.isMultiSelection
        ? 'Select ${selectedCountries.length} Countries'
        : 'Continue';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      color: Theme.of(context).primaryColor,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          minimumSize: Size.fromHeight(40),
          primary: Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        onPressed: submit,
      ),
    );
  }


  void selectCountry1(country) {
    if (widget.isMultiSelection) {
      final isSelected = selectedCountries.contains(country);
      print(isSelected);
      print(country);

      setState(() => isSelected
          ? selectedCountries.remove(country)
          : selectedCountries.add(country));
    } else {
      Navigator.pop(context, country);
    }
  }
  void submit() => Navigator.pop(context, selectedCountries);
}

