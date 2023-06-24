import 'package:flutter/foundation.dart';

import 'context_menu_mobile.dart';
import 'context_menu_web.dart';

abstract class ContextMenu {
  void onContextMenu();

  factory ContextMenu() {
    if (!kIsWeb) {
      return ContextMenuMobile();
    } else {
      return ContextMenuWeb();
    }
  }
}
