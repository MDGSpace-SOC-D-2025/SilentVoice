import 'dart:math';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';

class CallKitHelper {
  static Future<void> showIncomingCall() async {
    final String callId =
        DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(9999).toString();

    final CallKitParams params = CallKitParams(
      id: callId,
      nameCaller: 'Mom',
      appName: 'SilentVoice',
      handle: 'Mom_Call',
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      android: const AndroidParams(
        isCustomNotification: false,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',

        backgroundColor: '#000000',
        actionColor: '#4CAF50',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: false,
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  static Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }
}
