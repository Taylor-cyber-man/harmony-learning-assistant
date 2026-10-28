# 三问高效学习机 — Bug 修复文档

> 基于完整对话记录整理，按时间线梳理所有 Bug 及其修复方案。

---

## 1. 心智模型展示图字体过小、可视性差

**发现时间**: 2026-06-10 第一轮

**现象**: KnowledgeGraph Canvas 绘制的节点文字太小（12px），节点名称被截断为 5 个字符，深色模式下文字不可见

**根因**:
- Canvas 硬编码 320×260 尺寸，不适应实际屏幕宽度
- 节点标签字号 12px，名称截断为 5 字
- 文字颜色 `#1E293B` 在深色背景 `#1E293B` 上不可见

**修复文件**: `KnowledgeGraph.ets`, `DisputeMapView.ets`

**修复内容**:
- Canvas 使用 `onAreaChange` 响应式适配，高度从 260→400
- 节点半径 28→36，名称字体 12px→14px
- 新增白色半透明 Pill 背景包裹节点名称标签，确保深浅主题可读
- 名称不再截断为 5 字，改为自动折行 2 行
- DisputeMapView 所有字体提升 2px（标题 14→16，描述 12→14，内容 12→14）

---

## 2. 心智模型 Canvas 响应式/暗色模式适配

**发现时间**: 2026-06-10 第二轮

**现象**: 所有 Canvas 图表在高 DPI 设备上文字极小，与 ArkUI 组件大小不匹配

**根因**: Canvas 内部坐标系是物理像素（px），ArkUI 组件使用虚拟像素（vp）。高 DPI 设备上 1vp=2~3px，直接写 `fontSize('20px')` 导致 Canvas 内文字只有 ArkUI 文字的 1/2~1/3 大小

**修复文件**: `LineChart.ets`, `BarChart.ets`, `KnowledgeGraph.ets`

**修复内容**: 所有 Canvas 内部数值全部通过 `vp2px()` 转换：

| 类别 | 修复前 | 修复后 |
|------|--------|--------|
| 字号 | `'22px'` | `vp2px(22) + 'px'` |
| 线宽 | `3.5` | `vp2px(3.5)` |
| 间距/偏移 | `padLeft = 72` | `vp2px(72)` |
| 圆角半径 | `8` | `vp2px(8)` |
| 柱宽最小值 | `12` | `vp2px(12)` |

---

## 3. 课程页面按钮显示 `[object Object]`

**发现时间**: 2026-06-10 知识图谱重构后

**现象**: LearningSpacePage 上"我已理解"按钮的文字显示为 `[object Object] - 核心心智模型`

**根因**: `$r('app.string.confirm_understand')` 返回的是 `Resource` 对象（`{id, type, params}`），不能用 `+` 运算符与字符串拼接。拼接时 `Resource` 对象被转为 `[object Object]`

**修复文件**: `LearningSpacePage.ets`

**修复内容**: 将拼接语句替换为纯字符串：
```typescript
// ❌ 错误
Button($r('app.string.confirm_understand') + ' - 核心心智模型')

// ✅ 正确
Button('我已理解 - 核心心智模型')
```

**排查范围**: 全项目扫描所有 `$r() +` 拼接，确认无其他同类问题

---

## 4. 核心心智模型图标拖动卡顿、无法连续拖动

**发现时间**: 2026-06-10 知识图谱重构后

**现象**: 点击节点拖动一小段距离后无法继续拖动，松手后节点弹回原位

**根因**: 三层原因
1. **CSS 层面**: 未设置 `touch-action: none`，浏览器将触摸事件转发给父级滚动容器
2. **JS 层面**: `pointermove` 时仍在跑物理模拟（`simRunning = true`），每帧把节点拉回原处
3. **ArkTS 层面**: `Scroll` 父组件抢走了 WebView 内的触摸事件

**修复文件**: `knowledge_graph.html`, `KnowledgeGraph.ets`, `LearningSpacePage.ets`

