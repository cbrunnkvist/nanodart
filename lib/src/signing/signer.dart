import 'dart:typed_data';
import 'package:nanodart/src/crypto/blake2b.dart';
import 'package:nanodart/src/crypto/tweetnacl_blake2b.dart';
import 'package:nanodart/src/util.dart';

class NanoSignatures {
  static String signBlock(String hash, String privKey) {
    return NanoHelpers.byteToHex(Signature.detached(
            NanoHelpers.hexToBytes(hash), NanoHelpers.hexToBytes(privKey)))
        .toUpperCase();
  }

  /// Sign a message according to NOMS (Nano Off-chain Message Signing) standard (ORIS-001)
  static String signMessage(String message, String privKey) {
    Uint8List header =
        NanoHelpers.stringToBytesUtf8('\x18Nano Off-chain Message:\n');
    Uint8List messageBytes = NanoHelpers.stringToBytesUtf8(message);
    Uint8List lengthBytes = NanoHelpers.intToBytes(messageBytes.length, 4);

    Uint8List payloadHash =
        Blake2b.digest256([header, lengthBytes, messageBytes]);

    return NanoHelpers.byteToHex(Signature.detached(
            payloadHash, NanoHelpers.hexToBytes(privKey)))
        .toUpperCase();
  }

  /// Verify a message signature according to NOMS (Nano Off-chain Message Signing) standard (ORIS-001)
  static bool verifyMessage(
      String message, String signature, String publicKey) {
    Uint8List header =
        NanoHelpers.stringToBytesUtf8('\x18Nano Off-chain Message:\n');
    Uint8List messageBytes = NanoHelpers.stringToBytesUtf8(message);
    Uint8List lengthBytes = NanoHelpers.intToBytes(messageBytes.length, 4);

    Uint8List payloadHash =
        Blake2b.digest256([header, lengthBytes, messageBytes]);

    return Signature.detachedVerify(
        payloadHash,
        NanoHelpers.hexToBytes(signature),
        NanoHelpers.hexToBytes(publicKey));
  }
}