import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/util/ThemeNotifier.dart';
import '../constants.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          iconSize: 50.0, // adjust this value to change the size of the icon
          icon: Icon(
            Provider.of<ThemeNotifier>(context).currentTheme == kDarkTheme
                ? Icons.wb_sunny
                : Icons.nights_stay,
          ),
          onPressed: () {
            Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
          },
        ),
      ),
    );
  }
}