**修复内容**:
1. Canvas 添加 `touch-action: none`
2. `pointerdown` 时调用 `canvas.setPointerCapture(pointerId)` 锁定指针
3. 拖拽时暂停物理模拟（`simRunning = false`），松手后节点固定（`fixed = true`），其他节点围绕新位置重新布局
4. KnowledgeGraph Web 组件添加 `.hitTestBehavior(HitTestMode.Block)` 阻止触摸冒泡
5. 知识图谱从 `Scroll` 内移到 `Scroll` 外，彻底消除手势竞争；后因页面无法上下滚动，又移回 `Scroll` 内

**最终布局**:
```
Scroll {
  Column {
    KnowledgeGraph (WebView + hitTestMode.Block)  // 触摸不冒泡
    tag + "我已理解" 按钮
    学习资料区
    Q2 争议
    Q3 测试
    提交按钮
  }
}
```

---

## 5. 节点点击弹出详情面板遮挡屏幕

**发现时间**: 2026-06-10 心智模型拖动修复后

**现象**: 点击心智模型节点时弹出底部 Sheet 详情面板，遮挡了图谱和其他内容

**修复文件**: `knowledge_graph.html`, `KnowledgeGraph.ets`

**修复内容**:
- HTML 侧删除整个 `#detail` 弹窗面板（CSS + JS），点击节点只做选中高亮（蓝色圆环），1.5 秒后自动消失
- ArkTS 卡片从 2 行扩展为完整信息：名称、描述、**子概念列表**（带序号）、**逻辑关系**（自动解析节点名称）、**关联资料按钮**（点击展开信息来源）

---

## 6. 图谱连线密集、标签文字拥挤

**发现时间**: 2026-06-10 详情面板移除后

**现象**: 5 个节点互相连接（每个节点 2 条出边 = 10 条线），标签文字太长（"算法依赖数据训练(→神经网络分层抽象)"），重叠拥挤

**修复文件**: `AiEngine.ets`, `knowledge_graph.html`

**修复内容**:
- 预置数据每个节点的 `relations` 从 2 条减为 1 条，形成 5 条线的环形拓扑
- 边标签截断为最多 4 字符，字号 12px
- 边理想长度 130→180px，初始布局半径 30%→38%

---

## 7. 深色模式非全局生效

**发现时间**: 2026-06-10

**现象**: ProfileCenterPage 的深色模式 Toggle 只改了本地 `@State` 变量，切换后无实际效果，关闭 APP 后状态丢失

**修复文件**: `EntryAbility.ets`, `ProfileCenterPage.ets`

**修复内容**:
- `EntryAbility.onCreate` 中从 `preferences` 读取 `dark_mode` 偏好，调用 `setColorMode(COLOR_MODE_DARK/LIGHT)` 全局应用
- `ProfileCenterPage` Toggle 切换时调用 `setColorMode` + `preferences.putSync()` 持久化
- APP 重启后自动恢复上次设置

---

## 8. API Key 硬编码且不互通

**发现时间**: 2026-06-10

**现象**: `AiEngine.ets` 和 `ProfileCenterPage.ets` 各存一份硬编码的 API Key。个人中心 API Key 弹窗修改后，AiEngine 读不到

**修复文件**: 新建 `config/AppConfig.ets`, 修改 `AiEngine.ets`, `ProfileCenterPage.ets`, `EntryAbility.ets`

**修复方案**:
- 新建 `config/AppConfig.ets` 作为统一的 API Key 管理模块
- 基于 `preferences` 持久化 + 内存缓存（`cachedApiKey`）
- `AiEngine.callDeepSeekApi()` 改为 `await AppConfig.getApiKey()` 读取
- 个人中心弹窗改为 Stack overlay + TextInput 内联编辑，保存时调 `AppConfig.setApiKey()`

---

## 9. 评价报告 insertion 使用 `as` 转换导致 DB 分数全为 0

**发现时间**: 2026-06-10

**现象**: 提交全部测试后，evaluation 表中 `concept_score`、`critical_thinking_score`、`practice_score` 全部为 0

**根因**: `LearningSpacePage.submitAll()` 中使用 `{...} as EvaluationReport` 对象字面量 cast，ArkTS 运行时可能不把 Plain Object 的 `conceptScore` 属性视为 `EvaluationReport` 的属性

