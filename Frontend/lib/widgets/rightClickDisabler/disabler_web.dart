import 'dart:html' as html;
import 'disabler.dart';

class disabler_stub implements disabler {
  disabler_stub._();

  static final disabler_stub _instance = disabler_stub._();

  factory disabler_stub() {
    return _instance;
  }

  @override
  void disableRightClick() {
    html.document.onContextMenu.listen((event) => event.preventDefault());
  }
}
