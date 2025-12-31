import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPin(String pin, String salt) {
  final bytes = utf8.encode(pin + salt);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
