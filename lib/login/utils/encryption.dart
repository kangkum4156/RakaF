import 'package:encrypt/encrypt.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:typed_data';

final _iv = IV(Uint8List(16)); // 16바이트 0으로 채운 IV (고정)

// Remote Config에서 32바이트 key 가져오기
Future<String> fetchEncryptionKey() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.fetchAndActivate();

  final key = remoteConfig.getString('service_number_aes_key');

  if (key.length != 32) {
    throw Exception("AES 키는 32자여야 합니다. 현재 길이: ${key.length}");
  }

  return key;
}


Future<String> encryptServiceNumber(String input) async {
  final keyString = await fetchEncryptionKey();
  final key = Key.fromUtf8(keyString);

  final encrypter = Encrypter(
    AES(key, mode: AESMode.cbc, padding: 'PKCS7'), // ✅ 명시적으로 CBC + PKCS7
  );

  final encrypted = encrypter.encrypt(input, iv: _iv);
  return encrypted.base64;
}

// 복호화 함수
Future<String> decryptServiceNumber(String encryptedBase64) async {
  final keyString = await fetchEncryptionKey();
  final key = Key.fromUtf8(keyString);

  final encrypter = Encrypter(
    AES(key, mode: AESMode.cbc, padding: 'PKCS7'), // 암호화와 동일 설정
  );

  final decrypted = encrypter.decrypt(Encrypted.fromBase64(encryptedBase64), iv: _iv);
  return decrypted;
}
