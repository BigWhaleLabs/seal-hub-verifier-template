import { assert } from 'chai'
import { wasm as wasmTester } from 'circom_tester'
import getNullifierCreatorInputs from '../utils/inputs/getNullifierCreatorInputs'

describe('NullifierCreator circuit', function () {
  before(async function () {
    this.circuit = await wasmTester('circuits/NullifierCreator.circom')
    this.baseInputs = await getNullifierCreatorInputs()
  })

  it('should generate the witness successfully', async function () {
    const inputs = await getNullifierCreatorInputs()
    const witness = await this.circuit.calculateWitness(inputs)
    await this.circuit.assertOut(witness, {})
    assert.equal(witness[1], inputs.x * inputs.y)
    assert.equal(witness[2], inputs.y)
  })
})
