import 'native_encryptor_platform_interface.dart';

class NativeEncryptor {
  Future<String?> getPlatformVersion() {
    return NativeEncryptorPlatform.instance.getPlatformVersion();
  }

  Future<String?> encrypt({required String passPhrase, required String contentToEncrypt}) {
    return NativeEncryptorPlatform.instance.encrypt(passPhrase: passPhrase, contentToEncrypt: contentToEncrypt);
  }

  Future<String?> decrypt({required String passPhrase, required String concatenatedCipherText}) {
    return NativeEncryptorPlatform.instance
        .decrypt(passPhrase: passPhrase, concatenatedCipherText: concatenatedCipherText);
  }
}
