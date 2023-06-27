import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';
import 'package:unilink2023/presentation/edit_starting_page.dart';
import '../data/cache_factory_provider.dart';
import '../presentation/change_password_page.dart';
import '../presentation/remove_account_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _currentTheme;

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  Future<void> getSettings() async {
    _currentTheme = await cacheFactory.get('settings', 'theme');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      Option(
          icon: Icon(
              _currentTheme == "Dark" ? Icons.nights_stay : Icons.wb_sunny,
              color: Theme.of(context).secondaryHeaderColor,
              size: 40.0),
          title: 'Theme',
          subtitle: 'Change between dark and light themes.',
          toggleButton: true,
          onTap: () {
            setState(() {});
          }),
      Option(
          icon: Icon(Icons.waving_hand,
              color: Theme.of(context).secondaryHeaderColor, size: 40.0),
          title: 'Starting Page',
          subtitle: 'Select your preferable starting page.',
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return EditStartingPage();
                });
          }),
      Option(
          icon: Icon(Icons.password,
              color: Theme.of(context).secondaryHeaderColor, size: 40.0),
          title: 'Change Password',
          subtitle: 'Change your password for a new one.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangePasswordPage(),
              ),
            );
          }),
      Option(
          icon: Icon(Icons.delete_forever,
              color: Theme.of(context).secondaryHeaderColor, size: 40.0),
          title: 'Remove Account',
          subtitle: 'Delete your current account.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RemoveAccountPage()),
            );
          }),
      Option(
          icon: Icon(Icons.privacy_tip,
              color: Theme.of(context).secondaryHeaderColor, size: 40.0),
          title: 'About',
          subtitle: 'Verify our terms and conditions and privacy policy.',
          onTap: () {}),
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: options.length + 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return SizedBox(height: 15.0);
          } else if (index == options.length + 1) {
            return SizedBox(height: 100.0);
          }
          return Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(10.0),
              width: double.infinity,
              height: 80.0,
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.black26)),
              child: Row(children: [
                Expanded(
                  // You need to use Expanded widget here
                  child: ListTile(
                    leading: options[index - 1].icon,
                    title: Text(
                      options[index - 1].title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      options[index - 1].subtitle.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onTap: options[index - 1].onTap,
                  ),
                ),
                if (options[index - 1].toggleButton == true) ...[
                  Switch(
                    value: _currentTheme != "Dark",
                    onChanged: (value) {
                      setState(() {
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .toggleTheme();
                        _currentTheme =
                            _currentTheme == "Dark" ? "Light" : "Dark";
                      });
                    },
                    activeTrackColor:
                        Theme.of(context).primaryColor.withOpacity(0.5),
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ]
              ]));
        },
      ),
    );
  }
}

class Option {
  bool? isButton;
  Icon icon;
  String title;
  String subtitle;
  bool? toggleButton;
  VoidCallback onTap;

  Option({
    //this.isButton,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.toggleButton,
    required this.onTap,
  });
}
