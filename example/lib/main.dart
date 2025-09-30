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
  final _nativeEncryptorPlugin = NativeEncryptor();
  final TextEditingController _controller = TextEditingController(
    text: "Hello, from flutter team.",
  );
  final TextEditingController _customController = TextEditingController(
    text: "Hello, from Subhash Chandra Shukla.",
  );
  String? randomDecrypted;
  String? randomEncrypted;

  String? customDecrypted;
  String? customEncrypted;

  String customIv = "mn16t7t2x74uvm7b";

  String passPhrase = "ma93m3c2z92vvs1b81vozbxv5j2ntvax";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Native encryptor')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              spacing: 20,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 3,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              'Encryption/Decryption with Custom IV',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _customController,
                              decoration: const InputDecoration(
                                label: Text("Content to encrypt"),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (customEncrypted != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  "Encrypted value - $customEncrypted",
                                ),
                              ),
                            if (customDecrypted != null)
                              Text("Decrypted value - $customDecrypted"),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () async {
                                customEncrypted = await _nativeEncryptorPlugin
                                    .encryptWithCustomIV(
                                      passPhrase: passPhrase,
                                      iv: customIv,
                                      contentToEncrypt: _customController.text,
                                    );
                                setState(() {});
                              },
                              child: const Text("Encrypt"),
                            ),
                            if (customEncrypted != null)
                              ElevatedButton(
                                onPressed: () async {
                                  customDecrypted = await _nativeEncryptorPlugin
                                      .decryptWithCustomIV(
                                        passPhrase: passPhrase,
                                        iv: customIv,
                                        concatenatedCipherText:
                                            customEncrypted ?? "",
                                      );

                                  setState(() {});
                                },
                                child: const Text("Decrypt"),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 3,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              'Encryption/Decryption with random generated IV',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                label: Text("Content to encrypt"),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (randomEncrypted != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  "Encrypted value - $randomEncrypted",
                                ),
                              ),
                            if (randomDecrypted != null)
                              Text("Decrypted value - $randomDecrypted"),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () async {
                                randomEncrypted = await _nativeEncryptorPlugin
                                    .encrypt(
                                      passPhrase: passPhrase,
                                      contentToEncrypt: _controller.text,
                                    );
                                setState(() {});
                              },
                              child: const Text("Encrypt"),
                            ),
                            if (randomEncrypted != null)
                              ElevatedButton(
                                onPressed: () async {
                                  randomDecrypted = await _nativeEncryptorPlugin
                                      .decrypt(
                                        passPhrase: passPhrase,
                                        concatenatedCipherText:
                                            randomEncrypted ?? "",
                                      );

                                  setState(() {});
                                },
                                child: const Text("Decrypt"),
                              ),
                          ],
                        ),
                      ),
                    ),
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
