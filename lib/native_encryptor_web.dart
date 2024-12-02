import 'dart:developer';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:js' as js;
import 'native_encryptor_platform_interface.dart';

class NativeEncryptorWeb extends NativeEncryptorPlatform {
  NativeEncryptorWeb();

  static void registerWith(Registrar registrar) {
    NativeEncryptorPlatform.instance = NativeEncryptorWeb();
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = js.context['navigator']['userAgent'];
    return version;
  }

  @override
  Future<String?> encrypt({required String passPhrase, required String contentToEncrypt}) async {
    try {
      final result = await js.context.callMethod('aesService.encryptWithRandomSaltAndIv', [passPhrase, contentToEncrypt]);
      return result;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  @override
  Future<String?> decrypt({required String passPhrase, required String concatenatedCipherText}) async {
    try {
      final result = await js.context.callMethod('aesService.decryptWithConcatenatedCipherText', [passPhrase, concatenatedCipherText]);
      return result;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}