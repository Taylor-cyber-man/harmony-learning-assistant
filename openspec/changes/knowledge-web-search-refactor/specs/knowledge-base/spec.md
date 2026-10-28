## MODIFIED Requirements

### Requirement: AI preset knowledge supplement
课程创建后，系统 SHALL 通过 DeepSeek Anthropic 兼容端点（`/anthropic/v1/messages`）的 `web_search` 工具实时搜索互联网权威资料，生成结构化知识点补充到知识库。

#### Scenario: 课程创建后 WebSearch 联网搜索
- **WHEN** 课程创建完成
- **THEN** 系统调用 DeepSeek Anthropic 端点，携带 `web_search` tool（`web_search_20260209`），基于课程名称搜索权威网络信息，生成 15 条带来源 URL 的知识点

#### Scenario: 搜索失败降级
- **WHEN** Anthropic 端点调用失败
- **THEN** 系统降级使用本地预置知识数据（`getPresetKnowledge`）
