import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum UserRole {
  SU,
  DIRECTOR,
  PROF,
  STUDENT,
  UKN, // Unknown
}

class User {
  final String displayName;
  final String username;
  final String email;
  final String? role;
  final String? educationLevel;
  final String? birthDate;
  final String? profileVisibility;
  final String? state;
  final String? mobilePhone;
  final String? occupation;
  final String? creationTime;

  User({
    required this.displayName,
    required this.username,
    required this.email,
    required this.role,
    required this.educationLevel,
    required this.birthDate,
    required this.profileVisibility,
    required this.state,
    required this.mobilePhone,
    required this.occupation,
    required this.creationTime,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('user_role')) {
      return User(
        displayName: json['user_displayName']['string'],
        email: json['user_email']['string'],
        username: json['user_username']['string'],
        role: '',
        educationLevel: '',
        birthDate: '',
        profileVisibility: '',
        state: '',
        mobilePhone: '',
        occupation: '',
        creationTime: (json['user_creation_time'] as Timestamp).toDate().toString(),
      );
    } else {
      return User(
        displayName: json['user_displayName']['string'],
        email: json['user_email']['string'],
        mobilePhone: json['user_mobilePhone']['string'],
        occupation: json['user_occupation']['string'],
        educationLevel: json['user_educationLevel']['string'],
        birthDate: json['user_birthDate']['string'],
        profileVisibility: json['user_profileVisibility']['string'],
        role: json['user_role']['string'],
        state: json['user_state']['string'],
        username: json['user_username']['string'],
        creationTime: (json['user_creation_time'] as Timestamp).toDate().toString()
      );
    }
  }


  Color getRoleColor(String? role) {
    switch (getRole(role)) {
      case UserRole.SU:
        return Colors.red;
      case UserRole.DIRECTOR:
        return Colors.orange;
      case UserRole.PROF:
        return Colors.yellow;
      case UserRole.STUDENT:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  UserRole getRole(String? role) {
    switch (role) {
      case "SU":
        return UserRole.SU;
      case "DIRECTOR":
        return UserRole.DIRECTOR;
      case "PROF":
        return UserRole.PROF;
      case "STUDENT":
        return UserRole.STUDENT;
      default:
        return UserRole.UKN;
    }
  }

  String nullFormat(String? string){

    String result = '';
    if (string != null) result = string;

    return result;
  }

  Map<String, Object> toMap(String token, String password){
    return {
      'displayName': displayName,
      'email': email,
      'username': username,
      'role': nullFormat(role),
      'educationLevel': nullFormat(educationLevel),
      'birthDate': nullFormat(birthDate),
      'profileVisibility': nullFormat(profileVisibility),
      'state': nullFormat(state),
      'mobilePhone': nullFormat(mobilePhone),
      'occupation': nullFormat(occupation),
      'token': token,
      'password': password,
      'creationTime': nullFormat(creationTime),
    };
  }


}

