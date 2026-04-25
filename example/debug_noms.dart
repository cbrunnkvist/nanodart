import 'package:nanodart/nanodart.dart';

void main() {
  String seed = '681FD5ED71A9F81E9D29E3450F6CD8AACB87346FD21A26003389290B9D0CB173';
  String privKey = NanoKeys.seedToPrivate(seed, 0);
  print('Private Key (Seed Index 0): ' + privKey);
  
  String pk = NanoKeys.createPublicKey(privKey);
  print('Public Key for Private Key: ' + pk);
  print('Address for Public Key: ' + NanoAccounts.createAccount(NanoAccountType.NANO, pk));
}
