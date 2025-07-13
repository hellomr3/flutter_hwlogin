import 'package:hwlogin/login_result.dart';

import 'hwlogin_platform_interface.dart';

class Hwlogin {
  Future<String?> getMaskPhone() {
    return HwloginPlatform.instance.getPhone();
  }

  Future<LoginResult> login() {
    return HwloginPlatform.instance.login();
  }
}
