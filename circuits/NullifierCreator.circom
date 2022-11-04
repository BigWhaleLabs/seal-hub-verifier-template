pragma circom 2.0.4;

include "./templates/SealHubValidator.circom";
include "./templates/PublicKeyToAddress.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";

template NullifierCreator() {
  var k = 4;
  var levels = 30;
  // Get inputs, *never* export them publicly
  signal input r[k]; // Pre-commitment signature
  signal input s[k]; // Pre-commitment signature
  signal input pubKey[2][k]; // Pre-commitment public key
  signal input pathIndices[levels]; // Merkle proof that commitment is a part of the Merkle tree
  signal input siblings[levels]; // Merkle proof that commitment is a part of the Merkle tree
  // Verify SealHub commitment
  component sealHubValidator = SealHubValidator();
  for (var i = 0; i < k; i++) {
    sealHubValidator.r[i] <== r[i];
    sealHubValidator.s[i] <== s[i];
    sealHubValidator.pubKey[0][i] <== pubKey[0][i];
    sealHubValidator.pubKey[1][i] <== pubKey[1][i];
  }
  for (var i = 0; i < levels; i++) {
    sealHubValidator.pathIndices[i] <== pathIndices[i];
    sealHubValidator.siblings[i] <== siblings[i];
  }
  // Export Merkle root
  signal output merkleRoot <== sealHubValidator.merkleRoot;

  // !! By now, we have verified that the user:
  // !! 1. Knows the signature r, s with pubKey
  // !! 2. Commitments derived from r, s are in the Merkle tree
  // !! We can now use r, s to create a nullifier that will be deterministic for this r, s

  // Compute nullifier
  component mimc = MiMCSponge(2 * k + 2, 220, 1);
  for (var i = 0; i < k; i++) {
    mimc.ins[i] <== r[i];
    mimc.ins[i + k] <== s[i];
  }
  mimc.ins[2 * k] <== 420;
  mimc.ins[2 * k + 1] <== 69;
  mimc.k <== 0;
  // Export nullifier
  signal output nullifierHash <== mimc.outs[0];

  // !! We are now sure that the user who generates this ZKP
  // !! knows the signature r, s signed with private key corresponding
  // !! to the pubKey. We can use this pubKey anyway we want
  // !! e.g. proving that it's a part of a merkle tree and exporting
  // !! the merkle root
  // !! But we *should not* export it as a public output

  // Get the compact public key
  component publicKeyToAddress = PublicKeyToAddress();
  for (var i = 0; i < k; i++) {
    publicKeyToAddress.pubKey[0][i] <== pubKey[0][i];
    publicKeyToAddress.pubKey[1][i] <== pubKey[1][i];
  }
  signal address <== publicKeyToAddress.address; // *Never* export this publicly
}

component main = NullifierCreator();