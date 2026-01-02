import 'dart:typed_data';
import 'dart:math';

import 'package:pointycastle/export.dart';

class AesCrypto {
  static Uint8List encrypt({required Uint8List data, required Uint8List key}) {
    final iv = _randomBytes(16);

    final cipher = PaddedBlockCipher('AES/CBC/PKCS7');

    cipher.init(
      true,
      PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(key), iv),
        null,
      ),
    );

    final encryptedData = cipher.process(data);

    return Uint8List.fromList(iv + encryptedData);
  }

  static Uint8List decrypt({
    required Uint8List encryptedData,
    required Uint8List key,
  }) {
    final iv = encryptedData.sublist(0, 16);

    final ciphertext = encryptedData.sublist(16);

    final cipher = PaddedBlockCipher('AES/CBC/PKCS7');

    cipher.init(
      false,
      PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(key), iv),
        null,
      ),
    );

    return cipher.process(ciphertext);
  }

  static Uint8List _randomBytes(int length) {
    final rnd = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rnd.nextInt(256)),
    );
  }
}
