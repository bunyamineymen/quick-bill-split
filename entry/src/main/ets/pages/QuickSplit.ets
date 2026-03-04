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
  @State serviceError: boolean = false
  @State peopleError: boolean = false
  @State debounceTimer: number = -1
  @StorageLink('showOnboarding') showOnboarding: boolean = true
  @StorageLink('history') history: HistoryRecord[] = [];

  @State displayPerPerson: number = 0;

  private handleInputChange(field: string, value: string) {
    if (this.debounceTimer !== -1) {
      clearTimeout(this.debounceTimer)
    }
    this.debounceTimer = setTimeout(() => {
      // Clean value: remove thousand separators (.) and handle decimal point (,) if necessary for tr-TR
      // For calculation, we need a standard number string
      let cleanValue = value.replace(/\./g, '').replace(',', '.')
      let val = Number(cleanValue)

      if (field === 'total') {
          if (this.vm.isValidTotal(val)) {
              this.vm.total = val
              this.showErrors = false
          } else {
              this.showErrors = true
          }
      } else if (field === 'service') {
          if (this.vm.isValidService(val)) {
              this.vm.serviceFee = val
              this.serviceError = false
          } else {
              this.serviceError = true
          }
      } else if (field === 'tip') {
          if (this.vm.isValidTip(val)) {
              this.vm.tipPercentage = val
          }
      }
      this.animatePerPerson()
      this.debounceTimer = -1
    }, 200)
  }

  private animatePerPerson() {
    animateTo({ duration: 500, curve: Curve.EaseOut }, () => {
      this.displayPerPerson = this.vm.perPerson
    })
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
        this.serviceError = false
        this.peopleError = false
        this.displayPerPerson = 0
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
            // Total Amount Input with Icon and Formatting
            ArcListItem() {
              Column() {
                Row() {
                  Text(this.vm.currencySymbol).fontSize(18).margin({ left: 12, right: 8 }).fontColor($r('app.color.accent'))
                  TextInput({ placeholder: $r('app.string.p1'), text: this.vm.total > 0 ? this.vm.total.toLocaleString('tr-TR') : '' })
                    .type(InputType.Number)
                    .layoutWeight(1)
                    .height(48)
                    .borderRadius($r('app.float.input_radius'))
                    .backgroundColor(Color.Transparent)
                    .fontColor($r('app.color.text_primary'))
                    .onChange(value => {
                      this.handleInputChange('total', value)
                    })
                }
                .width('90%')
                .backgroundColor($r('app.color.fg'))
                .borderRadius($r('app.float.input_radius'))
                .border({ width: this.showErrors ? 1 : 0, color: $r('app.color.error') })

                if (this.showErrors) {
                  Text($r('app.string.err_total')).fontSize(10).fontColor($r('app.color.error')).margin({ top: 4 })
                }
              }.margin({ bottom: 8 })
            }

            // Currency & Rounding Selectors
            ArcListItem() {
              Row() {
                Button(this.vm.currencySymbol).onClick(() => {
                  const symbols = ['₺', '$', '€', '£']
                  let idx = (symbols.indexOf(this.vm.currencySymbol) + 1) % symbols.length
                  this.vm.currencySymbol = symbols[idx]
                }).width('45%').height(40).backgroundColor($r('app.color.fg')).fontSize(14)
                  .contentDescription('Change Currency')

                Blank().width('10%')

                Button(RoundingType[this.vm.roundingType]).onClick(() => {
                   this.vm.roundingType = (this.vm.roundingType + 1) % 4
                }).width('45%').height(40).backgroundColor($r('app.color.fg')).fontSize(10)
                  .contentDescription('Change Rounding Mode')
              }.width('90%').margin({ bottom: 12 })
            }

            // Service Fee % & Tip %
            ArcListItem() {
              Row() {
                Column() {
                  Text($r('app.string.p2')).fontSize(10).fontColor($r('app.color.text_secondary'))
                  Row() {
                     Text('%').fontSize(12).margin({ left: 8 }).fontColor($r('app.color.accent'))
                     TextInput({ placeholder: '10', text: this.vm.serviceFee.toString() })
                        .type(InputType.Number)
                        .width('80%')
                        .backgroundColor(Color.Transparent)
                        .onChange(value => {
                          this.handleInputChange('service', value)
                        })
                  }
                  .backgroundColor($r('app.color.fg'))
                  .borderRadius($r('app.float.input_radius'))
                  .border({ width: this.serviceError ? 1 : 0, color: $r('app.color.error') })
                }.width('45%')

                Blank().width('10%')

                Column() {
                  Text($r('app.string.tip')).fontSize(10).fontColor($r('app.color.text_secondary'))
                  Row() {
                      Text('%').fontSize(12).margin({ left: 8 }).fontColor($r('app.color.accent'))
                      TextInput({ placeholder: '5', text: this.vm.tipPercentage.toString() })
                        .type(InputType.Number)
                        .width('80%')
                        .backgroundColor(Color.Transparent)
                        .onChange(value => {
                          this.handleInputChange('tip', value)
                        })
                  }
                  .backgroundColor($r('app.color.fg'))
                  .borderRadius($r('app.float.input_radius'))
                }.width('45%')
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

            // People Stepper with Icon
            ArcListItem() {
              Column() {
                Text($r('app.string.p3')).fontSize(10).fontColor($r('app.color.text_secondary'))
                Row() {
                  Button('-').onClick(() => {
                    if(this.vm.people > 1) {
                        this.vm.people--
                        this.vm.resetWeights(this.vm.people)
                        this.animatePerPerson()
                    }
                  }).width(40).backgroundColor($r('app.color.fg'))
                    .contentDescription('Decrease People')

                  Row() {
                      Image($r('app.media.startIcon')).width(16).height(16).margin({ right: 4 }).fillColor($r('app.color.accent'))
                      Text(this.vm.people.toString()).fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
                  }.width(60).justifyContent(FlexAlign.Center)

                  Button('+').onClick(() => {
                    if(this.vm.people < 99) {
                        this.vm.people++
                        this.vm.resetWeights(this.vm.people)
                        this.animatePerPerson()
                    }
                  }).width(40).backgroundColor($r('app.color.fg'))
                    .contentDescription('Increase People')
                }
                .width('90%')
                .justifyContent(FlexAlign.Center)
                .padding(8)
                .backgroundColor($r('app.color.fg'))
                .borderRadius($r('app.float.input_radius'))
              }.margin({ bottom: 16 })
            }

            // Result Card with Animation
            ArcListItem() {
              Column() {
                Text($r('app.string.total')).fontSize(12).fontColor($r('app.color.text_secondary'))
                Text(this.vm.formatCurrency(this.vm.totalWithFees)).fontSize(16).fontColor($r('app.color.text_primary'))

                Divider().margin({ top: 8, bottom: 8 }).color($r('app.color.card_border'))

                Text($r('app.string.perperson')).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.accent'))
                Text(this.vm.formatCurrency(this.displayPerPerson)).fontSize(28).fontWeight(FontWeight.Bold).fontColor($r('app.color.accent'))

                if (this.vm.roundingType !== RoundingType.NONE) {
                  Text('Diff: ' + this.vm.roundingDifference.toFixed(2)).fontSize(10).fontColor($r('app.color.text_secondary'))
                }

                Button($r('app.string.share')).onClick(() => this.shareResult()).fontSize(10).height(24).margin({ top: 8 }).backgroundColor(Color.Transparent).fontColor($r('app.color.accent'))
                  .contentDescription('Share Results')
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
                    .contentDescription('Reset Fields')

                  Blank().width(10)

                  Button($r('app.string.history'))
                    .onClick(() => this.pathStack.pushPathByName('HistoryPage', null))
                    .width(100).height(50).borderRadius(25).backgroundColor($r('app.color.accent'))
                    .contentDescription('View History')
                }

                Row() {
                   Button($r('app.string.unequal'))
                    .onClick(() => this.pathStack.pushPathByName('CustomSplit', null))
                    .width('48%').height(40).borderRadius(20).backgroundColor($r('app.color.fg')).margin({ top: 10 }).fontSize(10)
                    .contentDescription('Custom Split')

                   Blank().width('4%')

                   Button('Save')
                    .onClick(() => this.saveRecord())
                    .width('48%').height(40).borderRadius(20).backgroundColor($r('app.color.success')).margin({ top: 10 }).fontSize(10)
                    .contentDescription('Save to History')
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
