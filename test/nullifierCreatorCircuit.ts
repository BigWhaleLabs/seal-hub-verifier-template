import { BigNumber, utils } from 'ethers'
import { expect } from 'chai'
import { wasm as wasmTester } from 'circom_tester'
import getNullifier from '../utils/inputs/getNullifier'
import getNullifierCreatorInputs, {
  generateTreeProof,
} from '../utils/inputs/getNullifierCreatorInputs'

describe('NullifierCreator circuit', function () {
  before(async function () {
    this.circuit = await wasmTester('circuits/NullifierCreator.circom')
    this.commitments = Array(99)
      .fill(undefined)
      .map(() => BigNumber.from(utils.randomBytes(32)).toBigInt())
    this.baseInputs = await getNullifierCreatorInputs(this.commitments)
    this.treeProof = await generateTreeProof(this.commitments, this.baseInputs)
  })

  it('should generate the witness successfully', async function () {
    const nullifier = await getNullifier(this.baseInputs)
    const witness = await this.circuit.calculateWitness(this.baseInputs)
    await this.circuit.assertOut(witness, {})
    expect(witness[1]).to.eq(this.treeProof.root)
    expect(witness[2]).to.eq(nullifier)
  })
  it('should fail because inputs are different', async function () {
    let inputs = await getNullifier(this.baseInputs)
    const witness = await this.circuit.calculateWitness(this.baseInputs)
    // corrupt input
    inputs = BigInt(123)
    // corrupt treeProof
    const commitments = Array(99)
      .fill(undefined)
      .map(() => BigNumber.from(utils.randomBytes(32)).toBigInt())
    const treeProof = await generateTreeProof(commitments, this.baseInputs)
    await this.circuit.assertOut(witness, {})
    expect(witness[1]).to.not.eq(treeProof.root)
    expect(witness[2]).to.not.eq(inputs)
  })
})
