import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'validator.dart';
import 'register.dart';
import 'home_page.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Travel Portal",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final formKey = GlobalKey<FormState>();

  String email, password;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _showDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);
    print("signed in " + user.displayName);
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            "assets/images/back2.png",
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.lighten,
          ),
          ListView(
            children: <Widget>[
              Form(
                key: formKey,
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "e.g. somebody@gmail.com",
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                        onSaved: (String value) {
                          email = value;
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Password",
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        validator: validatePassword,
                        onSaved: (String value) {
                          password = value;
                        },
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      RaisedButton(
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7.0)),
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            formKey.currentState.save();
                            _auth
                                .signInWithEmailAndPassword(
                                    email: this.email, password: this.password)
                                .then((signedInUser) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return HomePage();
                              }));
                            }).catchError((e) {
                              _showDialog("Something went wrong!", e.toString());
                            });
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      RaisedButton(
                        child: Text(
                          'Create account',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return RegisterPage();
                          }));
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Or continue with",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _googleIcon(),
                          SizedBox(
                            width: 20.0,
                          ),
                          _facebookIcon(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _googleIcon() {
    return InkWell(
      child: CircleAvatar(
        child: Image.asset(
          "assets/images/google_logo.png",
        ),
        backgroundColor: Colors.white,
        radius: 25.0,
      ),
      onTap: () {
        _handleSignIn().then((FirebaseUser user) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return HomePage();
          }));
        }).catchError((e) => print(e));
      },
    );
  }

  Widget _facebookIcon() {
    return InkWell(
      child: CircleAvatar(
        child: Image.asset(
          "assets/images/facebook_logo.png",
        ),
        radius: 25.0,
      ),
      onTap: () {},
    );
  }
}
