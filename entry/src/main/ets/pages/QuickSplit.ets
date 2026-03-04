import { SplitViewModel, RoundingType, HistoryRecord } from '../viewmodel/SplitViewmodel';
import { ArcList, ArcListItem, ComponentContent } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { OnboardingComponent } from './OnboardingComponent';
import { pasteboard } from '@kit.BasicServicesKit';

@Component
export struct QuickSplit {
  watchSize: string = '466px'
  context: UIContext = this.getUIContext()
  header: ComponentContent<object> = new ComponentContent(this.context, wrapBuilder(header))
  @Consume('pathStack') pathStack: NavPathStack;
  @Consume('vm') vm: SplitViewModel;
  @State showErrors: boolean = false
  @State debounceTimer: number = -1
  @StorageLink('showOnboarding') showOnboarding: boolean = true
  @StorageLink('history') history: HistoryRecord[] = [];

  private handleInputChange(field: string, value: string) {
    if (this.debounceTimer !== -1) {
      clearTimeout(this.debounceTimer)
    }
    this.debounceTimer = setTimeout(() => {
      let val = Number(value)
      if (field === 'total') {
          if (this.vm.isValidTotal(val)) {
              this.vm.total = val
              this.showErrors = false
          } else {
              this.showErrors = true
          }
      } else if (field === 'service') {
          this.vm.serviceFee = val
      } else if (field === 'tip') {
          this.vm.tipPercentage = val
      }
      this.debounceTimer = -1
    }, 200)
  }

  private reset() {
    promptAction.showDialog({
      title: $r('app.string.reset'),
      message: $r('app.string.confirm_reset'),
      buttons: [
        { text: 'Cancel', color: '#000000' },
        { text: 'Reset', color: '#EF4444' }
      ]
    }).then(data => {
      if (data.index === 1) {
        this.vm.total = 0
        this.vm.serviceFee = 0
        this.vm.tipPercentage = 0
        this.vm.people = 1
        this.vm.resetWeights(1)
        this.showErrors = false
      }
    })
  }

  private saveRecord() {
    const record: HistoryRecord = {
        id: Date.now().toString(),
        date: new Date().toLocaleString(),
        total: this.vm.totalWithFees,
        people: this.vm.people,
        perPerson: this.vm.perPerson,
        currency: this.vm.currencySymbol
    }
    this.history.unshift(record)
    if (this.history.length > 10) this.history.pop()
    AppStorage.setOrCreate('history', this.history)
    promptAction.showToast({ message: 'Saved!' })
  }

  private shareResult() {
    const text = `Bill Split Result:\nTotal: ${this.vm.formatCurrency(this.vm.totalWithFees)}\nPeople: ${this.vm.people}\nPer Person: ${this.vm.formatCurrency(this.vm.perPerson)}`
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    pasteboard.getSystemPasteboard().setData(data)
    promptAction.showToast({ message: $r('app.string.copied') })
  }

