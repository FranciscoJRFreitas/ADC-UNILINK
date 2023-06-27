import 'disabler_stub.dart'
    if (dart.library.html) 'disabler_web.dart'
    if (dart.library.io) 'disabler_other.dart';

class disabler_general {
  final disabler_stub impl;

  disabler_general() : impl = disabler_stub();

  void disable() {
    impl.disableRightClick();
  }
}

final disabler_general disablerFactory = disabler_general();
