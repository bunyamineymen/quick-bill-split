export class SplitViewModel {
  total: number = 0
  serviceFee: number = 0
  people: number = 1

  get totalWithService(): number {
    return this.total + this.total*(this.serviceFee)/100
  }

  get perPerson(): number {
    if (this.people <= 0) {}
    return (this.totalWithService / this.people)
  }
}
