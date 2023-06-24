import 'package:unilink2023/data/disabler.dart';

class disabler_stub implements disabler {
  disabler_stub._();

  static final disabler_stub _instance = disabler_stub._();

  factory disabler_stub() {
    return _instance;
  }

  @override
  void disableRightClick() {
    // Fallback behavior for non-web platforms
  }
}
