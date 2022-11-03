pragma circom 2.0.4;

template PublicKeyConstructor() {
  var k = 4;
  // Get inputs
  signal input publicKey[2][k];
  // Compute public key number
  // TODO: generate a single public key number and output it
  output signal compactPublicKey <== ...;
}