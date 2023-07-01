import 'package:flutter/material.dart';

// Colors
const kBackgroundColor = Color(0xff191720);
const kWhiteBackgroundColor = Color.fromARGB(214, 216, 215, 224);
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

const kExtractKeywordsUrl = 'https://yakeaux.oa.r.appspot.com/extract';
const kBaseUrl = "https://unilink23.oa.r.appspot.com/";
//const kBaseUrl = "http://localhost:8080/";

final ThemeData kLightTheme = ThemeData(
  scaffoldBackgroundColor: kWhiteBackgroundColor,
  primarySwatch: Colors.green, // This sets the primary color swatch
  primaryColor: Style.lightBlue,
  hoverColor: Colors.green[400],
  textTheme: TextTheme(
    bodyLarge:
        TextStyle(color: Colors.black, fontSize: 20 // Black for light theme
            ),
    bodyMedium:
        TextStyle(color: Colors.black54, fontSize: 16 // Black for light theme
            ),
    bodySmall:
        TextStyle(color: Colors.black54, fontSize: 13 // Black for light theme
            ),
    titleLarge: TextStyle(
        fontWeight: FontWeight.bold, fontSize: 40, color: Colors.black),
    titleMedium: TextStyle(
        fontWeight: FontWeight.bold, fontSize: 25, color: Colors.black),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color.fromARGB(255, 111, 175, 76),
    textTheme: ButtonTextTheme.primary, // This will make the text color white
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corners
    ), //
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Style.lightBlue,
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Style.black,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Style.lightBlack,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: Style.black,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(18),
    ),
  ),
  primaryIconTheme: IconThemeData(color: Style.lightBlack),
  secondaryHeaderColor: Colors.black,
  cardColor: Colors.white10,
  iconTheme: IconThemeData(color: Colors.white),
  // customize other properties as needed
);

final ThemeData kDarkTheme = ThemeData(
  scaffoldBackgroundColor: kBackgroundColor,
  primarySwatch: Colors.green, // This sets the primary color swatch
  primaryColor: Style.darkBlue,
  hoverColor: Style.lightBlue,
  textTheme: TextTheme(
    bodyLarge:
        TextStyle(color: Colors.white, fontSize: 20 // White for dark theme
            ),
    bodyMedium:
        TextStyle(color: Colors.white60, fontSize: 16 // Black for light theme
            ),
    bodySmall: TextStyle(
      color: Colors.white60, fontSize: 13, // Black for light theme
    ),
    titleLarge: TextStyle(
        fontWeight: FontWeight.bold, fontSize: 40, color: Colors.white),
    titleMedium: TextStyle(
        fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color.fromARGB(255, 111, 175, 76),
    textTheme: ButtonTextTheme.primary, // This will make the text color white
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corners
    ), // Blue buttons for dark theme
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Style.darkBlue,
    // Set your desired color here
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Style.grey,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Style.white,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: Style.grey,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(18),
    ),
  ),
  primaryIconTheme: IconThemeData(color: Style.grey),
  secondaryHeaderColor: Colors.white,
  cardColor: Colors.white30, iconTheme: IconThemeData(color: Colors.white),

  // customize other properties as needed
);

class Style {
  static Color white = Colors.white;
  static Color black = Colors.black87;
  static Color lightBlack = Colors.black54;
  static Color grey = Colors.grey;
  static Color darkBlue = Colors.blue.shade800;
  static Color lightBlue = Colors.blue.shade400;
  static Color green = Colors.green.shade200;
}
