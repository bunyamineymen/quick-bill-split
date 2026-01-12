import { SplitViewModel } from '../viewmodel/SplitViewmodel';
import { ArcList, ArcListItem, ComponentContent } from '@kit.ArkUI';


@Component
export struct QuickSplit {
  watchSize: string = '466px'
  context: UIContext = this.getUIContext()
  header: ComponentContent<object> = new ComponentContent(this.context, wrapBuilder(header))
  @Consume('pathStack') pathStack: NavPathStack;
  @State vm: SplitViewModel = new SplitViewModel()

  build() {
    NavDestination() {
      Flex() {
        ArcList({ header: this.header }) {
          ArcListItem() {
            TextInput({ placeholder: $r('app.string.p1') })
              .type(InputType.Number)
              .width(190)
              .margin({ bottom: 12 })
              .onChange(value => {
                this.vm.total = Number(value)
              })
          }

          ArcListItem() {

            TextInput({ placeholder: $r('app.string.p2') })
              .type(InputType.Number)
              .width(190)
              .margin({ bottom: 12 })
              .onChange(value => {
                this.vm.serviceFee = Number(value)
              })
          }

          ArcListItem() {

            TextInput({ placeholder: $r('app.string.p3') })
              .type(InputType.Number)
              .width(190)
              .margin({ bottom: 30 })
              .onChange(value => {
                this.vm.people = Number(value)
              })
          }

          ArcListItem() {

            Column() {
              Text($r('app.string.total')).fontSize(14)
              Text(this.vm.totalWithService.toFixed(2)).fontSize(14)
              Text($r('app.string.tl')).fontSize(14)

              Text($r('app.string.perperson')).fontSize(22).fontWeight(FontWeight.Bold)
              Text(this.vm.perPerson.toFixed(2)).fontSize(22).fontWeight(FontWeight.Bold)
              Text($r('app.string.tl')).fontSize(22).fontWeight(FontWeight.Bold)
            }
            .width('70%')
            .height('70%')
            .padding(20)
            .backgroundColor($r('app.color.fg'))
            .borderRadius(30)
          }

        }
      }
      .width(this.watchSize)
      .height(this.watchSize)
      .backgroundColor($r('app.color.bg'))
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}

@Builder
function header() {
    Text($r('app.string.title'))
      .fontSize(28)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .margin({ top: 16, bottom: 12 })
      .fontColor(Color.White)
}
