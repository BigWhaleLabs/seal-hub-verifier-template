import { BigNumber, utils } from 'ethers'
import { IncrementalMerkleTree } from '@zk-kit/incremental-merkle-tree'
import { Input } from 'utils/Input'
import { buildPoseidon } from 'circomlibjs'
import Mimc7 from '../Mimc7'
import generateCommitment from './generateCommitment'
import generateInputs from './generateInputs'
import wallet from '../wallet'

async function merkleTreeInputsForSig(signatureInputs: Input) {
  const preCommitment = generateCommitment(signatureInputs)
  const mimc7 = await new Mimc7().prepare()
  const commitment = BigNumber.from(mimc7.hash(preCommitment)).toBigInt()
  const ninetyNineCommitments = Array(99)
    .fill(undefined)
    .map(() => BigNumber.from(utils.randomBytes(32)).toBigInt())
  const poseidon = await buildPoseidon()
  const tree = new IncrementalMerkleTree(poseidon, 30, BigInt(0), 2)
  ninetyNineCommitments.forEach((c) => tree.insert(c))
  tree.insert(commitment)
  const proof = tree.createProof(99)
  return {
    pathIndices: proof.pathIndices,
    siblings: proof.siblings.map(([s]) => BigNumber.from(s).toHexString()),
  }
}

export default async function () {
  const signatureInputs = await generateInputs(
    wallet,
    `Signature for SealHub ${wallet.address}`
  )
  const merkleTreeInputs = await merkleTreeInputsForSig(signatureInputs)
  return {
    ...signatureInputs,
    ...merkleTreeInputs,
  }
}
