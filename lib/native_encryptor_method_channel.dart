import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_encryptor_platform_interface.dart';

/// An implementation of [NativeEncryptorPlatform] that uses method channels.
class MethodChannelNativeEncryptor extends NativeEncryptorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_encryptor');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> encrypt({required String passPhrase, required String contentToEncrypt}) async {
    try {
      final String? response = await methodChannel.invokeMethod('encrypt', {
        "passPhrase": passPhrase,
        "contentToEncrypt": contentToEncrypt,
      });
      log("Received encrypted value - $response");
      return response; // Response from native
    } catch (e) {
      log("Error on encrypt: $e");
      return null;
    }
  }

  @override
  Future<String?> decrypt({required String passPhrase, required String concatenatedCipherText}) async {
    try {
      String? response = await methodChannel.invokeMethod('decrypt', {
        "passPhrase": passPhrase,
        "concatenatedCipherText": concatenatedCipherText,
      });
      if (response != null && isBase64(response)) {
        log("Received decrypted value - $response");
        response = base64ToString(response);
      }
      return response; // Res
    } catch (e) {
      log("Error on decrypt: $e");
      return null;
    }
  }
  String? base64ToString(String base64String){
    try{
     return utf8.decode(base64.decode(base64String));
    }catch(e){
      return null;
    }
  }
  bool isBase64(String str) {
    try {
      // Try to decode the string and check if it produces valid UTF-8
      utf8.decode(base64.decode(str));
      return true;
    } catch (e) {
      return false;
    }
  }
}
