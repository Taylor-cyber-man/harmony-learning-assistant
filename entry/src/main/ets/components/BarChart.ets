import { webview } from '@kit.ArkWeb'
import { SubjectScore } from '../viewmodel/ProfileViewModel'

@Component
export struct BarChart {
  @Prop @Watch('onDataChange') data: SubjectScore[] = []
  private webController: webview.WebviewController = new webview.WebviewController()
  @State webReady: boolean = false


  build() {
    Column() {
      Text('学科能力对比')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .padding({ bottom: 8 })

      Web({ src: $rawfile('bar_chart.html'), controller: this.webController })
        .width('100%')
        .height(340)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(12)
        .domStorageAccess(true)
        .javaScriptAccess(true)
        .mixedMode(MixedMode.All)
        .onPageEnd(() => {
          this.webReady = true
          this.pushData()
        })
    }
    .width('100%')
  }

  private onDataChange(): void {
    this.pushData()
  }

  private pushData(): void {
    if (!this.webReady) {
      return
    }
    if (this.data.length === 0) {
      try {
        this.webController.runJavaScript('renderChart([])')
      } catch (e) {}
      return
    }
    const json = JSON.stringify(this.data)
    try {
      this.webController.runJavaScript('renderChart(' + json + ')')
    } catch (e) {}
  }
}
