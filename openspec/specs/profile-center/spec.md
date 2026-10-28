## Purpose

个人中心页面能力——提供用户级学习数据聚合和功能管理入口。包含学习数据总览（关键指标卡片）、Canvas数据可视化（周学习时长折线图 + 学科能力柱状图）、课程归档管理（查看/恢复）、资料上传历史（按时间排序）、设置选项（API Key、主题切换、关于信息），以及从主页进入的导航入口。

## Requirements

### Requirement: Learning statistics overview cards
系统 SHALL 在个人中心顶部展示学习数据总览卡片，包含累计学习天数、已完成课程数、平均得分三项关键指标。

#### Scenario: 展示学习统计卡片
- **WHEN** 用户进入个人中心页面
- **THEN** 顶部展示3张统计卡片：累计学习天数（从 evaluation 记录去重统计）、已完成课程数（course 表中 status=completed 计数）、平均得分（所有评价报告三维度总分的平均，0-100）

#### Scenario: 无学习记录时的空状态
- **WHEN** 用户尚未完成任何课程或测试
- **THEN** 三张卡片显示默认值0，并在卡片下方显示引导文案"开始你的第一门课程吧"

### Requirement: Weekly learning time line chart
系统 SHALL 以Canvas折线图展示近7天学习时长变化趋势。

#### Scenario: 渲染周学习时长折线图
- **WHEN** 用户进入个人中心页面
- **THEN** Canvas绘制折线图：X轴标注周一至周日日期，Y轴标注学习分钟数（0-120），7个数据点用实心圆标记并以直线连接，图表标题为"本周学习时长"

#### Scenario: 某天无学习记录
- **WHEN** 某天没有学习记录
- **THEN** 该天数据点为0分钟，连线降至X轴

### Requirement: Subject ability bar chart
系统 SHALL 以Canvas柱状图对比各课程的三维度能力得分。

#### Scenario: 渲染学科能力柱状图
- **WHEN** 用户进入个人中心页面且在 evaluation 表中有评价记录
- **THEN** Canvas绘制分组柱状图：每组3根柱子分别代表概念理解、批判思维、实践迁移，横轴标注课程名称，柱顶标注得分数字，使用渐变色区分三维度

#### Scenario: 仅有一门课程
- **WHEN** 用户仅完成了一门课程
- **THEN** 显示单组3根柱子，居中展示

#### Scenario: 超过5门课程的处理
- **WHEN** 用户完成了超过5门课程
- **THEN** 仅展示最近的5门课程，柱状图可水平滑动

### Requirement: Course archive management
用户 SHALL 能够在个人中心查看已归档课程列表，并恢复归档课程至活跃列表。

#### Scenario: 查看已归档课程
- **WHEN** 用户点击"课程归档"入口
- **THEN** 展示所有已归档课程的卡片列表，每张卡片显示课程名称、归档时间，不显示进度条

#### Scenario: 恢复归档课程
- **WHEN** 用户在归档课程卡片上点击"恢复"
- **THEN** 课程状态从"已归档"切换为"已完成"，重新出现在主页课程列表中

#### Scenario: 归档列表为空
- **WHEN** 用户没有任何已归档课程
- **THEN** 显示"暂无已归档课程"空状态提示

### Requirement: Material upload history
系统 SHALL 记录并展示知识库的文件上传历史。

#### Scenario: 查看上传历史
- **WHEN** 用户点击"上传历史"入口
- **THEN** 按上传时间倒序展示文件上传记录列表，每条显示文件名、所属课程、上传时间、文件大小

#### Scenario: 上传历史为空
- **WHEN** 用户未上传过任何文件
- **THEN** 显示"暂无上传记录"空状态提示

### Requirement: Settings options
个人中心 SHALL 提供设置选项的便捷入口。

#### Scenario: API Key 配置入口
- **WHEN** 用户点击"API Key 配置"
- **THEN** 系统弹出文本输入框，显示当前 apiKey（脱敏显示），用户可修改并保存

#### Scenario: 深色/浅色主题切换
- **WHEN** 用户点击"深色模式"开关
- **THEN** 系统切换深色/浅色主题，并持久化设置偏好

#### Scenario: 关于信息
- **WHEN** 用户点击"关于"
- **THEN** 系统展示APP名称"三问学习机"、版本号、技术栈信息（HarmonyOS NEXT、ArkTS）

### Requirement: Personal center navigation entry
主页 SHALL 提供进入个人中心的导航入口。

#### Scenario: 从主页进入个人中心
- **WHEN** 用户点击主页顶栏右侧的个人中心图标
- **THEN** 系统导航至 ProfileCenterPage
