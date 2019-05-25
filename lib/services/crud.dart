import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class CrudMethods {
  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addData(placeData) async {
    if (isLoggedIn()) {
      // Firestore.instance.collection("testcrud").add(carData).catchError((e) {
      //   print(e);
      // });
      Firestore.instance.runTransaction((Transaction crudTransaction) async {
        CollectionReference reference =
            Firestore.instance.collection('testcrud');
        reference.add(placeData);
      });
    } else {
      print("You need to be logged in!");
    }
  }

  Future getData() async {
    // return await Firestore.instance.collection('testcrud').getDocuments();
    return Firestore.instance.collection('testcrud').snapshots();
  }

  updateData(selectedDoc, newValues) {
    Firestore.instance
        .collection('testcrud')
        .document(selectedDoc)
        .updateData(newValues)
        .catchError((e) {
      print(e);
    });
  }

  deleteData(docId) {
    Firestore.instance
        .collection('testcrud')
        .document(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }
}
