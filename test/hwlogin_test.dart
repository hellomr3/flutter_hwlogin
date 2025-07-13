import 'package:flutter_test/flutter_test.dart';
import 'package:hwlogin/hwlogin.dart';
import 'package:hwlogin/hwlogin_platform_interface.dart';
import 'package:hwlogin/hwlogin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHwloginPlatform
    with MockPlatformInterfaceMixin
    implements HwloginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HwloginPlatform initialPlatform = HwloginPlatform.instance;

  test('$MethodChannelHwlogin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHwlogin>());
  });

  test('getPlatformVersion', () async {
    Hwlogin hwloginPlugin = Hwlogin();
    MockHwloginPlatform fakePlatform = MockHwloginPlatform();
    HwloginPlatform.instance = fakePlatform;

    expect(await hwloginPlugin.getPlatformVersion(), '42');
  });
}
