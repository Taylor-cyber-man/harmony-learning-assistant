## MODIFIED Requirements

### Requirement: Learning statistics overview cards
系统 SHALL 在个人中心顶部展示学习数据总览卡片。完成课程数显示为「已完成门数/总门数」格式。

#### Scenario: 展示学习统计卡片
- **WHEN** 用户进入个人中心页面
- **THEN** 顶部展示3张统计卡片：累计学习天数（evaluation记录去重日期数）、完成课程（已完成数/总创建数，如"2/3 门"）、平均得分（所有有效评价的三维度均分）
