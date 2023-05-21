import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/widgets/news_box.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/Contact.dart';
import '../widgets/contacts_box.dart';
import '../domain/fetchContacts.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  ScrollController _scrollController = ScrollController();
  List<Contact> _contacts = [];
  bool _hasMore = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  void _fetchContacts() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    Map<String, List<Contact>> fetchedContacts = await fetchContacts();
    setState(() {
      _isLoading = false;
      if (fetchedContacts.isNotEmpty) {
        _contacts.addAll(fetchedContacts['mainContacts'] ?? []);
        _contacts.addAll(fetchedContacts['departmentsContacts'] ?? []);
      } else {
        _hasMore = false;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView.separated(
            controller: _scrollController,
            itemCount: _contacts.length + (_hasMore ? 1 : 0),
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemBuilder: (BuildContext context, int index) {
              if (index == _contacts.length) {
                if (_isLoading) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return SizedBox.shrink();
                }
              }
              final item = _contacts[index];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _launchURL(item.url ?? ''),
                  child: ContactCard(
                    contact: item,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    // can't launch url, there is some error
    throw "Could not launch $url";
  }
}

class _ActionsRow extends StatelessWidget  {
  final Contact item;
  const _ActionsRow({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.white, size: 18),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(CupertinoIcons.share_up),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}