import { relationalStore } from '@kit.ArkData'
import { getDbStore } from './DatabaseHelper'
import { QuestionBlock } from '../model/QuestionBlock'

export class QuestionDao {
  private tableName: string = 'question_block'

  async insert(block: QuestionBlock): Promise<number> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'course_id': block.courseId,
      'question_type': block.questionType,
      'title': block.title,
      'ai_answer': block.aiAnswer,
      'user_reflection': block.userReflection,
      'status': block.status,
      'created_at': Date.now()
    }
    return store.insert(this.tableName, valueBucket)
  }

  async getByCourseId(courseId: number): Promise<QuestionBlock[]> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('course_id', courseId).orderByAsc('question_type')
    const resultSet = await store.query(predicates)
    return this.parseResultSet(resultSet)
  }

  async update(block: QuestionBlock): Promise<void> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'ai_answer': block.aiAnswer,
      'user_reflection': block.userReflection,
      'status': block.status
    }
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', block.id)
    await store.update(valueBucket, predicates)
  }

  async updateStatus(id: number, status: number): Promise<void> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'status': status
    }
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    await store.update(valueBucket, predicates)
  }

  async deleteByCourseId(courseId: number): Promise<void> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('course_id', courseId)
    await store.delete(predicates)
  }

  private parseResultSet(resultSet: relationalStore.ResultSet): QuestionBlock[] {
    const blocks: QuestionBlock[] = []
    while (resultSet.goToNextRow()) {
      const block = new QuestionBlock()
      block.id = resultSet.getLong(resultSet.getColumnIndex('id'))
      block.courseId = resultSet.getLong(resultSet.getColumnIndex('course_id'))
      block.questionType = resultSet.getLong(resultSet.getColumnIndex('question_type'))
      block.title = resultSet.getString(resultSet.getColumnIndex('title'))
      block.aiAnswer = resultSet.getString(resultSet.getColumnIndex('ai_answer'))
      block.userReflection = resultSet.getString(resultSet.getColumnIndex('user_reflection'))
      block.status = resultSet.getLong(resultSet.getColumnIndex('status'))
      block.createdAt = resultSet.getLong(resultSet.getColumnIndex('created_at'))
      blocks.push(block)
    }
    resultSet.close()
    return blocks
  }
}
