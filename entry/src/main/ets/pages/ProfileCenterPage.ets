import { router } from '@kit.ArkUI'
import { common, ConfigurationConstant } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { ProfileViewModel, WeekDataPoint, SubjectScore } from '../viewmodel/ProfileViewModel'
import { LineChart } from '../components/LineChart'
import { BarChart } from '../components/BarChart'
import { Course } from '../model/Course'
import { UploadLog } from '../model/UploadLog'
import { AppConfig } from '../config/AppConfig'
import { hilog } from '@kit.PerformanceAnalysisKit'

const viewModel = new ProfileViewModel()
const PREF_NAME = 'app_settings'

@Entry
@Component
struct ProfileCenterPage {
  @State loading: boolean = true
  @State totalDays: number = 0
  @State completedCourses: number = 0
  @State totalCourses: number = 0
  @State averageScore: number = 0
  @State weekData: WeekDataPoint[] = []
  @State subjectScores: SubjectScore[] = []
  @State archivedCourses: Course[] = []
  @State uploadLogs: UploadLog[] = []
  @State darkMode: boolean = false
  @State showApiDialog: boolean = false
  @State apiKeyInput: string = ''
  private aboutDialogController: CustomDialogController = new CustomDialogController({
    builder: AboutDialog(),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  })

  aboutToAppear(): void {
    this.loadData()
    this.loadDarkModePref()
    this.loadApiKeyDisplay()
  }

  onPageShow(): void {
    this.loadData()
    this.loadDarkModePref()
    this.loadApiKeyDisplay()
  }

  async loadApiKeyDisplay(): Promise<void> {
    const key = await AppConfig.getApiKey()
    if (key.length > 8) {
      this.apiKeyInput = key.substring(0, 4) + '****' + key.substring(key.length - 4)
    } else {
      this.apiKeyInput = key
    }
  }

  async loadDarkModePref(): Promise<void> {
    try {
      const ctx = getContext(this) as common.UIAbilityContext
      const prefs = await preferences.getPreferences(ctx, PREF_NAME)
      this.darkMode = prefs.getSync('dark_mode', false) as boolean
    } catch (e) {
      this.darkMode = false
    }
  }

  async toggleDarkMode(value: boolean): Promise<void> {
    this.darkMode = value
    try {
      const ctx = getContext(this) as common.UIAbilityContext
      const prefs = await preferences.getPreferences(ctx, PREF_NAME)
      prefs.putSync('dark_mode', value)
      prefs.flush()
      if (value) {
        ctx.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
      } else {
        ctx.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
      }
    } catch (e) {
      // 降级
    }
  }

  async loadData(): Promise<void> {
    this.loading = true
    await viewModel.loadAll(getContext(this))

    this.totalDays = viewModel.stats.totalLearningDays
    this.completedCourses = viewModel.stats.completedCourses
    this.totalCourses = viewModel.stats.totalCourses
    this.averageScore = viewModel.stats.averageScore
    this.weekData = [...viewModel.weekData]
    this.subjectScores = [...viewModel.subjectScores]
    this.archivedCourses = [...viewModel.archivedCourses]
    this.uploadLogs = [...viewModel.uploadLogs]

    hilog.info(0x0001, 'ProfilePage', 'UI 赋值: totalDays=' + this.totalDays +
      ' courses=' + this.completedCourses + '/' + this.totalCourses +
      ' score=' + this.averageScore +
      ' weekData=' + this.weekData.length +
      ' subjectScores=' + this.subjectScores.length +
      ' archived=' + this.archivedCourses.length +
      ' uploads=' + this.uploadLogs.length)

    this.loading = false
  }

  async onApiKeyEdit(): Promise<void> {
    const key = await AppConfig.getApiKey()
    this.apiKeyInput = key
    this.showApiDialog = true
  }

  async onApiKeySave(): Promise<void> {
    if (this.apiKeyInput.length > 0) {
      await AppConfig.setApiKey(this.apiKeyInput)
    }
    this.showApiDialog = false
    await this.loadApiKeyDisplay()
  }

  @Builder
  buildSkeletonCard(color: string) {
    Column() {
      LoadingProgress()
        .width(32).height(32).color(color)
      Blank().height(8)
    }
    .width('31%').height(80)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(14).justifyContent(FlexAlign.Center)
  }

  @Builder
  buildSkeletonRect() {
    Column()
      .width('100%').height(260)
      .backgroundColor($r('app.color.canvas_bg'))
      .borderRadius(12)
  }

  @Builder
  buildSkeletonSection(title: string) {
    Column() {
      Row() {
        Text(title)
          .fontSize(18).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }.width('100%').padding({ bottom: 12 })
      Column()
        .width('100%').height(56)
        .backgroundColor($r('app.color.canvas_bg'))
        .borderRadius(10)
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16).padding(16).margin({ top: 16 })
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Button('返回')
            .fontSize(15)
            .fontColor($r('app.color.primary'))
            .backgroundColor(Color.Transparent)
            .onClick(() => { router.back() })

          Text('个人中心')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .margin({ right: 48 })
        }
        .width('100%')
        .padding(16)

