import { relationalStore } from '@kit.ArkData'
import { getDbStore } from './DatabaseHelper'
import { KnowledgeItem } from '../model/KnowledgeItem'

export class KnowledgeDao {
  private tableName: string = 'knowledge_item'

  async insert(item: KnowledgeItem): Promise<number> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'course_id': item.courseId,
      'title': item.title,
      'content': item.content,
      'source': item.source,
      'created_at': Date.now()
    }
    return store.insert(this.tableName, valueBucket)
  }

  async getByCourseId(courseId: number): Promise<KnowledgeItem[]> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('course_id', courseId).orderByDesc('created_at')
    const resultSet = await store.query(predicates)
    return this.parseResultSet(resultSet)
  }

  async getById(id: number): Promise<KnowledgeItem | null> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    const resultSet = await store.query(predicates)
    const list = this.parseResultSet(resultSet)
    return list.length > 0 ? list[0] : null
  }

  async update(item: KnowledgeItem): Promise<void> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'title': item.title,
      'content': item.content
    }
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', item.id)
    await store.update(valueBucket, predicates)
  }

  async delete(id: number): Promise<void> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    await store.delete(predicates)
  }

  async search(courseId: number, keyword: string): Promise<KnowledgeItem[]> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('course_id', courseId)
      .and()
      .contains('title', keyword)
      .or()
      .contains('content', keyword)
      .orderByDesc('created_at')
    const resultSet = await store.query(predicates)
    return this.parseResultSet(resultSet)
  }

  async deleteByCourseId(courseId: number): Promise<void> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('course_id', courseId)
    await store.delete(predicates)
  }

  private parseResultSet(resultSet: relationalStore.ResultSet): KnowledgeItem[] {
    const items: KnowledgeItem[] = []
    while (resultSet.goToNextRow()) {
      const item = new KnowledgeItem()
      item.id = resultSet.getLong(resultSet.getColumnIndex('id'))
      item.courseId = resultSet.getLong(resultSet.getColumnIndex('course_id'))
      item.title = resultSet.getString(resultSet.getColumnIndex('title'))
      item.content = resultSet.getString(resultSet.getColumnIndex('content'))
      item.source = resultSet.getLong(resultSet.getColumnIndex('source'))
      item.createdAt = resultSet.getLong(resultSet.getColumnIndex('created_at'))
      items.push(item)
    }
    resultSet.close()
    return items
  }
}
