import { relationalStore } from '@kit.ArkData'
import { getDbStore } from './DatabaseHelper'
import { Course, COURSE_STATUS } from '../model/Course'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'CourseDao'
const DOMAIN = 0x0001

export class CourseDao {
  private tableName: string = 'course'

  async insert(course: Course): Promise<number> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'name': course.name,
      'keywords': course.keywords,
      'status': course.status,
      'progress': course.progress,
      'created_at': Date.now(),
      'updated_at': Date.now()
    }
    return store.insert(this.tableName, valueBucket)
  }

  async getAll(): Promise<Course[]> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.notEqualTo('status', COURSE_STATUS.ARCHIVED)
      .orderByAsc('sort_order')
    const resultSet = await store.query(predicates)
    return this.parseResultSet(resultSet)
  }

  async getAllForStats(): Promise<Course[]> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.orderByDesc('updated_at')
    const resultSet = await store.query(predicates)
    const courses = this.parseResultSet(resultSet)
    hilog.info(DOMAIN, TAG, 'getAllForStats: 查询到 ' + courses.length + ' 条')
    return courses
  }

  async updateSortOrder(id: number, order: number): Promise<void> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'sort_order': order,
      'updated_at': Date.now()
    }
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    await store.update(valueBucket, predicates)
  }

  async getMaxSortOrder(): Promise<number> {
    const store = await getDbStore()
    // 简单查询取最大 sort_order
    const all = await this.getAll()
    let max = 0
    for (let i = 0; i < all.length; i++) {
      if (all[i].sortOrder > max) {
        max = all[i].sortOrder
      }
    }
    return max
  }

  async getById(id: number): Promise<Course | null> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    const resultSet = await store.query(predicates)
    const list = this.parseResultSet(resultSet)
    return list.length > 0 ? list[0] : null
  }

  async getByName(name: string): Promise<Course | null> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('name', name)
    const resultSet = await store.query(predicates)
    const list = this.parseResultSet(resultSet)
    return list.length > 0 ? list[0] : null
  }

  async update(course: Course): Promise<void> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'name': course.name,
      'status': course.status,
      'progress': course.progress,
      'updated_at': Date.now()
    }
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', course.id)
    await store.update(valueBucket, predicates)
  }

  async updateStatus(id: number, status: number): Promise<void> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'status': status,
      'updated_at': Date.now()
    }
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    await store.update(valueBucket, predicates)
  }

  async updateProgress(id: number, progress: number): Promise<void> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'progress': progress,
      'updated_at': Date.now()
    }
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    await store.update(valueBucket, predicates)
  }

  async getArchivedCourses(): Promise<Course[]> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('status', COURSE_STATUS.ARCHIVED)
      .orderByDesc('updated_at')
    const resultSet = await store.query(predicates)
    return this.parseResultSet(resultSet)
  }

  async restoreCourse(id: number): Promise<void> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'status': COURSE_STATUS.COMPLETED,
      'updated_at': Date.now()
    }
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    await store.update(valueBucket, predicates)
  }

  async delete(id: number): Promise<void> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    await store.delete(predicates)
  }

  private parseResultSet(resultSet: relationalStore.ResultSet): Course[] {
    const courses: Course[] = []
    while (resultSet.goToNextRow()) {
      const course = new Course()
      course.id = resultSet.getLong(resultSet.getColumnIndex('id'))
      course.name = resultSet.getString(resultSet.getColumnIndex('name'))
      course.keywords = resultSet.getString(resultSet.getColumnIndex('keywords'))
      course.status = resultSet.getLong(resultSet.getColumnIndex('status'))
      course.progress = resultSet.getLong(resultSet.getColumnIndex('progress'))
      try {
        course.sortOrder = resultSet.getLong(resultSet.getColumnIndex('sort_order'))
      } catch (e) {
        course.sortOrder = 0
      }
      course.createdAt = resultSet.getLong(resultSet.getColumnIndex('created_at'))
      course.updatedAt = resultSet.getLong(resultSet.getColumnIndex('updated_at'))
      courses.push(course)
    }
    resultSet.close()
    return courses
  }
}
