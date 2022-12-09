import { BigNumber, utils } from 'ethers'
import {
  getCommitmentFromPrecommitment,
  getMerkleTreeInputs,
  getMessageForAddress,
  getUAndSFromSignature,
} from '@big-whale-labs/seal-hub-kit'
import wallet from '../wallet'

const ninetyNineCommitments = Array(99)
  .fill(undefined)
  .map(() => BigNumber.from(utils.randomBytes(32)).toBigInt())

export default async function (commitments = ninetyNineCommitments) {
  const message = getMessageForAddress(wallet.address)
  const signature = await wallet.signMessage(message)

  const { U, s } = getUAndSFromSignature(signature, message)
  const address = utils.verifyMessage(message, signature)
  const commitment = await getCommitmentFromPrecommitment({ U, s, address })
  const merkleTreeInputs = await getMerkleTreeInputs(commitment, [
    ...commitments,
    commitment,
  ])
  return {
    s,
    U,
    address,
    ...merkleTreeInputs,
  }
}
