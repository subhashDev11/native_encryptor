**Native Encryptor for Flutter**

_A powerful plugin for secure data handling in your Flutter apps._

**Key Features**

*   Native Code Integration: Ensures top-tier security and performance.
*   Random Salt & IV: Adds an extra layer of protection.
*   Passphrase-Based Encryption: Customizable and flexible security.
*   User-Friendly API:** Simplifies integration into your Flutter app.
*   Cross-Platform Compatibility: Works seamlessly on both iOS and Android.

### Screenshots

<div align="center">
  <img src="https://github.com/user-attachments/assets/6eb6429e-85b9-42b9-ae37-d762cf6858be" alt="encrypted_value" width="220" height="320" style="margin-right: 15px;" />
  <img src="https://github.com/user-attachments/assets/2d0c52fd-6d4e-4fb2-8340-e9e0d446abee" alt="decrypted_value" width="220" height="320" style="margin-right: 15px;" />
  <img src="https://github.com/user-attachments/assets/284629df-88c2-4f10-bbbd-e87c8418eab3" alt="input_content" width="220" height="320" />
</div>

**Installation**

1.  **Add to `pubspec.yaml`:**
     
     YAML
    
   ```
  dependencies:
      native_encryptor: <latest_version>
   ```
    
2.  **Fetch the plugin:**
  
  Bash
   
   ```
   flutter pub get
   ```
  
3.  **Import in your Dart code:**
  Dart
    ```
     import 'package:native_encryptor/native_encryptor.dart';
    ```

**Basic Usage**

Dart

```
import 'package:flutter/material.dart';
import 'package:native_encryptor/native_encryptor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final    _nativeEncryptorPlugin = NativeEncryptor();
  final TextEditingController _controller = TextEditingController(text: "Secret Message");
  String? encryptedData;
  String? decryptedData;
  final String passphrase = "YourSecretPassphrase";

  Future<void> encrypt() async {
    encryptedData = await _nativeEncryptorPlugin.encrypt(
      passPhrase: passphrase,
      contentToEncrypt: _controller.text,
    );
    setState(() {});
  }

  Future<void> decrypt() async {
    decryptedData = await _nativeEncryptorPlugin.decrypt(
      passPhrase: passphrase,
      concatenatedCipherText: encryptedData!,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Native    Encryptor')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText:    'Enter text'),
              ),
              ElevatedButton(onPressed: encrypt, child: const Text('Encrypt')),
              if (encryptedData != null)
                Text('Encrypted: $encryptedData'),
              ElevatedButton(onPressed: decrypt, child: const Text('Decrypt')),
              if (decryptedData != null)
                Text('Decrypted: $decryptedData'),
            ],
          ),
        ),
      ),
    );
  }
}
```
**API Reference**

*  `encrypt({required String passPhrase, required String contentToEncrypt})` Encrypts the given content with the provided passphrase.
      Returns: The encrypted data as a string.
*  `decrypt({required String passPhrase, required String concatenatedCipherText})` Decrypts the given encrypted data with the provided passphrase.
    Returns: The original decrypted content.
*  `getPlatformVersion()` Retrieves the current platform version for debugging purposes.

**License**

This plugin is licensed under the MIT License.

**Contributing**

We welcome contributions! Please feel free to open issues or submit pull requests.

**Connect with me:**

* **GitHub:** https://github.com/subhashDev11
* **LinkedIn:** https://www.linkedin.com/in/subhashcs/
* **Medium:** https://medium.com/@subhashchandrashukla

**Enhance your Flutter app's security with Native Encryptor!**

