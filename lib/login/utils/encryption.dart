import 'package:encrypt/encrypt.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:typed_data';

Future<String> fetchEncryptionKey() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.fetchAndActivate();
  return remoteConfig.getString('service_number_aes_key');
}

final _iv = IV(Uint8List(16)); // 0으로 채운 IV

Future<String> encryptServiceNumber(String input) async {
  final keyString = await fetchEncryptionKey();
  final key = Key.fromUtf8(keyString);
  final encrypter = Encrypter(AES(key));
  return encrypter.encrypt(input, iv: _iv).base64;
}