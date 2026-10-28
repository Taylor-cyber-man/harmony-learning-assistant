import { Course, COURSE_STATUS } from '../model/Course'

@Component
export struct CourseCard {
  @Prop course: Course = new Course()
  @Prop statusText: string = ''
  onTap: () => void = () => {}
  onArchive: () => void = () => {}
  onDelete: () => void = () => {}
  onUpload: () => void = () => {}
  onExport: () => void = () => {}
  onCardDrag: (dy: number) => void = (_dy: number) => {}
  @State showMenu: boolean = false
  @State dragOffsetY: number = 0

  build() {
    Column() {
      // 主卡片
      Row() {
        // 拖拽把手（左侧 ~1/5 宽度，仅此处可拖动排序）
        Column() {
          Text('⋮⋮')
            .fontSize(20)
            .fontColor($r('app.color.text_secondary'))
            .opacity(0.35)
        }
        .width('18%')
        .height(52)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 4 })
        .gesture(
          PanGesture({ fingers: 1, direction: PanDirection.Vertical, distance: 15 })
            .onActionStart(() => {
              this.dragOffsetY = 0
            })
            .onActionUpdate((event: GestureEvent | undefined) => {
              if (event) {
                this.dragOffsetY = event.offsetY
              }
            })
            .onActionEnd((event: GestureEvent | undefined) => {
              if (event) {
                this.onCardDrag(event.offsetY)
              }
              this.dragOffsetY = 0
            })
        )

        // 状态色条
        Column()
          .width(4)
          .height(52)
          .borderRadius(2)
          .backgroundColor(this.course.status === COURSE_STATUS.ACTIVE ?
            $r('app.color.primary') :
            this.course.status === COURSE_STATUS.COMPLETED ?
            $r('app.color.text_secondary') :
            $r('app.color.accent'))

        // 内容区（点击进入课程）
        Column() {
          Text(this.course.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Row() {
            Progress({ value: this.course.progress, total: 100, type: ProgressType.Linear })
              .width('50%')
              .height(4)
              .color(this.course.status === COURSE_STATUS.COMPLETED ?
                $r('app.color.success') :
                $r('app.color.primary'))
              .backgroundColor($r('app.color.card_border'))

            Blank()

            Text(this.statusText)
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.course.status === COURSE_STATUS.COMPLETED ?
                $r('app.color.text_secondary') :
                this.course.status === COURSE_STATUS.ACTIVE ?
                $r('app.color.primary') :
                $r('app.color.accent'))
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(6)
              .backgroundColor(this.course.status === COURSE_STATUS.COMPLETED ?
                $r('app.color.card_border') :
                this.course.status === COURSE_STATUS.ACTIVE ?
                'rgba(37,99,235,0.08)' :
                'rgba(249,115,22,0.08)')
          }
          .width('100%')
          .margin({ top: 10 })
        }
        .layoutWeight(1)
        .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 8, right: 12, top: 16, bottom: 16 })
      .borderRadius(this.showMenu ? { topLeft: 16, topRight: 16 } : 16)
      .backgroundColor($r('app.color.card_background'))
      .shadow({ radius: 6, color: 'rgba(0,0,0,0.06)', offsetY: 2 })
      .opacity(this.course.status === COURSE_STATUS.COMPLETED ? 0.55 : 1.0)
      .onClick(() => {
        if (this.showMenu) {
          this.showMenu = false
        } else {
          this.onTap()
        }
      })
      .translate({ y: this.dragOffsetY })
      .gesture(
        LongPressGesture({ repeat: false, duration: 600 })
          .onAction(() => {
            this.showMenu = !this.showMenu
          })
      )

      // 长按操作菜单
      if (this.showMenu) {
        Row() {
          this.buildBtn('上传', '#10B981', () => {
            this.showMenu = false; this.onUpload()
          })
          this.buildBtn('导出', '#3B82F6', () => {
            this.showMenu = false; this.onExport()
          })
          this.buildBtn('归档', '#F97316', () => {
            this.showMenu = false; this.onArchive()
          })
          this.buildBtn('删除', '#EF4444', () => {
            this.showMenu = false; this.onDelete()
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .padding({ top: 10, bottom: 14 })
        .backgroundColor($r('app.color.card_background'))
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })
        .shadow({ radius: 6, color: 'rgba(0,0,0,0.06)', offsetY: 2 })
      }
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  buildBtn(label: string, color: string, action: () => void) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor(color)
        .fontWeight(FontWeight.Medium)
    }
    .width(56)
    .padding({ top: 8, bottom: 8 })
    .borderRadius(8)
    .backgroundColor('rgba(0,0,0,0.03)')
    .onClick(() => { action() })
  }
}
