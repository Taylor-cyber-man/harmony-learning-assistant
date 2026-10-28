import { router } from '@kit.ArkUI'
import { AiEngine, MentalModel, DisputePoint, TestQuestion } from '../engine/AiEngine'
import { TestItem, BLOOM_LEVEL } from '../model/TestItem'
import { EvaluationReport } from '../model/EvaluationReport'
import { KnowledgeDao } from '../database/KnowledgeDao'
import { KnowledgeItem } from '../model/KnowledgeItem'
import { KnowledgeGraph } from '../components/KnowledgeGraph'
import { DisputeMapView } from '../components/DisputeMapView'
import { TestQuestionCard } from '../components/TestQuestionCard'
import { EvaluationDao } from '../database/EvaluationDao'
import { CourseDao } from '../database/CourseDao'
import { QuestionDao } from '../database/QuestionDao'
import { QuestionBlock, QUESTION_TYPE } from '../model/QuestionBlock'
import { Evaluator, EvaluationResult } from '../engine/Evaluator'
import { COURSE_STATUS } from '../model/Course'

const aiEngine = new AiEngine()
const evaluationDao = new EvaluationDao()
const courseDao = new CourseDao()
const knowledgeDao = new KnowledgeDao()
const questionDao = new QuestionDao()
const evaluator = new Evaluator()

