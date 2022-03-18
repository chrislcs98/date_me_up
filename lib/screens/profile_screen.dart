import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
// import 'package:csc_picker/csc_picker.dart';

import 'package:date_me_up/validator.dart';
import 'package:date_me_up/main.dart';
import 'package:date_me_up/constants.dart';

// Firebase and Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


enum SingingCharacter { country, everywhere }
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

Future<String?> _getToken() {
  return _firebaseMessaging.getToken();
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // final User? _user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  final _msgController = TextEditingController();

  String _birthDate = "";
  bool _dateReqMsg = false;

  final Set<String> _interests = {};
  final List<Widget> _interestsWidgets = [];

  String _name = "";
  String _country = "";
  // String _cityValue = "";
  String _newInterest = "";

  late String? _minAge = "";
  late String? _maxAge = "";
  late SingingCharacter _radioValue = SingingCharacter.country;
  // late SingingCharacter _radioValue = _cityValue.isEmpty? SingingCharacter.country : SingingCharacter.city;

  // @override
  // void initState() {
  //   super.initState();
  //
  // }

  @override
  Widget build(BuildContext context) {
    // It will provide us total height and width of our screen
    Size size = MediaQuery.of(context).size;

      return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          elevation: 20,
          backgroundColor: kSecondaryColor,
          // leading: IconButton(
          //   icon: const Icon(CupertinoIcons.profile_circled),
          //   color: Colors.grey,
          //   onPressed: () {
          //     Navigator.of(context).pop(widget.filters);
          //   }
          // ),
          leading: IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.grey,
            tooltip: "Logout",
            onPressed: () {
              try {
                FirebaseAuth.instance.signOut();
              } catch (e) {
                if (kDebugMode) print("Error $e");
              }
            }
          ),
          title: const Text(
              "Complete Profile",
              style: TextStyle(color: kTextColor)
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(CupertinoIcons.check_mark_circled_solid),
              color: Colors.green,
              tooltip: "Submit",
              onPressed: ()  {
                try {
                  String deviceToken = _getToken() as String;
                  _country = _country.trim();
                  if (_formKey.currentState!.validate()) {
                    if (_birthDate.isNotEmpty) {
                      FirebaseFirestore.instance.collection("users").doc(
                          widget.user.uid).set({
                        "name": _name.trim(),
                        "location": _country,
                        "birthDate": Timestamp.fromDate(
                            DateFormat("dd/MM/yyyy").parse(_birthDate)),
                        "interests": List<String>.from(_interests),
                        "agePrefs": [_minAge ?? "", _maxAge ?? ""],
                        "locationPrefs": _radioValue == SingingCharacter.country
                            ? _country : "",
                        "deviceToken": deviceToken
                      });

                      checkIfDocExists(widget.user.uid);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyHomePage()),
                      );
                    } else {
                      _dateReqMsg = true;
                      setState(() {});
                    }
                  }
                } catch (e) {
                  if (kDebugMode) print("Error $e");
                }
              }
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _titleContainer("Personal Information *"),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: Column(
                      children: <Widget>[
                        buildTextBox("Name", TextInputType.name),
                        _titleContainer("Location", size: 16),
                        const SizedBox(height: 10),
                        // CSCPicker(
                        //   currentCountry: _countryValue.isEmpty? "Country" : _countryValue,
                        //   // currentCity: _cityValue.isEmpty? "City" : _cityValue,
                        //   showStates: false,
                        //   // showCities: true,
                        //   onCountryChanged: (value) {
                        //     setState(() {
                        //       _countryValue = value;
                        //     });
                        //   },
                        //   onStateChanged:(value) {},
                        //   onCityChanged:(value) {},
                        //   flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                        //   dropdownDecoration: BoxDecoration(
                        //     color: const Color(0xffebefff),
                        //     borderRadius: BorderRadius.circular(10),
                        //     boxShadow: const [BoxShadow(
                        //       color: Colors.black26,
                        //       offset: Offset(0, 2),
                        //     )]
                        //   ),
                        // ),
                        buildTextBox("Country", TextInputType.text),
                        buildDateBox("dd/mm/yyyy", width: 210),
                      ]
                    )
                  ),
                  const Divider(color: Colors.blueGrey, height: 20.0),
                  Row(
                    children: <Widget>[
                      _titleContainer('Interests'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        color: kTextColor,
                        tooltip: 'Clear Interests',
                        splashColor: kTextColor,
                        onPressed: () {
                          _interests.clear();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: Column(
                      children: [
                        buildInterestsBox("Interest", TextInputType.text, value: _newInterest),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 10.0,
                            runSpacing: 3.0,
                            children: getInterestsWidgets(),
                          )
                        )
                      ],
                    ),
                  ),
                  const Divider(color: Colors.blueGrey, height: 20.0),
                  Row(
                    children: <Widget>[
                      _titleContainer('Preferences'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        color: kTextColor,
                        tooltip: 'Clear Preferences',
                        splashColor: kTextColor,
                        onPressed: () {
                          _minAge = "";
                          _maxAge = "";
                          _radioValue = SingingCharacter.country;
                          // _radioValue = _cityValue.isEmpty? SingingCharacter.country : SingingCharacter.city;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: Column(
                      children: [
                        buildAge(),
                        _titleContainer("Location", size: 16),
                        // _cityValue.isNotEmpty? Align(
                        //   alignment: Alignment.centerLeft,
                        //   child: SizedBox(
                        //     width: 230,
                        //     child: ListTile(
                        //       title: Text(
                        //         _cityValue,
                        //         style: const TextStyle(color: kTextColor),
                        //       ),
                        //       leading: Radio(
                        //         value: SingingCharacter.city,
                        //         groupValue: _radioValue,
                        //         onChanged: (SingingCharacter? value) {
                        //           setState(() { _radioValue = value!;});
                        //         },
                        //       ),
                        //     ),
                        //   ),
                        // ) : Container(),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 230,
                              child: ListTile(
                                title: Text(
                                  _country.isEmpty ? "My Country" : _country,
                                  style: const TextStyle(color: kTextColor),
                                ),
                                leading: Radio(
                                  value: SingingCharacter.country,
                                  groupValue: _radioValue,
                                  onChanged: (SingingCharacter? value) {
                                    setState(() { _radioValue = value!; });
                                  },
                                ),
                              ),
                            )
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 230,
                              child: ListTile(
                                  title: const Text(
                                    'Everywhere',
                                    style: TextStyle(color: kTextColor),
                                  ),
                                  leading: Radio(
                                    value: SingingCharacter.everywhere,
                                    groupValue: _radioValue,
                                    onChanged: (SingingCharacter? value) {
                                      setState(() { _radioValue = value!; });
                                    },
                                  ),
                                  trailing: const Icon(CupertinoIcons.globe, color: kTextColor)
                              ),
                            )
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
  }

  // Future<bool> _onBackPressed() {
  //   Navigator.of(context).pop(widget.filters);
  //   return null;
  // }

  Widget buildTextBox(String name, TextInputType type, {String value = "", double? width}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        type == TextInputType.name?
        _titleContainer(name, size: 16) : Container(),
        const SizedBox(height: 10),
        Container(
          width: width,
          height: 60,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xffebefff),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
            )]
          ),
          child: TextFormField(
            initialValue: value,
            keyboardType: type,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 20),
              hintText: name,
              hintStyle: const TextStyle(color: Colors.black38)
            ),
            onChanged: (value) {
              if (type == TextInputType.name) _name = value;
              if (type == TextInputType.text) _country = value;
            },
            autocorrect: false,
            validator: (value) => Validator.validateText(text: value, name: name)
          ),
        ),
        const SizedBox(height: 10)
      ],
    );
  }

  Widget buildDateBox(String value, {double? width}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleContainer("Birth Date", size: 16),
        const SizedBox(height: 10),
        Container(
          width: width,
          height: 60,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: const Color(0xffebefff),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
              )]
          ),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              elevation: MaterialStateProperty.all(0),
            ),
            onPressed: openCalendar,
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xff4c5166)),
                // IconButton(
                //   icon: const Icon(Icons.calendar_today, color: Color(0xff4c5166)),
                //   tooltip: 'Open Calendar',
                //   splashColor: kTextColor,
                //   onPressed: openCalendar,
                // ),
                const Spacer(),
                Text(
                  _birthDate.isNotEmpty? _birthDate : value,
                  style: TextStyle(
                    fontSize: 16,
                    color: getDateColor()
                  )
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.clear),
                  color: Colors.black,
                  tooltip: 'Clear Date',
                  splashColor: kTextColor,
                  onPressed: () {
                    _birthDate = "";
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10)
      ],
    );
  }

