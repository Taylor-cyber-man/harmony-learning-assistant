import { EvaluationDao } from '../database/EvaluationDao'
import { CourseDao } from '../database/CourseDao'
import { UploadLogDao } from '../database/UploadLogDao'
import { Course, COURSE_STATUS } from '../model/Course'
import { EvaluationReport } from '../model/EvaluationReport'
import { UploadLog } from '../model/UploadLog'
import { ensureDatabaseSafe } from '../database/DatabaseHelper'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'ProfileVM'
const DOMAIN = 0x0001

const evaluationDao = new EvaluationDao()
const courseDao = new CourseDao()
const uploadLogDao = new UploadLogDao()

export class WeekDataPoint {
  dayLabel: string = ''
  dayDate: string = ''
  minutes: number = 0
}

export class SubjectScore {
  courseName: string = ''
  conceptScore: number = 0
  criticalScore: number = 0
  practiceScore: number = 0
}

export class ProfileStats {
  totalLearningDays: number = 0
  completedCourses: number = 0
  totalCourses: number = 0
  averageScore: number = 0
}

@Observed
export class ProfileViewModel {
  stats: ProfileStats = new ProfileStats()
  weekData: WeekDataPoint[] = []
  subjectScores: SubjectScore[] = []
  archivedCourses: Course[] = []
  uploadLogs: UploadLog[] = []
  allReports: EvaluationReport[] = []

  // 需要 Context 来确保 DB 初始化（用于 Page 传入的 context）
  async loadAll(context: Context): Promise<void> {
    hilog.info(DOMAIN, TAG, '========== loadAll 开始 ==========')
    await ensureDatabaseSafe(context)
    hilog.info(DOMAIN, TAG, 'DB 就绪，开始加载各模块...')

    await this.loadStats()
    await this.loadWeekData()
    await this.loadSubjectScores()
    await this.loadArchivedCourses()
    await this.loadUploadLogs()
    hilog.info(DOMAIN, TAG, '========== loadAll 完成: days=' + this.stats.totalLearningDays +
      ' courses=' + this.stats.completedCourses + '/' + this.stats.totalCourses +
      ' score=' + this.stats.averageScore + ' ==========')
  }

  async loadStats(): Promise<void> {
    hilog.info(DOMAIN, TAG, '--- loadStats 开始 ---')
    const allEvals = await evaluationDao.getAll()
    this.allReports = allEvals
    hilog.info(DOMAIN, TAG, 'evaluation 表: ' + allEvals.length + ' 条')

    if (allEvals.length > 0) {
      const e = allEvals[0]
      hilog.info(DOMAIN, TAG, '首条 evaluation: id=' + e.id + ' courseId=' + e.courseId +
        ' concept=' + e.conceptScore + ' critical=' + e.criticalThinkingScore +
        ' practice=' + e.practiceScore + ' createdAt=' + e.createdAt)
    }

    // 累计学习天数
    const dateList: string[] = []
    for (let i = 0; i < allEvals.length; i++) {
      const dateStr = this.formatDate(allEvals[i].createdAt)
      let found = false
      for (let j = 0; j < dateList.length; j++) {
        if (dateList[j] === dateStr) {
          found = true
          break
        }
      }
      if (!found) {
        dateList.push(dateStr)
      }
    }
    this.stats.totalLearningDays = dateList.length

    // 课程统计
    const allCourses = await courseDao.getAllForStats()
    let completedCount = 0
    for (let i = 0; i < allCourses.length; i++) {
      const st = allCourses[i].status
      if (st === COURSE_STATUS.COMPLETED || st === COURSE_STATUS.ARCHIVED) {
        completedCount++
      }
    }
    this.stats.completedCourses = completedCount
    this.stats.totalCourses = allCourses.length
    hilog.info(DOMAIN, TAG, 'course 表 (getAllForStats): ' + allCourses.length + ' 条')
    for (let i = 0; i < allCourses.length; i++) {
      hilog.info(DOMAIN, TAG, '  [' + i + '] id=' + allCourses[i].id +
        ' name=' + allCourses[i].name + ' status=' + allCourses[i].status +
        ' progress=' + allCourses[i].progress)
    }
    hilog.info(DOMAIN, TAG, '已完成(含归档): ' + completedCount +
      ' 总课程: ' + allCourses.length)

    // 平均得分：不做过滤，直接根据实际数据计算
    let totalScore = 0
    for (let i = 0; i < allEvals.length; i++) {
      const e = allEvals[i]
      totalScore = totalScore + (e.conceptScore + e.criticalThinkingScore + e.practiceScore) / 3
    }
    this.stats.averageScore = allEvals.length > 0 ?
      Math.round(totalScore / allEvals.length) : 0
  }