**修复文件**: `LearningSpacePage.ets`

**修复内容**:
```typescript
// ❌ 错误：对象字面量 cast
await evaluationDao.insertEvaluation({
  conceptScore: result.conceptScore,  // Plain Object
  ...
} as EvaluationReport)

// ✅ 正确：new 类实例 + 逐字段赋值
const report = new EvaluationReport()
report.conceptScore = result.conceptScore
report.criticalThinkingScore = result.criticalThinkingScore
report.practiceScore = result.practiceScore
report.reportJson = reportJson
report.qaLogJson = qaLogJson
await evaluationDao.insertEvaluation(report)
```

---

## 10. 本地数据缓存未生效（心智/争议/测试）

**发现时间**: 2026-06-10

**现象**: 关闭 APP 重新进入课程后，心智模型、学术争议和测试题重新调用 API，未使用本地缓存

**修复文件**: `LearningSpacePage.ets`

**修复内容**:
- 利用已有 `question_block` 表：Q1/Q2 首次 API 调用后 `JSON.stringify` 存入 `question_block.ai_answer`
- 再次打开时先从 `questionDao.getByCourseId()` 读取缓存，有则直接 `JSON.parse`，跳过 API
- 进度状态（`q1Done`/`q2Done`）也从 `question_block.status` 恢复
- Q3 测试题复用已有 `test_item` 表缓存逻辑

---

## 11. 学习资料区从隐藏弹窗改为始终可见

**发现时间**: 2026-06-10

**现象**: 需求书要求"学习空间有资料区展示所有 AI 和用户上传的知识点"，当前仅在点击图谱节点时弹窗显示关联资料

**修复文件**: `LearningSpacePage.ets`

**修复内容**:
- 隐藏式"关联资料"弹窗替换为始终可见的"学习资料"区块，位于 Q1 确认按钮后 Q2 之前
- 所有知识点条目展示，来源分类着色（AI搜索=蓝、手动=橙、上传=绿）
- 图谱节点点击联动高亮（匹配条目加蓝色边框），点击"查看关联资料"展开信息来源详情（含 URL）

---

## 12. AI 知识点搜索重构（Anthropic 端点 + web_search）

**发现时间**: 2026-06-10

**现象**: `fetchKnowledgeItems` 使用 DeepSeek Chat API 静态知识，无法联网获取权威最新资料

**修复文件**: `AiEngine.ets`, `AppConfig.ets`

**修复方案**:
- 新增 `searchKnowledgeItems()` 方法，调用 DeepSeek Anthropic 兼容端点 `POST https://api.deepseek.com/anthropic/v1/messages`
- 携带 `web_search_20260209` tool，利用 DeepSeek 原生 Web Search 能力
- 解析响应中 `web_search_tool_result`（来源 title/url）和最终 `text` 块（结构化 JSON）
- 降级逻辑：Anthropic 端点失败时自动调用 `getPresetKnowledge` 兜底
- 复用 DeepSeek API Key，无需额外 Key

---

## 13. 图片上传功能预置（需求书要求）

**发现时间**: 2026-06-10

**现象**: 需求书要求"支持文件上传（PDF/Word/Markdown）"

**修复文件**: `CourseSetupPage.ets`

**修复内容**:
- 使用 `@ohos.file.picker` 的 `DocumentViewPicker`，支持选择任意文件
- `fileIo.readSync` 读取内容
- 自动解析为知识点条目（来源=`UPLOAD`），标题=文件名，内容=文本摘要（前 1000 字符）

---

## 14. 课程卡片管理增强（排序/长按菜单/导出）

**发现时间**: 2026-06-10

**需求**:
- 课程卡片排序（拖动排序）
- 长按卡片弹出操作菜单（上传资料、课程导出、归档/删除）
- 导出评价报告功能

**修复文件**: `CourseCard.ets`, `Index.ets`, `CourseViewModel.ets`, `CourseDao.ets`, `Course.ets`, `DatabaseHelper.ets`

**修复内容**:

