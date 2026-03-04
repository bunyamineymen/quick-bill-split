@Component
export struct OnboardingComponent {
  @State step: number = 0
  @Link showOnboarding: boolean

  build() {
    Stack() {
      Column() {
        if (this.step === 0) {
          Text('Step 1: Enter Bill Total').fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White)
          Text('Enter the total amount including service fee.').fontSize(14).fontColor(Color.White).margin({ top: 10 })
        } else if (this.step === 1) {
          Text('Step 2: Add Tip').fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White)
          Text('Select or enter a tip percentage.').fontSize(14).fontColor(Color.White).margin({ top: 10 })
        } else if (this.step === 2) {
          Text('Step 3: Split!').fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White)
          Text('Adjust the number of people to see the split.').fontSize(14).fontColor(Color.White).margin({ top: 10 })
        }

        Button(this.step < 2 ? 'Next' : 'Got it!')
          .onClick(() => {
            if (this.step < 2) {
              this.step++
            } else {
              this.showOnboarding = false
            }
          })
          .margin({ top: 20 })
          .width(100).backgroundColor($r('app.color.accent'))
      }
      .width('80%')
      .padding(20)
      .backgroundColor('rgba(0,0,0,0.8)')
      .borderRadius(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.4)')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
