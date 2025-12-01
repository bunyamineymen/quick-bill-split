import { QuickSplit } from './QuickSplit';

@Entry
@Component
struct SplashPage {
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack()

  @Builder
  PageMap(name: string) {
    if (name === 'QuickSplit') {
      QuickSplit()
    }
  }

  aboutToAppear(): void {
    setTimeout(() => {
      this.pathStack.pushPathByName('QuickSplit', null)
    }, 2000)
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Text($r('app.string.welcome'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        Text($r('app.string.split'))
          .fontSize(16)
          .opacity(0.8)
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