@Entry
@Component
struct LearningSpacePage {
  @State courseId: number = 0
  @State courseName: string = ''
  @State mentalModels: MentalModel[] = []
  @State disputes: DisputePoint[] = []
  @State testQuestions: TestItem[] = []
  @State progress: number = 0
  @State q1Done: boolean = false
  @State q2Done: boolean = false
  @State q3Done: boolean = false
  @State q1Online: boolean = false
  @State q2Online: boolean = false
  @State q1Loaded: boolean = false
  @State q2Loaded: boolean = false
  @State q3Online: boolean = false
  @State submitting: boolean = false
  @State knowledgeItems: KnowledgeItem[] = []
  @State highlightMaterialRef: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number | string>
    if (params !== null && params !== undefined) {
      this.courseId = params['courseId'] as number
      this.courseName = params['courseName'] as string
      this.loadQuestions()
    }
  }

  async loadQuestions(): Promise<void> {
    // 加载知识条目
    const knowledgeItems = await knowledgeDao.getByCourseId(this.courseId)
    this.knowledgeItems = knowledgeItems

    let knowledgeSummary = ''
    for (const item of knowledgeItems) {
      knowledgeSummary = knowledgeSummary + item.title + ': ' + item.content + '\n'
    }
    if (knowledgeSummary.length === 0) {
      knowledgeSummary = '华为HCIA-AI认证相关知识：人工智能技术链、DeepSeek大模型、RAG检索增强生成、AI Agent智能体、MindSpore框架、ModelArts平台等。'
    }

    // ======== 加载已缓存的 question_block ========
    const cachedBlocks = await questionDao.getByCourseId(this.courseId)
    let q1Block: QuestionBlock | null = null
    let q2Block: QuestionBlock | null = null
    for (const b of cachedBlocks) {
      if (b.questionType === QUESTION_TYPE.FIRST) {
        q1Block = b
      } else if (b.questionType === QUESTION_TYPE.SECOND) {
        q2Block = b
      }
    }
    // 恢复进度状态
    if (q1Block !== null && q1Block.status >= 1) {
      this.q1Done = true
    }
    if (q2Block !== null && q2Block.status >= 1) {
      this.q2Done = true
    }
    this.updateProgress()

    // ======== 第一问：心智模型 ========
    if (q1Block !== null && q1Block.aiAnswer.length > 0) {
      // 从本地缓存加载
      try {
        this.mentalModels = this.parseMentalModels(q1Block.aiAnswer)
        this.q1Online = false
      } catch (e) {
        this.mentalModels = aiEngine.getMentalModels()
      }
    } else {
      // 首次：调用 API
      try {
        const modelJson = await aiEngine.fetchMentalModels(knowledgeSummary)
        this.mentalModels = this.parseMentalModels(modelJson)
        this.q1Online = true
      } catch (e) {
        this.mentalModels = aiEngine.getMentalModels()
        this.q1Online = false
      }
      // 保存到本地
      const block = new QuestionBlock()
      block.courseId = this.courseId
      block.questionType = QUESTION_TYPE.FIRST
      block.title = '核心心智模型'
      block.aiAnswer = JSON.stringify(this.mentalModels)
      block.status = 0
      await questionDao.insert(block)
    }
    this.q1Loaded = true

    // ======== 第二问：学术争议 ========
    if (q2Block !== null && q2Block.aiAnswer.length > 0) {
      try {
        this.disputes = this.parseDisputes(q2Block.aiAnswer)
        this.q2Online = false
      } catch (e) {
        this.disputes = aiEngine.getDisputePoints()
      }
    } else {
      try {
        const disputeJson = await aiEngine.fetchDisputes(knowledgeSummary)
        this.disputes = this.parseDisputes(disputeJson)
        this.q2Online = true
      } catch (e) {
        this.disputes = aiEngine.getDisputePoints()
        this.q2Online = false
      }
      const block = new QuestionBlock()
      block.courseId = this.courseId
      block.questionType = QUESTION_TYPE.SECOND
      block.title = '学术技术分歧'
      block.aiAnswer = JSON.stringify(this.disputes)
      block.status = 0
      await questionDao.insert(block)
    }
    this.q2Loaded = true

    // ======== 第三问：深度测试题 ========
    const existing = await evaluationDao.getTestItemsByCourseId(this.courseId)
    if (existing.length === 0) {
      let qs: TestQuestion[] = []
      try {
        qs = await aiEngine.fetchTestQuestions(knowledgeSummary)
        this.q3Online = true
      } catch (e) {
        qs = aiEngine.getTestQuestions()
        this.q3Online = false
      }
      const items: TestItem[] = []
      for (const q of qs) {
        const item = new TestItem()
        item.courseId = this.courseId
        item.questionText = q.question
        item.bloomLevel = q.bloomLevel
        item.isCorrect = 0
        item.createdAt = Date.now()
        items.push(item)
      }
      await evaluationDao.insertTestItems(items)
    }
    this.testQuestions = await evaluationDao.getTestItemsByCourseId(this.courseId)
  }

  updateProgress(): void {
    if (this.q1Done && this.q2Done) {
      this.progress = 66
    } else if (this.q1Done) {
      this.progress = 33
    } else {
      this.progress = 0
    }
  }

  parseMentalModels(json: string): MentalModel[] {
    const cleaned = this.cleanJson(json)
    const arr = JSON.parse(cleaned) as Record<string, Object>[]
    const result: MentalModel[] = []
    for (let i = 0; i < arr.length; i++) {
      const m = new MentalModel()
      m.id = i + 1
      m.name = arr[i]['name'] as string
      m.description = arr[i]['description'] as string
      const relRaw = arr[i]['relations']
      if (Array.isArray(relRaw)) {
        m.relations = (relRaw as (number | string)[]).map((v: number | string) => '' + v)
      }
      const labelRaw = arr[i]['relationLabels']
      if (Array.isArray(labelRaw)) {
        m.relationLabels = labelRaw as string[]
      }
      const childRaw = arr[i]['children']
      if (Array.isArray(childRaw)) {
        m.children = childRaw as string[]
      }
      const refRaw = arr[i]['materialRef']
      if (typeof refRaw === 'string') {
        m.materialRef = refRaw
      }
      result.push(m)
    }
    return result
  }

  parseDisputes(json: string): DisputePoint[] {
    const cleaned = this.cleanJson(json)
    const arr = JSON.parse(cleaned) as Record<string, string>[]
    const result: DisputePoint[] = []
    for (let i = 0; i < arr.length; i++) {
      const d = new DisputePoint()
      d.id = i + 1
      d.title = arr[i]['title']
      d.proSide = arr[i]['proSide']
      d.conSide = arr[i]['conSide']
      d.proEvidence = arr[i]['proEvidence']
      d.conEvidence = arr[i]['conEvidence']
      result.push(d)
    }
    return result
  }

  cleanJson(raw: string): string {
    let s = raw.trim()
    if (s.startsWith('```')) {
      const firstNewline = s.indexOf('\n')
      if (firstNewline > 0) {
        s = s.substring(firstNewline + 1)
      }
      if (s.endsWith('```')) {
        s = s.substring(0, s.length - 3)
      }
      s = s.trim()
    }
    return s
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        Button('返回')
          .fontSize(14)
          .fontColor($r('app.color.primary'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            router.back()
          })

        Column() {
          Text(this.courseName)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
          Text('进度 ' + this.progress + '%')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)

      Scroll() {
        Column() {
          // ======== 第一问 ========
          if (this.q1Loaded) {
            KnowledgeGraph({ models: this.mentalModels, knowledgeItems: this.knowledgeItems, onMaterialJump: (ref: string) => {
              this.highlightMaterialRef = ref
            } })
          } else {
            Column() {
              Text($r('app.string.question_one_title'))
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
              LoadingProgress()
                .width(24)
                .height(24)
                .margin({ top: 40 })
              Text('AI 正在分析心智模型...')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 12 })
            }
            .width('100%')
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(16)
            .padding(16)
            .margin({ top: 12 })
          }

          Row() {
            Text(this.q1Online ? 'AI 联网生成' : '离线预置数据')
              .fontSize(11)
              .fontColor(Color.White)
              .backgroundColor(this.q1Online ? '#10B981' : '#94A3B8')
              .borderRadius(4)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          }
          .width('100%')
          .margin({ top: 8 })

          if (!this.q1Done) {
            Button('我已理解 - 核心心智模型')
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.primary'))
              .borderRadius(10)
              .width('100%')
              .height(44)
              .margin({ top: 8, bottom: 8 })
              .onClick(async () => {
                this.q1Done = true
                this.updateProgress()
                const cachedBlocks = await questionDao.getByCourseId(this.courseId)
                for (const b of cachedBlocks) {
                  if (b.questionType === QUESTION_TYPE.FIRST && b.status === 0) {
                    await questionDao.updateStatus(b.id, 1)
                  }
                }
              })
          } else {
            Text('✓ 第一问已完成')
              .fontSize(14)
              .fontColor($r('app.color.success'))
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 8, bottom: 8 })
          }

          // ======== 学习资料区 ========
          Column() {
            Row() {
              Text('学习资料')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))

              Blank()

              Text('' + this.knowledgeItems.length + ' 条')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('100%')
            .padding({ bottom: 12 })

            if (this.knowledgeItems.length === 0) {
              Text('暂无学习资料，请在课程设置中添加')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 16, bottom: 16 })
            } else {
              ForEach(this.knowledgeItems, (item: KnowledgeItem) => {
                Column() {
                  Row() {
                    // 来源色条
                    Column()
                      .width(4)
                      .height(36)
                      .borderRadius(2)
                      .backgroundColor(item.source === 0 ? '#F97316' :
                        (item.source === 2 ? '#3B82F6' : '#10B981'))

                    Column() {
                      Text(item.title)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.highlightMaterialRef.length > 0 &&
                          (item.title.indexOf(this.highlightMaterialRef) >= 0 ||
                           this.highlightMaterialRef.indexOf(item.title) >= 0) ?
                          $r('app.color.primary') : $r('app.color.text_primary'))
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('100%')

                      Text(item.content)
                        .fontSize(12)
                        .fontColor($r('app.color.text_secondary'))
                        .maxLines(4)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('100%')
                        .margin({ top: 4 })
                        .lineHeight(18)
                    }
                    .layoutWeight(1)
                    .margin({ left: 10 })

                    // 来源标签
                    Text(item.source === 0 ? '手动' :
                      (item.source === 2 ? 'AI搜索' : '上传'))
                      .fontSize(10)
                      .fontColor(Color.White)
                      .backgroundColor(item.source === 0 ? '#F97316' :
                        (item.source === 2 ? '#3B82F6' : '#10B981'))
                      .borderRadius(4)
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  }
                  .width('100%')
                  .padding(10)
                }
                .width('100%')
                .borderRadius(10)
                .backgroundColor($r('app.color.background'))
                .border({
                  width: this.highlightMaterialRef.length > 0 &&
                    (item.title.indexOf(this.highlightMaterialRef) >= 0 ||
                     this.highlightMaterialRef.indexOf(item.title) >= 0) ? 1.5 : 0,
                  color: $r('app.color.primary')
                })
                .margin({ top: 6 })
              })
            }
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .padding(16)
          .margin({ top: 4, bottom: 20 })

          // ======== 第二问 ========
          if (this.q2Loaded) {
            DisputeMapView({ disputes: this.disputes })
          } else {
            Column() {
              Text('学术分歧分析')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
              LoadingProgress()
                .width(24)
                .height(24)
                .margin({ top: 40 })
              Text('AI 正在分析争议点...')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 12 })
            }
            .width('100%')
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(16)
            .padding(16)
            .margin({ top: 12 })
          }

          Row() {
            Text(this.q2Online ? 'AI 联网生成' : '离线预置数据')
              .fontSize(11)
              .fontColor(Color.White)
              .backgroundColor(this.q2Online ? '#10B981' : '#94A3B8')
              .borderRadius(4)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          }
          .width('100%')
          .margin({ top: 8 })

          if (!this.q2Done) {
            Button('我已理解 - 学术技术分歧')
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.accent'))
              .borderRadius(10)
              .width('100%')
              .height(44)
              .margin({ top: 8, bottom: 20 })
              .onClick(async () => {
                this.q2Done = true
                this.updateProgress()
                const cachedBlocks = await questionDao.getByCourseId(this.courseId)
                for (const b of cachedBlocks) {
                  if (b.questionType === QUESTION_TYPE.SECOND && b.status === 0) {
                    await questionDao.updateStatus(b.id, 1)
                  }
                }
              })
          } else {
            Text('✓ 第二问已完成')
              .fontSize(14)
              .fontColor($r('app.color.success'))
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 8, bottom: 20 })
          }

          // ======== 第三问 ========
          Column() {
            Text($r('app.string.question_three_title'))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .padding({ bottom: 12 })

            ForEach(this.testQuestions, (item: TestItem, index: number) => {
              TestQuestionCard({
                item: item,
                index: index,
                onSubmit: (answer: string) => {
                  this.onSubmitAnswer(item, index, answer)
                }
              })
            }, (item: TestItem) => item.id.toString())
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .padding(16)
          .margin({ top: 4, bottom: 20 })

          // 完成测试按钮
          if (this.submitting) {
            Column() {
              LoadingProgress()
                .width(28).height(28)
                .color($r('app.color.primary'))
              Text('正在生成评价报告...')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 8 })
            }
            .width('100%')
            .padding({ top: 8, bottom: 30 })
          } else {
            Button('提交全部 & 查看评价报告')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .backgroundColor(this.allAnswered() ? $r('app.color.primary') : $r('app.color.card_border'))
              .borderRadius(12)
              .width('100%')
              .height(48)
              .margin({ bottom: 30 })
              .enabled(this.allAnswered())
              .onClick(() => {
                this.submitAll()
              })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  allAnswered(): boolean {
    return this.testQuestions.every((t: TestItem) => t.isCorrect !== 0)
  }

  async onSubmitAnswer(item: TestItem, index: number, answer: string): Promise<void> {
    item.studentAnswer = answer
    try {
      const result = await aiEngine.evaluateAnswer(item.questionText, answer)
      const evalObj = JSON.parse(result) as Record<string, string | boolean>
      item.isCorrect = evalObj['isCorrect'] === true ? 1 : 2
      item.aiFeedback = evalObj['feedback'] as string
      this.q3Online = true
    } catch (e) {
      item.isCorrect = answer.length > 20 ? 1 : 2
      item.aiFeedback = answer.length > 20 ?
        '回答涉及了核心概念，理解基本正确。' :
        '你的回答可能遗漏了关键概念，请重新审视问题。'
    }
    await evaluationDao.updateTestItem(item)
    const updated: TestItem[] = []
    for (let i = 0; i < this.testQuestions.length; i++) {
      updated.push(this.testQuestions[i])
    }
    this.testQuestions = updated
  }

  async submitAll(): Promise<void> {
    this.submitting = true
    const items = this.testQuestions
    const result = evaluator.evaluate(items)

    const reportJson = JSON.stringify({
      conceptScore: result.conceptScore,
      criticalThinkingScore: result.criticalThinkingScore,
      practiceScore: result.practiceScore,
      correctCount: result.correctCount,
      totalCount: result.totalCount
    })
    const qaLog: Record<string, Record<string, string>> = {}
    for (const item of items) {
      qaLog['q' + item.id] = {
        'question': item.questionText,
        'bloomLevel': item.bloomLevel.toString(),
        'studentAnswer': item.studentAnswer,
        'aiFeedback': item.aiFeedback,
        'isCorrect': item.isCorrect === 1 ? '正确' : '待改进'
      }
    }
    const qaLogJson = JSON.stringify(qaLog)

    const report = new EvaluationReport()
    report.courseId = this.courseId
    report.conceptScore = result.conceptScore
    report.criticalThinkingScore = result.criticalThinkingScore
    report.practiceScore = result.practiceScore
    report.reportJson = reportJson
    report.qaLogJson = qaLogJson
    await evaluationDao.insertEvaluation(report)

    this.progress = 100
    this.q3Done = true
    await courseDao.updateStatus(this.courseId, COURSE_STATUS.COMPLETED)
    await courseDao.updateProgress(this.courseId, 100)

    // AI 综合评价（设 8 秒超时，超时则跳过直接显示基础报告）
    let overallSummary = ''
    try {
      const summaryPromise = aiEngine.generateOverallSummary(
        this.courseName, qaLogJson,
        {
          'conceptScore': result.conceptScore,
          'criticalScore': result.criticalThinkingScore,
          'practiceScore': result.practiceScore
        } as Record<string, number>
      )
      // 8 秒超时
      const timeoutPromise = new Promise<string>((_resolve: (value: string) => void,
        reject: (reason: Error) => void) => {
        setTimeout(() => { reject(new Error('AI评价超时')) }, 8000)
      })
      const summaryJson = await Promise.race([summaryPromise, timeoutPromise])
      const cleaned = this.cleanJson(summaryJson)
      const summaryObj = JSON.parse(cleaned) as Record<string, string>
      const parts: string[] = []
      if (summaryObj['overallEvaluation']) {
        parts.push('## 学习过程总体评价\n\n' + summaryObj['overallEvaluation'])
      }
      if (summaryObj['topicSummary']) {
        parts.push('## 题目概括性总结\n\n' + summaryObj['topicSummary'])
      }
      if (summaryObj['strengths']) {
        parts.push('## 优势领域分析\n\n' + summaryObj['strengths'])
      }
      if (summaryObj['improvements']) {
        parts.push('## 改进建议\n\n' + summaryObj['improvements'])
      }
      overallSummary = parts.join('\n\n---\n\n')
    } catch (e) {
      overallSummary = ''
    }

    this.submitting = false
    const params: Record<string, number | string> = {
      'courseId': this.courseId,
      'courseName': this.courseName,
      'conceptScore': result.conceptScore,
      'criticalScore': result.criticalThinkingScore,
      'practiceScore': result.practiceScore,
      'correctCount': result.correctCount,
      'totalCount': result.totalCount,
      'qaLogJson': qaLogJson,
      'gapList': JSON.stringify(result.gapList),
      'suggestions': JSON.stringify(result.suggestions),
      'aiSummary': overallSummary
    }
    router.pushUrl({
      url: 'pages/EvaluationReportPage',
      params: params
    })
  }
}
