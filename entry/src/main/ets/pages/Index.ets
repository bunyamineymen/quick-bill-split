import { QuickSplit } from './QuickSplit';
import { HistoryPage } from './HistoryPage';
import { CustomSplit } from './CustomSplit';
import { FavoritesPage } from './FavoritesPage';
import { SplitViewModel } from '../viewmodel/SplitViewmodel';

@Entry
@Component
struct Index {
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack()
  @Provide('vm') vm: SplitViewModel = new SplitViewModel()
  @State opacityLevel: number = 0
  @State scaleLevel: number = 0.5

  @Builder
  PageMap(name: string) {
    if (name === 'QuickSplit') {
      QuickSplit()
    } else if (name === 'HistoryPage') {
      HistoryPage()
    } else if (name === 'CustomSplit') {
      CustomSplit()
    } else if (name === 'FavoritesPage') {
      FavoritesPage()
    }
  }

  aboutToAppear(): void {
    PersistentStorage.persistProp('history', []);
    PersistentStorage.persistProp('favorites', []);
    PersistentStorage.persistProp('showOnboarding', true);

    animateTo({ duration: 1000, curve: Curve.EaseInOut }, () => {
      this.opacityLevel = 1
      this.scaleLevel = 1
    })

    setTimeout(() => {
      animateTo({ duration: 500, curve: Curve.EaseOut }, () => {
        this.opacityLevel = 0
      })
      setTimeout(() => {
        this.pathStack.pushPathByName('QuickSplit', null)
      }, 500)
    }, 2500)
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Image($r('app.media.startIcon'))
          .width(100).height(100)
          .margin({ bottom: 24 })
          .scale({ x: this.scaleLevel, y: this.scaleLevel })
          .opacity(this.opacityLevel)

        Text($r('app.string.welcome'))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.accent'))
          .opacity(this.opacityLevel)
          .margin({ bottom: 12 })

        Text($r('app.string.split'))
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .opacity(this.opacityLevel)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor($r('app.color.bg'))
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)
    .navDestination(this.PageMap)
  }
}