  async loadWeekData(): Promise<void> {
    const dayNames: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    const now = Date.now()
    const oneDayMs = 86400000
    const today = new Date(now)
    const dayOfWeek = today.getDay()
    const mondayOffset = dayOfWeek === 0 ? 6 : dayOfWeek - 1
    const monday = new Date(now - mondayOffset * oneDayMs)
    monday.setHours(0, 0, 0, 0)
    const weekStart = monday.getTime()

    const weekData: WeekDataPoint[] = []
    for (let i = 0; i < 7; i++) {
      const dayStart = weekStart + i * oneDayMs
      const dayEnd = dayStart + oneDayMs
      let count = 0
      for (let j = 0; j < this.allReports.length; j++) {
        const created = this.allReports[j].createdAt
        if (created >= dayStart && created < dayEnd) {
          count++
        }
      }
      const date = new Date(dayStart)
      const month = date.getMonth() + 1
      const day = date.getDate()

      const point = new WeekDataPoint()
      point.dayLabel = dayNames[i]
      point.dayDate = '' + month + '/' + day
      point.minutes = count * 30
      weekData.push(point)
    }
    this.weekData = weekData
    hilog.info(DOMAIN, TAG, '--- loadWeekData: ' + weekData.length + ' 天 ---')
    for (let i = 0; i < weekData.length; i++) {
      hilog.info(DOMAIN, TAG, '  ' + weekData[i].dayLabel + ' ' + weekData[i].dayDate +
        ': ' + weekData[i].minutes + 'min')
    }
  }

  async loadSubjectScores(): Promise<void> {
    hilog.info(DOMAIN, TAG, '--- loadSubjectScores 开始 ---')
    const allCourses = await courseDao.getAllForStats()
    const completedCourses: Course[] = []
    for (let i = 0; i < allCourses.length; i++) {
      if (allCourses[i].status === COURSE_STATUS.COMPLETED ||
        allCourses[i].status === COURSE_STATUS.ARCHIVED) {
        completedCourses.push(allCourses[i])
      }
    }
    const recentCourses = completedCourses.slice(0, 5)
    const scores: SubjectScore[] = []
    for (let i = 0; i < recentCourses.length; i++) {
      const course = recentCourses[i]
      const report = await evaluationDao.getByCourseId(course.id)
      if (report !== null) {
        const score = new SubjectScore()
        const name = course.name.length > 6 ? course.name.substring(0, 6) + '…' : course.name
        score.courseName = name
        score.conceptScore = report.conceptScore
        score.criticalScore = report.criticalThinkingScore
        score.practiceScore = report.practiceScore
        scores.push(score)
      }
    }
    this.subjectScores = scores
    hilog.info(DOMAIN, TAG, '--- loadSubjectScores: ' + scores.length + ' 门 ---')
    for (let i = 0; i < scores.length; i++) {
      hilog.info(DOMAIN, TAG, '  ' + scores[i].courseName +
        ' concept=' + scores[i].conceptScore +
        ' critical=' + scores[i].criticalScore +
        ' practice=' + scores[i].practiceScore)
    }
  }

  async loadArchivedCourses(): Promise<void> {
    this.archivedCourses = await courseDao.getArchivedCourses()
    hilog.info(DOMAIN, TAG, '--- loadArchivedCourses: ' + this.archivedCourses.length + ' 门 ---')
  }

  async restoreCourse(courseId: number): Promise<void> {
    await courseDao.restoreCourse(courseId)
    await this.loadArchivedCourses()
  }

  async loadUploadLogs(): Promise<void> {
    this.uploadLogs = await uploadLogDao.getAll()
  }

  private formatDate(timestamp: number): string {
    const date = new Date(timestamp)
    const y = date.getFullYear()
    const m = date.getMonth() + 1
    const d = date.getDate()
    const mStr: string = m < 10 ? '0' + m : '' + m
    const dStr: string = d < 10 ? '0' + d : '' + d
    return '' + y + '-' + mStr + '-' + dStr
  }
}
