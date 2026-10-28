## Context

当前 AiEngine 的知识搜索（`fetchKnowledgeItems`）使用 DeepSeek Chat API，仅返回模型训练数据中的静态知识，无法获取最新的权威网络信息。DeepSeek 提供了一个 Anthropic Messages API 兼容端点 `https://api.deepseek.com/anthropic/v1/messages`，支持 `web_search` 工具，可实时搜索互联网并返回带来源 URL 的结构化结果。

**API 架构**:
- **DeepSeek Chat API** (`/v1/chat/completions`) → 心智模型分析、争议挖掘、测试题生成、答题评价（保持现状）
- **DeepSeek Anthropic 端点** (`/anthropic/v1/messages`) → **知识搜索**，利用 `web_search` tool 获取权威网络信息（新增）

**当前流程**: 课程创建 → DeepSeek Chat 生成通用知识点 → LearningSpacePage 点击图谱节点弹窗查看关联资料

**目标流程**: 课程创建 → DeepSeek Anthropic 端点 + web_search 搜索权威资料 + 生成结构化知识点（带来源URL）→ LearningSpacePage 全域可见资料区

## Goals / Non-Goals

**Goals:**
- 知识搜索切换到 DeepSeek Anthropic 端点，启用 `web_search` 工具获取实时权威资料
- 知识点附带来源 URL，用户可追溯原始资料
- 学习空间新增独立资料区展示所有知识条目
- 资料区支持折叠展开、来源分类着色、图谱联动高亮

**Non-Goals:**
- 不引入额外的 API Key（复用 DeepSeek Key）
- 不修改心智模型/争议/测试等已有功能
- 不修改 CourseSetupPage

## Decisions

### D1: 知识搜索 API → DeepSeek Anthropic 端点 + web_search tool

**请求格式**:
```
POST https://api.deepseek.com/anthropic/v1/messages
Headers:
  x-api-key: <DeepSeek API Key>
  Content-Type: application/json
Body:
{
  "model": "deepseek-v4-flash",
  "tools": [{ "type": "web_search_20260209", "name": "web_search" }],
  "messages": [{ "role": "user", "content": "搜索...<courseName>..." }]
}
```

**响应结构**: `content` 数组中包含 `thinking` → `server_tool_use`（触发搜索）→ `web_search_tool_result`（搜索结果，含 title/url）→ `thinking`（分析结果）→ `text`（最终文本回答）

**提取策略**: 
- 从 `web_search_tool_result` 提取搜索结果（title + url）作为来源
- 从最后的 `text` 块提取 AI 总结内容
- 解析为 KnowledgeItem 数组

### D2: prompt 设计

```
system: 你是知识体系构建专家。请使用 web_search 工具搜索与用户课程相关的最新、权威互联网资料。
        基于搜索结果生成15条结构化知识点。每条知识点包含：标题、详细内容（200-300字）、来源网站名、来源URL。
        最后以JSON数组格式输出所有知识点。

user: 课程名称：{courseName}。请搜索该领域的最新权威资料并生成知识点。
```

### D3: 资料区卡片设计
折叠列表，左侧色条区分来源，点击展开查看完整内容。底部上传按钮。

## Risks

- **[风险] Anthropic 端点响应格式变化**: → 解析逻辑使用了 `server_tool_use`/`web_search_tool_result`/`text` 的稳定字段
- **[风险] 搜索增加延迟**: → 保留 `getPresetKnowledge` 降级方案
