import { cwd } from 'process'
import { resolve } from 'path'
import { writeFileSync } from 'fs'
import getNullifierCreatorInputs from '../utils/inputs/getNullifierCreatorInputs'

void (async () => {
  const inputs = {
    'nullifier-creator': getNullifierCreatorInputs,
  }
  for (const [name, fn] of Object.entries(inputs)) {
    const inputs = await fn()
    // Writing inputs
    writeFileSync(
      resolve(cwd(), 'inputs', `input-${name}.json`),
      JSON.stringify(inputs),
      'utf-8'
    )
    console.log(`Generated input-${name}.json!`)
  }
})()