### 14.1 拖动排序
- 卡片左侧 18% 区域为拖动把手（`⋮⋮`），仅此处可拖动排序
- `PanGesture` 控制拖动偏移，松手后计算跨越卡片数交换位置
- 排序结果通过 `sort_order` 字段持久化到 RDB

### 14.2 长按菜单
- 长按 600ms 触发操作菜单：上传、导出、归档、删除
- 菜单展开时再次点击卡片收起菜单

### 14.3 导出格式
- 底部 Sheet 选择格式：TXT / Markdown / JSON
- 使用 `DocumentViewPicker.save()` 弹出系统保存选择器
- `fileIo.writeSync` 写入内容到用户指定路径

---

## 15. 评价报告导出功能缺失

**发现时间**: 2026-06-10

**现象**: EvaluationReportPage 无导出功能，无法保存评价报告

**修复文件**: `EvaluationReportPage.ets`

**修复内容**:
- 雷达图下方新增「导出评价报告」按钮
- 点击弹出底部 Sheet 选择格式：TXT / Markdown / JSON
- TXT 报告包含：综合评分、能力维度、认知漏洞、复习建议、完整问答记录
- Markdown 报告包含：表格、引用块、✅/⚠️ 标签
- JSON 报告包含：结构化全部数据

---

## 16. 评价报告内容过于单一 — AI 综合学习评价

**发现时间**: 2026-06-10

**现象**: 导出报告仅有评分和问答记录，缺少 AI 对学习过程的整体评价

**修复文件**: `AiEngine.ets`（新增 `generateOverallSummary`）、`LearningSpacePage.ets`（`submitAll` 调用）、`EvaluationReportPage.ets`（展示 + 导出包含）

**修复内容**:
- 新增 `AiEngine.generateOverallSummary()` — 将全部 Q&A 日志 + 三维度得分发给 DeepSeek，返回四段综合评价：
  1. 学习过程总体评价
  2. 题目概括性总结
  3. 优势领域分析
  4. 改进建议
- 报告页面新增「AI 学习评价」卡片展示
- 导出文件的 TXT/Markdown 格式均包含 AI 评价

---

## 17. 个人中心统计数据始终为 0

**发现时间**: 2026-06-10（多次迭代）

**现象**: 已完成课程后，个人中心的累计学习天数、完成课程数、平均得分全部显示 0

### 根因链（多层叠加）：

1. **DB 初始化时序问题**: `EntryAbility.onCreate` 异步调用 `initDatabase`，但 `onWindowStageCreate` 立即 `loadContent`，页面打开时 `rdbStore` 可能仍为 `null`，所有查询超时返回空结果

2. **错误静默吞没**: `ProfileViewModel.loadAll()` 中每个模块用 `try/catch` 包裹但不做任何处理，查询失败后 `@State` 保持默认值 0

3. **@State 不追踪嵌套对象**: 之前使用 `@State stats: ProfileStats`，修改 `stats.totalLearningDays` 这类嵌套属性，ArkUI 不感知变化

4. **@Builder 传参不响应变化**: `this.buildStatCard('累计学习', '' + this.totalDays, ...)` — `@Builder` 编译时捕获参数，运行时 `@State` 变化后参数不重新计算

### 修复文件:
`EntryAbility.ets`, `DatabaseHelper.ets`, `ProfileViewModel.ets`, `ProfileCenterPage.ets`

### 修复内容:

1. **EntryAbility 同步等待 DB**:
```typescript
onWindowStageCreate(windowStage) {
  this.waitForDbThenLoad(windowStage)
}
async waitForDbThenLoad(windowStage) {
  await getDbStore()  // 阻塞等待 rdbStore 就绪（最多 3 秒）
  windowStage.loadContent('pages/Index', ...)
}
```

2. **DB 主动初始化**: `ProfileViewModel.loadAll(context)` 第一行调用 `ensureDatabaseSafe(context)`

3. **独立 @State 原语**: `@State totalDays/ completedCourses/ totalCourses/ averageScore: number`

4. **内联渲染替代 @Builder 传参**:
```typescript
// ✅ 直接内联
Text(this.totalDays.toString())
Text(this.completedCourses.toString() + '/' + this.totalCourses.toString())
Text(this.averageScore.toString())
```

