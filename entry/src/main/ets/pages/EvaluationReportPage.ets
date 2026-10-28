import { router } from '@kit.ArkUI'
import { RadarChart } from '../components/RadarChart'
import { picker } from '@kit.CoreFileKit'
import { fileIo } from '@kit.CoreFileKit'

class QaItem {
  key: string = ''
  question: string = ''
  studentAnswer: string = ''
  aiFeedback: string = ''
  isCorrect: string = ''
}

@Entry
@Component
struct EvaluationReportPage {
  @State courseName: string = ''
  @State conceptScore: number = 0
  @State criticalScore: number = 0
  @State practiceScore: number = 0
  @State correctCount: number = 0
  @State totalCount: number = 0
  @State gapList: string[] = []
  @State suggestions: string[] = []
  @State qaList: QaItem[] = []
  @State expandedQa: string = ''
  @State aiSummary: string = ''
  @State showExportSheet: boolean = false

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number | string>
    if (params !== null && params !== undefined) {
      this.courseName = params['courseName'] as string
      this.conceptScore = params['conceptScore'] as number
      this.criticalScore = params['criticalScore'] as number
      this.practiceScore = params['practiceScore'] as number
      this.correctCount = params['correctCount'] as number
      this.totalCount = params['totalCount'] as number
      const qaLogStr = params['qaLogJson'] as string
      if (qaLogStr) { this.qaList = this.parseQaLog(qaLogStr) }
      const gapListStr = params['gapList'] as string
      if (gapListStr) { this.gapList = JSON.parse(gapListStr) }
      const suggestionsStr = params['suggestions'] as string
      if (suggestionsStr) { this.suggestions = JSON.parse(suggestionsStr) }
      const aiSummaryStr = params['aiSummary'] as string
      if (aiSummaryStr && aiSummaryStr.length > 0) { this.aiSummary = aiSummaryStr }
    }
  }

  getAvgScore(): number {
    return Math.round((this.conceptScore + this.criticalScore + this.practiceScore) / 3)
  }

  parseQaLog(jsonStr: string): QaItem[] {
    const obj = JSON.parse(jsonStr) as Record<string, Record<string, string>>
    const keys = Object.keys(obj)
    const result: QaItem[] = []
    for (let i = 0; i < keys.length; i++) {
      const k = keys[i]
      const qa = new QaItem()
      qa.key = k
      qa.question = obj[k]['question']
      qa.studentAnswer = obj[k]['studentAnswer']
      qa.aiFeedback = obj[k]['aiFeedback']
      qa.isCorrect = obj[k]['isCorrect']
      result.push(qa)
    }
    return result
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Button('返回').fontSize(14).fontColor($r('app.color.primary'))
            .backgroundColor(Color.Transparent).onClick(() => { router.back() })
          Text($r('app.string.evaluation_report')).fontSize(18).fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary')).layoutWeight(1).textAlign(TextAlign.Center)
        }.width('100%').padding(16)

        Scroll() {
          Column() {
            // 综合评分
            Column() {
              Text('综合评分').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
              Text(this.getAvgScore() + '分').fontSize(48).fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary')).margin({ top: 4 })
              Text(this.correctCount + '/' + this.totalCount + ' 题正确')
                .fontSize(14).fontColor($r('app.color.text_secondary'))
            }.width('100%').padding(16).backgroundColor($r('app.color.card_background')).borderRadius(16)

            // 雷达图 + 导出按钮
            Column() {
              Text('能力维度分析').fontSize(16).fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary')).width('100%').padding({ bottom: 8 })
              RadarChart({
                conceptScore: this.conceptScore,
                criticalScore: this.criticalScore,
                practiceScore: this.practiceScore
              })
              Button('导出评价报告').fontSize(14).fontColor($r('app.color.primary'))
                .backgroundColor('rgba(37,99,235,0.06)')
                .border({ width: 1, color: $r('app.color.primary') }).borderRadius(10)
                .width('100%').height(40).margin({ top: 16 })
                .onClick(() => { this.showExportSheet = true })
            }.width('100%').padding(16).backgroundColor($r('app.color.card_background'))
            .borderRadius(16).margin({ top: 12 })

            // AI 学习评价
            if (this.aiSummary.length > 0) {
              Column() {
                Text('AI 学习评价').fontSize(16).fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary')).width('100%').padding({ bottom: 8 })
                Text(this.aiSummary).fontSize(13).fontColor($r('app.color.text_primary'))
                  .width('100%').lineHeight(20)
              }.width('100%').padding(16).backgroundColor($r('app.color.card_background'))
              .borderRadius(16).margin({ top: 12 })
            }

            // 认知漏洞
            if (this.gapList.length > 0) {
              Column() {
                Text('认知漏洞诊断').fontSize(16).fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.error')).width('100%').padding({ bottom: 8 })
                ForEach(this.gapList, (gap: string) => {
                  Text('❌ ' + gap).fontSize(13).fontColor($r('app.color.text_primary'))
                    .width('100%').padding({ top: 4, bottom: 4 })
                })
              }.width('100%').padding(16).backgroundColor($r('app.color.card_background'))
              .borderRadius(16).margin({ top: 12 })
            }

            // 复习建议
            if (this.suggestions.length > 0) {
              Column() {
                Text('复习建议').fontSize(16).fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.accent')).width('100%').padding({ bottom: 8 })
                ForEach(this.suggestions, (sug: string) => {
                  Text('• ' + sug).fontSize(13).fontColor($r('app.color.text_primary'))
                    .width('100%').padding({ top: 4, bottom: 4 })
                })
              }.width('100%').padding(16).backgroundColor($r('app.color.card_background'))
              .borderRadius(16).margin({ top: 12 })
            }

            // 问答记录
            Column() {
              Text('问答原始记录').fontSize(16).fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary')).width('100%').padding({ bottom: 8 })
              ForEach(this.qaList, (item: QaItem) => {
                Column() {
                  Row() {
                    Text('第' + item.key.substring(1) + '题: ' + item.question.substring(0, 30) + '...')
                      .fontSize(13).fontColor($r('app.color.text_primary')).layoutWeight(1).maxLines(1)
                    Text(this.expandedQa === item.key ? '▲' : '▼').fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                  }.width('100%').padding(10).onClick(() => {
                    this.expandedQa = this.expandedQa === item.key ? '' : item.key
                  })
                  if (this.expandedQa === item.key) {
                    Column() {
                      Text('Q: ' + item.question).fontSize(12)
                        .fontColor($r('app.color.text_primary')).width('100%').padding({ bottom: 8 })
                      Text('A: ' + item.studentAnswer).fontSize(12)
                        .fontColor($r('app.color.text_secondary')).width('100%').padding({ bottom: 8 })
                      Text('-> ' + item.aiFeedback).fontSize(12)
                        .fontColor(item.isCorrect === '正确' ? $r('app.color.success') : $r('app.color.error'))
                        .width('100%')
                    }.width('100%').padding(10)
                    .backgroundColor($r('app.color.canvas_bg')).borderRadius(8)
                  }
                }.width('100%').border({ width: { bottom: 0.5 }, color: $r('app.color.card_border') })
              })
            }.width('100%').backgroundColor($r('app.color.card_background'))
            .borderRadius(16).padding(16).margin({ top: 12, bottom: 30 })
          }.width('100%').padding({ left: 16, right: 16 })
        }.layoutWeight(1).scrollBar(BarState.Off)
      }.width('100%').height('100%').backgroundColor($r('app.color.background'))

      // 导出格式选择 Sheet
      if (this.showExportSheet) {
        Column()
          .width('100%').height('100%').backgroundColor('#40000000')
          .justifyContent(FlexAlign.End)
          .onClick(() => { this.showExportSheet = false })
        Column() {
          Column().width(40).height(4).borderRadius(2).backgroundColor('#E2E8F0')
            .margin({ top: 10, bottom: 14 })
          Text('选择导出格式').fontSize(17).fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary')).width('100%').textAlign(TextAlign.Center)
            .padding({ bottom: 16 })
          this.buildExportBtn('TXT — 纯文本', 'txt')
          this.buildExportBtn('Markdown — 带格式排版', 'md')
          this.buildExportBtn('JSON — 结构化数据', 'json')
          Button('取消').fontSize(15).fontColor($r('app.color.text_secondary'))
            .backgroundColor(Color.Transparent).width('100%').height(44).margin({ top: 4 })
            .onClick(() => { this.showExportSheet = false })
        }.width('100%').padding({ left: 24, right: 24, bottom: 20 })
        .backgroundColor($r('app.color.card_background'))
        .borderRadius({ topLeft: 20, topRight: 20 })
      }
    }.width('100%').height('100%')
  }

  @Builder
  buildExportBtn(label: string, fmt: string) {
    Button(label).fontSize(15).fontColor($r('app.color.text_primary'))
      .backgroundColor($r('app.color.background')).borderRadius(10)
      .width('100%').height(48).margin({ bottom: 8 })
      .onClick(() => { this.showExportSheet = false; this.doExportReportFile(fmt) })
  }

  async doExportReportFile(format: string): Promise<void> {
    let content = ''
    if (format === 'md') {
      content = this.generateReportMarkdown()
    } else if (format === 'json') {
      content = this.generateReportJson()
    } else {
      content = this.generateReportText()
    }
    const fileName = this.courseName.replace(/[\\/:*?"<>|]/g, '_') + '_评价报告.' + format
    try {
      const saveOptions = new picker.DocumentSaveOptions()
      saveOptions.newFileNames = [fileName]
      const documentPicker = new picker.DocumentViewPicker()
      const uris = await documentPicker.save(saveOptions)
      if (uris.length === 0) { return }
      const uri = uris[0]
      const file = fileIo.openSync(uri, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
      fileIo.writeSync(file.fd, content)
      fileIo.closeSync(file)
      AlertDialog.show({ title: '导出成功', message: '文件已保存', autoCancel: true,
        alignment: DialogAlignment.Center, primaryButton: { value: '确定', action: () => {} } })
    } catch (e) {
      AlertDialog.show({ title: '导出失败', message: '无法保存文件', autoCancel: true,
        alignment: DialogAlignment.Center, primaryButton: { value: '确定', action: () => {} } })
    }
  }

  generateReportText(): string {
    let text = '===== 评价报告 =====\n'
    text = text + '课程: ' + this.courseName + '\n'
    text = text + '综合评分: ' + this.getAvgScore() + '/100\n'
    text = text + '正确题数: ' + this.correctCount + '/' + this.totalCount + '\n\n'
    text = text + '===== 能力维度 =====\n'
    text = text + '概念理解: ' + this.conceptScore + '分\n'
    text = text + '批判思维: ' + this.criticalScore + '分\n'
    text = text + '实践迁移: ' + this.practiceScore + '分\n\n'
    if (this.aiSummary.length > 0) {
      text = text + '===== AI 学习评价 =====\n' + this.aiSummary + '\n\n'
    }
    if (this.gapList.length > 0) {
      text = text + '===== 认知漏洞 =====\n'
      for (let i = 0; i < this.gapList.length; i++) { text = text + (i + 1) + '. ' + this.gapList[i] + '\n' }
      text = text + '\n'
    }
    if (this.suggestions.length > 0) {
      text = text + '===== 复习建议 =====\n'
      for (let i = 0; i < this.suggestions.length; i++) { text = text + (i + 1) + '. ' + this.suggestions[i] + '\n' }
      text = text + '\n'
    }
    text = text + '===== 问答记录 =====\n'
    for (let i = 0; i < this.qaList.length; i++) {
      const qa = this.qaList[i]
      text = text + 'Q' + (i + 1) + ': ' + qa.question + '\n'
      text = text + 'A: ' + qa.studentAnswer + '\n'
      text = text + '评价: ' + qa.aiFeedback + ' [' + qa.isCorrect + ']\n\n'
    }
    return text
  }

  generateReportMarkdown(): string {
    let md = '# 📊 评价报告\n\n'
    md = md + '**课程：' + this.courseName + '**  \n'
    md = md + '综合评分：**' + this.getAvgScore() + '/100**  \n'
    md = md + '正确：' + this.correctCount + '/' + this.totalCount + ' 题\n\n'
    md = md + '---\n\n## 🎯 能力维度\n\n'
    md = md + '| 维度 | 得分 | 等级 |\n|------|------|------|\n'
    md = md + '| 概念理解 | ' + this.conceptScore + ' | ' + this.scoreLevel(this.conceptScore) + ' |\n'
    md = md + '| 批判思维 | ' + this.criticalScore + ' | ' + this.scoreLevel(this.criticalScore) + ' |\n'
    md = md + '| 实践迁移 | ' + this.practiceScore + ' | ' + this.scoreLevel(this.practiceScore) + ' |\n\n'
    if (this.aiSummary.length > 0) {
      md = md + '---\n\n## 🤖 AI 学习评价\n\n' + this.aiSummary + '\n\n'
    }
    if (this.gapList.length > 0) {
      md = md + '---\n\n## ❌ 认知漏洞\n\n'
      for (let i = 0; i < this.gapList.length; i++) { md = md + '- ' + this.gapList[i] + '\n' }
      md = md + '\n'
    }
    if (this.suggestions.length > 0) {
      md = md + '---\n\n## 💡 复习建议\n\n'
      for (let i = 0; i < this.suggestions.length; i++) { md = md + (i + 1) + '. ' + this.suggestions[i] + '\n' }
      md = md + '\n'
    }
    md = md + '---\n\n## 📝 问答记录\n\n'
    for (let i = 0; i < this.qaList.length; i++) {
      const qa = this.qaList[i]
      md = md + '### Q' + (i + 1) + ': ' + qa.question + '\n\n'
      md = md + '> **你的回答：** ' + qa.studentAnswer + '\n\n'
      const resultTag = qa.isCorrect === '正确' ? '✅ 正确' : '⚠️ 待改进'
      md = md + '> **评价：** ' + qa.aiFeedback + '  \n'
      md = md + '> **结果：** ' + resultTag + '\n\n'
    }
    md = md + '---\n*由「三问学习机」生成*\n'
    return md
  }

  generateReportJson(): string {
    const qaArr: Record<string, string>[] = []
    for (let i = 0; i < this.qaList.length; i++) {
      const qa = this.qaList[i]
      const item: Record<string, string> = {}
      item['question'] = qa.question
      item['answer'] = qa.studentAnswer
      item['feedback'] = qa.aiFeedback
      item['result'] = qa.isCorrect
      qaArr.push(item)
    }
    const data: Record<string, Object> = {}
    data['courseName'] = this.courseName
    data['totalScore'] = this.getAvgScore()
    data['correctCount'] = this.correctCount
    data['totalCount'] = this.totalCount
    data['conceptScore'] = this.conceptScore
    data['criticalScore'] = this.criticalScore
    data['practiceScore'] = this.practiceScore
    data['gaps'] = this.gapList
    data['suggestions'] = this.suggestions
    data['aiSummary'] = this.aiSummary
    data['qaLog'] = qaArr
    return JSON.stringify(data, null, 2)
  }

  private scoreLevel(score: number): string {
    if (score >= 80) { return '⭐⭐⭐ 优秀' }
    if (score >= 60) { return '⭐⭐ 良好' }
    if (score >= 40) { return '⭐ 及格' }
    return '待提升'
  }
}
