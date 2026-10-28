import { relationalStore } from '@kit.ArkData'
import { UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'DatabaseHelper'
const DOMAIN = 0x0001

const DB_NAME = 'LearningApp.db'
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: DB_NAME,
  securityLevel: relationalStore.SecurityLevel.S1
}

// 建表 SQL
const SQL_CREATE_COURSE = `
  CREATE TABLE IF NOT EXISTS course (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    keywords TEXT,
    status INTEGER DEFAULT 0,
    progress INTEGER DEFAULT 0,
    sort_order INTEGER DEFAULT 0,
    created_at INTEGER,
    updated_at INTEGER
  )`

const SQL_CREATE_KNOWLEDGE = `
  CREATE TABLE IF NOT EXISTS knowledge_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER,
    title TEXT NOT NULL,
    content TEXT,
    source INTEGER DEFAULT 0,
    created_at INTEGER,
    FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
  )`

const SQL_CREATE_QUESTION = `
  CREATE TABLE IF NOT EXISTS question_block (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER,
    question_type INTEGER,
    title TEXT,
    ai_answer TEXT,
    user_reflection TEXT,
    status INTEGER DEFAULT 0,
    created_at INTEGER,
    FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
  )`

const SQL_CREATE_TEST = `
  CREATE TABLE IF NOT EXISTS test_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER,
    question_text TEXT,
    bloom_level INTEGER,
    student_answer TEXT,
    ai_feedback TEXT,
    is_correct INTEGER DEFAULT 0,
    created_at INTEGER,
    FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
  )`

const SQL_CREATE_EVALUATION = `
  CREATE TABLE IF NOT EXISTS evaluation (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER,
    concept_score INTEGER DEFAULT 0,
    critical_thinking_score INTEGER DEFAULT 0,
    practice_score INTEGER DEFAULT 0,
    report_json TEXT,
    qa_log_json TEXT,
    created_at INTEGER,
    FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
  )`

const SQL_CREATE_UPLOAD_LOG = `
  CREATE TABLE IF NOT EXISTS upload_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER,
    course_name TEXT,
    file_name TEXT NOT NULL,
    file_size INTEGER DEFAULT 0,
    upload_time INTEGER,
    FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE SET NULL
  )`

let rdbStore: relationalStore.RdbStore | null = null
let dbInitPromise: Promise<void> | null = null

export async function initDatabase(context: Context): Promise<void> {
  if (rdbStore !== null) {
    return
  }
  if (dbInitPromise !== null) {
    return dbInitPromise
  }
  dbInitPromise = (async () => {
    rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG)
    await rdbStore.executeSql(SQL_CREATE_COURSE)
    await rdbStore.executeSql(SQL_CREATE_KNOWLEDGE)
    await rdbStore.executeSql(SQL_CREATE_QUESTION)
    await rdbStore.executeSql(SQL_CREATE_TEST)
    await rdbStore.executeSql(SQL_CREATE_EVALUATION)
    await rdbStore.executeSql(SQL_CREATE_UPLOAD_LOG)
    // 兼容旧表：尝试添加 sort_order 列
    try {
      await rdbStore.executeSql(
        'ALTER TABLE course ADD COLUMN sort_order INTEGER DEFAULT 0'
      )
    } catch (e) {
      // 列已存在，忽略
    }
  })()
  return dbInitPromise
}

export async function ensureDatabase(): Promise<void> {
  if (rdbStore !== null) {
    return
  }
  if (dbInitPromise !== null) {
    await dbInitPromise
    return
  }
  throw new Error('Database not initialized. Call initDatabase(context) first.')
}

export async function ensureDatabaseSafe(context: Context): Promise<void> {
  hilog.info(DOMAIN, TAG, 'ensureDatabaseSafe: rdbStore=' + (rdbStore !== null ? 'OK' : 'null') +
    ' dbInitPromise=' + (dbInitPromise !== null ? 'exists' : 'null'))
  if (rdbStore !== null) {
    return
  }
  if (dbInitPromise !== null) {
    hilog.info(DOMAIN, TAG, '等待已存在的 dbInitPromise...')
    await dbInitPromise
    hilog.info(DOMAIN, TAG, 'dbInitPromise 完成, rdbStore=' + (rdbStore !== null ? 'OK' : 'null'))
    return
  }
  // 尚未初始化，用传入的 context 初始化
  hilog.info(DOMAIN, TAG, 'DB 尚未初始化，调用 initDatabase...')
  await initDatabase(context)
  hilog.info(DOMAIN, TAG, 'initDatabase 完成, rdbStore=' + (rdbStore !== null ? 'OK' : 'null'))
}

export async function getDbStore(): Promise<relationalStore.RdbStore> {
  if (rdbStore !== null) {
    return rdbStore
  }
  hilog.info(DOMAIN, TAG, 'getDbStore: rdbStore 为 null，进入重试循环...')
  for (let i = 0; i < 30; i++) {
    await new Promise<void>((resolve: (value: void) => void) => {
      setTimeout(() => { resolve() }, 100)
    })
    if (rdbStore !== null) {
      hilog.info(DOMAIN, TAG, 'getDbStore 重试 ' + (i + 1) + ' 次成功')
      return rdbStore
    }
  }
  hilog.error(DOMAIN, TAG, 'getDbStore 30 次重试后仍为 null！')
  throw new Error('数据库初始化超时')
}

export function getTableNames(): string[] {
  return ['course', 'knowledge_item', 'question_block', 'test_item', 'evaluation', 'upload_log']
}
