import 'dart:typed_data';
import 'package:pointycastle/export.dart';

Uint8List deriveKeyFromPin({required String pin, required Uint8List salt}) {
  final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));

  final derivationConfig = Pbkdf2Parameters(salt, 100000, 32);

  derivator.init(derivationConfig);

  return derivator.process(Uint8List.fromList(pin.codeUnits));
}
