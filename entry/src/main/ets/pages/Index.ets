import { router } from '@kit.ArkUI'
import { CourseViewModel } from '../viewmodel/CourseViewModel'
import { CourseCard } from '../components/CourseCard'
import { Course, COURSE_STATUS } from '../model/Course'
import { ensureDatabase } from '../database/DatabaseHelper'
import { picker } from '@kit.CoreFileKit'
import { fileIo } from '@kit.CoreFileKit'

@Entry
@Component
struct Index {
  @State searchText: string = ''
  @State courses: Course[] = []
  @State showExportSheet: boolean = false
  @State exportTarget: Course | null = null
  private viewModel: CourseViewModel = new CourseViewModel()
  private personIconSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private personIconCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.personIconSettings)

  aboutToAppear(): void { this.refreshCourses() }
  onPageShow(): void { this.refreshCourses() }

  async refreshCourses(): Promise<void> {
    await ensureDatabase()
    this.viewModel.loadCourses().then(() => { this.courses = this.viewModel.courses })
  }

  build() {
    Stack() {
      Column() {
        // 渐变顶栏
        Column() {
          Row() {
            Text('三问学习机').fontSize(28).fontWeight(FontWeight.Bold).fontColor(Color.White).layoutWeight(1)
            Canvas(this.personIconCtx).width(40).height(40).borderRadius(20)
              .backgroundColor('rgba(255,255,255,0.15)')
              .onReady(() => { this.drawPersonIcon(40, 40) })
              .onClick(() => { router.pushUrl({ url: 'pages/ProfileCenterPage' }) })
          }.width('100%').padding({ left: 20, right: 16, top: 12, bottom: 4 })
          Text('AI 驱动的认知加速工具').fontSize(13).fontColor('rgba(255,255,255,0.7)')
            .width('100%').padding({ left: 20, bottom: 16 })
        }.width('100%').borderRadius({ bottomLeft: 24, bottomRight: 24 })
        .linearGradient({ direction: GradientDirection.Bottom,
          colors: [['#1E40AF', 0], ['#2563EB', 0.5], ['#3B82F6', 1]] })

        // 搜索区
        Column() {
          Row() {
            TextInput({ placeholder: '输入你的学习问题...' }).fontSize(15)
              .fontColor($r('app.color.text_primary')).backgroundColor(Color.Transparent)
              .layoutWeight(1).height(52)
              .onChange((value: string) => { this.searchText = value })
            Button('开始学习').fontSize(14).fontWeight(FontWeight.Medium).fontColor(Color.White)
              .backgroundColor($r('app.color.primary')).borderRadius(22).height(44)
              .padding({ left: 20, right: 20 })
              .shadow({ radius: 8, color: 'rgba(37,99,235,0.3)' })
              .onClick(() => { this.onSearch() })
          }.width('100%').height(56)
          .backgroundColor($r('app.color.card_background')).borderRadius(18)
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.06)', offsetY: 2 })
          .padding({ left: 16, right: 6 })
          Text('例如：如何掌握华为HCIA-AI认证？').fontSize(12)
            .fontColor($r('app.color.text_secondary')).width('100%').padding({ left: 6, top: 10 })
        }.width('100%').padding({ left: 16, right: 16 }).margin({ top: -12 })

        // 分割标题
        if (this.courses.length > 0) {
          Row() {
            Divider().width(24).height(2).backgroundColor($r('app.color.primary')).borderRadius(1)
            Text('  我的课程').fontSize(16).fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary')).layoutWeight(1)
            Text(this.courses.length + ' 门').fontSize(13).fontColor($r('app.color.text_secondary'))
          }.width('100%').padding({ left: 20, right: 16, top: 24, bottom: 12 })
        }

        // 课程列表
        if (this.courses.length === 0) {
          this.buildEmptyState()
        } else {
          Scroll() {
            Column() {
              ForEach(this.courses, (course: Course, index: number) => {
                CourseCard({
                  course: course,
                  statusText: this.viewModel.getStatusText(course.status),
                  onTap: () => { this.onCourseTap(course) },
                  onArchive: () => { this.showArchiveDialog(course) },
                  onDelete: () => { this.showDeleteDialog(course) },
                  onUpload: () => { this.onUploadToCourse(course) },
                  onExport: () => { this.exportTarget = course; this.showExportSheet = true },
                  onCardDrag: (dy: number) => { this.onCardDragEnd(index, dy) }
                })
              }, (course: Course) => course.id.toString())
            }.width('100%').padding({ left: 16, right: 16 })
          }.layoutWeight(1).scrollBar(BarState.Off)
        }
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
      .onClick(() => {
        this.showExportSheet = false
        if (this.exportTarget) { this.doExportCourseFile(this.exportTarget, fmt) }
      })
  }

  async doExportCourseFile(course: Course, format: string): Promise<void> {
    const content = await this.viewModel.exportCourse(course, format)
    const fileName = course.name.replace(/[\\/:*?"<>|]/g, '_') + '.' + format
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

  private drawPersonIcon(w: number, h: number): void {
    const ctx = this.personIconCtx
    ctx.clearRect(0, 0, w, h)
    const cx = w / 2
    const headR = 7
    const headY = 10
    ctx.beginPath()
    ctx.arc(cx, headY, headR, 0, Math.PI * 2)
    ctx.fillStyle = '#FFFFFF'
    ctx.fill()
    const bodyTop = headY + headR
    const bodyR = 10
    ctx.beginPath()
    ctx.arc(cx, bodyTop + bodyR, bodyR, Math.PI, 0)
    ctx.closePath()
    ctx.fillStyle = '#FFFFFF'
    ctx.fill()
  }

  showDeleteDialog(course: Course): void {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除课程"' + course.name + '"吗？此操作不可恢复。',
      autoCancel: true, alignment: DialogAlignment.Center,
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: { value: '删除', fontColor: '#EF4444',
        action: () => { this.viewModel.deleteCourse(course.id).then(() => { this.courses = this.viewModel.courses }) } }
    })
  }

  showArchiveDialog(course: Course): void {
    AlertDialog.show({
      title: '归档课程',
      message: '归档后课程将移至个人中心的归档列表',
      autoCancel: true, alignment: DialogAlignment.Center,
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: { value: '归档', fontColor: '#F97316',
        action: () => { this.viewModel.archiveCourse(course).then(() => { this.courses = this.viewModel.courses }) } }
    })
  }

  onUploadToCourse(course: Course): void {
    const params: Record<string, number | string> = { 'courseId': course.id, 'courseName': course.name }
    router.pushUrl({ url: 'pages/CourseSetupPage', params: params })
  }

  onCardDragEnd(index: number, dy: number): void {
    const cardH = 84
    const steps = Math.round(dy / cardH)
    if (steps === 0) { return }
    const targetIndex = index + steps
    if (targetIndex < 0 || targetIndex >= this.courses.length || targetIndex === index) { return }
    const moved = this.courses.splice(index, 1)
    this.courses.splice(targetIndex, 0, moved[0])
    this.courses = [...this.courses]
    this.viewModel.saveSortOrder(this.courses)
  }

  onSearch(): void {
    const keyword = this.searchText.trim()
    if (keyword.length === 0) { return }
    const courseName = keyword.length > 10 ? keyword.substring(0, 10) + '...' : keyword
    this.viewModel.createCourse(courseName, keyword).then((course: Course | null) => {
      if (course !== null) {
        this.courses = this.viewModel.courses
        const params: Record<string, number | string> = { 'courseId': course.id, 'courseName': course.name }
        router.pushUrl({ url: 'pages/CourseSetupPage', params: params })
      }
    })
  }

  onCourseTap(course: Course): void {
    this.viewModel.enterLearning(course).then(() => {
      this.courses = this.viewModel.courses
      const params: Record<string, number | string> = { 'courseId': course.id, 'courseName': course.name }
      router.pushUrl({ url: 'pages/LearningSpacePage', params: params })
    })
  }

  @Builder
  buildEmptyState() {
    Column() {
      Column() {
        Text('?').fontSize(64).fontWeight(FontWeight.Lighter).fontColor($r('app.color.primary'))
          .width(100).height(100).borderRadius(50).backgroundColor('rgba(37,99,235,0.08)')
          .textAlign(TextAlign.Center).margin({ bottom: 20 })
        Text('输入你的第一个学习问题').fontSize(18).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).margin({ bottom: 8 })
        Text('开启三问高效学习之旅').fontSize(14).fontColor($r('app.color.text_secondary'))
        Row() {
          this.buildStep('1', '提问创建\n课程')
          this.buildArrow()
          this.buildStep('2', '三问认知\n学习')
          this.buildArrow()
          this.buildStep('3', '深度测试\n评价')
        }.width('100%').justifyContent(FlexAlign.Center).margin({ top: 36 })
      }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
    }.width('100%').layoutWeight(1)
  }

  @Builder
  buildStep(num: string, label: string) {
    Column() {
      Text(num).fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White)
        .width(36).height(36).borderRadius(18).backgroundColor($r('app.color.primary')).textAlign(TextAlign.Center)
      Text(label).fontSize(11).fontColor($r('app.color.text_secondary')).textAlign(TextAlign.Center).margin({ top: 6 })
    }
  }

  @Builder
  buildArrow() {
    Text(' > ').fontSize(16).fontColor($r('app.color.text_secondary')).margin({ left: 8, right: 8 }).opacity(0.4)
  }
}
