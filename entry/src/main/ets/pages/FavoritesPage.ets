import { SplitViewModel, HistoryRecord } from '../viewmodel/SplitViewmodel';

@Component
export struct FavoritesPage {
  @Consume('pathStack') pathStack: NavPathStack;
  @Consume('vm') vm: SplitViewModel;
  @StorageLink('favorites') favorites: HistoryRecord[] = [];

  private saveCurrentToFavorites() {
    const record: HistoryRecord = {
        id: Date.now().toString(),
        date: new Date().toLocaleString(),
        total: this.vm.total,
        people: this.vm.people,
        perPerson: this.vm.perPerson,
        currency: this.vm.currencySymbol
    }
    this.favorites.push(record)
  }

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.favorites')).fontSize(22).fontWeight(FontWeight.Bold).margin({ top: 40, bottom: 20 }).fontColor($r('app.color.accent'))

        List({ space: 12 }) {
          ForEach(this.favorites, (item: HistoryRecord, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text(`Total: ${item.total} ${item.currency}`).fontSize(14).fontColor($r('app.color.text_primary'))
                  Text(`${item.people} PPL`).fontSize(10).fontColor($r('app.color.text_secondary'))
                }.alignItems(HorizontalAlign.Start)

                Blank()
                Row() {
                    Button('Load').onClick(() => {
                        this.vm.total = item.total
                        this.vm.people = item.people
                        this.vm.currencySymbol = item.currency
                        this.vm.resetWeights(item.people)
                        this.pathStack.pop()
                    }).fontSize(10).backgroundColor($r('app.color.accent')).height(30).width(50)

                    Blank().width(4)

                    Button('X').onClick(() => {
                        this.favorites.splice(index, 1)
                    }).fontSize(10).backgroundColor($r('app.color.error')).height(30).width(30)
                }
              }
              .width('90%')
              .padding(12)
              .backgroundColor($r('app.color.fg'))
              .borderRadius($r('app.float.input_radius'))
            }
          })
        }.width('100%').layoutWeight(1)

        Row() {
            Button('Add Current').onClick(() => this.saveCurrentToFavorites()).width('45%').backgroundColor($r('app.color.success')).fontSize(10)
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
