import 'package:flutter/widgets.dart';
import 'package:silentvoice/navigation/root_navigator.dart';

import 'app_lock_controller.dart';

class AppLifecycleHandler with WidgetsBindingObserver {
  static final AppLifecycleHandler _instance = AppLifecycleHandler._internal();

  factory AppLifecycleHandler() => _instance;

  AppLifecycleHandler._internal();

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (AppLockController.allowBackground) return;

    if (state == AppLifecycleState.inactive) {
      return;
    }

    if (state == AppLifecycleState.paused) {
      _lockApp();
    }
  }

  void _lockApp() {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamedAndRemoveUntil('/calculator', (route) => false);
  }
}
