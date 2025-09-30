import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_encryptor_method_channel.dart';

abstract class NativeEncryptorPlatform extends PlatformInterface {
  /// Constructs a NativeEncryptorPlatform.
  NativeEncryptorPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeEncryptorPlatform _instance = MethodChannelNativeEncryptor();

  /// The default instance of [NativeEncryptorPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeEncryptor].
  static NativeEncryptorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeEncryptorPlatform] when
  /// they register themselves.
  static set instance(NativeEncryptorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> encrypt(
      {required String passPhrase, required String contentToEncrypt}) {
    throw UnimplementedError('encrypt() has not been implemented.');
  }

  Future<String?> decrypt(
      {required String passPhrase, required String concatenatedCipherText}) {
    throw UnimplementedError('encrypt() has not been implemented.');
  }

  Future<String?> encryptWithCustomIV(
      {required String passPhrase,
      required String iv,
      required String contentToEncrypt}) {
    throw UnimplementedError('encrypt() has not been implemented.');
  }

  Future<String?> decryptWithCustomIV(
      {required String passPhrase,
      required String iv,
      required String concatenatedCipherText}) {
    throw UnimplementedError('encrypt() has not been implemented.');
  }
}
