import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
  String _platformVersion = 'Unknown';
  final _nativeEncryptorPlugin = NativeEncryptor();
  final TextEditingController _controller = TextEditingController(text: "Hello, from flutter team.");
  String? decrypted;
  String? encrypted;
  String passPhrase = "PassPhrase";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _nativeEncryptorPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native encryptor'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text('Running on: $_platformVersion\n'),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(label: Text("Content to encrypt")),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (encrypted != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                    ),
                    child: Text("Encrypted value - $encrypted"),
                  ),
                if (decrypted != null) Text("Decrypted value - $decrypted"),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () async {
                    encrypted = await _nativeEncryptorPlugin.encrypt(
                      passPhrase: passPhrase,
                      contentToEncrypt: _controller.text,
                    );
                    setState(() {});
                  },
                  child: const Text(
                    "Encrypt",
                  ),
                ),
                if (encrypted != null)
                  ElevatedButton(
                    onPressed: () async {
                      decrypted = await _nativeEncryptorPlugin.decrypt(
                        passPhrase: passPhrase,
                        concatenatedCipherText: encrypted ?? "",
                      );

                      setState(() {});
                    },
                    child: const Text(
                      "Decrypt",
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
