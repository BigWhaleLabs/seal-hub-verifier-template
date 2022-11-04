pragma circom 2.0.4;

include "../../node_modules/circomlib/circuits/bitify.circom";

// Sourced from https://github.com/0xPARC/circom-ecdsa/blob/master/circuits/zk-identity/eth.circom
template FlattenPubkey(numBits, k) {
  signal input chunkedPubkey[2][k];
  signal output pubkeyBits[512];
  assert(numBits*k >= 256);
  component chunks2BitsY[k];
  for(var chunk = 0; chunk < k; chunk++){
    chunks2BitsY[chunk] = Num2Bits(numBits);
    chunks2BitsY[chunk].in <== chunkedPubkey[1][chunk];

    for(var bit = 0; bit < numBits; bit++){
        var bitIndex = bit + numBits * chunk;
        if(bitIndex < 256) {
          pubkeyBits[bitIndex] <== chunks2BitsY[chunk].out[bit];
        }
    }
  }
  component chunks2BitsX[k];
  for(var chunk = 0; chunk < k; chunk++){
    chunks2BitsX[chunk] = Num2Bits(numBits);
    chunks2BitsX[chunk].in <== chunkedPubkey[0][chunk];

    for(var bit = 0; bit < numBits; bit++){
        var bitIndex = bit + 256 + (numBits * chunk);
        if(bitIndex < 512) {
          pubkeyBits[bitIndex] <== chunks2BitsX[chunk].out[bit];
        }
    }
  }
}

template PublicKeyChunksToNum() {
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
  component bits2Num = Bits2Num(512);
  for (var i = 0; i < 512; i++) {
    bits2Num.in[i] <== flattenPubkey.pubkeyBits[i];
  }
  signal output publicKeyNum <== bits2Num.out;
}