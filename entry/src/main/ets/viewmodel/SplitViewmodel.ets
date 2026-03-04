export enum RoundingType {
  NONE,
  UP,
  DOWN,
  NEAREST_HALF
}

export interface SplitItem {
  name: string;
  weight: number;
}

export interface HistoryRecord {
  id: string;
  date: string;
  total: number;
  people: number;
  perPerson: number;
  currency: string;
}

@Observed
export class SplitViewModel {
  total: number = 0
  serviceFee: number = 0
  tipPercentage: number = 0
  people: number = 1
  roundingType: RoundingType = RoundingType.NONE
  currencySymbol: string = '₺'
  currencyCode: string = 'TRY'
  isUnequal: boolean = false
  weights: number[] = []

  constructor() {
    this.resetWeights(1)
  }

  resetWeights(count: number) {
    this.weights = Array(count).fill(1)
  }

  get serviceAmount(): number {
    return (this.total * this.serviceFee) / 100
  }

  get tipAmount(): number {
    return (this.total * this.tipPercentage) / 100
  }

  get totalWithFees(): number {
    return this.total + this.serviceAmount + this.tipAmount
  }

  get perPersonRaw(): number {
    if (this.people <= 0) return 0
    return this.totalWithFees / this.people
  }

  get perPerson(): number {
    return this.applyRounding(this.perPersonRaw)
  }

  applyRounding(amount: number): number {
    switch (this.roundingType) {
      case RoundingType.UP:
        return Math.ceil(amount)
      case RoundingType.DOWN:
        return Math.floor(amount)
      case RoundingType.NEAREST_HALF:
        return Math.round(amount * 2) / 2
      case RoundingType.NONE:
      default:
        return amount
    }
  }

  get roundingDifference(): number {
    if (this.people <= 0) return 0
    return (this.perPerson * this.people) - this.totalWithFees
  }

  calculateUnequal(index: number): number {
    const totalWeight = this.weights.reduce((a, b) => a + b, 0)
    if (totalWeight === 0) return 0
    const raw = (this.weights[index] / totalWeight) * this.totalWithFees
    return this.applyRounding(raw)
  }

  // Validation methods
  isValidTotal(val: number): boolean {
    return val >= 0 && val <= 999999
  }

  isValidService(val: number): boolean {
    return val >= 0 && val <= 100
  }

  isValidTip(val: number): boolean {
    return val >= 0 && val <= 50
  }

  isValidPeople(val: number): boolean {
    return val >= 1 && val <= 99
  }

  formatCurrency(amount: number): string {
    return amount.toLocaleString('tr-TR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }) + ' ' + this.currencySymbol
  }
}
