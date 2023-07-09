import 'package:flutter/material.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:unilink2023/widgets/LineComboBoxFlag.dart';
import 'package:unilink2023/widgets/my_text_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:country_flags/country_flags.dart';
import 'package:unilink2023/domain/LocaleProvider.dart';
import 'package:provider/provider.dart';

class EditLanguagePage extends StatefulWidget {
  final VoidCallback? onDialogClosed;
  const EditLanguagePage(
      {Key? key, this.onDialogClosed})
      : super(key: key);

  @override
  _EditLanguagePageState createState() => _EditLanguagePageState();
}

class _EditLanguagePageState extends State<EditLanguagePage> {
  String _language = "english";
  Widget flagWidget = Image.asset(
    'assets/icon/portuguese_flag.png',
    height: 24,
    width: 24,
    fit: BoxFit.cover,
  );

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  Future<void> getSettings() async {
    _language = await cacheFactory.get('settings', 'language');
    setState(() {});
    if (_language != 'english' && _language != 'portugues')
      _language = "english";
    updateIcon();
  }

  void updateIcon() {
    if (_language == "portugues")
      flagWidget = Image.asset(
        'assets/icon/portuguese_flag.png',
        height: 10,
        width: 10,
        fit: BoxFit.cover,
      );
    if (_language == "english")
      flagWidget = Image.asset(
        'assets/icon/english_flag.png',
        height: 10,
        width: 10,
        fit: BoxFit.cover,
      );
  }

  void changeLanguage(String language) {
    var locale = language == 'portugues' ? Locale('pt') : Locale('en');
    Provider.of<LocaleProvider>(context, listen: false).currentLocale = locale;
  }

  @override
  Widget build(BuildContext context) {
    double offset = MediaQuery.of(context).size.width * 0.08;
    final localizations = AppLocalizations.of(context)!;
    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(offset, 80, offset, 50),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 300, // Set the maximum width for the Dialog
              ),
              //child: Padding(
              //padding: EdgeInsets.only(
              //  top: 20), // Provide space for the image at the top
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 5.0),
                    child: Text(localizations.language,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  Divider(
                    thickness: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 15),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineComboBoxFlag(
                        selectedValue: _language,
                        icon: flagWidget,
                        items: itemList(),
                        onChanged: (dynamic newValue) {
                          setState(() {
                            _language = newValue;
                            updateIcon();
                          });
                        },
                      )),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: MyTextButton(
                      alignment: Alignment.center,
                      buttonName: 'Save Changes',
                      onTap: () {
                        cacheFactory.set('language', _language);
                        changeLanguage(_language);
                        Navigator.pop(context);
                        widget.onDialogClosed?.call();
                      },
                      bgColor: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      height: 45,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // ),
          Positioned(
            top: 1,
            right: 1,
            child: IconButton(
              hoverColor:
                  Theme.of(context).secondaryHeaderColor.withOpacity(0.6),
              splashRadius: 20.0,
              icon: Container(
                height: 25,
                width: 25,
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> itemList() {
    return [
      'english',
      'portugues',
    ];
  }
}
