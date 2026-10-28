import { DisputePoint } from '../engine/AiEngine'

@Component
export struct DisputeMapView {
  @Prop disputes: DisputePoint[] = []
  @State selectedIndex: number = 0

  build() {
    Column() {
      Text($r('app.string.question_two_title'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .padding({ bottom: 12 })

      // 认知地图三区
      this.buildZoneCard('共识区', '所有专家认可的AI核心基础：大语言模型是AI应用的核心推理引擎', '#10B981')
      this.buildZoneCard('争议区', this.disputes.length > 0 ? this.disputes[this.selectedIndex].title :
        '', '#F97316')
      this.buildZoneCard('未知区', 'AGI的实现路径、AI安全的最终解决方案', '#94A3B8')

      // 争议点标签切换
      if (this.disputes.length > 0) {
        Row() {
          ForEach(this.disputes, (dispute: DisputePoint, index: number) => {
            Button('争议' + (index + 1))
              .fontSize(12)
              .fontColor(this.selectedIndex === index ? Color.White : $r('app.color.primary'))
              .backgroundColor(this.selectedIndex === index ? $r('app.color.primary') :
              Color.Transparent)
              .border({ width: 1, color: $r('app.color.primary') })
              .borderRadius(6)
              .height(28)
              .margin({ right: 8 })
              .onClick(() => { this.selectedIndex = index })
          })
        }
        .width('100%')
        .margin({ top: 12 })

        // 正反方对比
        if (this.disputes.length > this.selectedIndex) {
          Row() {
            Column() {
              Text('正方')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary'))
                .margin({ bottom: 8 })
              Text(this.disputes[this.selectedIndex].proSide)
                .fontSize(12)
                .fontColor($r('app.color.text_primary'))
                .margin({ bottom: 4 })
              Text('证据：' + this.disputes[this.selectedIndex].proEvidence)
                .fontSize(11)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('48%')
            .padding(12)
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(10)

            Blank()

            Column() {
              Text('反方')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.accent'))
                .margin({ bottom: 8 })
              Text(this.disputes[this.selectedIndex].conSide)
                .fontSize(12)
                .fontColor($r('app.color.text_primary'))
                .margin({ bottom: 4 })
              Text('证据：' + this.disputes[this.selectedIndex].conEvidence)
                .fontSize(11)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('48%')
            .padding(12)
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(10)
          }
          .width('100%')
          .margin({ top: 8 })
        }
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .padding(16)
  }

  @Builder
  buildZoneCard(title: string, desc: string, color: string) {
    Row() {
      // 色条
      Column()
        .width(4)
        .height('100%')
        .backgroundColor(color)
        .borderRadius(2)

      Column() {
        Text(title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
        Text(desc)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
    }
    .width('100%')
    .height(48)
    .margin({ top: 4 })
  }
}
