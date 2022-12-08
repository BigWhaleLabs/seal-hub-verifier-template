pragma circom 2.0.4;

include "./templates/SealHubValidator.circom";
include "../circomlib/circuits/mimcsponge.circom";

template NullifierCreator() {
  var k = 4; // ECDSA verification number of components per number
  var levels = 30; // Depth of the commitment Merkle tree
  // Private inputs, *never* export them publicly
  signal input s[k]; // Pre-commitment signature component
  signal input U[2][k]; // Pre-commitment signature component
  signal input address; // Pre-commitment address
  signal input pathIndices[levels]; // Merkle proof that commitment is a part of the Merkle tree
  signal input siblings[levels]; // Merkle proof that commitment is a part of the Merkle tree
  // Verify SealHub commitment
  component sealHubValidator = SealHubValidator();
  for (var i = 0; i < k; i++) {
    sealHubValidator.s[i] <== s[i];
    sealHubValidator.U[0][i] <== U[0][i];
    sealHubValidator.U[1][i] <== U[1][i];
  }
  sealHubValidator.address <== address;
  for (var i = 0; i < levels; i++) {
    sealHubValidator.pathIndices[i] <== pathIndices[i];
    sealHubValidator.siblings[i] <== siblings[i];
  }
  // Export Merkle root
  signal output merkleRoot <== sealHubValidator.merkleRoot;

  // !! By now, we have verified that the user:
  // !! 1. Knows the signature r, U with the address
  // !! 2. Commitment derived from r, U and the address are in the Merkle tree
  // !! We can now use r, U, address to create a nullifier that will be deterministic for this r, U and address

  // Compute nullifier
  component nullifierMimc = MiMCSponge(3 * k + 3, 220, 1);
  nullifierMimc.k <== 0;
  // Fill in pre-commitment
  for (var i = 0; i < k; i++) {
    nullifierMimc.ins[i] <== s[i];
    nullifierMimc.ins[k + i] <== U[0][i];
    nullifierMimc.ins[2 * k + i] <== U[1][i];
  }
  nullifierMimc.ins[3 * k] <== address;
  // Add extra numbers specific to our application (just to scramble the hash)
  nullifierMimc.ins[3 * k + 1] <== 69;
  nullifierMimc.ins[3 * k + 2] <== 420;
  // Export nullifier
  signal output nullifierHash <== nullifierMimc.outs[0];

  // !! We are now sure that the user who generates this ZKP
  // !! knows the signature s, U signed with private key corresponding
  // !! to the address. We can use this address anyway we want
  // !! e.g. proving that it's a part of a merkle tree of Cryptopunk holders and exporting
  // !! the merkle root
  // !! But we *should not* export it as a public output

  // Print the address
  log(address); // *Never* export this publicly
}

component main = NullifierCreator();