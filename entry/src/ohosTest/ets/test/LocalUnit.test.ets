import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { SplitViewModel, RoundingType } from '../../../main/ets/viewmodel/SplitViewmodel'

export default function localUnitTest() {
  describe('SplitViewModelTest', () => {
    let vm: SplitViewModel

    beforeEach(() => {
      vm = new SplitViewModel()
    })

    it('should_calculate_correct_total_with_fees', 0, () => {
      vm.total = 100
      vm.serviceFee = 10
      vm.tipPercentage = 5
      expect(vm.totalWithFees).assertEqual(115)
    })

    it('should_handle_division_by_zero', 0, () => {
      vm.total = 100
      vm.people = 0
      expect(vm.perPerson).assertEqual(0)
    })

    it('should_split_correctly_among_people', 0, () => {
      vm.total = 120
      vm.people = 3
      expect(vm.perPerson).assertEqual(40)
    })

    it('should_apply_rounding_up', 0, () => {
      vm.total = 100
      vm.people = 3 // 33.333...
      vm.roundingType = RoundingType.UP
      expect(vm.perPerson).assertEqual(34)
    })

    it('should_apply_rounding_down', 0, () => {
      vm.total = 100
      vm.people = 3
      vm.roundingType = RoundingType.DOWN
      expect(vm.perPerson).assertEqual(33)
    })

    it('should_calculate_unequal_split', 0, () => {
      vm.total = 100
      vm.people = 2
      vm.resetWeights(2)
      vm.weights[0] = 3 // 75%
      vm.weights[1] = 1 // 25%
      expect(vm.calculateUnequal(0)).assertEqual(75)
      expect(vm.calculateUnequal(1)).assertEqual(25)
    })

    it('should_validate_inputs', 0, () => {
      expect(vm.isValidTotal(500)).assertTrue()
      expect(vm.isValidTotal(-1)).assertFalse()
      expect(vm.isValidTotal(1000000)).assertFalse()

      expect(vm.isValidService(10)).assertTrue()
      expect(vm.isValidService(101)).assertFalse()

      expect(vm.isValidPeople(5)).assertTrue()
      expect(vm.isValidPeople(0)).assertFalse()
      expect(vm.isValidPeople(100)).assertFalse()
    })
  })
}
