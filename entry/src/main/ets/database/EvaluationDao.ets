import { relationalStore } from '@kit.ArkData'
import { getDbStore } from './DatabaseHelper'
import { EvaluationReport } from '../model/EvaluationReport'
import { TestItem } from '../model/TestItem'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'EvaluationDao'
const DOMAIN = 0x0001

export class EvaluationDao {
  private tableName: string = 'evaluation'
  private testTable: string = 'test_item'

  // ---- TestItem CRUD ----

  async insertTestItems(items: TestItem[]): Promise<void> {
    const store = await getDbStore()
    for (const item of items) {
      const valueBucket: relationalStore.ValuesBucket = {
        'course_id': item.courseId,
        'question_text': item.questionText,
        'bloom_level': item.bloomLevel,
        'student_answer': item.studentAnswer,
        'ai_feedback': item.aiFeedback,
        'is_correct': item.isCorrect,
        'created_at': Date.now()
      }
      await store.insert(this.testTable, valueBucket)
    }
  }

  async getTestItemsByCourseId(courseId: number): Promise<TestItem[]> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.testTable)
    predicates.equalTo('course_id', courseId).orderByAsc('id')
    const resultSet = await store.query(predicates)
    const items: TestItem[] = []
    while (resultSet.goToNextRow()) {
      const item = new TestItem()
      item.id = resultSet.getLong(resultSet.getColumnIndex('id'))
      item.courseId = resultSet.getLong(resultSet.getColumnIndex('course_id'))
      item.questionText = resultSet.getString(resultSet.getColumnIndex('question_text'))
      item.bloomLevel = resultSet.getLong(resultSet.getColumnIndex('bloom_level'))
      item.studentAnswer = resultSet.getString(resultSet.getColumnIndex('student_answer'))
      item.aiFeedback = resultSet.getString(resultSet.getColumnIndex('ai_feedback'))
      item.isCorrect = resultSet.getLong(resultSet.getColumnIndex('is_correct'))
      item.createdAt = resultSet.getLong(resultSet.getColumnIndex('created_at'))
      items.push(item)
    }
    resultSet.close()
    return items
  }

  async updateTestItem(item: TestItem): Promise<void> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'student_answer': item.studentAnswer,
      'ai_feedback': item.aiFeedback,
      'is_correct': item.isCorrect
    }
    const predicates = new relationalStore.RdbPredicates(this.testTable)
    predicates.equalTo('id', item.id)
    await store.update(valueBucket, predicates)
  }

  // ---- Evaluation CRUD ----

  async insertEvaluation(report: EvaluationReport): Promise<number> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'course_id': report.courseId,
      'concept_score': report.conceptScore,
      'critical_thinking_score': report.criticalThinkingScore,
      'practice_score': report.practiceScore,
      'report_json': report.reportJson,
      'qa_log_json': report.qaLogJson,
      'created_at': Date.now()
    }
    return store.insert(this.tableName, valueBucket)
  }

  async getByCourseId(courseId: number): Promise<EvaluationReport | null> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('course_id', courseId).orderByDesc('created_at').limitAs(1)
    const resultSet = await store.query(predicates)
    let report: EvaluationReport | null = null
    if (resultSet.goToNextRow()) {
      report = this.parseRow(resultSet)
    }
    resultSet.close()
    return report
  }

  async getAll(): Promise<EvaluationReport[]> {
    const store = await getDbStore()
    hilog.info(DOMAIN, TAG, 'getAll: 开始查询 evaluation 表')
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.orderByDesc('created_at')
    const resultSet = await store.query(predicates)
    const reports: EvaluationReport[] = []
    while (resultSet.goToNextRow()) {
      reports.push(this.parseRow(resultSet))
    }
    resultSet.close()
    hilog.info(DOMAIN, TAG, 'getAll: 查询到 ' + reports.length + ' 条')
    return reports
  }

  async getByCourseIdList(courseIds: number[]): Promise<EvaluationReport[]> {
    if (courseIds.length === 0) {
      return []
    }
    const store = await getDbStore()
    // 为每个 courseId 查询最新一条 evaluation
    const reports: EvaluationReport[] = []
    for (let i = 0; i < courseIds.length; i++) {
      const report = await this.getByCourseId(courseIds[i])
      if (report !== null) {
        reports.push(report)
      }
    }
    return reports
  }

  private parseRow(resultSet: relationalStore.ResultSet): EvaluationReport {
    const report = new EvaluationReport()
    report.id = resultSet.getLong(resultSet.getColumnIndex('id'))
    report.courseId = resultSet.getLong(resultSet.getColumnIndex('course_id'))
    report.conceptScore = resultSet.getLong(resultSet.getColumnIndex('concept_score'))
    report.criticalThinkingScore = resultSet.getLong(resultSet.getColumnIndex('critical_thinking_score'))
    report.practiceScore = resultSet.getLong(resultSet.getColumnIndex('practice_score'))
    report.reportJson = resultSet.getString(resultSet.getColumnIndex('report_json'))
    report.qaLogJson = resultSet.getString(resultSet.getColumnIndex('qa_log_json'))
    report.createdAt = resultSet.getLong(resultSet.getColumnIndex('created_at'))
    return report
  }
}
