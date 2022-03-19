import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:date_me_up/constants.dart';
import 'package:date_me_up/user_data.dart';

// Firebase and Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedTab = 0;
  final List<Widget> _interestsWidgets = [];
  late final UserData _userData;
  final List<UserData> _Users = [];
  final List<UserData> _MatchedUsers = [];
  final List<Map<String, dynamic>> _Matches = [];
  int _idx = 0;
  int _midx = 0;
  bool _endListUsers = false;

  @override
  void initState() {
    super.initState();
    getUserData(widget.user);
  }

  UserData? assignUserData(id, Map<String, dynamic>? data) {
    if (data != null) {
      return UserData(
        id: id,
        name: data['name'],
        location: data['location'],
        birthDate: data['birthDate'].toDate(),
        age: calculateAge(data['birthDate'].toDate()),
        agePrefs: data['agePrefs'],
        locationPrefs: data['locationPrefs'],
        interests: data['interests'],
        image: data['image']
      );
    }
    return null;
  }

  Future<void> getUserData(User user) async {
    // UserData? userData;

    await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get()
      .then((doc) {
      _userData = assignUserData(doc.id, doc.data())!;
    });

    if (kDebugMode) print("Me: " + _userData.name);
    getMatches(_userData);
    // return userData;
  }

  Future<void> getMatches(UserData userData) async {
    _Matches.clear();
    Map<String, dynamic> data;

    await FirebaseFirestore.instance.collection('matches')
      .where('senderUId', isEqualTo: userData.id)
      .get()
      .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          data = doc.data();
          data['id'] = doc.id;

          _Matches.add(data);
        });
    });

    getPeople(userData: userData);
  }

  Future<void> getPeople({UserData? userData}) async {
    _Users.clear();
    late UserData? tmpUser;
    bool commonInterest = false;
    List<String> receiverIdMatches = [ for (var el in _Matches) el['receiverUId'] ];

    await FirebaseFirestore.instance.collection('users')
      // .orderBy('name')
      // .limit(10)
      // .startAfterDocument(documentSnapshot)
      .where('__name__', isNotEqualTo: _userData.id)
      .get()
      .then((querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          // if (kDebugMode) print(doc.data()["name"]);
          // if (kDebugMode) print(doc.data());

          tmpUser = assignUserData(doc.id, doc.data());
          if (tmpUser != null) {
            if (userData == null) {
              _Users.add(tmpUser!);
            } else {
              if (!receiverIdMatches.contains(tmpUser?.id)) {
                bool condLoc = userData.locationPrefs!.isEmpty ? true
                    : (userData.locationPrefs?.toLowerCase().compareTo(
                    tmpUser!.location.toLowerCase()) == 0);
                if (condLoc) {
                  // tmpUser!.age = calculateAge(tmpUser!.birthDate);
                  bool condAge1 = userData.agePrefs![0].isEmpty ? true : (tmpUser!.age! >= int.parse(userData.agePrefs![0]));
                  bool condAge2 = userData.agePrefs![1].isEmpty ? true : (tmpUser!.age! <= int.parse(userData.agePrefs![1]));

                  if (condAge1 && condAge2) {
                    commonInterest = false;
                    if ((userData.interests!.isNotEmpty && tmpUser!.interests!.isNotEmpty) &&
                        ((userData.interests != null) && (tmpUser!.interests != null))) {

                      try {
                        tmpUser?.interests?.forEach((el) {
                          if (userData.interests!.contains(el)) {
                            commonInterest = true;
                            throw '';
                          }
                        });
                      } catch (e) {}
                    } else {
                      commonInterest = true;
                    }

                    if (commonInterest) {
                      _Users.add(tmpUser!);
                      if (_Users.length == 1) setState(() {});
                    }
                  }
                }
              } else {
                _MatchedUsers.add(tmpUser!);
                if (_MatchedUsers.length == 1) setState(() {});
              }
            }
          }
        })
    });
    // setState(() {});
  }

  int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  Future<void> addOrRemoveMatch() async {
    if (_selectedTab == 0) {
      var data = {
        "senderUId": _userData.id,
        "receiverUId": _Users[_idx].id,
        "twoWays": true    // True because in this case we assume there only matches with mock users which are accepted immediately
      };

      await FirebaseFirestore.instance.collection('matches')
        .add(data)
        .then((value) {
          if (kDebugMode) print("Match Added!");
          _MatchedUsers.add(_Users[_idx]);
          _midx = _MatchedUsers.length - 1;
          _Users.removeAt(_idx);
          if (_Users.length == _idx) {
            _idx = 0;
            _endListUsers = true;
          }

          _Matches.add(data);
        })
        .catchError((error) { if (kDebugMode) print("Failed to add user: $error"); });
    } else {
      int idx = _Matches.indexWhere((el)  {
        if ((el['receiverUId'] == _MatchedUsers[_midx].id) && (el['senderUId'] == _userData.id)) return true;
        return false;
      });

      await FirebaseFirestore.instance.collection('matches').doc(_Matches[idx]['id'])
        .delete()
        .then((v) {
          if (kDebugMode) print("Match Deleted!");
          _Users.add(_MatchedUsers[_midx]);
          _MatchedUsers.removeAt(_midx);
          if (_MatchedUsers.length == _midx) _midx = 0;
        })
        .catchError((error) { if (kDebugMode) print("Failed to delete match: $error"); });
    }

    setState(() {});
  }

  void _onItemTapped(int index) {
    _selectedTab = index;
    _endListUsers = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // It will provide us total height and width of our screen
    // Size size = MediaQuery.of(context).size;

    UserData? user;
    if (_selectedTab == 0) {
      user = _Users.isNotEmpty ? _Users[_idx] : null;
    } else {
      user = _MatchedUsers.isNotEmpty ? _MatchedUsers[_midx] : null;
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 20,
        backgroundColor: kPrimaryColor,
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
        title: Row(
          children: [
            const SizedBox(width: 50),
            SizedBox(
              width: 180,
              child: Tooltip(
                message: "https://www.designevo.com/",
                preferBelow: true,
                waitDuration: const Duration(milliseconds: 2000),
                child: Image.asset(
                  "assets/images/horizontal_logo.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ]
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            iconSize: 30,
            color: Colors.grey,
            tooltip: "Refresh",
            onPressed: () {
              getMatches(_userData);
              setState(() {});
            }
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedTab,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded, size: 30), label: "Home"),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/logo.png", width: 30), label: "Matches")
        ]
      ),
      body: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: (user == null || (_endListUsers && _selectedTab == 0)) ?
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedTab == 0 ? "No more users available yet..." : "No matches",
                  style: const TextStyle(color: kTextColor, fontSize: 24)
                ),
                user != null ? const SizedBox(height: 50) : Container(),
                user != null ? Tooltip(
                  message: "Refresh from the start",
                  preferBelow: true,
                  child: ActionIcon(
                    icon: Icons.refresh,
                    color: Colors.white,
                    onPress: () {
                      setState(() {
                        _endListUsers = false;
                      });
                    },
                  ),
                ) : Container(),
              ],
            )
            : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: _getImage(user),
                  fit: BoxFit.cover
                )
              ),
              child: Column(
                mainAxisAlignment: _selectedTab == 1 ? MainAxisAlignment.start : MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _selectedTab == 0 ? Container()
                  : Center(
                    child: Chip(
                      backgroundColor: kSecondaryColor.withOpacity(0.8),
                      elevation: 3,
                      label: const Text("  It's a match!  "),
                      labelStyle: GoogleFonts.lobster(fontSize: 26, color: kTextColor)
                    )
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: kTextColor
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              user.age?.toString() ?? "",
                              style: const TextStyle(
                                  fontSize: 24,
                                  color: kTextColor
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: kSecondaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              user.location,
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: kTextColor
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 3.0,
                          children: getInterestsWidgets(user.interests)
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            (_selectedTab == 1 && _MatchedUsers.length == 1) ? Container() : const Spacer(),
                            (_selectedTab == 1 && _MatchedUsers.length == 1) ? Container()
                            : ActionIcon(
                              icon: Icons.refresh,
                              color: Colors.white,
                              onPress: () {
                                if (_selectedTab == 0) {
                                  _idx++;
                                  if (_Users.length == _idx) {
                                    _idx = 0;
                                    _endListUsers = true;
                                  }
                                } else {
                                  _midx++;
                                  if (_MatchedUsers.length == _midx) _midx = 0;
                                }
                                setState(() {});
                              },
                            ),
                            const Spacer(),
                            ActionIcon(
                              icon: CupertinoIcons.heart_fill,
                              color: _selectedTab == 0 ? Colors.white70 : Colors.red,
                              borderColor: Colors.red,
                              onPress: () {
                                addOrRemoveMatch();
                              },
                            ),
                            const Spacer()
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),

            ),
        ),
      )

    );
  }

  // Future<bool> _onBackPressed() {
  //   Navigator.of(context).pop(widget.filters);
  //   return null;
  // }

  List<Widget> getInterestsWidgets(List<dynamic>? interests)
  {
    _interestsWidgets.clear();
    if (interests == null) return _interestsWidgets;

    for (var el in interests) {
      if (_userData.interests!.contains(el)) {
        _interestsWidgets.insert(0, _interestsChip(el, bgColor: Colors.red));
      } else {
        _interestsWidgets.add(_interestsChip(el));
      }
    }

    return _interestsWidgets;
  }

  Widget _interestsChip(String chipName, { Color bgColor = Colors.grey, double fontSize = 14, FontWeight? fontWeight = FontWeight.bold, String? fontFam }) {
    return Chip(
      backgroundColor: bgColor.withOpacity(0.9),
      elevation: 3,
      label: Text(chipName),
      labelStyle: TextStyle(color: kTextColor, fontSize: fontSize, fontWeight: fontWeight, fontFamily: fontFam),
    );
  }

  ImageProvider<Object> _getImage(UserData user) {
    if (user.image != null) {
      return NetworkImage(user.image!);
    } else {
      return const AssetImage("assets/images/blank_profile.png");
    }
  }
}

class ActionIcon extends StatelessWidget {
  const ActionIcon({ Key? key , this.large = true, required this.icon, this.color = Colors.red, this.borderColor, this.onPress })
      : super(key: key);

  final bool large;
  final IconData icon;
  final Color color;
  final Color? borderColor;
  final Function? onPress;

  @override
  Widget build(BuildContext context) {
    Color? newBorderColor = borderColor ?? color;
    return Container(
      height: large ? 60 : 40,
      width: large ? 60 : 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(width: 2, color: newBorderColor),
        // boxShadow: const [kDefaultShadow]
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          alignment: Alignment.center,
          shape: MaterialStateProperty.all(const CircleBorder())
        ),
        onPressed: () {
          onPress!();
        },
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}

class Message {
  String title;
  String body;
  String message;

  Message(this.title, this.body, this.message);
}