## Context

当前 APP 已实现课程管理、知识库、三问引擎、评价报告四个核心模块，采用 MVVM 架构 + RDB 持久化 + Canvas 绘图的技术栈。缺少用户级别的数据聚合展示和功能管理入口（个人中心）。本次新增独立页面，聚合展示学习统计数据、归档课程、上传历史、设置选项，并通过 Canvas 绘制折线图和柱状图实现数据可视化。

技术栈继承自现有架构：HarmonyOS NEXT API 6.0.2、ArkTS、RDB、Canvas API、零第三方依赖、深色/浅色主题。

## Goals / Non-Goals

**Goals:**
- 新增 ProfileCenterPage 个人中心页面，作为用户级功能聚合入口
- Canvas 绘制周学习时长折线图（7天趋势）和学科能力柱状图（多课程对比）
- 学习数据总览卡片：累计学习天数、完成课程数、平均得分
- 课程归档管理：查看已归档课程、恢复归档
- 资料上传历史：展示知识库文件上传记录
- 设置选项：API Key 配置跳转、深色/浅色主题切换、关于信息
- 主页面 (Index.ets) 添加个人中心入口

**Non-Goals:**
- 不支持修改已归档课程的内部数据（仅查看和恢复）
- 不支持导出折线图/柱状图为图片
- 不引入第三方图表库（全部 Canvas 手绘）
- 不实现多用户/账户系统（单用户本地 APP）
- 不上传学习数据到云端

## Decisions

### D1: Canvas 手绘折线图 → 坐标映射 + path 连线
**选择**: 基于 Canvas + path API 绘制折线图。X轴 = 7天日期，Y轴 = 学习时长（分钟）。数据点用实心圆标记，连线用 path 绘制，底部 X 轴标签和左侧 Y 轴刻度用 fillText。
**理由**: 折线图结构简单（7个数据点），Canvas 手绘完全可控，无需第三方库。与现有 KnowledgeGraph/RadarChart 的技术方案一致。
**替代方案**: 使用第三方图表库（如 ECharts）→ 引入 npm 依赖增加包体积，与零依赖原则冲突。

### D2: Canvas 手绘柱状图 → fillRect + 渐变
**选择**: 基于 Canvas fillRect 绘制柱状图。每个柱子 = 一门课程的能力得分（纵轴），课程名称作为 X 轴标签。柱顶显示得分数字。柱子使用渐变色提升视觉效果。
**理由**: 柱状图是 Canvas 最基础的图形之一，fillRect + fillText 即可完成，代码量极小。与现有设计系统的色彩 token 一致。
**替代方案**: 同样排除第三方库。

### D3: 学习数据来源 → RDB 聚合查询 + ViewModel 计算
**选择**: 从已有 RDB 表（course、evaluation）中聚合查询，在 ProfileViewModel 中计算统计数据，无需新建表。
- 累计学习天数 = 有 evaluation 记录的不同日期数（从 created_at 字段提取）
- 完成课程数 = course 表中 status=completed 的 COUNT
- 平均得分 = evaluation 表中所有报告的三维度平均分
- 周学习时长 = 本周每天有学习记录的天数（暂用 evaluation 的 created_at 替代，后续可扩展 learning_log 表）
**理由**: 复用现有数据，避免数据冗余。后续如需精确到分钟的时长追踪，可新增 `learning_log` 表。
**替代方案**: 新建 `user_stats` 汇总表 → 增加写入逻辑复杂度，当前查询量小，聚合查询足够。

### D4: 文件上传历史 → 新增 upload_log 表
**选择**: 在 RDB 中新增 `upload_log` 表（id, course_id, file_name, file_size, upload_time），记录每次文件上传。知识库上传时写入一条记录。
**理由**: 上传历史需要保留，即使知识点被删除，上传记录也应可追溯。独立表结构清晰，支持按时间排序。
**替代方案**: 在 knowledge_item 表中添加 upload 相关字段 → 知识条目可能被删除，丢失历史。

### D5: 课程归档管理 → extension CourseDao + reuse CourseCard
**选择**: CourseDao 新增 `getArchivedCourses()` 和 `restoreCourse(id)` 方法。UI 复用现有 CourseCard 组件，但隐藏进度条和进入学习按钮，显示"恢复"操作。
**理由**: 归档课程与活跃课程的数据结构相同，复用组件和 DAO 减少重复代码。
**替代方案**: 新建 ArchiveCourse 组件 → 维护两套相似的课程卡片代码。

### D6: 设置选项 → 跳转 + 本地存储
**选择**: 
- API Key 配置：提供跳转按钮指向 AiEngine 中的 apiKey 配置位置（或弹窗编辑）
- 深色/浅色主题：使用 `@ohos.app.ability.common` 的 Context 设置 colorMode，或使用 `@StorageLink('colorMode')`
- 关于信息：展示 APP 名称、版本号、技术栈
**理由**: 简洁实现，不引入额外复杂度。主题切换利用 HarmonyOS 原生能力。

### D7: 导航入口 → Index 页顶栏右侧图标
**选择**: 在 Index.ets 顶栏右侧添加个人中心图标按钮（用户头像或齿轮图标），点击跳转 ProfileCenterPage。
**理由**: 最小侵入性修改，不影响现有搜索框+课程卡片布局。移动端应用常见的"右上角个人中心"交互模式。
**替代方案**: 底部 TabBar 切换 → 引入 Tab 组件重构 Index 页，改动范围大。

## Risks / Trade-offs

- **[风险] 学习时长数据不精确**: 当前仅通过 evaluation 记录日期推断学习天数，无精确分钟数。→ 折线图 Y 轴使用"学习次数"而非"分钟"，或后续新增 `learning_log` 表记录精确时长。
- **[风险] Canvas 图表在小屏设备上拥挤**: → 柱状图最多展示5门课程，折线图固定7天，使用响应式 Canvas 宽度（onAreaChange）。
- **[风险] upload_log 表需要 DatabaseHelper 版本迁移**: → 首次安装 APP 时会自动建表，已有用户需在 DatabaseHelper 中处理版本升级逻辑。
- **[取舍] 折线图与柱状图的动画效果**: → 当前不实现动画（避免过度工程），仅静态渲染。后续可扩展添加 animateTo 渐入效果。
