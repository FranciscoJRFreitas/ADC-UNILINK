import 'package:flutter/material.dart';
import '../domain/Contact.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactCard extends StatelessWidget {
  final Contact? contact;

  ContactCard({
    required this.contact,
  });

  /*Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // rounded corners
        ),
        elevation: 5,
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // new line
            children: [
              Text(
                contact?.name ?? 'N/A',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 18),
              ),

              if (contact?.phoneNumber != '') ...[
                // add some space between name and the other details
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.white),
                    SizedBox(width: 5.0),
                    Expanded(
                      // new line
                      child: Text(
                        contact?.phoneNumber ?? 'N/A',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(
                  height: 8.0), // add some space between phone number and email
              Row(
                children: [
                  InkWell(
                    child: Icon(Icons.email, color: Colors.white),
                    onTap: () async {
                      var email =
                          contact?.email; // replace with the email you want

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
                          .copyWith(fontSize: 18),
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
                      /*Text(
                        'Facebook:',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 18),
                      ),*/
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
                        child: Icon(Icons.facebook, color: Colors.white),
                      ),
                    ])
                  ],
                  if (contact?.instagram != '') ...[
                    SizedBox(
                        height:
                            8.0), // add some space between email and Facebook
                    Row(children: [
                      /*Text(
                        'Instagram:',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 18),
                      ),*/
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
                            color: Colors.white),
                      ),
                    ])
                  ]
                ],
              ),
              /*Expanded(
                      // new line
                      child: Text(
                        contact?.facebook ?? 'N/A',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 18),
                      ),
                    ),*/
            ],
          ),
        ),
      ),
    );
  }
}*/
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // rounded corners
        ),
        elevation: 5,
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            // <-- Add this
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(
                    'assets/images/NOVA_Logo.png'), // replace with your image file
              ),
              SizedBox(width: 20), // To give some space between image and text
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
                          .copyWith(fontSize: 18),
                    ),

                    if (contact?.phoneNumber != '') ...[
                      // add some space between name and the other details
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.white),
                          SizedBox(width: 5.0),
                          Expanded(
                            // new line
                            child: Text(
                              contact?.phoneNumber ?? 'N/A',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 18),
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
                          child: Icon(Icons.email, color: Colors.white),
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
                                .copyWith(fontSize: 18),
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
                            /*Text(
                        'Facebook:',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 18),
                      ),*/
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
                              child: Icon(Icons.facebook, color: Colors.white),
                            ),
                          ])
                        ],
                        if (contact?.instagram != '') ...[
                          SizedBox(
                              height:
                                  8.0), // add some space between email and Facebook
                          Row(children: [
                            /*Text(
                        'Instagram:',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 18),
                      ),*/
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
                                  color: Colors.white),
                            ),
                          ])
                        ]
                      ],
                    ),
                    /*Expanded(
                      // new line
                      child: Text(
                        contact?.facebook ?? 'N/A',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 18),
                      ),
                    ),*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
