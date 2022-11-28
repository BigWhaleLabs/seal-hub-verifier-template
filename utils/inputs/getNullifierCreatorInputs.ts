import { BigNumber, utils } from 'ethers'
import { IncrementalMerkleTree } from '@zk-kit/incremental-merkle-tree'
import { Input } from 'utils/Input'
import { buildPoseidon } from 'circomlibjs'
import generateCommitment from './generateCommitment'
import generateInputs from './generateInputs'
import wallet from '../wallet'

const ninetyNineCommitments = Array(99)
  .fill(undefined)
  .map(() => BigNumber.from(utils.randomBytes(32)).toBigInt())

export async function generateTreeProof(
  commitments: bigint[],
  signatureInputs: Input
) {
  const commitment = await generateCommitment(signatureInputs)

  const poseidon = await buildPoseidon()
  const F = poseidon.F
  const tree = new IncrementalMerkleTree(
    (values) => BigInt(F.toString(poseidon(values))),
    30,
    BigInt(0),
    2
  )
  commitments.forEach((c) => tree.insert(c))
  tree.insert(commitment)

  return tree.createProof(99)
}

async function merkleTreeInputsForSig(
  commitments: bigint[],
  signatureInputs: Input
) {
  const proof = await generateTreeProof(commitments, signatureInputs)

  return {
    pathIndices: proof.pathIndices,
    siblings: proof.siblings.map(([s]) => BigNumber.from(s).toHexString()),
  }
}

export default async function (commitments = ninetyNineCommitments) {
  const signatureInputs = await generateInputs(
    wallet,
    `Signature for SealHub ${wallet.address}`
  )
  const merkleTreeInputs = await merkleTreeInputsForSig(
    commitments,
    signatureInputs
  )
  return {
    ...signatureInputs,
    ...merkleTreeInputs,
  }
}