5. **防止 DB 分数为 0 的记录影响平均值**: evaluation 的 `concept_score + critical_score + practice_score === 0` 的记录不参与平均分计算

---

## 18. 图表 Y 轴溢出

**发现时间**: 2026-06-10

**现象**: 折线图 Y 轴固定 `max: 120`，当学习时长超过 120 分钟时数据点超出图表

**修复文件**: `line_chart.html`, `bar_chart.html`

**修复内容**:
- 折线图: `yMax = max(120, ceil(dataMax * 1.3 / 30) * 30)`
- 柱状图: `yMax = max(100, ceil(dataMax * 1.25 / 10) * 10)`

---

## 19. 加载状态无视觉反馈

**发现时间**: 2026-06-10

**现象**: 个人中心打开后先显示全 0，数据加载完成后突然跳变，体验不好

**修复文件**: `ProfileCenterPage.ets`

**修复内容**: 新增骨架屏（Skeleton Screen）
- `loading = true` 时显示骨架屏：三张卡片位 `LoadingProgress` 转圈 + 图表区灰色占位矩形 + 各板块灰色占位条
- `loading = false` 时淡入真实内容

---

## 20. ArkTS 语法兼容性问题汇总

在整个对话中反复遇到的 ArkTS 语法限制及修复方式：

| 语法限制 | 错误代码 | 修复方式 |
|---------|---------|---------|
| 不支持无类型对象字面量 | `{ key: value }` | 声明类实例或 `Record<string, Type>` |
| 不支持 `any`/`unknown` | `catch (e: Error)` | 省略类型标注 `catch (e)` |
| 不支持 `a.b` 方括号索引 | `obj['key']` | 使用类实例 `obj.key` |
| 不支持 `Set` | `new Set<string>()` | Array + 手动 `indexOf` 去重 |
| 不支持 `as const` 断言 | `as const` | 显式类型标注 |
| 不支持嵌套函数 | `function f() {}` | Lambda 箭头函数 `() => {}` |
| 不支持 static 块赋值 | `static { ... }` | 合并到变量初始化 |
| `@Builder` 中不能用 `this.xxx` | Builder 内用 this | 改为内联渲染 |
| `$r()` 不能参与表达式 | `$r('x') + '...'` | 纯字符串替代 |
| 不支持 `{...} as Type` 创建对象 | 对象字面量 cast | `new Type()` + 逐字段赋值 |
| 不支持动态 `import()` | `await import(...)` | 顶层 import |

---

## 修复文件清单

| 文件 | 修复次数 | 涉及 Bug 编号 |
|------|---------|-------------|
| `KnowledgeGraph.ets` | 4 | #1, #4, #5 |
| `knowledge_graph.html` | 5 | #4, #5, #6 |
| `DisputeMapView.ets` | 1 | #1 |
| `LineChart.ets` | 1 | #2 |
| `BarChart.ets` | 1 | #2 |
| `line_chart.html` | 2 | #2, #18 |
| `bar_chart.html` | 2 | #2, #18 |
| `LearningSpacePage.ets` | 6 | #3, #4, #9, #10, #11, #16 |
| `ProfileCenterPage.ets` | 5 | #7, #8, #17, #19 |
| `ProfileViewModel.ets` | 4 | #17 |
| `Index.ets` | 4 | #14, #17, #19 |
| `CourseCard.ets` | 3 | #14 |
| `EvaluationReportPage.ets` | 3 | #15, #16 |
| `CourseViewModel.ets` | 2 | #14, #15 |
| `CourseDao.ets` | 2 | #14, #17 |
| `DatabaseHelper.ets` | 3 | #14, #17 |
| `EntryAbility.ets` | 3 | #7, #8, #17 |
| `AiEngine.ets` | 4 | #6, #8, #9, #12, #16 |
| `AppConfig.ets` (新建) | 1 | #8 |
| `Course.ets` | 1 | #14 |
| `EvaluationDao.ets` | 1 | #9 |
| `CourseSetupPage.ets` | 1 | #13 |

---

*由「Claude Code」在 2026-06-10 会话中自动整理生成*
