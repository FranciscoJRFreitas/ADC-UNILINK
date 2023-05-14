import 'package:flutter/cupertino.dart';

class Token {
  final String? tokenID;
  final String? username;

  Token({
    required this.tokenID,
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'tokenID': tokenID,
      'username': username,
    };
  }

}
