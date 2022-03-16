import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:date_me_up/constants.dart';

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
  final Set<String> _interests = {};
  final List<Widget> _interestsWidgets = [];

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
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage("assets/images/image.jpeg"),
                fit: BoxFit.cover
              )
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Mercedes",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: kTextColor
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "20",
                        style: TextStyle(
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
                        "Cyprus",
                        style: TextStyle(
                            fontSize: 20,
                            color: kTextColor
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    children: getInterestsWidgets()
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Spacer(),
                      ActionIcon(
                        icon: Icons.refresh,
                        color: Colors.white,
                      ),
                      Spacer(),
                      ActionIcon(
                        icon: CupertinoIcons.heart_fill,
                        color: Colors.white70,
                        borderColor: Colors.red,
                      ),

                      Spacer()
                    ],
                  )
                ],
              )
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

// Widget _titleContainer(String myTitle, {double leftPadding = 0, double size = 24}) {
//   return Align(
//     alignment: Alignment.centerLeft,
//     child: Padding(
//       padding: EdgeInsets.fromLTRB(leftPadding, 15, 5, 5),
//       child: Text(
//         myTitle,
//         style: TextStyle(
//             color: kTextColor, fontSize: size, fontWeight: FontWeight.bold),
//       ),
//     ),
//   );
// }

class ActionIcon extends StatelessWidget {
  const ActionIcon({ Key? key , this.large = true, required this.icon, this.color = Colors.red, this.borderColor })
      : super(key: key);

  final bool large;
  final IconData icon;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    Color? newBorderColor = borderColor ?? color;
    return Container(
      height: large ? 60 : 40,
      width: large ? 60 : 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(width: 2, color: newBorderColor),
        boxShadow: [kDefaultShadow]
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          alignment: Alignment.center,
          shape: MaterialStateProperty.all(CircleBorder())
        ),
        onPressed: () {

        },
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}