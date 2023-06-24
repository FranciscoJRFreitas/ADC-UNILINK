import 'package:flutter/scheduler.dart';

import 'context_menu.dart';
//import 'dart:html' as html;

class ContextMenuWeb implements ContextMenu {
  @override
  void onContextMenu() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
  /*    html.window.onContextMenu.listen((event) {
        event.preventDefault();
      }); */
    });
  }
}
