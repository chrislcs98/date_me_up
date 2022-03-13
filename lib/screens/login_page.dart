import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key? key, this.snackMsg}) : super(key: key);

  String? snackMsg;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = "";
  String _password = "";

  User? _user;
  bool _emailVerification = false;
  bool _secret = true;

  var visible = const Icon(
    Icons.visibility,
    color: Color(0xff4c5166),
  );
  var visibleOff = const Icon(
    Icons.visibility_off,
    color: Color(0xff4c5166),
  );

  _showAlert(title, content) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          elevation: 25,
          backgroundColor: Colors.lightBlueAccent.withOpacity(0.85),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkUser();
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        )
    );
  }

  Future<void> _checkUser() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Error $e");
    }

    try {
      UserCredential userCredential = await FirebaseAuth
          .instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      print("User: $userCredential");

      _user = userCredential.user;
      await _user?.reload();

    } on FirebaseAuthException catch (e) {
      print("Error $e");
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print("Error $e");
    } finally {
      // Check if user's email is verified
      if (_user != null && !_user!.emailVerified) {
        if (!_emailVerification) {
          await _user!.sendEmailVerification();
          _emailVerification = true;
        }
        // await FirebaseAuth.instance.signOut();
      }
    }
  }

  Future<void> _createUser() async {

    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);
    try {
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: _email, password: _password);

      _user = userCredential.user;
      Future.sync(() => userCredential);
      if (_user != null && !_user!.emailVerified) {
        await _user!.sendEmailVerification();

        _emailVerification = true;

        // await FirebaseAuth.instance.signOut();
        _showAlert("Waiting for Email Verification", "Verify your email through the link in your email account.");
      }
    }
    on FirebaseAuthException catch (e) {
      // Do something with exception. This try/catch is here to make sure
      // that even if the user creation fails, app.delete() runs, if is not,
      // next time Firebase.initializeApp() will fail as the previous one was
      // not deleted.
      await app.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xffcd0505),
                  Color(0xffa30505),
                  Color(0xff9c0202),
                  Color(0xff720202),
                  Color(0xff440101),
                  Color(0xff2b0000),
                  Color(0xff000000),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 250,
                      // decoration: const BoxDecoration(
                      //   shape: BoxShape.circle,
                      // ),
                      // clipBehavior: Clip.hardEdge,
                      child: Tooltip(
                        message: "https://www.designevo.com/",
                        preferBelow: true,
                        waitDuration: const Duration(milliseconds: 2000),
                        child: Image.asset(
                          "assets/images/logo.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildEmail(),
                    const SizedBox(height: 15),
                    buildPassword(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildEmailVerification(),
                        buildForgetPassword()
                      ],
                    ),
                    const SizedBox(height: 5),
                    buildLoginButton(),
                    buildSignupButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Email",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
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
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.email,color: Color(0xff4c5166),),
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.black38)
              ),
              onChanged: (value) {
                _email = value;
              },
              autocorrect: false,
          ),
        ),
      ],
    );
  }

  Widget buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 10,),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xffebefff),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2)
              )
            ],
          ),
          height: 60,
          child: TextFormField(
              obscureText: _secret,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _secret = !_secret;
                      });
                    },
                    icon: _secret ? visibleOff : visible,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 14),
                  prefixIcon: const Icon(Icons.vpn_key, color: Color(0xff4c5166)),
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.black38)
              ),
              onChanged: (value) {
                _password = value;
              },
              autocorrect: false,
              enableSuggestions: false,
          ),
        )
      ],
    );
  }

  Widget buildEmailVerification(){
    return Container(
      alignment: Alignment.centerRight,
      child: _emailVerification ? TextButton(
        child: const Text(
            "Sent Email Verification (again)",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline)
        ),
        onPressed: () async {
          try {
            _emailVerification = false;
            _checkUser();

          } catch (e) {
            print(e);
          }
        },
      ) : Container(),
    );
  }

  Widget buildForgetPassword(){
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        child: const Text(
            "Forget Password",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline)
        ),
        onPressed: (){
          if (_email.isNotEmpty) {
            FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
          }
        },
      ),
    );
  }

  Widget buildLoginButton(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child:  ElevatedButton(
          onPressed: (){
            _checkUser();
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xffffffff)),
            elevation: MaterialStateProperty.all(10),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
          ),
          child: const Text(
            "Login",
            style: TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSignupButton(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child:  ElevatedButton(
          onPressed: (){
              _createUser();
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xfffcfafa)),
            elevation: MaterialStateProperty.all(10),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
          ),
          child: const Text(
            "Sign Up",
            style: TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}