import { router } from '@kit.ArkUI'
import { KnowledgeItem, KNOWLEDGE_SOURCE } from '../model/KnowledgeItem'
import { KnowledgeDao } from '../database/KnowledgeDao'
import { AiEngine } from '../engine/AiEngine'
import { picker } from '@kit.CoreFileKit'
import { fileIo } from '@kit.CoreFileKit'

const knowledgeDao = new KnowledgeDao()
const aiEngine = new AiEngine()

@Entry
@Component
struct CourseSetupPage {
  @State courseId: number = 0
  @State courseName: string = ''
  @State knowledgeItems: KnowledgeItem[] = []
  @State newTitle: string = ''
  @State newContent: string = ''
  @State searchKeyword: string = ''
  @State filterSource: number = -1
  @State isAiLoading: boolean = false
  @State usedLocalData: boolean = false

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number | string>
    if (params !== null && params !== undefined) {
      this.courseId = params['courseId'] as number
      this.courseName = params['courseName'] as string
      this.loadKnowledge()
      this.loadAiKnowledge()
    }
  }

  async loadKnowledge(): Promise<void> {
    this.knowledgeItems = await knowledgeDao.getByCourseId(this.courseId)
  }

  async loadAiKnowledge(): Promise<void> {
    const existing = await knowledgeDao.getByCourseId(this.courseId)
    const aiExisting = existing.filter((item: KnowledgeItem) => item.source === KNOWLEDGE_SOURCE.AI)
    if (aiExisting.length === 0) {
      this.isAiLoading = true
      let aiItems: KnowledgeItem[] = []
      try {
        aiItems = await aiEngine.fetchKnowledgeItems(this.courseName)
        this.usedLocalData = false
      } catch (e) {
        aiItems = aiEngine.getPresetKnowledge(this.courseId, this.courseName)
        this.usedLocalData = true
      }
      for (const item of aiItems) {
        item.courseId = this.courseId
        await knowledgeDao.insert(item)
      }
      this.knowledgeItems = await knowledgeDao.getByCourseId(this.courseId)
      this.isAiLoading = false
    }
  }

  async refreshAiKnowledge(): Promise<void> {
    AlertDialog.show({
      title: '重新搜索',
      message: '将清除现有AI知识点并重新联网搜索，确定继续？',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定',
        fontColor: $r('app.color.primary'),
        action: async () => {
          // 删除所有 AI 来源的知识点
          const allItems = await knowledgeDao.getByCourseId(this.courseId)
          for (const item of allItems) {
            if (item.source === KNOWLEDGE_SOURCE.AI) {
              await knowledgeDao.delete(item.id)
            }
          }
          this.knowledgeItems = await knowledgeDao.getByCourseId(this.courseId)
          // 重新触发 AI 搜索
          this.isAiLoading = true
          let aiItems: KnowledgeItem[] = []
          try {
            aiItems = await aiEngine.fetchKnowledgeItems(this.courseName)
            this.usedLocalData = false
          } catch (e) {
            aiItems = aiEngine.getPresetKnowledge(this.courseId, this.courseName)
            this.usedLocalData = true
          }
          for (const item of aiItems) {
            item.courseId = this.courseId
            await knowledgeDao.insert(item)
          }
          this.knowledgeItems = await knowledgeDao.getByCourseId(this.courseId)
          this.isAiLoading = false
        }
      }
    })
  }

  getFilteredItems(): KnowledgeItem[] {
    let items = this.knowledgeItems
    if (this.filterSource >= 0) {
      items = items.filter((item: KnowledgeItem) => item.source === this.filterSource)
    }
    if (this.searchKeyword.length > 0) {
      const keyword = this.searchKeyword.toLowerCase()
      items = items.filter((item: KnowledgeItem) =>
        item.title.toLowerCase().includes(keyword) ||
      item.content.toLowerCase().includes(keyword))
    }
    return items
  }

  // 按来源分组
  getAiItems(): KnowledgeItem[] {
    return this.knowledgeItems.filter((item: KnowledgeItem) => item.source === KNOWLEDGE_SOURCE.AI)
  }

  getUploadItems(): KnowledgeItem[] {
    return this.knowledgeItems.filter((item: KnowledgeItem) => item.source ===
    KNOWLEDGE_SOURCE.UPLOAD)
  }

  getManualItems(): KnowledgeItem[] {
    return this.knowledgeItems.filter((item: KnowledgeItem) => item.source ===
    KNOWLEDGE_SOURCE.MANUAL)
  }

  getSourceLabel(source: number): string {
    if (source === KNOWLEDGE_SOURCE.AI) {
      return this.usedLocalData ? '本地' : 'AI 搜索'
    } else if (source === KNOWLEDGE_SOURCE.UPLOAD) {
      return '上传'
    }
    return '手动'
  }

  getSourceColor(source: number): string {
    if (source === KNOWLEDGE_SOURCE.AI) {
      return '#3B82F6'
    } else if (source === KNOWLEDGE_SOURCE.UPLOAD) {
      return '#10B981'
    }
    return '#F97316'
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        Button('← 返回')
          .fontSize(14)
          .fontColor($r('app.color.primary'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            router.back()
          })

        Text(this.courseName)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding(16)

      Scroll() {
        Column() {
          // ============ AI 知识点区 ============
          Column() {
            Row() {
              Text(this.usedLocalData ? 'AI 总结知识点（本地数据）' : 'AI 搜索知识点')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)

              Text(this.usedLocalData ? '(本地预置)' : '(联网搜索)')
                .fontSize(11)
                .fontColor(this.usedLocalData ?
                  $r('app.color.accent') :
                  $r('app.color.primary'))
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor(this.usedLocalData ?
                  'rgba(249,115,22,0.08)' :
                  'rgba(37,99,235,0.08)')
                .borderRadius(4)

              if (!this.isAiLoading) {
                Text('↻')
                  .fontSize(18)
                  .fontColor($r('app.color.primary'))
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.refreshAiKnowledge()
                  })
              }

              if (this.isAiLoading) {
                LoadingProgress()
                  .width(16)
                  .height(16)
                  .margin({ left: 6 })
              }
            }
            .width('100%')

            if (this.isAiLoading) {
              Text('AI 正在搜索相关知识，请稍候...')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 12 })
                .width('100%')
            }

            if (this.getAiItems().length === 0 && !this.isAiLoading) {
              Text('暂无 AI 知识点')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 8 })
                .width('100%')
            }

            ForEach(this.getAiItems(), (item: KnowledgeItem) => {
              this.KnowledgeItemCard(item)
            })
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .padding(16)
          .margin({ top: 12 })

          // ============ 上传文件区 ============
          Column() {
            Row() {
              Text('上传资料')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)

              Text('(' + this.getUploadItems().length + '个文件)')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('100%')

            Button('+ 上传学习资料')
              .fontSize(14)
              .fontColor($r('app.color.primary'))
              .backgroundColor('rgba(37,99,235,0.06)')
              .border({ width: 1, color: $r('app.color.primary'), style: BorderStyle.Dashed })
              .borderRadius(12)
              .width('100%')
              .height(48)
              .margin({ top: 8 })
              .onClick(() => {
                this.uploadFile()
              })

            ForEach(this.getUploadItems(), (item: KnowledgeItem) => {
              this.KnowledgeItemCard(item)
            })
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .padding(16)
          .margin({ top: 12 })

          // ============ 手动添加区 ============
          Column() {
            Text('手动添加知识点')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')

            Text('(' + this.getManualItems().length + '条)')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 2 })

            TextInput({ placeholder: '知识点标题' })
              .fontSize(14)
              .width('100%')
              .margin({ top: 8 })
              .onChange((value: string) => {
                this.newTitle = value
              })

            TextArea({ placeholder: '请输入内容...' })
              .fontSize(14)
              .width('100%')
              .height(80)
              .margin({ top: 8 })
              .onChange((value: string) => {
                this.newContent = value
              })

            Button($r('app.string.add_knowledge'))
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.primary'))
              .borderRadius(12)
              .width('100%')
              .height(44)
              .margin({ top: 12 })
              .onClick(() => {
                this.addKnowledge()
              })

            // 手动条目列表
            ForEach(this.getManualItems(), (item: KnowledgeItem) => {
              this.KnowledgeItemCard(item)
            })
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .padding(16)
          .margin({ top: 12 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 80 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部 CTA
      Button($r('app.string.btn_start_learning'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(12)
        .width('100%')
        .height(48)
        .margin({ left: 16, right: 16, bottom: 24 })
        .onClick(() => {
          const params: Record<string, number | string> = {
            'courseId': this.courseId,
            'courseName': this.courseName
          }
          router.pushUrl({
            url: 'pages/LearningSpacePage',
            params: params
          })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  KnowledgeItemCard(item: KnowledgeItem) {
    Column() {
      Row() {
        Text(item.source === KNOWLEDGE_SOURCE.AI ? 'AI' :
          (item.source === KNOWLEDGE_SOURCE.UPLOAD ? 'F' : 'K'))
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .width(28)
          .height(28)
          .borderRadius(6)
          .backgroundColor(item.source === KNOWLEDGE_SOURCE.AI ?
            '#3B82F6' :
            (item.source === KNOWLEDGE_SOURCE.UPLOAD ? '#10B981' : '#F97316'))
          .textAlign(TextAlign.Center)

        Column() {
          Text(item.title)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Text(item.content)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .margin({ left: 8 })

        // 来源标签
        Text(this.getSourceLabel(item.source))
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor(this.getSourceColor(item.source))
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      }
      .width('100%')
      .padding(12)
    }
    .width('100%')
    .borderRadius(10)
    .backgroundColor($r('app.color.background'))
    .margin({ top: 8 })
  }

  async addKnowledge(): Promise<void> {
    if (this.newTitle.length === 0 || this.newContent.length === 0) {
      return
    }
    const item = new KnowledgeItem()
    item.courseId = this.courseId
    item.title = this.newTitle
    item.content = this.newContent
    item.source = KNOWLEDGE_SOURCE.MANUAL
    item.createdAt = Date.now()
    await knowledgeDao.insert(item)
    this.newTitle = ''
    this.newContent = ''
    await this.loadKnowledge()
  }

  async uploadFile(): Promise<void> {
    try {
      const documentSelectOptions = new picker.DocumentSelectOptions()
      documentSelectOptions.maxSelectNumber = 1
      const documentPicker = new picker.DocumentViewPicker()
      const uris = await documentPicker.select(documentSelectOptions)
      if (uris.length === 0) {
        return
      }
      const uri = uris[0]
      const fileName = uri.substring(uri.lastIndexOf('/') + 1)
      let content = ''
      try {
        const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
        const stat = fileIo.statSync(file.fd)
        const buf = new ArrayBuffer(stat.size)
        fileIo.readSync(file.fd, buf)
        fileIo.closeSync(file)
        content = this.bufferToString(buf)
      } catch (e) {
        content = '(文件内容无法解析，请手动输入或使用文本格式)'
      }
      const truncated = content.length > 1000 ? content.substring(0, 1000) + '...' : content
      const item = new KnowledgeItem()
      item.courseId = this.courseId
      item.title = fileName
      item.content = truncated
      item.source = KNOWLEDGE_SOURCE.UPLOAD
      item.createdAt = Date.now()
      await knowledgeDao.insert(item)
      await this.loadKnowledge()
    } catch (e) {
      // 用户取消选择
    }
  }

  private bufferToString(buf: ArrayBuffer): string {
    const bytes = new Uint8Array(buf)
    let str = ''
    for (let i = 0; i < bytes.length; i++) {
      str = str + String.fromCharCode(bytes[i])
    }
    return str
  }
}
