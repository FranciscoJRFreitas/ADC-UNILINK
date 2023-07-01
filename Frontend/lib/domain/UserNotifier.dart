import 'package:flutter/foundation.dart';
import '../data/cache_factory_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../features/userManagement/domain/User.dart';

class UserNotifier with ChangeNotifier {
  Future<Uint8List?>? profilePic;
  User? _user;

  UserNotifier() {
    initialize();
  }

  Future<void> initialize() async {
    //await getUsername();
    _user = await cacheFactory.get("users", "user");
    await downloadData();
  }

  Future<Uint8List?>? get currentPic => profilePic;

  User? get currentUser => _user;

  Future<void> downloadData() async {
    profilePic = FirebaseStorage.instance
        .ref('ProfilePictures/' + _user!.username)
        .getData()
        .onError((error, stackTrace) => null);

    notifyListeners();
  }

  /*Future<void> getUsername() async{

    username = await cacheFactory.get('users', 'username');
    print(await cacheFactory.get('users', 'username'));
  }*/

  Future<void> updateUser(User user) async {
    _user = user;
    cacheFactory.setUser(user, await cacheFactory.get('users', 'token'),
        await cacheFactory.get('users', 'password'));

    notifyListeners();
  }
}
