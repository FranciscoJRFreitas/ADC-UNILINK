import 'package:flutter/material.dart';
import '../features/contacts/domain/Contact.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';
import 'package:unilink2023/constants.dart';

class ContactCard extends StatelessWidget {
  final Contact? contact;

  ContactCard({
    required this.contact,
  });

  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Calculate available height and width
      final double availableHeight = constraints.maxHeight;
      final double availableWidth = constraints.maxWidth;

      // Calculate card height and font size based on available space
      final double cardHeight =
          availableHeight < MediaQuery.of(context).size.height
              ? availableHeight / 5
              : MediaQuery.of(context).size.height / 5;
      final double fontSize = availableWidth < 400 ? 12 : 17;
      final double iconSize = availableWidth < 400 ? 20 : 30;

      return Container(
        height: cardHeight + 15,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // rounded corners
          ),
          elevation: 5,
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Provider.of<ThemeNotifier>(context).currentTheme ==
                            kDarkTheme
                        ? Colors.blue.shade900
                        : Colors.black54, // shadow color
                    offset: Offset(5, 5), // Offset in x and y axes
                    blurRadius: 10, // blur effect
                    spreadRadius: 3, // spread effect
                  ),
                ],
              ),
              child: Row(
                // <-- Add this
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(
                        'assets/images/NOVA_Logo.png'), // replace with your image file
                  ),
                  SizedBox(
                      width: 20), // To give some space between image and text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // new line
                      children: [
                        Text(
                          contact?.name ?? 'N/A',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontSize: fontSize + 2),
                        ),

                        if (contact?.phoneNumber != '') ...[
                          // add some space between name and the other details
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              Icon(Icons.phone,
                                  color: Colors.white, size: iconSize - 10),
                              SizedBox(width: 5.0),
                              Expanded(
                                // new line
                                child: Text(
                                  contact?.phoneNumber ?? 'N/A',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(fontSize: fontSize),
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(
                            height:
                                8.0), // add some space between phone number and email
                        Row(
                          children: [
                            InkWell(
                              child: Icon(Icons.email,
                                  color: Colors.white, size: iconSize - 10),
                              onTap: () async {
                                var email = contact
                                    ?.email; // replace with the email you want

                                final uri = 'mailto:$email';

                                Uri url = Uri.parse(uri);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              // new line
                              child: Text(
                                contact?.email ?? 'N/A',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(fontSize: fontSize),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            if (contact?.facebook != '') ...[
                              SizedBox(
                                  height:
                                      8.0), // add some space between email and Facebook
                              Row(children: [
                                SizedBox(width: 5.0),
                                InkWell(
                                  onTap: () async {
                                    String? uri = contact?.facebook;
                                    if (uri != null) {
                                      Uri url = Uri.parse(uri);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    }
                                  },
                                  child: Icon(Icons.facebook,
                                      color: Colors.white, size: iconSize),
                                ),
                              ])
                            ],
                            if (contact?.instagram != '') ...[
                              SizedBox(
                                  height:
                                      8.0), // add some space between email and Facebook
                              Row(children: [
                                SizedBox(width: 8.0),
                                InkWell(
                                  onTap: () async {
                                    String? uri = contact?.instagram;
                                    if (uri != null) {
                                      Uri url = Uri.parse(uri);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    }
                                  },
                                  child: Icon(FontAwesomeIcons.instagram,
                                      color: Colors.white, size: iconSize),
                                ),
                              ])
                            ],
                            SizedBox(width: 8.0),
                            GestureDetector(
                              onTap: () async {
                                String? uri = contact?.url;
                                if (uri != null) {
                                  Uri url = Uri.parse(uri);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Provider.of<ThemeNotifier>(context)
                                              .currentTheme ==
                                          kDarkTheme
                                      ? Colors.blue.shade900
                                      : Colors.blue.shade700,
                                  border: Border.all(
                                      color: Provider.of<ThemeNotifier>(context)
                                                  .currentTheme ==
                                              kDarkTheme
                                          ? Colors.blue.shade900
                                          : Colors.blue.shade700),
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Provider.of<ThemeNotifier>(context)
                                                        .currentTheme ==
                                                    kDarkTheme
                                                ? Colors.blue.shade900
                                                    .withOpacity(0.5)
                                                : Colors.blue.shade700
                                                    .withOpacity(0.5),
                                        offset: Offset(0, 25),
                                        blurRadius: 3,
                                        spreadRadius:
                                            -10 // changes position of shadow
                                        ),
                                  ],
                                ),
                                child: Text(
                                  'More Info',
                                  style: TextStyle(
                                    //color: Colors.green,
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // can't launch url, there is some error
      throw "Could not launch $url";
    }
  }
}
