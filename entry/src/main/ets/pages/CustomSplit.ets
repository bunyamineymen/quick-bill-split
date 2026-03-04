import { SplitViewModel } from '../viewmodel/SplitViewmodel';

@Component
export struct CustomSplit {
  @Consume('pathStack') pathStack: NavPathStack;
  @Consume('vm') vm: SplitViewModel;

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.unequal')).fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 40, bottom: 20 }).fontColor($r('app.color.accent'))

        List({ space: 10 }) {
          ForEach(this.vm.weights, (weight: number, index: number) => {
            ListItem() {
              Row() {
                Text(`Person ${index + 1}`).fontSize(14).fontColor($r('app.color.text_primary'))
                Blank()
                Row() {
                    Button('-').onClick(() => {
                        if(this.vm.weights[index] > 0) {
                            this.vm.weights[index]--
                            this.vm.weights = [...this.vm.weights]
                        }
                    }).width(30).backgroundColor($r('app.color.bg')).fontSize(10)
                    Text(weight.toString()).width(30).textAlign(TextAlign.Center).fontColor(Color.White)
                    Button('+').onClick(() => {
                        this.vm.weights[index]++
                        this.vm.weights = [...this.vm.weights]
                    }).width(30).backgroundColor($r('app.color.bg')).fontSize(10)
                }
                Text(`(${this.vm.formatCurrency(this.vm.calculateUnequal(index))})`).fontSize(10).fontColor($r('app.color.text_secondary')).margin({ left: 4 })
              }
              .width('90%')
              .padding(10)
              .backgroundColor($r('app.color.fg'))
              .borderRadius(10)
            }
          })
        }.width('100%').layoutWeight(1)

        Column() {
           Text(`Total: ${this.vm.formatCurrency(this.vm.totalWithFees)}`).fontSize(14).fontColor($r('app.color.text_secondary'))
           Button('Apply').onClick(() => this.pathStack.pop()).width('50%').margin({ top: 10, bottom: 40 }).backgroundColor($r('app.color.accent'))
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.bg'))
    }
    .hideTitleBar(true)
  }
}
