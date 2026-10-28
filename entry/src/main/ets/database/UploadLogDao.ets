import { relationalStore } from '@kit.ArkData'
import { getDbStore } from './DatabaseHelper'
import { UploadLog } from '../model/UploadLog'

export class UploadLogDao {
  private tableName: string = 'upload_log'

  async insert(log: UploadLog): Promise<number> {
    const store = await getDbStore()
    const valueBucket: relationalStore.ValuesBucket = {
      'course_id': log.courseId,
      'course_name': log.courseName,
      'file_name': log.fileName,
      'file_size': log.fileSize,
      'upload_time': Date.now()
    }
    return store.insert(this.tableName, valueBucket)
  }

  async getByCourseId(courseId: number): Promise<UploadLog[]> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('course_id', courseId)
      .orderByDesc('upload_time')
    const resultSet = await store.query(predicates)
    return this.parseResultSet(resultSet)
  }

  async getAll(): Promise<UploadLog[]> {
    const store = await getDbStore()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.orderByDesc('upload_time')
    const resultSet = await store.query(predicates)
    return this.parseResultSet(resultSet)
  }

  private parseResultSet(resultSet: relationalStore.ResultSet): UploadLog[] {
    const logs: UploadLog[] = []
    while (resultSet.goToNextRow()) {
      const log = new UploadLog()
      log.id = resultSet.getLong(resultSet.getColumnIndex('id'))
      log.courseId = resultSet.getLong(resultSet.getColumnIndex('course_id'))
      log.courseName = resultSet.getString(resultSet.getColumnIndex('course_name'))
      log.fileName = resultSet.getString(resultSet.getColumnIndex('file_name'))
      log.fileSize = resultSet.getLong(resultSet.getColumnIndex('file_size'))
      log.uploadTime = resultSet.getLong(resultSet.getColumnIndex('upload_time'))
      logs.push(log)
    }
    resultSet.close()
    return logs
  }
}
