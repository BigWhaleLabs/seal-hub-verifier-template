import { BigIntOrString, Input } from '../Input'
import MimcSponge from '../MimcSponge'

export default async function getNullifier(inputs: Input) {
  const k = 4
  const prepHash: BigIntOrString[] = []

  for (let i = 0; i < k; i++) {
    prepHash[i] = inputs.s[i]
    prepHash[k + i] = inputs.U[0][i]
    prepHash[2 * k + i] = inputs.U[1][i]
  }

  prepHash[3 * k] = inputs.address
  prepHash[3 * k + 1] = 69n
  prepHash[3 * k + 2] = 420n

  const mimc7 = await new MimcSponge().prepare()
  const preNullifier = prepHash.flat().map((v) => BigInt(v))
  const nullifier = mimc7.hash(preNullifier)

  return nullifier
}
