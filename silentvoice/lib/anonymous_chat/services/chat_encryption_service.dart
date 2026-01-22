import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'dart:typed_data';

class ChatEncryptionService {
  Key _deriveKey(String chatId) {
    final bytes = utf8.encode(chatId);
    final padded = bytes.length >= 32
        ? bytes.sublist(0, 32)
        : Uint8List.fromList([...bytes, ...List.filled(32 - bytes.length, 0)]);
    return Key(Uint8List.fromList(padded));
  }

  final IV _iv = IV(Uint8List.fromList(List.filled(16, 0)));

  String encryptText({required String chatId, required String plainText}) {
    final key = _deriveKey(chatId);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  String decryptText({required String chatId, required String cipherText}) {
    try {
      final key = _deriveKey(chatId);

      final encrypter = Encrypter(
        AES(key, mode: AESMode.cbc, padding: 'PKCS7'),
      );

      return encrypter.decrypt(Encrypted.fromBase64(cipherText), iv: _iv);
    } catch (e) {
      return '[Unable to decrypt message]';
    }
  }
}
