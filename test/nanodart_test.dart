import 'dart:typed_data';

import 'package:nanodart/nanodart.dart';
import 'package:test/test.dart';

void main() { 
  group('nanodart tests', () {
    test('test seed to private key', () {
      expect(NanoKeys.seedToPrivate('E11A48D701EA1F8A66A4EB587CDC8808D726FE75B325DF204F62CA2B43F9ADA1', 0), '67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6');
      expect(NanoKeys.seedToPrivate('E11A48D701EA1F8A66A4EB587CDC8808D726FE75B325DF204F62CA2B43F9ADA1', 1), '22EDDBF0D72E9A4232C3FE6689A6CB0A228C9ED822715A63E2F8644AA2C905A4');
    });

    test('test address from seed', () {
      String privKey = '67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6';
      expect(NanoAccounts.createAccount(NanoAccountType.BANANO, 
                                        NanoKeys.createPublicKey(privKey)),
            'ban_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkggc');
      expect(NanoAccounts.createAccount(NanoAccountType.NANO, 
                                        NanoKeys.createPublicKey(privKey)),
            'nano_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkggc');
    });

    test('test hex to byte array and back', () {
      String hex = '67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6';
      Uint8List byteArray = NanoHelpers.hexToBytes('67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6');
      expect(NanoHelpers.byteToHex(byteArray), hex);
    });

    test('test hex to binary and back', () {
      String hex = '67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6';
      String binary = NanoHelpers.hexToBinary('67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6');
      expect(NanoHelpers.binaryToHex(binary), hex);
    });

    test('test bigint to byte and back', () {
      BigInt raw = BigInt.parse('1000000000000000000000000000000');
      Uint8List byteRaw = NanoHelpers.bigIntToBytes(raw);
      expect(NanoHelpers.byteToBigInt(byteRaw), raw);
    });
    test('test address validation', () {
      // Three valid accounts
      expect(NanoAccounts.isValid(NanoAccountType.BANANO, 'ban_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkggc'), true);
      expect(NanoAccounts.isValid(NanoAccountType.NANO, 'xrb_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkggc'), true);
      expect(NanoAccounts.isValid(NanoAccountType.NANO, 'nano_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkggc'), true);
      // Invalid checksum
      expect(NanoAccounts.isValid(NanoAccountType.BANANO, 'ban_3zzzzzzzzzzzhw11111111111111111111111111111111111111spcronyu'), false);
      // Too short of length
      expect(NanoAccounts.isValid(NanoAccountType.BANANO, 'ban_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkg'), false);
      // Invalid prefix
      expect(NanoAccounts.isValid(NanoAccountType.BANANO, 'xrb_1p95xji1g5gou8auj8h6qcuezpdpcyoqmawao6mpwj4p44939oouoturkggc'), false);
    });

    test('test state block hash computation', () {
      // open state block
      int accountType = NanoAccountType.NANO;
      String account = 'xrb_3igf8hd4sjshoibbbkeitmgkp1o6ug4xads43j6e4gqkj5xk5o83j8ja9php';
      String previous = '0';
      String representative = 'xrb_3p1asma84n8k84joneka776q4egm5wwru3suho9wjsfyuem8j95b3c78nw8j';
      BigInt balance = BigInt.parse('1');
      String link = '1EF0AD02257987B48030CC8D38511D3B2511672F33AF115AD09E18A86A8355A8';
      String calculatedHash = NanoBlocks.computeStateHash(accountType, account, previous, representative, balance, link);
      expect(calculatedHash,
            'FC5A7FB777110A858052468D448B2DF22B648943C097C0608D1E2341007438B0');
      // receive state block
      account = 'xrb_3igf8hd4sjshoibbbkeitmgkp1o6ug4xads43j6e4gqkj5xk5o83j8ja9php';
      previous = 'FC5A7FB777110A858052468D448B2DF22B648943C097C0608D1E2341007438B0';
      representative = 'xrb_3p1asma84n8k84joneka776q4egm5wwru3suho9wjsfyuem8j95b3c78nw8j';
      balance = BigInt.parse('5000000000000000000000000000001');
      link = 'B2EC73C1F503F47E051AD72ECB512C63BA8E1A0ACC2CEE4EA9A22FE1CBDB693F';
      calculatedHash = NanoBlocks.computeStateHash(accountType, account, previous, representative, balance, link);
      expect(calculatedHash,
            '597395E83BD04DF8EF30AF04234EAAFE0606A883CF4AEAD2DB8196AAF5C4444F');
      // send state block
      account = 'xrb_3igf8hd4sjshoibbbkeitmgkp1o6ug4xads43j6e4gqkj5xk5o83j8ja9php';
      previous = '597395E83BD04DF8EF30AF04234EAAFE0606A883CF4AEAD2DB8196AAF5C4444F';
      representative = 'xrb_3p1asma84n8k84joneka776q4egm5wwru3suho9wjsfyuem8j95b3c78nw8j';
      balance = BigInt.parse('3000000000000000000000000000001');
      link = 'xrb_1q3hqecaw15cjt7thbtxu3pbzr1eihtzzpzxguoc37bj1wc5ffoh7w74gi6p';
      calculatedHash = NanoBlocks.computeStateHash(accountType, account, previous, representative, balance, link);
      expect(calculatedHash,
            '128106287002E595F479ACD615C818117FCB3860EC112670557A2467386249D4');
      // change state block
      account = 'xrb_3igf8hd4sjshoibbbkeitmgkp1o6ug4xads43j6e4gqkj5xk5o83j8ja9php';
      previous = '128106287002E595F479ACD615C818117FCB3860EC112670557A2467386249D4';
      representative = 'xrb_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs';
      balance = BigInt.parse('3000000000000000000000000000001');
      link = '0000000000000000000000000000000000000000000000000000000000000000';
      calculatedHash = NanoBlocks.computeStateHash(accountType, account, previous, representative, balance, link);
      expect(calculatedHash,
            '2A322FD5ACAF50C057A8CF5200A000CF1193494C79C786B579E0B4A7D10E5A1E');
    });

    test('test block signature', () {
      String privKey = '9F0E444C69F77A49BD0BE89DB92C38FE713E0963165CCA12FAF5712D7657120F';
      String hash = 'AEC75F807DCE45AFA787DE7B395BE498A885525569DD614162E0C80FD4F27EE9';

      String signature = NanoSignatures.signBlock(hash, privKey);

      expect(signature,
            '1123C926EF53B0FFA3585D5F6FA17D05B2AAD486D28CBEED88837B83265F264CBAF3FEA78AF80AAB4C59740546B220ADBE207F6B800FFE864E0934E9C1078401');
    });
    test('Can turn a nano seed into a mnemonic phrase and back', () {
      String seed = 'BE3E51EE51BAB11950B2495013512FEB110D9898B4137DA268709621CE2862F4';
      List<String> expectedWordsOrdered = [
        'sail', 'verb', 'knee', 'pet',
        'prison', 'million', 'drift', 'empty',
        'exotic', 'once', 'episode', 'stomach',
        'awkward', 'slush', 'glare', 'list',
        'laundry', 'battle', 'bring', 'clump',
        'brother', 'before', 'mesh', 'pair'
      ];
      List<String> seedAsMnemonic = NanoMnemomics.seedToMnemonic(seed);
      expect(seedAsMnemonic.length, expectedWordsOrdered.length);
      for (int i = 0; i < seedAsMnemonic.length; i++) {
        expect(expectedWordsOrdered[i], seedAsMnemonic[i]);
      }
      /// Turn it back to a seed
      expect(NanoMnemomics.mnemonicListToSeed(expectedWordsOrdered), seed);
    });
    test('Can turn a utf-8 string into a byte array and back', () {
      String originalStr = 'bbedward';
      Uint8List asBytes = NanoHelpers.stringToBytesUtf8(originalStr);
      expect(NanoHelpers.bytesToUtf8String(asBytes), originalStr);
    });
    test('Can concatenate byte arrays', () {
      Uint8List hex1 = NanoHelpers.hexToBytes('CA02');
      Uint8List hex2 = NanoHelpers.hexToBytes('F2D1');
      expect(NanoHelpers.byteToHex(NanoHelpers.concat([hex1, hex2])), 'CA02F2D1');
    });
    test('Can encrypt and decrypt a seed/private key', () {
      Uint8List seed = NanoHelpers.hexToBytes('E11A48D701EA1F8A66A4EB587CDC8808D726FE75B325DF204F62CA2B43F9ADA1');
      String password = 'abc123';
      // Encrypt seed
      Uint8List encrypted = NanoCrypt.encrypt(seed, password);
      // Decrypt seed
      Uint8List decrypted = NanoCrypt.decrypt(encrypted, password);
      expect(NanoHelpers.byteToHex(decrypted), NanoHelpers.byteToHex(seed));
    });

    test('test NOMS message signing and verification', () {
      String privKey =
          '67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6';
      String publicKey = NanoKeys.createPublicKey(privKey);
      String message = 'Hello Nano!';

      String signature = NanoSignatures.signMessage(message, privKey);

      // Verify correct signature
      expect(NanoSignatures.verifyMessage(message, signature, publicKey), true);

      // Verify failure with wrong message
      expect(
          NanoSignatures.verifyMessage('Hello Nano?', signature, publicKey),
          false);

      // Verify failure with wrong signature
      String invalidSignature = signature.replaceFirst('A', 'B');
      expect(
          NanoSignatures.verifyMessage(message, invalidSignature, publicKey),
          false);

      // Verify failure with wrong public key
      String otherPrivKey =
          '22EDDBF0D72E9A4232C3FE6689A6CB0A228C9ED822715A63E2F8644AA2C905A4';
      String otherPublicKey = NanoKeys.createPublicKey(otherPrivKey);
      expect(NanoSignatures.verifyMessage(message, signature, otherPublicKey),
          false);
    });

    test('test NOMS message signing and verification with known vector', () {
      // Known vector provided by user
      String privKey =
          '681FD5ED71A9F81E9D29E3450F6CD8AACB87346FD21A26003389290B9D0CB173';
      String expectedPublicKey =
          'D2B3C9D00FFB55E84E7979D67308A515FB07CA79E40A77EB1AAFE62881781783';
      String expectedAddress =
          'nano_3noms9a1zytox399kygpge6cc7hu1z79ms1cgzojodz8741qi7w5u3nzb8mn';
      String message = 'Hej Nano!🥦';
      String expectedSignature =
          '535C745819D0F40056F3C46402B4FAE4356B3A8897BDE99C955D411920E740D781E6DDDCBDE228E8B86C4383A1003F9F315519FF73BD356F561D19865DC90F09';

      // Verify key derivation
      String publicKey = NanoKeys.createPublicKey(privKey);
      expect(publicKey.toUpperCase(), expectedPublicKey.toUpperCase());

      // Verify address generation
      String address =
          NanoAccounts.createAccount(NanoAccountType.NANO, publicKey);
      expect(address, expectedAddress);

      // Verify signing
      String signature = NanoSignatures.signMessage(message, privKey);
      expect(signature.toUpperCase(), expectedSignature.toUpperCase());

      // Verify verification
      expect(NanoSignatures.verifyMessage(message, signature, publicKey), true);
    });

    test('test NOMS message signing and verification with library-generated key',
        () {
      // Path 2: Library-generated key
      String seed = NanoSeeds.generateSeed();
      String privKey = NanoKeys.seedToPrivate(seed, 0);
      String publicKey = NanoKeys.createPublicKey(privKey);
      String address =
          NanoAccounts.createAccount(NanoAccountType.NANO, publicKey);
      String message = 'Test message for library-generated key 🚀';

      // Sign
      String signature = NanoSignatures.signMessage(message, privKey);

      // Verify
      expect(NanoSignatures.verifyMessage(message, signature, publicKey), true);

      // Verify address matches the public key
      expect(NanoAccounts.createAccount(NanoAccountType.NANO, publicKey),
          address);

      // Negative test: wrong message
      expect(NanoSignatures.verifyMessage(message + '!', signature, publicKey),
          false);
    });

    test('test NOMS message signing and verification with empty message', () {
      String privKey =
          '67EDBC8F904091738DF33B4B6917261DB91DD9002D3985A7BA090345264A46C6';
      String publicKey = NanoKeys.createPublicKey(privKey);
      String message = '';

      // Sign
      String signature = NanoSignatures.signMessage(message, privKey);
      expect(signature,
          '06ABEFD232DEF6238AB88ADA8EF6500BE81C8C516D4C34D61273F2DAE706339611F2E58570575AE6DAA43381FC479615D23690FFBE26F678579D8779735F7D0B');

      // Verify
      expect(NanoSignatures.verifyMessage(message, signature, publicKey), true);
    });

    test('test NOMS verification with OWS-generated signature (dogfooding)', () {
      String address =
          "nano_1hfrig58wzrg4pzqen17cyannpy1173oi7jz7zd6srjsqjh7ozcgec9uyo9n";
      String message = "I am me.";
      String signature =
          "3de8620fb30967916d3dc36cd09eba9a633d1678b986fbc31b70ae2834db25a898085bbce32b744aef42ed56b5c001ffebd5516e78c9f22c678dde2d8bdc150a";

      String publicKey = NanoAccounts.extractPublicKey(address);
      expect(publicKey.toUpperCase(),
          '3DB883866E7F0E15BF76500557914A5BC0014358163F2FD64CE239BC5E5AFD4E');

      // Verify
      expect(NanoSignatures.verifyMessage(message, signature, publicKey), true);
    });
  });
}
