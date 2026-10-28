## Purpose

三问认知引擎核心能力——包含第一问（心智模型提取+知识图谱Canvas可视化）、第二问（学术争议挖掘+认知地图展示）、第三问（布鲁姆六层级深度测试+苏格拉底追问链）。三个问题依次推进，驱动用户从被动接收知识转向主动深度思考。

## Requirements

### Requirement: First question - Core mental model extraction
系统 SHALL 分析知识库，识别该领域的核心心智模型，并以知识图谱可视化呈现。

#### Scenario: 生成心智模型
- **WHEN** 用户进入第一问页面
- **THEN** 系统基于知识库展示5个核心心智模型（如AI领域的"数据-算法-算力三角"、"预训练+微调范式"、"RAG检索增强模式"、"Agent LLM+P+M+T架构"、"神经网络分层抽象"），以知识图谱呈现

#### Scenario: 知识图谱节点交互
- **WHEN** 用户点击知识图谱中的某个节点
- **THEN** 展开该节点的详细描述和关联知识条目链接

### Requirement: Second question - Academic dispute mining
系统 SHALL 对比多源知识，标注关键技术争议点及正反方论据，生成认知地图。

#### Scenario: 展示争议认知地图
- **WHEN** 用户进入第二问页面
- **THEN** 系统展示认知地图，分为共识区、争议区、未知区三块，重点标注3个争议点及各方最有力的论据

#### Scenario: 切换争议主题
- **WHEN** 用户点击不同争议点标签
- **THEN** 页面切换展示对应争议的正反方论据详情

### Requirement: Third question - Bloom's taxonomy deep test
系统 SHALL 基于布鲁姆认知层级（记忆/理解/应用/分析/评价/创造）生成10道自测题，覆盖6个层级。

#### Scenario: 展示测试题目列表
- **WHEN** 用户进入第三问页面
- **THEN** 按布鲁姆层级分类展示10道题目，标注每题对应的认知层级

#### Scenario: 逐题作答
- **WHEN** 用户选中一道题并输入答案提交
- **THEN** 系统显示AI反馈，指出回答中的认知漏洞

#### Scenario: Socratic probe on wrong answer
- **WHEN** 用户回答错误
- **THEN** 系统触发苏格拉底追问："你为什么会这样想？你漏掉了什么关键概念？请重新解释一遍"，用户可在追问框再次作答

#### Scenario: 显示学习空间单页布局
- **WHEN** 用户进入学习空间页面
- **THEN** 页面以单页滚动布局展示：顶部为知识图谱（第一问）、中部为认知地图（第二问）、底部为测试入口和资料列表

### Requirement: Learning progress tracking
系统 SHALL 追踪每门课程的三问完成进度。

#### Scenario: 第一问标记完成
- **WHEN** 用户阅读完心智模型并确认"我已理解"
- **THEN** 第一问标记为完成，进度更新为33%

#### Scenario: 第二问标记完成
- **WHEN** 用户阅读完争议分析并确认"我已理解"
- **THEN** 第二问标记为完成，进度更新为66%

#### Scenario: 第三问全部完成
- **WHEN** 用户完成所有10道测试题
- **THEN** 第三问标记为完成，课程进度100%，状态切换为"已完成"
