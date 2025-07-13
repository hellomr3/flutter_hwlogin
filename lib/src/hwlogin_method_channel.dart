import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'login_result.dart';

import 'hwlogin_platform_interface.dart';

/// An implementation of [HwloginPlatform] that uses method channels.
class MethodChannelHwlogin extends HwloginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.looptry/hwlogin');

  Future<String?> getPhone() async {
    try {
      final result = await methodChannel.invokeMethod<String>('getPhone');
      return result;
    } catch (error) {
      print('HwLoginPlatform: Failed to get phone: $error');
      return null;
    }
  }

  Future<LoginResult> login() async {
    try {
      final result = await methodChannel.invokeMethod<String>('login');
      return LoginResult(success: true, authCode: result);
    } on PlatformException catch (error) {
      return LoginResult(
          success: false, errorCode: error.code, errorMessage: error.message);
    }
  }
}
