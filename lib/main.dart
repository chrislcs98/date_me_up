import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:date_me_up/screens/login_page.dart';
import 'package:date_me_up/screens/main_screen.dart';
import 'package:date_me_up/screens/profile_screen.dart';

// Firebase and Firestore
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


/// Define a top-level named handler which background/terminated messages will call.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  if (kDebugMode) print('Handling a background message ${message.messageId}');
  print('onBackgroundMessage: $message');
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Date Me Up',
      home: MyHomePage(),
    );
  }
}


/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // Create the initialization Future outside of `build`:
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

bool? _exists;

class _MyHomePageState extends State<MyHomePage> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MyHomePage()),
        );
      }
    });

    // When App is on foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage: ${message.notification?.body}');

      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_ID', 'channel name',
              importance: Importance.low,
              playSound: true,
              showProgress: true,
              priority: Priority.low,
            ),
          ),
        );
      }
    });

    // When App is running on the background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
        print('onMessageOpenedApp: $message');
      }
    });

    // FirebaseMessaging.instance.getToken().whenComplete(() => {
    //
    // });
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          if (kDebugMode) print(snapshot.error);
          return const LoginPage(snackMsg: "Network Connection Failed");
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                // User? user = snapshot.data as User?;
                FirebaseAuth.instance.currentUser?.reload();
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null && user.emailVerified) {
                  // bool exists = false;
                  // try {
                  //   print(user.uid);
                  //   var doc = FirebaseFirestore.instance.collection("users").doc(user.uid).get();
                  //   print(doc);
                  //   exists = true;
                  // } catch (e) {
                  //   if (kDebugMode) print("Error $e");
                  //   // exists = false;
                  // }

                  // Future<bool> docExists = MyHomePage.checkIfDocExists(user.uid);
                  // // print("Document exists in Firestore? " + );
                  // docExists.then((value) => print(value));
                  // print("Document exists in Firestore? " + _exists.toString());

                  // FirebaseFirestore.instance.doc(user.uid).get()
                  //   .then((docSnapshot) => {
                  //     if (docSnapshot.exists) {
                  //       exists = true
                  //     } else {
                  //       exists = false
                  //     }
                  //   });

                  checkIfDocExists(user.uid);
                  if (kDebugMode) print("Ex: " + _exists.toString());

                  if (_exists == null) {
                    return const MyHomePage();
                  } else if (_exists == true) {
                    return MainScreen(user: user);
                  }

                  return ProfileScreen(user: user);

                } else {
                  return const LoginPage();
                }
              }

              // Checking Authentication ...
              return const LoginPage(snackMsg: "Checking Authentication ... (Wait)");
            },
          );
        }

        // Otherwise, show message whilst waiting for initialization to complete
        return const LoginPage(snackMsg: "Connecting to the app ... (Wait)");
      },
    );
  }
}

// Check If Document Exists
checkIfDocExists(String docId) async {
  try {
    await FirebaseFirestore.instance.doc("users/$docId").get().then((doc) {
      _exists = doc.exists;
    });
    return _exists;
  } catch (e) {
    return false;
  }
}