import 'package:flutter/material.dart';
// import 'package:date_me_up/screens/main_screen.dart';
import 'package:date_me_up/screens/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env");
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Me Up',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
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

class _MyHomePageState extends State<MyHomePage> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print(snapshot.error);
          return LoginPage(snackMsg: "Network Connection Failed");
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
                  // // Check if user's email is verified
                  // print(user);
                  // print(user.emailVerified);
                  //
                  // if (!user.emailVerified) {
                  //   try {
                  //     FirebaseAuth.instance.signOut();
                  //   } catch (e) {
                  //     print("Error $e");
                  //   }
                  //   return LoginPage();
                  // }
                  // return MainScreen();
                } else {
                  return LoginPage();
                }
              }

              // Checking Authentication ...
              return LoginPage(snackMsg: "Checking Authentication ... (Wait)");
            },
          );
        }

        // Otherwise, show message whilst waiting for initialization to complete
        return LoginPage(snackMsg: "Connecting to the app ... (Wait)");
      },
    );
  }
}