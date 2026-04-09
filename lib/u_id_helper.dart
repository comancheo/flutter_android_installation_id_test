import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:app_set_id/app_set_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_udid/flutter_udid.dart';
import 'package:crypto/crypto.dart';

class UIdHelper {
  Future<String?> flutterUdid() async {
    //Not supported in this version of Flutter
    final String? udid = null; //await FlutterUdid.consistentUdid;
    debugPrint('FlutterUdid: $udid');
    return udid;
  }

  Future<Map<String, dynamic>> allDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.androidInfo;
    final Map<String, dynamic> allDeviceInfo = deviceInfo.data;
    debugPrint('allDeviceInfo:');
    for (dynamic info in allDeviceInfo.entries) {
      debugPrint('$info');
    }
    return allDeviceInfo;
  }

  Future<String?> androidId() async {
    //Not supported in this version of Flutter
    // final androidIdPlugin = AndroidId();
    // final String? androidId = await androidIdPlugin.getId();
    // debugPrint('androidId: $androidId');

    return null;
  }

  Future<String?> appSetId() async {
    final String? appSetId = await AppSetId().getIdentifier();
    debugPrint('appSetId: $appSetId');
    return appSetId;
  }

  String? tryParseMacAddress() {
    try {
      final String res = shellSync('ip -d address show dev wlan0 | grep link/ether')
          .trim()
          .split(' ')
          .where((String s) {
            return s.indexOf(':') == 2;
          })
          .toList()[0]
          .toUpperCase()
          .replaceAll(':', '');
      debugPrint('tryParseMacAddress: $res');
      return res;
    } catch (error) {
      return null;
    }
  }

  String? getSerial() {
    final String? res = getFirstFilledProp(['ro.boot.device.wifi_mac', 'ro.boot.device.eth_mac', 'MAC Address', 'ro.boot.device.hwid', 'ro.boot.msmserialno', 'ro.hardware.uuid', 'net.hostname']); //.replace('android-', '');
    debugPrint('getSerial: $res');
    return res;
  }

  String? getFirstFilledProp(List<String> arguments) {
    for (var i = 0; i < arguments.length; i++) {
      var result = shellSync('getprop ""${arguments[i]}""').trim();
      if (result.isNotEmpty) return result;
    }
    return null;
  }

  Future<String> getDeviceString() async {
    final Map<String, dynamic> di = await allDeviceInfo();
    final String? udid = await flutterUdid();
    final String? aid = await androidId();
    final String? aSI = await appSetId();
    final String? mac = tryParseMacAddress();
    //final String? ramSize = di['physicalRamSize']?.toString(); //not supported yet
    final String? fingerprint = di['fingerprint'];
    final String? id = di['id'];
    //final String? totalDiskSize = di['totalDiskSize']?.toString(); //not supported yet
    final String? version = di['version']?.toString();
    String res = '$aSI $mac $fingerprint $id $version';
    debugPrint('getDeviceString: $res');
    return res;
  }

  Future<String> hash() async {
    String? deviceString = await getDeviceString();
    final Uint8List bytes = utf8.encode(deviceString); // data being hashed

    final Digest hash = sha512.convert(bytes);
    debugPrint("hash result: $hash");
    return hash.toString();
  }

  String shellSync(String command) {
    final result = Process.runSync('sh', ['-c', command]);
    _showWarnings(command, result);
    return result.stdout.toString().trim();
  }

  void _showWarnings(String command, ProcessResult result) {
    if (result.stderr.isNotEmpty) {
      if (result.exitCode == 0) {
        debugPrint("Warning running command '$command': ${result.stderr}");
      } else {
        debugPrint("Error running command '$command': ${result.stderr}");
      }
    }
  }
}
