import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../data/cache_factory_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'User.dart';

class PictureNotifier with ChangeNotifier {

  String? username;
  Future<Uint8List?>? profilePic;

  PictureNotifier(){
    initialize();
  }

  Future<void> initialize() async{
    await getUsername();
    await downloadData();
  }

  Future<Uint8List?>? get currentPic => profilePic;

  Future<void> downloadData() async {

    profilePic = FirebaseStorage.instance
        .ref('ProfilePictures/' + username!)
        .getData()
        .onError((error, stackTrace) => null);

    notifyListeners();
  }

  Future<void> getUsername() async{

    username = await cacheFactory.get('users', 'username');
    print(await cacheFactory.get('users', 'username'));
  }

}
