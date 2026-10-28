import { webview } from '@kit.ArkWeb'
import { MentalModel } from '../engine/AiEngine'
import { KnowledgeItem } from '../model/KnowledgeItem'

class MaterialJumpProxy {
  private callback: (ref: string) => void = (_ref: string) => {}

  setCallback(cb: (ref: string) => void): void {
    this.callback = cb
  }

  materialJump(ref: string): void {
    this.callback(ref)
  }
}

@Component
export struct KnowledgeGraph {
  @Prop @Watch('onDataChange') models: MentalModel[] = []
  @Prop knowledgeItems: KnowledgeItem[] = []
  onMaterialJump: (ref: string) => void = (_ref: string) => {}
  private webController: webview.WebviewController = new webview.WebviewController()
  private jumpProxy: MaterialJumpProxy = new MaterialJumpProxy()
  @State webReady: boolean = false
  @State expandedMaterialRef: string = ''
  @State expandedMaterialSources: string[] = []

  aboutToAppear(): void {
    this.jumpProxy.setCallback((ref: string) => {
      this.onMaterialJump(ref)
    })
  }

  build() {
    Column() {
      Text($r('app.string.question_one_title'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .padding({ bottom: 8 })

      Web({ src: $rawfile('knowledge_graph.html'), controller: this.webController })
        .width('100%')
        .height(400)
        .backgroundColor($r('app.color.canvas_bg'))
        .borderRadius(12)
        .domStorageAccess(true)
        .javaScriptAccess(true)
        .mixedMode(MixedMode.All)
        .hitTestBehavior(HitTestMode.Block)
        .javaScriptProxy({
          object: this.jumpProxy,
          name: 'materialJumpObj',
          methodList: ['materialJump'],
          controller: this.webController
        })
        .onPageEnd(() => {
          this.webReady = true
          this.pushData()
        })

      if (this.models.length > 0) {
        Column() {
          Text('心智模型详解')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .padding({ top: 16, bottom: 8 })

          ForEach(this.models, (model: MentalModel, index: number) => {
            Column() {
              Row() {
                Text(this.formatIndex(index + 1))
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .width(40)
                  .height(40)
                  .borderRadius(10)
                  .backgroundColor(this.getNodeColor(index))
                  .textAlign(TextAlign.Center)

                Column() {
                  Text(model.name)
                    .fontSize(17)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')

                  Text(model.description)
                    .fontSize(14)
                    .fontColor($r('app.color.text_secondary'))
                    .maxLines(4)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                    .margin({ top: 6 })
                    .lineHeight(20)
                }
                .layoutWeight(1)
                .margin({ left: 14 })
              }

              // 子概念
              if (model.children.length > 0) {
                Column() {
                  Text('子概念')
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#64748B')
                    .width('100%')
                    .padding({ top: 12, bottom: 6 })

                  ForEach(model.children, (child: string, ci: number) => {
                    Row() {
                      Text('' + (ci + 1))
                        .fontSize(12)
                        .fontColor('#64748B')
                        .width(20)
                      Text(child)
                        .fontSize(13)
                        .fontColor($r('app.color.text_secondary'))
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .padding({ top: 2, bottom: 2 })
                  })
                }
                .width('100%')
              }

              // 逻辑关系
              if (model.relations.length > 0) {
                Column() {
                  Text('逻辑关系')
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#64748B')
                    .width('100%')
                    .padding({ top: 12, bottom: 6 })

                  ForEach(this.getRelationTexts(model), (rel: string) => {
                    Text(rel)
                      .fontSize(13)
                      .fontColor($r('app.color.text_secondary'))
                      .width('100%')
                      .padding({ top: 2, bottom: 2 })
                  })
                }
                .width('100%')
              }

              // 关联资料按钮
              if (model.materialRef.length > 0) {
                if (this.expandedMaterialRef === model.materialRef) {
                  // 展开状态：显示匹配的知识点来源
                  Column() {
                    Text('信息来源')
                      .fontSize(13)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#64748B')
                      .width('100%')
                      .padding({ top: 12, bottom: 6 })

                    if (this.expandedMaterialSources.length === 0) {
                      Text('未找到匹配的知识点')
                        .fontSize(13)
                        .fontColor($r('app.color.text_secondary'))
                        .width('100%')
                    }

                    ForEach(this.expandedMaterialSources, (src: string) => {
                      Text(src)
                        .fontSize(12)
                        .fontColor($r('app.color.text_secondary'))
                        .width('100%')
                        .lineHeight(18)
                        .padding({ top: 4, bottom: 4 })
                    })

                    Row() {
                      Button('收起')
                        .fontSize(12)
                        .fontColor($r('app.color.text_secondary'))
                        .backgroundColor(Color.Transparent)
                        .onClick(() => {
                          this.expandedMaterialRef = ''
                          this.expandedMaterialSources = []
                        })
                    }
                    .width('100%')
                    .margin({ top: 8 })
                  }
                  .width('100%')
                } else {
                  Button('查看关联资料')
                    .fontSize(13)
                    .fontColor($r('app.color.primary'))
                    .backgroundColor('rgba(37,99,235,0.06)')
                    .border({ width: 1, color: $r('app.color.primary') })
                    .borderRadius(8)
                    .height(32)
                    .margin({ top: 12 })
                    .onClick(() => {
                      const sources = this.findMaterialSources(model.materialRef)
                      this.expandedMaterialRef = model.materialRef
                      this.expandedMaterialSources = sources
                    })
                }
              }
            }
            .width('100%')
            .padding(14)
            .borderRadius(12)
            .backgroundColor($r('app.color.card_background'))
            .margin({ top: 8 })
          })
        }
        .width('100%')
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .padding(16)
  }

  private formatIndex(num: number): string {
    if (num < 10) {
      return '0' + num
    }
    return '' + num
  }

  private getNodeColor(index: number): string {
    const colors: string[] = ['#2563EB', '#7C3AED', '#0891B2', '#059669', '#D97706']
    return colors[index % colors.length]
  }

  private getRelationTexts(model: MentalModel): string[] {
    const texts: string[] = []
    for (let i = 0; i < model.relations.length; i++) {
      const targetId = parseInt(model.relations[i])
      let targetName = ''
      for (let j = 0; j < this.models.length; j++) {
        if (this.models[j].id === targetId) {
          targetName = this.models[j].name
          break
        }
      }
      const label = i < model.relationLabels.length ? model.relationLabels[i] : '关联'
      texts.push(model.name + ' → ' + targetName + '（' + label + '）')
    }
    return texts
  }

  private findMaterialSources(ref: string): string[] {
    const sources: string[] = []
    for (let i = 0; i < this.knowledgeItems.length; i++) {
      const item = this.knowledgeItems[i]
      if (item.title.indexOf(ref) >= 0 || ref.indexOf(item.title) >= 0) {
        // 从 content 中提取来源信息
        const srcMatch = item.content.indexOf('来源:')
        if (srcMatch >= 0) {
          const srcText = item.content.substring(srcMatch)
          const firstLine = srcText.split('\n')[0]
          if (firstLine.length > 4) {
            sources.push('📄 ' + item.title + '\n' + firstLine)
          } else {
            sources.push('📄 ' + item.title)
          }
        } else {
          sources.push('📄 ' + item.title)
        }
      }
    }
    return sources
  }

  private onDataChange(): void {
    this.pushData()
  }

  private pushData(): void {
    if (!this.webReady) {
      return
    }
    if (this.models.length === 0) {
      try {
        this.webController.runJavaScript('renderChart([])')
      } catch (e) {}
      return
    }
    const json = JSON.stringify(this.models)
    try {
      this.webController.runJavaScript('renderChart(' + json + ')')
    } catch (e) {}
  }
}
