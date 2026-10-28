import { TestItem, BLOOM_LEVEL } from '../model/TestItem'

@Component
export struct TestQuestionCard {
  @Prop item: TestItem = new TestItem()
  @Prop index: number = 0
  @State inputAnswer: string = ''
  @State submitted: boolean = false
  onSubmit: (answer: string) => void = () => {}

  getBloomLabel(level: number): string {
    switch (level) {
      case BLOOM_LEVEL.REMEMBER: return '记忆'
      case BLOOM_LEVEL.UNDERSTAND: return '理解'
      case BLOOM_LEVEL.APPLY: return '应用'
      case BLOOM_LEVEL.ANALYZE: return '分析'
      case BLOOM_LEVEL.EVALUATE: return '评价'
      case BLOOM_LEVEL.CREATE: return '创造'
      default: return ''
    }
  }

  getBloomColor(level: number): string {
    if (level <= 2) {
      return '#3B82F6'
    } else if (level <= 4) {
      return '#F97316'
    } else {
      return '#8B5CF6'
    }
  }

  aboutToAppear(): void {
    if (this.item.isCorrect !== 0) {
      this.submitted = true
      this.inputAnswer = this.item.studentAnswer
    }
  }

  build() {
    Column() {
      Row() {
        Text('第' + (this.index + 1) + '题')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(this.getBloomLabel(this.item.bloomLevel))
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor(this.getBloomColor(this.item.bloomLevel))
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .margin({ left: 8 })
      }
      .width('100%')

      Text(this.item.questionText)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ top: 10 })

      if (!this.submitted) {
        TextArea({ placeholder: '请输入你的回答...' })
          .fontSize(14)
          .width('100%')
          .height(100)
          .margin({ top: 10 })
          .onChange((value: string) => {
            this.inputAnswer = value
          })

        Button($r('app.string.submit_answer'))
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(10)
          .width('100%')
          .height(40)
          .margin({ top: 8 })
          .onClick(() => {
            const answer = this.inputAnswer.trim()
            if (answer.length > 0) {
              this.submitted = true
              this.onSubmit(answer)
            }
          })
      } else {
        Text('你的回答：')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .margin({ top: 8 })
        Text(this.inputAnswer)
          .fontSize(13)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .padding(10)
          .backgroundColor($r('app.color.canvas_bg'))
          .borderRadius(8)
          .margin({ top: 4 })

        if (this.item.aiFeedback.length > 0) {
          Text('AI反馈：')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.item.isCorrect === 1 ? $r('app.color.success') : $r('app.color.error'))
            .width('100%')
            .margin({ top: 8 })
          Text(this.item.aiFeedback)
            .fontSize(13)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .padding(10)
            .backgroundColor($r('app.color.canvas_bg'))
            .borderRadius(8)
            .margin({ top: 4 })
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .margin({ bottom: 12 })
  }
}
