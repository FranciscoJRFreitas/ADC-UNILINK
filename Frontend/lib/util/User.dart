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
  final String? landlinePhone;
  final String? mobilePhone;
  final String? occupation;
  final String? workplace;
  final String? address;
  final String? additionalAddress;
  final String? locality;
  final String? postalCode;
  final String? nif;
  final String? photoUrl;

  User({
    required this.displayName,
    required this.username,
    required this.email,
    required this.role,
    required this.educationLevel,
    required this.birthDate,
    required this.profileVisibility,
    required this.state,
    required this.landlinePhone,
    required this.mobilePhone,
    required this.occupation,
    required this.workplace,
    required this.address,
    required this.additionalAddress,
    required this.locality,
    required this.postalCode,
    required this.nif,
    required this.photoUrl,
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
        landlinePhone: '',
        mobilePhone: '',
        occupation: '',
        workplace: '',
        address: '',
        additionalAddress: '',
        locality: '',
        postalCode: '',
        nif: '',
        photoUrl: '',
      );
    } else {
      return User(
        additionalAddress: json['user_additionalAddress']['string'],
        address: json['user_address']['string'],
        displayName: json['user_displayName']['string'],
        email: json['user_email']['string'],
        landlinePhone: json['user_landlinePhone']['string'],
        locality: json['user_locality']['string'],
        mobilePhone: json['user_mobilePhone']['string'],
        occupation: json['user_occupation']['string'],
        postalCode: json['user_postalCode']['string'],
        educationLevel: json['user_educationLevel']['string'],
        birthDate: json['user_birthDate']['string'],
        profileVisibility: json['user_profileVisibility']['string'],
        role: json['user_role']['string'],
        state: json['user_state']['string'],
        nif: json['user_taxIdentificationNumber']['string'],
        username: json['user_username']['string'],
        workplace: json['user_workplace']['string'],
        photoUrl: json['user_photo']['string'],
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
}

