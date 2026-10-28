@Component
export struct RadarChart {
  @Prop conceptScore: number = 0
  @Prop criticalScore: number = 0
  @Prop practiceScore: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Canvas(this.context)
      .width('100%')
      .height(260)
      .onReady(() => {
        this.drawRadar()
      })
  }

  private drawRadar(): void {
    const ctx = this.context
    const w = ctx.width
    const h = ctx.height
    const cx = w / 2
    const cy = h / 2
    const r = Math.min(w, h) / 2 - 30

    const labels: string[] = ['概念理解', '批判思维', '实践迁移']
    const scores: number[] = [this.conceptScore, this.criticalScore, this.practiceScore]

    // 画背景网格
    ctx.strokeStyle = '#E2E8F0'
    ctx.lineWidth = 0.5
    for (let level = 1; level <= 3; level++) {
      const ir = r * level / 3
      ctx.beginPath()
      for (let i = 0; i < 3; i++) {
        const angle = -Math.PI / 2 + i * (Math.PI * 2 / 3)
        const x = cx + ir * Math.cos(angle)
        const y = cy + ir * Math.sin(angle)
        if (i === 0) {
          ctx.moveTo(x, y)
        } else {
          ctx.lineTo(x, y)
        }
      }
      ctx.closePath()
      ctx.stroke()
    }

    // 画轴线
    for (let i = 0; i < 3; i++) {
      const angle = -Math.PI / 2 + i * (Math.PI * 2 / 3)
      ctx.beginPath()
      ctx.moveTo(cx, cy)
      ctx.lineTo(cx + r * Math.cos(angle), cy + r * Math.sin(angle))
      ctx.stroke()
    }

    // 画得分区域
    ctx.beginPath()
    for (let i = 0; i < 3; i++) {
      const angle = -Math.PI / 2 + i * (Math.PI * 2 / 3)
      const sr = r * scores[i] / 100
      const x = cx + sr * Math.cos(angle)
      const y = cy + sr * Math.sin(angle)
      if (i === 0) {
        ctx.moveTo(x, y)
      } else {
        ctx.lineTo(x, y)
      }
    }
    ctx.closePath()
    ctx.fillStyle = 'rgba(59, 130, 246, 0.3)'
    ctx.fill()
    ctx.strokeStyle = '#3B82F6'
    ctx.lineWidth = 2
    ctx.stroke()

    // 画标签
    ctx.font = '12px sans-serif'
    ctx.fillStyle = '#1E293B'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    for (let i = 0; i < 3; i++) {
      const angle = -Math.PI / 2 + i * (Math.PI * 2 / 3)
      const lx = cx + (r + 24) * Math.cos(angle)
      const ly = cy + (r + 24) * Math.sin(angle)
      ctx.fillText(labels[i] + ' ' + scores[i] + '%', lx, ly)
    }

    // 中心文字
    const avg = Math.round((scores[0] + scores[1] + scores[2]) / 3)
    ctx.font = 'bold 16px sans-serif'
    ctx.fillStyle = '#1E293B'
    ctx.fillText(avg + '分', cx, cy)
  }
}
