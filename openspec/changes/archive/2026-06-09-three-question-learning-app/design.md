## Context

当前工程为 HarmonyOS NEXT (API 6.0.2) 空白模板，仅有 Hello World 页面。需从零构建完整的"三问高效学习机"APP。目标设备为手机(phone)，使用 stageMode 模块类型，ArkTS 开发语言。演示课程内容为华为 HCIA-AI 认证（融合三门微认证：人工智能技术链与实践、基于DeepSeek和RAG构建智能小助手、AI Agent技术与应用）。

## Goals / Non-Goals

**Goals:**
- 实现完整的 7 个页面 + 6 个可复用组件
- 全部基于 HarmonyOS 原生 SDK，零第三方依赖
- 关系型数据库（RDB）持久化存储课程、知识、问答、评价数据
- 课程-知识库-三问引擎-评价报告完整闭环
- 知识图谱和雷达图使用 Canvas 绘制
- 深色/浅色主题支持

**Non-Goals:**
- AI API Key 由用户手动配置（代码预留 DeepSeek API 接口和 apiKey 配置项，演示使用预置模拟数据）
- 真实网络爬取（使用预置资料模拟）
- 协作讨论区、数据导出（P1 后期实现）
- 多语言国际化（仅中文）

## Decisions

### D1: 单页滚动布局 vs Tab 分页
**选择**: 学习空间使用单页滚动布局（知识图谱 → 争议地图 → 资料区 + 测试入口）
**理由**: 符合需求书原文设计，用户可在一个页面内看到三问全貌，符合"一目了然"的产品理念。通过 `Scroll` 组件实现，滚动流畅。

### D2: Canvas vs 第三方库绘制图表
**选择**: 使用 HarmonyOS 内置 `Canvas` + `CanvasRenderingContext2D` 手绘知识图谱和雷达图
**理由**: 零依赖、完全可控、与ArkTS无缝集成。知识图谱用 circle + line + text 组合绘制，雷达图用 path + fill 实现。

### D3: RDB vs 文件存储
**选择**: `@ohos.data.relationalStore` 关系型数据库
**理由**: 结构化数据（课程/知识/问答/评价）适合 RDB 存储，支持 SQL 查询、排序、筛选。建表脚本内置在 `DatabaseHelper.ets` 中，首次启动自动建表 + 插入预置数据。

### D4: 预置数据 vs DeepSeek API
**选择**: 演示阶段使用预置模拟数据，代码预留 DeepSeek API 接口。用户完成程序后手动填入 apiKey 即可切换真实 AI。
**理由**: 演示稳定、无需网络、不依赖外部服务。DeepSeek API 兼容 OpenAI 格式，使用 `@ohos.net.http` 直接调用，零额外 SDK 依赖。`AiEngine.ets` 中：
- 定义一个 `DEEPSEEK_CONFIG` 对象（apiKey + endpoint + model），apiKey 字段留空待用户填入
- 预留 `callDeepSeekApi(systemPrompt, userPrompt): Promise<string>` 方法
- 演示方法 `analyzeMentalModels()`、`analyzeDisputes()`、`generateTestQuestions()` 返回预置数据
- 切换真实 API 时只需替换方法调用为 `callDeepSeekApi()`

### D8: API 配置方式
**选择**: 代码内常量配置（非 UI 面板）
**理由**: 减少 UI 复杂度，用户只需在 `AiEngine.ets` 中修改一行 `apiKey` 值即可切换。配置结构：
```
const DEEPSEEK_CONFIG = {
  apiKey: '',  // ← 用户替换为自己的 Key
  endpoint: 'https://api.deepseek.com/v1/chat/completions',
  model: 'deepseek-chat'
}
```

### D9: UI Design System（简约科技风格）

**选择**: SaaS Blue 配色 + 卡片式布局 + 大量留白的极简设计
**理由**: 匹配"学习工具"的产品定位，科技蓝传递信任感，卡片式布局在移动端清晰易操作。设计参考 ui-ux-pro-max 技能规则和 SaaS 配色方案。

**色彩 Token:**
| 角色 | Hex | 用途 |
|------|-----|------|
| Primary | #2563EB | 主色，按钮、选中状态、进度条 |
| Secondary | #3B82F6 | 辅色，标签、链接、渐变 |
| Accent/CTA | #F97316 | 强调，关键操作按钮 |
| Background | #F8FAFC | 页面背景（浅色） |
| Dark Background | #0F172A | 页面背景（深色） |
| Card | #FFFFFF / #1E293B | 卡片背景 |
| Text Primary | #1E293B / #F1F5F9 | 正文文字 |
| Text Secondary | #64748B | 辅助文字 |
| Success | #10B981 | 完成/正确状态 |
| Error | #EF4444 | 错误状态 |

**圆角系统:** 搜索框 28fp | 卡片 16fp | 按钮 12fp | 标签 6fp | 弹窗 20fp
**间距基准:** 4fp 增量系统 (4/8/12/16/20/24/32)
**阴影层级:** e1: 0 1fp 3fp α8% | e2: 0 4fp 8fp α12% | e3: 0 8fp 24fp α16%
**字体:** HarmonyOS Sans 系统字体 | 字重: Bold(标题)/Regular(正文)/Medium(标签)
**字号层级:** h1:24fp | h2:20fp | h3:16fp | body:14fp | note:12fp
**交互反馈:** 按下 opacity 0.6+scale 0.97 | 动画 150-300ms | Canvas渐入 600ms

### D5: MVVM 架构分层
**选择**: Model-ViewModel-View 三层分离
- **Model**: `model/` 数据模型类 + `database/` DAO 数据访问层
- **ViewModel**: `viewmodel/` 业务逻辑层（状态管理、数据转换）
- **View**: `pages/` + `components/` UI 层

### D6: 路由设计
**选择**: 使用 `@ohos.router` 进行页面导航
页面路由表:
- `pages/Index` → 主页
- `pages/CourseSetupPage` → 课程设置
- `pages/LearningSpacePage` → 学习空间（单页滚动，内嵌三问内容）
- `pages/EvaluationReportPage` → 评价报告

### D7: 数据库表设计
6张RDB表:
- `course`: id, name, keywords, status, progress, created_at, updated_at
- `knowledge_item`: id, course_id(FK), title, content, source(0=manual/1=upload/2=ai), created_at
- `question_block`: id, course_id(FK), question_type(1/2/3), title, ai_answer, user_reflection, status, created_at
- `test_item`: id, course_id(FK), question_text, bloom_level, student_answer, ai_feedback, is_correct
- `evaluation`: id, course_id(FK), concept_score, critical_thinking_score, practice_score, report_json, qa_log_json, created_at

## Risks / Trade-offs

- **[风险] Canvas知识图谱在低端设备上渲染性能**: → 限制节点数量（≤10个），使用 `renderGroup(true)` 减少渲染批次
- **[风险] 预置数据可能不够丰富**: → 三门微认证课程内容交叉映射，预置 ~15 条知识点 + 5 个心智模型 + 3 个争议点 + 10 道测试题
- **[风险] ArkTS语法限制**: → 严格遵循项目管理规则 `harmonyos.md` 中的27条语法约束，避免使用不支持的特性（如解构、any类型、函数表达式等）
- **[取舍] 单页滚动可能过长**: → 使用锚点导航（Scroll自带的scrollTo），每个区块可快速定位
