import { BigIntOrString, Input } from '../Input'
import MimcSponge from '../MimcSponge'

export default async function getNullifier(inputs: Input) {
  const k = 4
  const prepHash: BigIntOrString[] = []

  for (let i = 0; i < k; i++) {
    prepHash[i] = inputs.r[0][i]
    prepHash[k + i] = inputs.s[0][i]
  }

  prepHash[2 * k] = '420'
  prepHash[2 * k + 1] = '69'

  const mimc7 = await new MimcSponge().prepare()
  const preNullifier = prepHash.flat().map((v) => BigInt(v))
  const nullifier = mimc7.hash(preNullifier)

  return nullifier
}
