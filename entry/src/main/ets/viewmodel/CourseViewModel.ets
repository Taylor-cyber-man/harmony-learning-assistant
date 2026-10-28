import { Course, COURSE_STATUS } from '../model/Course'
import { CourseDao } from '../database/CourseDao'
import { KnowledgeDao } from '../database/KnowledgeDao'
import { QuestionDao } from '../database/QuestionDao'
import { EvaluationDao } from '../database/EvaluationDao'
import { KnowledgeItem } from '../model/KnowledgeItem'
import { EvaluationReport } from '../model/EvaluationReport'

const courseDao = new CourseDao()
const knowledgeDao = new KnowledgeDao()
const questionDao = new QuestionDao()
const evaluationDao = new EvaluationDao()

@Observed
export class CourseViewModel {
  courses: Course[] = []

  async loadCourses(): Promise<void> {
    this.courses = await courseDao.getAll()
  }

  async createCourse(name: string, keywords: string): Promise<Course | null> {
    const existing = await courseDao.getByName(name)
    if (existing !== null) {
      return existing
    }
    const course = new Course()
    course.name = name
    course.keywords = keywords
    course.status = COURSE_STATUS.CREATED
    course.progress = 0
    const id = await courseDao.insert(course)
    course.id = id
    this.courses.unshift(course)
    return course
  }

  async enterLearning(course: Course): Promise<void> {
    if (course.status === COURSE_STATUS.CREATED) {
      course.status = COURSE_STATUS.ACTIVE
      await courseDao.updateStatus(course.id, COURSE_STATUS.ACTIVE)
    }
  }

  async completeCourse(course: Course): Promise<void> {
    course.status = COURSE_STATUS.COMPLETED
    course.progress = 100
    await courseDao.update(course)
  }

  async deleteCourse(id: number): Promise<void> {
    await courseDao.delete(id)
    this.courses = this.courses.filter((c: Course) => c.id !== id)
  }

  async archiveCourse(course: Course): Promise<void> {
    course.status = COURSE_STATUS.ARCHIVED
    await courseDao.updateStatus(course.id, COURSE_STATUS.ARCHIVED)
    this.courses = this.courses.filter((c: Course) => c.id !== course.id)
  }

  async exportCourse(course: Course, format: string = 'txt'): Promise<string> {
    const knowledgeItems = await knowledgeDao.getByCourseId(course.id)
    const report = await evaluationDao.getByCourseId(course.id)

    if (format === 'md') {
      return this.exportCourseMarkdown(course, knowledgeItems, report)
    }
    if (format === 'json') {
      return this.exportCourseJson(course, knowledgeItems, report)
    }

    // TXT 格式
    let text = '===== 课程名称 =====\n' + course.name + '\n'
    text = text + '关键词: ' + course.keywords + '\n'
    text = text + '进度: ' + course.progress + '%\n'
    text = text + '创建时间: ' + this.formatTime(course.createdAt) + '\n\n'

    text = text + '===== 知识点 (' + knowledgeItems.length + '条) =====\n'
    for (let i = 0; i < knowledgeItems.length; i++) {
      const ki = knowledgeItems[i]
      text = text + (i + 1) + '. ' + ki.title + '\n'
      text = text + '   ' + ki.content.substring(0, 200) + '\n\n'
    }

    if (report !== null) {
      text = text + '===== 能力评价 =====\n'
      text = text + '概念理解: ' + report.conceptScore + '分\n'
      text = text + '批判思维: ' + report.criticalThinkingScore + '分\n'
      text = text + '实践迁移: ' + report.practiceScore + '分\n'
    }

    return text
  }

  private exportCourseJson(course: Course, knowledgeItems: KnowledgeItem[],
    report: EvaluationReport | null): string {
    const kiArr: Record<string, string>[] = []
    for (let i = 0; i < knowledgeItems.length; i++) {
      const ki: Record<string, string> = {
        'title': knowledgeItems[i].title,
        'content': knowledgeItems[i].content.substring(0, 500)
      }
      kiArr.push(ki)
    }

    const data: Record<string, Object> = {
      'courseName': course.name,
      'keywords': course.keywords,
      'progress': course.progress,
      'createdAt': this.formatTime(course.createdAt),
      'knowledgeCount': knowledgeItems.length,
      'knowledgeItems': kiArr
    }

    if (report !== null) {
      const evalObj: Record<string, number> = {
        'conceptScore': report.conceptScore,
        'criticalThinkingScore': report.criticalThinkingScore,
        'practiceScore': report.practiceScore
      }
      data['evaluation'] = evalObj
    }

    return JSON.stringify(data, null, 2)
  }

  private exportCourseMarkdown(course: Course, knowledgeItems: KnowledgeItem[],
    report: EvaluationReport | null): string {
    let md = '# ' + course.name + '\n\n'
    md = md + '> AI 驱动的认知加速工具 — 三问高效学习机\n\n'
    md = md + '| 属性 | 值 |\n|------|----|\n'
    md = md + '| 关键词 | ' + course.keywords + ' |\n'
    md = md + '| 进度 | ' + course.progress + '% |\n'
    md = md + '| 创建时间 | ' + this.formatTime(course.createdAt) + ' |\n\n'

    md = md + '---\n\n## 📚 知识点（' + knowledgeItems.length + ' 条）\n\n'
    for (let i = 0; i < knowledgeItems.length; i++) {
      const ki = knowledgeItems[i]
      const srcLabel = ki.source === 0 ? '手动' : (ki.source === 2 ? 'AI搜索' : '上传')
      md = md + '### ' + (i + 1) + '. ' + ki.title + '\n\n'
      md = md + '> 来源：' + srcLabel + '\n\n'
      md = md + ki.content.substring(0, 400) + '\n\n'
    }

    if (report !== null) {
      md = md + '---\n\n## 📊 能力评价\n\n'
      md = md + '| 维度 | 得分 | 等级 |\n|------|------|------|\n'
      md = md + '| 概念理解 | ' + report.conceptScore + ' | ' +
        this.scoreLevel(report.conceptScore) + ' |\n'
      md = md + '| 批判思维 | ' + report.criticalThinkingScore + ' | ' +
        this.scoreLevel(report.criticalThinkingScore) + ' |\n'
      md = md + '| 实践迁移 | ' + report.practiceScore + ' | ' +
        this.scoreLevel(report.practiceScore) + ' |\n\n'
      const avg = Math.round((report.conceptScore + report.criticalThinkingScore +
        report.practiceScore) / 3)
      md = md + '**综合均分：' + avg + '/100**\n'
    }

    md = md + '\n---\n*由「三问学习机」生成于 ' + this.formatTime(Date.now()) + '*\n'
    return md
  }

  private scoreLevel(score: number): string {
    if (score >= 80) {
      return '⭐⭐⭐ 优秀'
    }
    if (score >= 60) {
      return '⭐⭐ 良好'
    }
    if (score >= 40) {
      return '⭐ 及格'
    }
    return '待提升'
  }

  saveSortOrder(courses: Course[]): void {
    for (let i = 0; i < courses.length; i++) {
      courseDao.updateSortOrder(courses[i].id, i)
    }
  }

  getStatusText(status: number): string {
    switch (status) {
      case COURSE_STATUS.ACTIVE:
        return '活跃中'
      case COURSE_STATUS.COMPLETED:
        return '已完成'
      default:
        return '已创建'
    }
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp)
    const y = date.getFullYear()
    const m = date.getMonth() + 1
    const d = date.getDate()
    return '' + y + '/' + m + '/' + d
  }
}
