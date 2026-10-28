## 1. AiEngine 新增 Anthropic 端点 + web_search

- [x] 1.1 AiEngine.ets：新增 `searchKnowledgeItems(courseName: string)` 方法，调用 DeepSeek Anthropic 端点 `/anthropic/v1/messages`，携带 `web_search` tool
- [x] 1.2 解析 Anthropic 响应：提取 `web_search_tool_result` 中的搜索结果（title/url），提取最后的 `text` 块内容
- [x] 1.3 将搜索结果和 AI 总结合成结构化 KnowledgeItem 数组（title/content/source），标注 source=AI
- [x] 1.4 降级逻辑：Anthropic 端点失败时调用 `getPresetKnowledge` 兜底

## 2. LearningSpacePage 资料区 UI

- [x] 2.1 LearningSpacePage：在第一问"我已理解"按钮后、第二问之前，新增独立"学习资料"区块
- [x] 2.2 资料区展示全部 `knowledgeItems`，每条可折叠展开（标题+来源标签+色条 → 展开全文）
- [x] 2.3 按来源分类着色（AI搜索=蓝、上传=绿、手动=橙）
- [x] 2.4 图谱节点点击联动高亮（匹配 `highlightMaterialRef` 的条目加边框）
- [x] 2.5 资料区底部上传按钮

## 3. 构建验证

- [x] 3.1 hvigorw assembleHap 构建通过
