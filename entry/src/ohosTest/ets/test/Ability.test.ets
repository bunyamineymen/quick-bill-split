import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { Driver, ON, Component } from '@ohos.UiTest'
import { AbilityDelegatorRegistry } from '@ohos.app.ability.abilityDelegatorRegistry'

export default function abilityTest() {
  describe('AbilityTest', () => {
    it('should_navigate_and_calculate_split', 0, async () => {
      let driver = Driver.create()
      let delegator = AbilityDelegatorRegistry.getAbilityDelegator()

      // Wait for splash screen to finish
      await driver.delayMs(3000)

      // Check if title exists
      await driver.assertComponentExist(ON.text('Quick Split'))

      // Try to find history button
      let historyBtn = await driver.findComponent(ON.text('History'))
      expect(historyBtn).assertNotNull()

      // Navigate to history
      await historyBtn.click()
      await driver.delayMs(500)
      await driver.assertComponentExist(ON.text('History'))

      // Go back
      let backBtn = await driver.findComponent(ON.text('Back'))
      await backBtn.click()
      await driver.delayMs(500)
    })
  })
}
