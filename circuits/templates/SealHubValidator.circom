pragma circom 2.0.4;

include "../../circomlib/circuits/mimc.circom";
include "../helpers/MerkleTreeChecker.circom";

template SealHubValidator() {
  var k = 4;

  // Get inputs
  signal input s[k];
  signal input U[2][k];
  signal input pubKey[2][k];

  // Compute commitment
  component mimc7 = MultiMiMC7(k * 5, 91);
  mimc7.k <== 0;
  for (var i = 0; i < k; i++) {
    mimc7.in[i] <== s[i];
    mimc7.in[k + i] <== U[0][i];
    mimc7.in[2 * k + i] <== U[1][i];
    mimc7.in[3 * k + i] <== pubKey[0][i];
    mimc7.in[4 * k + i] <== pubKey[1][i];
  }

  signal output commitment <== mimc7.out;

  // Check Merkle tree
  var levels = 30;
  signal input pathIndices[levels];
  signal input siblings[levels];

  component merkleTreeChecker = MerkleTreeChecker(levels);
  merkleTreeChecker.leaf <== commitment;
  for (var i = 0; i < levels; i++) {
    merkleTreeChecker.pathElements[i] <== siblings[i];
    merkleTreeChecker.pathIndices[i] <== pathIndices[i];
  }
  signal output merkleRoot <== merkleTreeChecker.root;
}
