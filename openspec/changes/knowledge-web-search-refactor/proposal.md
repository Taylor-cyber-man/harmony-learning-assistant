## Why

需求书明确要求学习空间页面应包含"资料区"，集中展示所有 AI 收集和用户上传的知识点。当前实现仅在用户点击知识图谱节点时弹窗显示关联资料，用户体验碎片化。同时，当前 AI 知识搜索仅使用 DeepSeek Chat API 的静态训练知识（截止日期限制），无法获取最新权威网络信息。DeepSeek API 支持联网搜索功能（通过 `stream_options` 中的 `search` 参数），可以实时查找权威来源内容，让知识点更加准确和时效性强。

## What Changes

- **学习空间新增资料区**：在评教空间底部（第三问之前）新增独立的"学习资料"区块，完整展示所有 AI 和用户上传的知识点列表，支持展开/折叠查看内容
- **重构 AI 知识点搜索**：`fetchKnowledgeItems` 启用 DeepSeek 联网搜索模式，实时查找权威网络资料并生成结构化知识点
- **资源区与图谱联动保留**：知识图谱节点点击后仍可高亮关联资料，同时资料区始终可见
- **文件上传嵌入资料区**：在学习空间资料区添加上传入口，用户可在学习时直接上传补充资料

## Capabilities

### Modified Capabilities

- `knowledge-base`: 扩展 AI 知识搜索能力——启用 DeepSeek API 联网搜索，实时获取权威网络信息并结构化存储为知识点
- `three-question-engine`: 学习空间 UI 调整——在第一问与第二问之间的关联资料区域下方，新增完整资料区展示所有知识点

## Impact

- **修改文件**: `LearningSpacePage.ets`（新增资料区 UI）、`AiEngine.ets`（启用联网搜索）、`CourseSetupPage.ets`（文件上传联动）
- **新增配置**: `AiEngine.ets` 中新增 `enableWebSearch` 标志和搜索参数
- **API 方式**: DeepSeek API `stream_options.search.enabled = true` 启用联网搜索
