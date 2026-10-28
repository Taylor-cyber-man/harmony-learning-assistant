## ADDED Requirements

### Requirement: Multi-dimension scoring
系统 SHALL 对学生的第三问作答进行三维度评分：概念理解（40%）、批判思维（30%）、实践迁移（30%）。

#### Scenario: 生成三维度得分
- **WHEN** 用户完成所有测试题
- **THEN** 系统生成三维度得分，展示能力雷达图

#### Scenario: 概念理解维度计算
- **WHEN** 评估概念理解维度
- **THEN** 基于布鲁姆层级1-2（记忆/理解）题目的正确率计算得分

#### Scenario: 批判思维维度计算
- **WHEN** 评估批判思维维度
- **THEN** 基于布鲁姆层级3-4（应用/分析）题目的正确率计算得分

#### Scenario: 实践迁移维度计算
- **WHEN** 评估实践迁移维度
- **THEN** 基于布鲁姆层级5-6（评价/创造）题目的正确率计算得分

### Requirement: Q&A raw log preservation
系统 SHALL 完整保存第三问所有问答记录，包括每道题的原始问题、学生回答、AI反馈及苏格拉底追问链。

#### Scenario: 查看原始对话记录
- **WHEN** 用户进入评价报告页面
- **THEN** 可展开查看每道题的完整对话记录（题目 → 学生回答 → AI第一次反馈 → 追问 → 学生再答）

#### Scenario: 问答记录不可被AI预填
- **WHEN** 系统展示测试题
- **THEN** 回答输入框为空，不预填任何内容，确保评价真实性

### Requirement: Cognitive gap diagnosis
系统 SHALL 基于答题结果生成认知漏洞诊断和复习建议。

#### Scenario: 认知漏洞列表
- **WHEN** 评价报告生成
- **THEN** 展示错题对应的知识点溯源、认知漏洞分析列表

#### Scenario: 复习建议
- **WHEN** 报告生成
- **THEN** 针对薄弱维度给出具体的复习建议（如"建议重新学习RAG技术原理部分的知识点"）

### Requirement: Radar chart visualization
系统 SHALL 以Canvas绘制的能力雷达图展示三维度得分。

#### Scenario: 雷达图渲染
- **WHEN** 评价报告页面加载
- **THEN** Canvas绘制三角形雷达图，三个顶点分别为概念理解、批判思维、实践迁移，显示各维度得分

#### Scenario: 雷达图动画
- **WHEN** 评价报告页面首次展示
- **THEN** 雷达图以渐入动画方式呈现得分区域