  build() {
    NavDestination() {
      Stack() {
        Flex() {
          ArcList({ header: this.header }) {
            // Total Amount Input
            ArcListItem() {
              Column() {
                TextInput({ placeholder: $r('app.string.p1'), text: this.vm.total > 0 ? this.vm.total.toString() : '' })
                  .type(InputType.Number)
                  .width('90%')
                  .height(48)
                  .borderRadius($r('app.float.input_radius'))
                  .backgroundColor($r('app.color.fg'))
                  .fontColor($r('app.color.text_primary'))
                  .placeholderColor($r('app.color.text_secondary'))
                  .onChange(value => {
                    this.handleInputChange('total', value)
                  })
                if (this.showErrors) {
                  Text($r('app.string.err_total')).fontSize(10).fontColor($r('app.color.error'))
                }
              }.margin({ bottom: 8 })
            }

            // Currency & Rounding Selectors
            ArcListItem() {
              Row() {
                // Currency Selector (Simplified as a cycle button)
                Button(this.vm.currencySymbol).onClick(() => {
                  const symbols = ['₺', '$', '€', '£']
                  let idx = (symbols.indexOf(this.vm.currencySymbol) + 1) % symbols.length
                  this.vm.currencySymbol = symbols[idx]
                }).width('45%').height(40).backgroundColor($r('app.color.fg')).fontSize(14)

                Blank().width('10%')

                // Rounding Selector
                Button(RoundingType[this.vm.roundingType]).onClick(() => {
                   this.vm.roundingType = (this.vm.roundingType + 1) % 4
                }).width('45%').height(40).backgroundColor($r('app.color.fg')).fontSize(10)
              }.width('90%').margin({ bottom: 12 })
            }

            // Service Fee % & Tip %
            ArcListItem() {
              Row() {
                Column() {
                  Text($r('app.string.p2')).fontSize(10).fontColor($r('app.color.text_secondary'))
                  TextInput({ placeholder: '10', text: this.vm.serviceFee.toString() })
                    .type(InputType.Number)
                    .width('42%')
                    .borderRadius($r('app.float.input_radius'))
                    .backgroundColor($r('app.color.fg'))
                    .onChange(value => {
                      this.handleInputChange('service', value)
                    })
                }
                Blank().width('6%')
                Column() {
                  Text($r('app.string.tip')).fontSize(10).fontColor($r('app.color.text_secondary'))
                  TextInput({ placeholder: '5', text: this.vm.tipPercentage.toString() })
                    .type(InputType.Number)
                    .width('42%')
                    .borderRadius($r('app.float.input_radius'))
                    .backgroundColor($r('app.color.fg'))
                    .onChange(value => {
                      this.handleInputChange('tip', value)
                    })
                }
              }.width('90%').margin({ bottom: 8 })
            }

            // Service Fee Presets
            ArcListItem() {
              Row() {
                Button('10%').onClick(() => this.vm.serviceFee = 10).fontSize(12).height(30).backgroundColor($r('app.color.fg'))
                Blank().width(4)
                Button('15%').onClick(() => this.vm.serviceFee = 15).fontSize(12).height(30).backgroundColor($r('app.color.fg'))
                Blank().width(4)
                Button('20%').onClick(() => this.vm.serviceFee = 20).fontSize(12).height(30).backgroundColor($r('app.color.fg'))
              }.margin({ bottom: 8 })
            }

            // People Stepper
            ArcListItem() {
              Column() {
                Text($r('app.string.p3')).fontSize(10).fontColor($r('app.color.text_secondary'))
                Row() {
                  Button('-').onClick(() => {
                    if(this.vm.people > 1) {
                        this.vm.people--
                        this.vm.resetWeights(this.vm.people)
                    }
                  }).width(40).backgroundColor($r('app.color.fg'))
                  Text(this.vm.people.toString()).fontSize(18).fontWeight(FontWeight.Bold).width(40).textAlign(TextAlign.Center).fontColor($r('app.color.text_primary'))
                  Button('+').onClick(() => {
                    if(this.vm.people < 99) {
                        this.vm.people++
                        this.vm.resetWeights(this.vm.people)
                    }
                  }).width(40).backgroundColor($r('app.color.fg'))
                }
                .width('90%')
                .justifyContent(FlexAlign.Center)
                .padding(8)
                .backgroundColor($r('app.color.fg'))
                .borderRadius($r('app.float.input_radius'))
              }.margin({ bottom: 16 })
            }

            // Result Card
            ArcListItem() {
              Column() {
                Text($r('app.string.total')).fontSize(12).fontColor($r('app.color.text_secondary'))
                Text(this.vm.formatCurrency(this.vm.totalWithFees)).fontSize(16).fontColor($r('app.color.text_primary'))

                Divider().margin({ top: 8, bottom: 8 }).color($r('app.color.card_border'))

                Text($r('app.string.perperson')).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.accent'))
                Text(this.vm.formatCurrency(this.vm.perPerson)).fontSize(28).fontWeight(FontWeight.Bold).fontColor($r('app.color.accent'))

                if (this.vm.roundingType !== RoundingType.NONE) {
                  Text('Diff: ' + this.vm.roundingDifference.toFixed(2)).fontSize(10).fontColor($r('app.color.text_secondary'))
                }

                Button($r('app.string.share')).onClick(() => this.shareResult()).fontSize(10).height(24).margin({ top: 8 }).backgroundColor(Color.Transparent).fontColor($r('app.color.accent'))
              }
              .width('90%')
              .padding(16)
              .backgroundColor($r('app.color.card_bg'))
              .borderRadius($r('app.float.card_radius'))
              .border({ width: 1, color: $r('app.color.card_border') })
              .margin({ bottom: 16 })
            }

            // Actions
            ArcListItem() {
              Column() {
                Row() {
                  Button('Reset')
                    .onClick(() => this.reset())
                    .width(70).height(50).borderRadius(25).backgroundColor($r('app.color.error')).fontSize(12)

                  Blank().width(10)

                  Button($r('app.string.history'))
                    .onClick(() => this.pathStack.pushPathByName('HistoryPage', null))
                    .width(100).height(50).borderRadius(25).backgroundColor($r('app.color.accent'))
                }

                Row() {
                   Button($r('app.string.unequal'))
                    .onClick(() => this.pathStack.pushPathByName('CustomSplit', null))
                    .width('48%').height(40).borderRadius(20).backgroundColor($r('app.color.fg')).margin({ top: 10 }).fontSize(10)

                   Blank().width('4%')

                   Button('Save')
                    .onClick(() => this.saveRecord())
                    .width('48%').height(40).borderRadius(20).backgroundColor($r('app.color.success')).margin({ top: 10 }).fontSize(10)
                }.width('90%')
              }.margin({ bottom: 80 })
            }
          }
        }
        .width(this.watchSize)
        .height(this.watchSize)
        .backgroundColor($r('app.color.bg'))

        if (this.showOnboarding) {
          OnboardingComponent({ showOnboarding: $showOnboarding })
        }
      }
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}

@Builder
function header() {
  Column() {
    Text($r('app.string.title'))
      .fontSize(22)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .fontColor($r('app.color.accent'))
      .margin({ top: 40, bottom: 4 })
    Text('Wearable Edition')
      .fontSize(10)
      .fontColor($r('app.color.text_secondary'))
      .margin({ bottom: 12 })
  }
}
