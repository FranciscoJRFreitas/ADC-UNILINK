import 'package:android_intent/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';
import 'package:unilink2023/features/settings/edit_starting_page.dart';
import '../../data/cache_factory_provider.dart';
import '../userManagement/change_password_page.dart';
import '../userManagement/remove_account_page.dart';

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
            getSettings();
          }),
      Option(
        icon: Icon(Icons.waving_hand,
            color: Theme.of(context).secondaryHeaderColor, size: 40.0),
        title: 'Starting Page',
        subtitle: 'Select your preferable starting page.',
        rightWidget: Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Distribute space evenly
            children: [
              FutureBuilder(
                future: cacheFactory.get('settings', 'index'),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    IconData iconData;
                    switch (snapshot.data) {
                      case 'News':
                        iconData = Icons.newspaper;
                        break;
                      case 'Profile':
                        iconData = Icons.person;
                        break;
                      case 'Schedule':
                        iconData = Icons.schedule;
                        break;
                      case 'Chat':
                        iconData = Icons.chat;
                        break;
                      case 'Contacts':
                        iconData = Icons.call;
                        break;
                      case 'Map':
                        iconData = Icons.map;
                        break;
                      default:
                        iconData = Icons.pages;
                    }
                    return Row(
                      children: [
                        Icon(iconData,
                            color: Theme.of(context).secondaryHeaderColor),
                        SizedBox(
                            width: 5.0), // Add space between the icon and text
                        Text(
                          snapshot.data,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    );
                  }
                },
              ),
              SizedBox(), // Add an empty SizedBox to ensure proper alignment
            ],
          ),
        ),
        onTap: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return EditStartingPage(
                onDialogClosed: () {
                  setState(() {});
                },
              );
            },
          );
        },
      ),
      if (!kIsWeb)
        Option(
            icon: Icon(Icons.notifications,
                color: Theme.of(context).secondaryHeaderColor, size: 40.0),
            title: 'Notifications',
            subtitle: 'Don\'t miss out on any updates!',
            onTap: () {
              openNotificationSettings();
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
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: options[index - 1].toggleButton == true
                  ? () {
                      setState(() {
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .toggleTheme();
                        _currentTheme =
                            _currentTheme == "Dark" ? "Light" : "Dark";
                      });
                    }
                  : options[index - 1].onTap,
              child: Container(
                margin: EdgeInsets.all(10.0),
                width: double.infinity,
                height: 85.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.black26),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        options[index - 1].icon,
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                options[index - 1].title,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                options[index - 1].subtitle.toString(),
                                style: Theme.of(context).textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        if (options[index - 1].toggleButton == true)
                          Switch(
                            value: _currentTheme != "Dark",
                            onChanged: (value) {
                              setState(() {
                                Provider.of<ThemeNotifier>(context,
                                        listen: false)
                                    .toggleTheme();
                                _currentTheme =
                                    _currentTheme == "Dark" ? "Light" : "Dark";
                              });
                            },
                            activeTrackColor:
                                Theme.of(context).primaryColor.withOpacity(0.5),
                            activeColor: Theme.of(context).primaryColor,
                          )
                        else
                          SizedBox.shrink(),
                        if (options[index - 1].rightWidget != null)
                          options[index - 1].rightWidget!,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void openNotificationSettings() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final AndroidIntent intent = AndroidIntent(
      action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
      data: 'package:${packageInfo.packageName}',
    );
    await intent.launch();
  }
}

class Option {
  bool? isButton;
  Icon icon;
  String title;
  String subtitle;
  bool? toggleButton;
  VoidCallback onTap;
  Widget? rightWidget;

  Option({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.toggleButton,
    required this.onTap,
    this.rightWidget,
  });
}
