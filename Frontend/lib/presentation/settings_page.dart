import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';
import '../constants.dart';
import '../data/cache_factory_provider.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _currentTheme;

  @override
  void initState() {
    super.initState();
    getTheme();
  }

  Future<void> getTheme() async {
    _currentTheme = await cacheFactory.get('settings', 'theme');
    setState(
        () {}); // this is required to trigger a rebuild after the theme has been loaded
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          iconSize: 50.0,
          icon: Icon(
            Provider.of<ThemeNotifier>(context, listen: false).currentTheme ==
                    kDarkTheme
                ? Icons.nights_stay
                : Icons.wb_sunny,
          ),
          onPressed: () {
            Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
          },
        ),
      ),
    );
  }
}
