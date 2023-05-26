import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';
import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../widgets/ToggleButton.dart';

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      Option(
        icon: Icon(_currentTheme == "Dark" ? Icons.nights_stay : Icons.wb_sunny,
            color: Theme.of(context).secondaryHeaderColor, size: 40.0),
        title: 'Theme',
        subtitle: 'Change between dark and light themes.',
        toggleButton: true,
      ),
      Option(
        icon: Icon(Icons.waving_hand,
            color: Theme.of(context).secondaryHeaderColor, size: 40.0),
        title: 'Starting Page',
        subtitle: 'Select your preferable starting page.',
      ),
      Option(
        icon: Icon(Icons.password,
            color: Theme.of(context).secondaryHeaderColor, size: 40.0),
        title: 'Change Password',
        subtitle: 'Change your password for a new one.',
      ),
      Option(
        icon: Icon(Icons.delete_forever,
            color: Theme.of(context).secondaryHeaderColor, size: 40.0),
        title: 'Remove Account',
        subtitle: 'Delete your current account.',
      ),
      Option(
        icon: Icon(Icons.privacy_tip,
            color: Theme.of(context).secondaryHeaderColor, size: 40.0),
        title: 'About',
        subtitle: 'Verify our terms and conditions and privacy policy.',
      ),
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
                      options[index - 1].subtitle,
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                    onTap: options[index - 1].toggleButton == true
                        ? null
                        : () {
                            setState(() {});
                          },
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

  Option({
    //this.isButton,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.toggleButton,
  });
}

/*Widget build(BuildContext context) {
Row(
              children: [
              ListTile(
              leading: options[index - 1].icon,
              title: Text(
                options[index - 1].title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                options[index - 1].subtitle,
                style: TextStyle(
                  color:
                      Theme.of(context).cardColor,
                ),
              ),
              
              onTap: () {
                //if (options[index - 1].isButton == true) {//has to be == true, because can be null
                  setState(() {
                    _selectedOption = index - 1;
                  });
                //} else {
                  //Navigator.push
                //}
              },
            ),
            Switch(
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.5),
              activeColor: Theme.of(context).primaryColor,
            ),
            ])    return Scaffold(
      body: Center(
        child: IconButton(
          iconSize: 50.0,
          icon: Icon(
            _currentTheme == kDarkTheme
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
}*/