        if (this.loading) {
          // 加载骨架屏
          Column() {
            // 三张统计卡片骨架
            Row() {
              this.buildSkeletonCard('#3B82F6')
              this.buildSkeletonCard('#10B981')
              this.buildSkeletonCard('#F97316')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 8 })

            // 折线图骨架
            Column() {
              Row() {
                Text('本周学习时长')
                  .fontSize(20).fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
              }.width('100%').padding({ bottom: 16 })
              this.buildSkeletonRect()
            }
            .width('100%').height(340).backgroundColor($r('app.color.card_background'))
            .borderRadius(16).padding(16).margin({ top: 16 })

            // 柱状图骨架
            Column() {
              Row() {
                Text('学科能力对比')
                  .fontSize(20).fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
              }.width('100%').padding({ bottom: 16 })
              this.buildSkeletonRect()
            }
            .width('100%').height(360).backgroundColor($r('app.color.card_background'))
            .borderRadius(16).padding(16).margin({ top: 16 })

            // 课程归档骨架
            this.buildSkeletonSection('课程归档')

            // 上传历史骨架
            this.buildSkeletonSection('上传历史')

            // 设置骨架
            this.buildSkeletonSection('设置')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8 })
        } else {
          Scroll() {
            Column() {
              // ======== 学习数据总览卡片 ========
              Row() {
                Column() {
                  Row() {
                    Text(this.totalDays.toString())
                      .fontSize(28).fontWeight(FontWeight.Bold).fontColor('#3B82F6')
                    Text('天').fontSize(14).fontColor($r('app.color.text_secondary')).margin({ left: 4 })
                  }
                  Text('累计学习').fontSize(12).fontColor($r('app.color.text_secondary')).margin({ top: 6 })
                }
                .width('31%').height(80).backgroundColor($r('app.color.card_background'))
                .borderRadius(14).justifyContent(FlexAlign.Center)
                .shadow({ radius: 4, color: '#00000008', offsetY: 2 })

                Column() {
                  Row() {
                    Text(this.completedCourses.toString() + '/' + this.totalCourses.toString())
                      .fontSize(28).fontWeight(FontWeight.Bold).fontColor('#10B981')
                    Text('门').fontSize(14).fontColor($r('app.color.text_secondary')).margin({ left: 4 })
                  }
                  Text('完成课程').fontSize(12).fontColor($r('app.color.text_secondary')).margin({ top: 6 })
                }
                .width('31%').height(80).backgroundColor($r('app.color.card_background'))
                .borderRadius(14).justifyContent(FlexAlign.Center)
                .shadow({ radius: 4, color: '#00000008', offsetY: 2 })

                Column() {
                  Row() {
                    Text(this.averageScore.toString())
                      .fontSize(28).fontWeight(FontWeight.Bold).fontColor('#F97316')
                    Text('分').fontSize(14).fontColor($r('app.color.text_secondary')).margin({ left: 4 })
                  }
                  Text('平均得分').fontSize(12).fontColor($r('app.color.text_secondary')).margin({ top: 6 })
                }
                .width('31%').height(80).backgroundColor($r('app.color.card_background'))
                .borderRadius(14).justifyContent(FlexAlign.Center)
                .shadow({ radius: 4, color: '#00000008', offsetY: 2 })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              // ======== 折线图：周学习时长 ========
              Column() {
                LineChart({ data: this.weekData })
              }
              .width('100%')
              .backgroundColor($r('app.color.card_background'))
              .borderRadius(16)
              .padding(16)
              .margin({ top: 16 })

              // ======== 柱状图：学科能力对比 ========
              Column() {
                BarChart({ data: this.subjectScores })
              }
              .width('100%')
              .backgroundColor($r('app.color.card_background'))
              .borderRadius(16)
              .padding(16)
              .margin({ top: 16 })

              // ======== 课程归档 ========
              this.buildArchiveSection()

              // ======== 上传历史 ========
              this.buildUploadSection()

              // ======== 设置选项 ========
              this.buildSettingsSection()

              Blank().height(30)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))

      if (this.showApiDialog) {
        Column() {
          Column() {
            Text('API Key 配置')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 20, bottom: 16 })

            TextInput({ text: this.apiKeyInput })
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor($r('app.color.background'))
              .borderRadius(8)
              .width('100%')
              .height(44)
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => { this.apiKeyInput = value })

            Row() {
              Button('取消')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .backgroundColor($r('app.color.card_background'))
                .border({ width: 1, color: $r('app.color.card_border') })
                .borderRadius(8)
                .layoutWeight(1)
                .height(40)
                .onClick(() => { this.showApiDialog = false })

              Blank().width(12)

              Button('保存')
                .fontSize(14)
                .fontColor(Color.White)
                .backgroundColor($r('app.color.primary'))
                .borderRadius(8)
                .layoutWeight(1)
                .height(40)
                .onClick(() => { this.onApiKeySave() })
            }
            .width('100%')
            .margin({ top: 16, bottom: 20 })
          }
          .width('80%')
          .padding({ left: 20, right: 20 })
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => { this.showApiDialog = false })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildArchiveSection() {
    Column() {
      Row() {
        Text('课程归档')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text('' + this.archivedCourses.length + ' 门')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .padding({ bottom: 12 })

      if (this.archivedCourses.length === 0) {
        Text('暂无已归档课程')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 16, bottom: 16 })
      } else {
        ForEach(this.archivedCourses, (course: Course) => {
          this.buildArchivedCourseRow(course)
        })
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .padding(16)
    .margin({ top: 16 })
  }

  @Builder
  buildArchivedCourseRow(course: Course) {
    Row() {
      Column()
        .width(4)
        .height(40)
        .borderRadius(2)
        .backgroundColor('#94A3B8')
      Column() {
        Text(course.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text('归档于 ' + this.formatTime(course.updatedAt))
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      Button('恢复')
        .fontSize(12)
        .fontColor($r('app.color.primary'))
        .backgroundColor($r('app.color.card_background'))
        .border({ width: 1, color: $r('app.color.primary') })
        .borderRadius(8)
        .height(30)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          viewModel.restoreCourse(course.id).then(() => {
            this.archivedCourses = [...viewModel.archivedCourses]
          })
        })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  buildUploadSection() {
    Column() {
      Row() {
        Text('上传历史')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .padding({ bottom: 12 })

      if (this.uploadLogs.length === 0) {
        Text('暂无上传记录')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 16, bottom: 16 })
      } else {
        ForEach(this.uploadLogs, (log: UploadLog) => {
          Row() {
            Column() {
              Text(log.fileName)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Row() {
                Text(log.courseName)
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                Text(' · ' + this.formatFileSize(log.fileSize))
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                Text(' · ' + this.formatTime(log.uploadTime))
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 10, bottom: 10 })
          .border({ width: { bottom: 0.5 }, color: $r('app.color.card_border') })
        })
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .padding(16)
    .margin({ top: 16 })
  }

  @Builder
  buildSettingsSection() {
    Column() {
      Text('设置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .padding({ bottom: 12 })

      this.buildSettingsRow('API Key 配置', '已配置（点击修改）', () => {
        this.onApiKeyEdit()
      })

      Row() {
        Column() {
          Text('深色模式')
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))
          Text(this.darkMode ? '已开启' : '已关闭')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 2 })
        }
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
          .onChange((value: boolean) => { this.toggleDarkMode(value) })
      }
      .width('100%')
      .padding({ top: 14, bottom: 14 })
      .border({ width: { bottom: 0.5 }, color: $r('app.color.card_border') })

      this.buildSettingsRow('关于', '三问学习机 v1.0.0', () => {
        this.aboutDialogController.open()
      })
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .padding(16)
    .margin({ top: 16 })
  }

  @Builder
  buildSettingsRow(label: string, desc: string, onTap: () => void) {
    Row() {
      Column() {
        Text(label)
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
        Text(desc)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      Text('>')
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .padding({ top: 14, bottom: 14 })
    .border({ width: { bottom: 0.5 }, color: $r('app.color.card_border') })
    .onClick(() => { onTap() })
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp)
    const m = date.getMonth() + 1
    const d = date.getDate()
    const h = date.getHours()
    const min = date.getMinutes()
    const hStr: string = h < 10 ? '0' + h : '' + h
    const mStr: string = min < 10 ? '0' + min : '' + min
    return '' + m + '/' + d + ' ' + hStr + ':' + mStr
  }

  private formatFileSize(bytes: number): string {
    if (bytes < 1024) { return bytes + 'B' }
    if (bytes < 1024 * 1024) { return Math.round(bytes / 1024) + 'KB' }
    return (bytes / (1024 * 1024)).toFixed(1) + 'MB'
  }
}

@CustomDialog
struct AboutDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: AboutDialog() })

  build() {
    Column() {
      Text('关于')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 24, bottom: 16 })
      Text('三问学习机')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary'))
        .padding({ bottom: 8 })
      Text('版本 1.0.0')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .padding({ bottom: 12 })
      Text('基于 HarmonyOS NEXT + ArkTS 构建')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .padding({ bottom: 4 })
      Text('AI 驱动的认知加速工具')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .padding({ bottom: 20 })
      Button('确定')
        .fontSize(14)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(8)
        .width('60%')
        .height(40)
        .onClick(() => { this.controller.close() })
        .margin({ bottom: 20 })
    }
    .width('75%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
  }
}
