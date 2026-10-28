## Purpose

复合知识库构建能力——支持手动输入知识点、AI预置补充资料、知识条目搜索和按来源筛选。手动输入与AI补充的知识融合展示，每条标注来源，形成课程的个性化知识库。

## Requirements

### Requirement: Manual knowledge input
用户 SHALL 能够在课程设置页手动输入知识点，每条知识包含标题和内容。

#### Scenario: 添加知识点
- **WHEN** 用户在课程设置页填写标题和内容并提交
- **THEN** 知识点保存至该课程的知识库，显示在知识条目列表中

#### Scenario: 编辑已添加的知识点
- **WHEN** 用户点击已有知识点进行编辑
- **THEN** 系统展示编辑界面，修改后保存更新

### Requirement: AI preset knowledge supplement
课程创建后，系统 SHALL 自动加载预置的AI补充资料（模拟联网检索），包含权威论文摘要、核心概念解释等。

#### Scenario: 课程创建后自动补充AI资料
- **WHEN** 课程"华为HCIA-AI认证"创建完成
- **THEN** 系统自动将预置的HCIA-AI核心知识点（AI基础、RAG概念、Agent架构等）加入知识库

### Requirement: Knowledge base search and filter
用户 SHALL 能够按关键词搜索或按来源筛选知识库内容。

#### Scenario: 关键词搜索知识条目
- **WHEN** 用户在知识库输入"RAG"进行搜索
- **THEN** 显示标题或内容中包含"RAG"的所有知识条目

#### Scenario: 按来源筛选
- **WHEN** 用户选择筛选条件"手动输入"
- **THEN** 仅显示用户手动添加的知识条目，隐藏AI预置条目

### Requirement: Knowledge fusion display
知识库 SHALL 融合展示手动输入和AI补充的知识条目，明确标注每条知识的来源。

#### Scenario: 混合来源列表展示
- **WHEN** 用户查看知识库列表
- **THEN** 每条知识条目显示标题、来源标签（"手动"/"AI"），按添加时间排列