Color getDateColor() {
  if (_birthDate.isNotEmpty) {
    return Colors.black;
  } else if (_dateReqMsg) {
    return Colors.red;
  } else {
    return Colors.grey;
  }
}

  Widget buildInterestsBox(String name, TextInputType type, {String value = "", double? width}) {
    _msgController.text = value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Container(
          width: width,
          height: 60,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: const Color(0xffebefff),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
              )]
          ),
          child: TextFormField(
            controller: _msgController,
            onFieldSubmitted: (value) {
              if (_newInterest.isNotEmpty) {
                _interests.add(_newInterest.trim());
                // _msgController.clear();
                _newInterest = "";
                setState(() {});
              }
            },
            keyboardType: type,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14, left: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_rounded),
                // color: Colors.black,
                iconSize: 30,
                tooltip: 'Add Interest',
                splashColor: kTextColor,
                onPressed: () {
                  if (_newInterest.isNotEmpty) {
                    _interests.add(_newInterest.trim());
                    // _msgController.clear();
                    _newInterest = "";
                    setState(() {});
                  }
                },
              ),
              hintText: name,
              hintStyle: const TextStyle(color: Colors.black38)
            ),
            onChanged: (value) {
              _newInterest = value;
            },
            autocorrect: false,
          ),
        ),
        const SizedBox(height: 10)
      ],
    );
  }

  Widget buildAge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleContainer("Age", size: 16),
        const SizedBox(height: 10),
        Row(
            children: [
              Container(
                width: 100,
                height: 60,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                    color: const Color(0xffebefff),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                    )]
                ),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 15),
                    hintText: 'Min',
                    hintStyle: TextStyle(color: Colors.black38)
                  ),
                  onChanged: (value) {
                    _minAge = value;
                  },
                  autocorrect: false,
                  validator: (value) => Validator.validateAge(age: value)
                ),
              ),
              Container(
                width: 30,
                alignment: Alignment.center,
                child: const Text(
                  "—",
                  style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                  width: 100,
                  height: 60,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: const Color(0xffebefff),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                      )]
                  ),
                  child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 15),
                          hintText: 'Max',
                          hintStyle: TextStyle(color: Colors.black38)
                      ),
                      onChanged: (value) {
                        _maxAge = value;
                      },
                      autocorrect: false,
                      validator: (value) => Validator.validateAge(age: value, minAge: _minAge)
                  )
              )
            ]
        ),
        const SizedBox(height: 10)
      ],
    );
  }

  void openCalendar() async {
    var date = DateTime.now();
    date = DateTime(date.year-18, date.month, date.day);
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(date.year-150, date.month, date.day),
      lastDate: date,
    );
    _birthDate = DateFormat("dd/MM/yyyy").format(d!);
    setState(() {});
  }

  List<Widget> getInterestsWidgets()
  {
    _interestsWidgets.clear();
    _interests.forEach((e) {
      _interestsWidgets.add(_interestsChip(e));
    });

    return _interestsWidgets;
  }

  Widget _interestsChip(String chipName) {
    return InputChip(
      label: Text(chipName),
      labelStyle: const TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.bold),
      onDeleted: (){
        setState(() {_interests.remove(chipName);});
      },
    );
  }
}

Widget _titleContainer(String myTitle, {double leftPadding = 0, double size = 24}) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, 15, 5, 5),
      child: Text(
        myTitle,
        style: TextStyle(
            color: kTextColor, fontSize: size, fontWeight: FontWeight.bold),
      ),
    ),
  );
}