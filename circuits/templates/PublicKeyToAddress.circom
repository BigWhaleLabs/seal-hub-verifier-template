pragma circom 2.0.4;

include "../../circom-ecdsa/circuits/zk-identity/eth.circom";

// adapted from https://github.com/personaelabs/circuits
// which was adapted from https://github.com/jefflau/zk-identity
template PublicKeyToAddress() {
  var k = 4;
  var n = 64;
  // Get inputs
  signal input pubKey[2][k];
  // Compute address
  signal pubkeyBits[512];
  component flattenPubkey = FlattenPubkey(n, k);
  for (var i = 0; i < k; i++) {
    flattenPubkey.chunkedPubkey[0][i] <== pubKey[0][i];
    flattenPubkey.chunkedPubkey[1][i] <== pubKey[1][i];
  }
  for (var i = 0; i < 512; i++) {
    pubkeyBits[i] <== flattenPubkey.pubkeyBits[i];
  }
  component pubkeyToAddress = PubkeyToAddress();
  for (var i = 0; i < 512; i++) {
    pubkeyToAddress.pubkeyBits[i] <== pubkeyBits[i];
  }
  signal output address <== pubkeyToAddress.address;
}