import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import './services/crud.dart';
import './main.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String title;
  String desc;
  String url;
  String profilePicUrl;
  String nickName;
  String userEmail;
  File sampleImage;

  Stream places;

  CrudMethods crudObj = new CrudMethods();

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage;
    });
  }


  void _signOut(Future<FirebaseUser> user) async {
    if (FirebaseAuth.instance.currentUser() != null) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return MyApp();
      }));
    } else {
      return null;
    }
  }

  Future<bool> addDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ListView(children: <Widget>[
            AlertDialog(
              title: Text("Add new place"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: sampleImage == null
                        ? RaisedButton(
                            child: Text('Choose Image'),
                            onPressed: getImage,
                          )
                        : Image.file(sampleImage, height: 200, width: 200),
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: "Enter title"),
                    onChanged: (value) {
                      this.title = value;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: "Enter description"),
                    onChanged: (value) {
                      this.desc = value;
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Add"),
                  onPressed: () async {
                    final timeKey = DateTime.now();
                    final StorageUploadTask task = FirebaseStorage.instance
                        .ref()
                        .child(timeKey.toString() + '.jpg')
                        .putFile(sampleImage);
                    sampleImage = null;
                    var imageUrl =
                        await (await task.onComplete).ref.getDownloadURL();
                    url = imageUrl.toString();
                    Navigator.of(context).pop();
                    Map<String, dynamic> placeData = {
                      'title': this.title,
                      'url': this.url,
                      'desc': this.desc,
                    };
                    crudObj.addData(placeData).then((result) {
                      addDialogTrigger(context);
                    }).catchError((e) {
                      print(e);
                    });
                  },
                ),
              ],
            ),
          ]);
        });
  }

  Future<bool> addDialogTrigger(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Job done!"),
          content: Text("Added"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          actions: <Widget>[
            FlatButton(
              child: Text("Alright"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> updateDialog(BuildContext context, selectedDoc) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Update Data"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: "Enter title"),
                  onChanged: (value) {
                    this.title = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Enter description"),
                  onChanged: (value) {
                    this.desc = value;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Update"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Map<String, dynamic> placeData = {
                    'title': this.title,
                    'desc': this.desc,
                  };
                  crudObj.updateData(selectedDoc, placeData).then((result) {
                    updateDialogTrigger(context);
                  }).catchError((e) {
                    print(e);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<bool> updateDialogTrigger(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Job done!"),
          content: Text("Updated"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          actions: <Widget>[
            FlatButton(
              child: Text("Alright"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
     FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        nickName = (user.displayName == null ? 'Your Name' : user.displayName);
        profilePicUrl = (user.photoUrl == null ? 'https://sugambaskota.com.np/travelPortal/male-circle.png' : user.photoUrl);
        userEmail = (user.email == null ? 'Your Email' : user.email);
      });
    }).catchError((e) {
      print(e);
    });
    crudObj.getData().then((results) {
      setState(() {
        places = results;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          addDialog(context);
        },
      ),
      appBar: AppBar(
        title: Text("Welcome"),
        centerTitle: true,
        actions: <Widget>[
          Row(
            children: <Widget>[
              InkWell(child: Icon(Icons.search), onTap: (){},),
              Padding(padding: EdgeInsets.only(right: 20.0),),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("$nickName"),
              accountEmail: Text("$userEmail"),
              currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage(profilePicUrl)),
            ),
            FlatButton(
              child: Row(
                children: <Widget>[
                  Text("Logout"),
                  SizedBox(
                    width: 30.0,
                  ),
                  Icon(Icons.power_settings_new),
                ],
              ),
              onPressed: () {
                return _signOut(FirebaseAuth.instance.currentUser());
              },
            ),
          ],
        ),
      ),
      body: Container(
        child: RefreshIndicator(
          child: _placesList(),
          onRefresh: () {
            return crudObj.getData().then((result) {
              setState(() {
                places = result;
              });
            });
          },
        ),
      ),
    );
  }

  Widget _placesList() {
    if (places != null) {
      // return ListView.builder(
      //   itemCount: places.documents.length,
      //   padding: EdgeInsets.all(10.0),
      //   itemBuilder: (context, i) {
      //     return Card(
      //       margin: EdgeInsets.all(10.0),
      //       child: Column(
      //         children: <Widget>[
      //           Image.asset("assets/images/pashupatinath.jpg"),
      //           Text(places.documents[i].data['title']),
      //           Text(places.documents[i].data['desc']),
      //         ],
      //       ),
      //     );
      //   },
      // );
      return StreamBuilder(
        stream: places,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, i) {
                return InkWell(
                  child: Card(
                    margin: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Image.network(snapshot.data.documents[i].data['url']),
                        Text(snapshot.data.documents[i].data['title'], style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(snapshot.data.documents[i].data['desc']),
                      ],
                    ),
                  ),
                  onTap: () {
                    updateDialog(
                        context, snapshot.data.documents[i].documentID);
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirmation!"),
                          content: Text(
                              "Are your sure you want to remove this item?"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("No!"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            FlatButton(
                              child: Text("Yes, remove!"),
                              onPressed: () {
                                Navigator.of(context).pop();
                                crudObj.deleteData(
                                    snapshot.data.documents[i].documentID);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          }
        },
      );
    } else {
      return Center(
        child: Text(
          'Loading... please wait!',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 20.0,
          ),
        ),
      );
    }
  }
}
