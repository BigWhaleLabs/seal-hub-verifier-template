import { BigIntOrString, Input } from 'utils/Input'

export default function generateCommitment(inputs: Input) {
  const k = 4
  const prepHash: BigIntOrString[] = []

  for (let i = 0; i < k; i++) {
    prepHash[i] = inputs.s[0][i]
    prepHash[k + i] = inputs.U[0][i]
    prepHash[2 * k + i] = inputs.U[1][i]
    prepHash[3 * k + i] = inputs.pubKey[0][i]
    prepHash[4 * k + i] = inputs.pubKey[1][i]
  }

  return prepHash.flat().map((v) => BigInt(v))
}
