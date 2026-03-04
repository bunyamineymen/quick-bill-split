import { SplitViewModel, HistoryRecord } from '../viewmodel/SplitViewmodel';

@Component
export struct HistoryPage {
  @Consume('pathStack') pathStack: NavPathStack;
  @Consume('vm') vm: SplitViewModel;
  @StorageLink('history') history: HistoryRecord[] = [];

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.history')).fontSize(22).fontWeight(FontWeight.Bold).margin({ top: 40, bottom: 20 }).fontColor($r('app.color.accent'))

        List({ space: 12 }) {
          ForEach(this.history, (item: HistoryRecord, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.date).fontSize(8).fontColor($r('app.color.text_secondary'))
                  Text(`Total: ${item.total.toFixed(2)} ${item.currency}`).fontSize(12).fontColor($r('app.color.text_primary'))
                }.alignItems(HorizontalAlign.Start)

                Blank()

                Column() {
                  Text(`${item.people} PPL`).fontSize(8).fontColor($r('app.color.text_secondary'))
                  Text(`${item.perPerson.toFixed(2)} ${item.currency}`).fontSize(14).fontWeight(FontWeight.Bold).fontColor($r('app.color.accent'))
                }.alignItems(HorizontalAlign.End)

                Blank().width(4)
                Button('X').onClick(() => {
                    this.history.splice(index, 1)
                }).fontSize(10).backgroundColor($r('app.color.error')).height(30).width(30)
              }
              .width('90%')
              .padding(10)
              .backgroundColor($r('app.color.fg'))
              .borderRadius($r('app.float.input_radius'))
            }
          })
        }.width('100%').layoutWeight(1)

        Row() {
            Button('Favorites').onClick(() => this.pathStack.pushPathByName('FavoritesPage', null)).width('45%').backgroundColor($r('app.color.accent')).fontSize(10)
            Blank().width('5%')
            Button('Back').onClick(() => this.pathStack.pop()).width('45%').backgroundColor($r('app.color.fg')).fontSize(10)
        }.margin({ bottom: 40 }).width('90%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.bg'))
    }
    .hideTitleBar(true)
  }
}
