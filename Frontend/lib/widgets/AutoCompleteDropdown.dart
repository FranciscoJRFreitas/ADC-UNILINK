/*import 'dart:convert';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../domain/Token.dart';
import 'package:http/http.dart' as http;

import '../features/userManagement/domain/User.dart';

class AutocompleteDropDown extends StatefulWidget {
  const AutocompleteDropDown({Key? key}) : super(key: key);

  @override
  State<AutocompleteDropDown> createState() => _SimpleDropDownState();
}

class _SimpleDropDownState extends State<AutocompleteDropDown> {
  String _selectedItem = '';
  final _formKey = GlobalKey<FormState>();
  late List<String> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = kBaseUrl + 'rest/list/';
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
      List<String> updatedUsers = responseBody
          .map((userJson) => User.fromJson(userJson).username)
          .toList();

      setState(() {
        users = updatedUsers;
        isLoading = false;
      });
    } else {
      print('Failed to fetch users: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text(
        "Send an Invite",
        textAlign: TextAlign.left,
      ),
      backgroundColor: Theme.of(context).canvasColor,
      content: SingleChildScrollView(
      child: Form(
        key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLoading
                    ? CircularProgressIndicator() // Show loading indicator
                    : AutocompleteTextField(
                  items: users!,
                  decoration: const InputDecoration(
                    labelText: "Select a User",
                    //hintText: title,
                    //hintStyle: Theme.of(context).textTheme.bodyMedium,
                    //labelStyle: Theme.of(context).textTheme.bodyMedium,
                   // contentPadding: padding ?? null,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(92, 161, 161, 161))),
                    errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0)),
                    focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0)),
                  ),
                  validator: (val) {
                    if (users!.contains(val)) {
                      return null;
                    } else {
                      return 'Invalid Country';
                    }
                  },
                  onItemSelect: (selected) {
                    setState(() {
                      _selectedItem = selected;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String message = 'Form invalid';
                    if (_formKey.currentState?.validate() ?? false) {
                      message = 'Form valid';
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                  child: const Text("Continue"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
      ));
    }
}

class AutocompleteTextField extends StatefulWidget {
  final List<String> items;
  final Function(String) onItemSelect;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;
  const AutocompleteTextField(
      {Key? key,
        required this.items,
        required this.onItemSelect,
        this.decoration,
        this.validator})
      : super(key: key);

  @override
  State<AutocompleteTextField> createState() => _AutocompleteTextFieldState();
}

class _AutocompleteTextFieldState extends State<AutocompleteTextField> {
  final FocusNode _focusNode = FocusNode();
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late List<String> _filteredItems;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context)?.insert(_overlayEntry);
      } else {
        _overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onFieldChange,
        decoration: widget.decoration,
        validator: widget.validator,
      ),
    );
  }

  void _onFieldChange(String val) {
    setState(() {
      if (val == '') {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where(
                (element) => element.toLowerCase().contains(val.toLowerCase()))
            .toList();
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
        builder: (context) => Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height + 5.0),
            child: Material(
              elevation: 4.0,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  itemCount: _filteredItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = _filteredItems[index];
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        setState(() {
                          _controller.text = item;
                        });
                        _focusNode.unfocus();
                        widget.onItemSelect(item);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ));
  }
}
*/
import 'package:flutter/material.dart';

class AutocompleteDropdown extends StatefulWidget {
  final List<String> options;

  AutocompleteDropdown({required this.options});

  @override
  _AutocompleteDropdownState createState() => _AutocompleteDropdownState();
}

class _AutocompleteDropdownState extends State<AutocompleteDropdown> {
  String _selectedOption = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return widget.options.where((option) =>
            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selectedOption) {
        setState(() {
          _selectedOption = selectedOption;
        });
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            labelText: 'Search',
          ),
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: Container(
              height: 200.0,
              width: 200.0,
              child: ListView(
                children: options
                    .map((String option) => ListTile(
                  title: Text(option),
                  onTap: () {
                    onSelected(option);
                  },
                ))
                    .toList(),
              ),
            ),
          ),
        );
      },
        ));
  }
}
