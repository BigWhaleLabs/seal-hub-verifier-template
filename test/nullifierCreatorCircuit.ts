import { BigNumber, utils } from 'ethers'
import { expect } from 'chai'
import {
  getCommitmentFromPrecommitment,
  getMerkleTreeProof,
  getMessage,
  getUAndSFromSignature,
} from '@big-whale-labs/seal-hub-kit'
import { wasm as wasmTester } from 'circom_tester'
import getNullifier from '../utils/inputs/getNullifier'
import getNullifierCreatorInputs from '../utils/inputs/getNullifierCreatorInputs'
import wallet from '../utils/wallet'

describe('NullifierCreator circuit', function () {
  before(async function () {
    this.circuit = await wasmTester('circuits/NullifierCreator.circom')
    const message = getMessage()
    const signature = await wallet.signMessage(message)

    const { U, s } = getUAndSFromSignature(signature, message)
    const address = utils.verifyMessage(message, signature)
    this.commitment = await getCommitmentFromPrecommitment({ U, s, address })
    this.commitments = Array(99)
      .fill(undefined)
      .map(() => BigNumber.from(utils.randomBytes(32)).toBigInt())
    this.baseInputs = await getNullifierCreatorInputs(this.commitments)
    this.treeProof = await getMerkleTreeProof(this.commitment, [
      ...this.commitments,
      this.commitment,
    ])
  })
  it('should generate the witness successfully', async function () {
    const nullifier = await getNullifier(this.baseInputs)
    const witness = await this.circuit.calculateWitness(this.baseInputs)
    await this.circuit.assertOut(witness, {})
    expect(witness[1]).to.eq(this.treeProof.root)
    expect(witness[2]).to.eq(nullifier)
  })
})
