import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'validator.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  String _email, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sign Up Page"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(20.0),
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
                  _email = value;
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
                  _password = value;
                },
              ),
              SizedBox(
                height: 15.0,
              ),
              RaisedButton(
                child: Text(
                  'Create account',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0)),
                onPressed: () {
                  if (formKey.currentState.validate()) {
                    formKey.currentState.save();
                    FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: this._email,
                      password: this._password,
                    ).then((signedInUser) {
                      Firestore.instance.collection('/users').add({
                        'uid': signedInUser.uid,
                        'email': signedInUser.email,
                        'displayName': signedInUser.displayName,
                        'photoUrl': signedInUser.photoUrl
                      }).then((result){}).catchError((e) => print(e));
                      }).catchError((e) => print(e));
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return HomePage();
                      }));
                  }
                },
              ),
            ],
          ),
        ),
    );
  }
}
