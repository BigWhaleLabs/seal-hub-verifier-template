pragma circom 2.0.4;

include "./templates/SealHubValidator.circom";
include "./templates/PublicKeyConstructor.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";

template NullifierCreator() {
  var k = 4;
  // Get inputs
  signal input r[k]; // Pre-commitment signature
  signal input s[k]; // Pre-commitment signature
  signal input pubKey[2][k]; // Pre-commitment public key
  signal input pathIndices[levels]; // Merkle proof that commitment is a part of the Merkle tree
  signal input siblings[levels]; // Merkle proof that commitment is a part of the Merkle tree
  // Verify SealHub commitment
  component sealHubValidator = SealHubValidator();
  sealHubValidator.r <== r;
  sealHubValidator.s <== s;
  sealHubValidator.pubKey <== pubKey;
  sealHubValidator.pathIndices <== pathIndices;
  sealHubValidator.siblings <== siblings;
  // Export Merkle root
  signal output merkleRoot <== sealHubValidator.merkleRoot;

  // !! By now, we have verified that the user:
  // !! 1. Knows the signature r, s with pubKey
  // !! 2. Commitments derived from r, s are in the Merkle tree
  // !! We can now use r, s to create a nullifier that will be deterministic for this r, s

  // Compute nullifier
  component mimc = MiMCSponge(4, 220, 1);
  mimc.ins[0] <== r;
  mimc.ins[1] <== s;
  mimc.ins[2] <== 420;
  mimc.ins[3] <== 69;
  mimc.k <== 0;
  // Export nullifier
  signal output nullifierHash <== mimc.outs[0];

  // !! We are now sure that the user who generates this ZKP
  // !! knows the signature r, s signed with private key corresponding
  // !! to the pubKey. We can use this pubKey anyway we want
  // !! But we *should not* export it as a public output

  // Get the compact public key
  component publicKeyConstructor = PublicKeyConstructor();
  publicKeyConstructor.publicKey <== pubKey;
  signal compactPublicKey <== publicKeyConstructor.compactPublicKey;
}

component main = NullifierCreator();