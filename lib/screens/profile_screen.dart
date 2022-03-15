import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:csc_picker/csc_picker.dart';

import '../validator.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

enum SingingCharacter { city, country, everywhere }

class _ProfileScreenState extends State<ProfileScreen> {
  String _dateSelected = "";
  List<Widget> interestsWidgets = <Widget>[];

  String _name = "";
  String _countryValue = "";
  String? _cityValue = "";
  String _newInterest = "";

  late String? _minAge;
  late String? _maxAge;
  late SingingCharacter _radioValue = SingingCharacter.city;


  Widget buildTextBox(String name, TextInputType type, {String value = "", double? width}) {
    var msgController = TextEditingController();
    msgController.text = value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        type != TextInputType.text?
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
              controller: msgController,
              onFieldSubmitted: (value) {
                if (_newInterest.isNotEmpty) {
                  interestsWidgets.add(_interestsChip(value));
                  // msgController.clear();
                  _newInterest = "";
                  setState(() {});
                }
              },
              keyboardType: type,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 14, left: 20),
                suffixIcon: type == TextInputType.text? IconButton(
                  icon: const Icon(Icons.add_circle_rounded),
                  // color: Colors.black,
                  iconSize: 30,
                  tooltip: 'Add Interest',
                  splashColor: Colors.blue[700],
                  onPressed: () {
                    if (_newInterest.isNotEmpty) {
                      interestsWidgets.add(_interestsChip(_newInterest));
                      // msgController.clear();
                      _newInterest = "";
                      setState(() {});
                    }
                  },
                ) : null,
                hintText: name,
                hintStyle: const TextStyle(color: Colors.black38)
              ),
              onChanged: (value) {
                if (type == TextInputType.name) _name = value;
                if (type == TextInputType.text) _newInterest = value;
              },
              autocorrect: false,
              validator: (value) => Validator.validateText(text: value, name: name)
          ),
        ),
        const SizedBox(height: 10)
      ],
    );
  }

  Widget buildDateBox(String name, {double? width}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleContainer("Birth Date", size: 16),
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
            initialValue: _dateSelected,
            keyboardType: TextInputType.datetime,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14, left: 20),
              prefixIcon: IconButton(
                icon: const Icon(Icons.calendar_today, color: Color(0xff4c5166)),
                tooltip: 'Open Calendar',
                splashColor: Colors.blue[700],
                onPressed: openCalendar,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear Date',
                splashColor: Colors.blue[700],
                onPressed: () {
                  _dateSelected = "";
                  setState(() {});
                },
              ),
              hintText: name,
              hintStyle: const TextStyle(color: Colors.black38)
            ),
            onChanged: (value) {
              _dateSelected = value;
            },
            autocorrect: false,
            // validator: (value) => Validator.validateDate(text: value, name: name)
          ),
        ),
        const SizedBox(height: 10),

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
                  contentPadding: EdgeInsets.only(top: 14, left: 15),
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
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                    contentPadding: EdgeInsets.only(top: 14, left: 15),
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

  @override
  Widget build(BuildContext context) {
    // It will provide us total height and width of our screen
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        leading: const Icon(CupertinoIcons.profile_circled, color: Colors.grey),
        title: const Text("Complete Profile", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(CupertinoIcons.check_mark, color: Colors.green),
            onPressed: () {
            }
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: Column(
            children: <Widget>[
              _titleContainer("Personal Information"),
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: Column(
                  children: <Widget>[
                    buildTextBox("Name", TextInputType.name),
                    const SizedBox(height: 20),
                    _titleContainer("Location", size: 16),
                    CSCPicker(
                      onCountryChanged: (value) {
                        setState(() {
                          _countryValue = value;
                        });
                      },
                      onCityChanged:(value) {
                        setState(() {
                          _cityValue = value;
                        });
                      },
                      flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                      showStates: false,
                      // showCities: true
                    ),
                    buildDateBox("dd/mm/yy", width: 200),
                  ]
                )
              ),
              const Divider(color: Colors.blueGrey, height: 10.0),
              Row(
                children: <Widget>[
                  _titleContainer('Interests'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear Interests',
                    splashColor: Colors.blue[700],
                    onPressed: () {
                      interestsWidgets.clear();
                      setState(() {});
                    },
                  ),
                ],
              ),
              Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: buildTextBox("Interest", TextInputType.text, value: _newInterest),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 10.0,
                        runSpacing: 3.0,
                        children: interestsWidgets,
                        // children: getInterestsWidgets(),
                      )
                  ),
                ),
              ),
              const Divider(color: Colors.blueGrey, height: 20.0),
              Row(
                children: <Widget>[
                  _titleContainer('Preferences'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear Preferences',
                    splashColor: Colors.blue[700],
                    onPressed: () {
                      _minAge = null;
                      _maxAge = null;
                      _radioValue = SingingCharacter.city;
                    },
                  ),
                ],
              ),
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: Padding(
              //     padding: const EdgeInsets.fromLTRB(25, 15, 5, 5),
              //     child:
              //   ),
              // ),
              buildAge(),
              const Divider(color: Colors.blueGrey, height: 10.0),
              const Text(
                "Location",
                style: TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        _cityValue != null?
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 230,
                            child: ListTile(
                              title: Text(_cityValue!),
                              leading: Radio(
                                value: SingingCharacter.city,
                                groupValue: _radioValue,
                                onChanged: (SingingCharacter? value) {
                                  setState(() { _radioValue = value!;});
                                },
                              ),
                            ),
                          ),
                        ) : Container(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 230,
                            child: ListTile(
                              title: Text(_countryValue),
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
                              title: const Text('Everywhere'),
                              leading: Radio(
                                value: SingingCharacter.everywhere,
                                groupValue: _radioValue,
                                onChanged: (SingingCharacter? value) {
                                  setState(() { _radioValue = value!; });
                                },
                              ),
                              trailing: const Icon(CupertinoIcons.globe)
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    _dateSelected = DateFormat("dd/MM/yy").format(d!);
    setState(() {});
  }

  // List<Widget> getInterestsWidgets()
  // {
  //   interestsWidgets.clear();
  //   datesSelected.forEach((date) {
  //     interestsWidgets.add(_interestsChip(date));
  //   });
  //
  //   return interestsWidgets;
  // }

  Widget _interestsChip(String chipName) {
    return InputChip(
      label: Text(chipName),
      labelStyle: const TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.bold),
      onDeleted: (){
        setState(() {interestsWidgets.remove(this);});
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
            color: Colors.black, fontSize: size, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
