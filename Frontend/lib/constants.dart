import 'package:flutter/material.dart';

// Colors
const kBackgroundColor = Color(0xff191720);
const kWhiteBackgroundColor = Color(0xffd8d7e0);
const kTextFieldFill = Color(0xff1E1C24);

// TextStyles
const kHeadline = TextStyle(
  color: Colors.white,
  fontSize: 34,
  fontWeight: FontWeight.bold,
);

const kButtonText = TextStyle(
  color: Colors.black87,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

const kBodyText = TextStyle(
  color: Colors.grey,
  fontSize: 15,
);

const kBodyText1 = TextStyle(
  color: Colors.white,
  fontSize: 16,
);

const kBodyText2 = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w500,
  color: Colors.white,
);

const kBaseUrl = "https://unilink23.oa.r.appspot.com/";
//const kBaseUrl = "http://localhost:8080/";

final ThemeData kLightTheme = ThemeData(
  scaffoldBackgroundColor: kWhiteBackgroundColor,
  primarySwatch: Colors.green, // This sets the primary color swatch
  primaryColor: Colors.green[400],
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: Colors.black, // Black for light theme
    ),
    bodyMedium: TextStyle(
      color: Colors.black54, // Black for light theme
    ),
    bodySmall: TextStyle(
      color: Colors.black54, // Black for light theme
    ),
    titleLarge: TextStyle(
        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.green, // Blue buttons for light theme
  ),
  // customize other properties as needed
);

final ThemeData kDarkTheme = ThemeData(
  scaffoldBackgroundColor: kBackgroundColor,
  primarySwatch: Colors.green, // This sets the primary color swatch
  primaryColor: Colors.green[400],
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white, // White for dark theme
    ),
    bodyMedium: TextStyle(
      color: Colors.white60, // Black for light theme
    ),
    bodySmall: TextStyle(
      color: Colors.white60, // Black for light theme
    ),
    titleLarge: TextStyle(
        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.green, // Blue buttons for dark theme
  ),
  // customize other properties as needed
);

class Style {
  static Color white = Colors.white;
  static Color black = Colors.black;
  static Color grey = Colors.grey;
  static Color darkBlue = Colors.blue.shade800;
  static Color green = Colors.green.shade200;
}
