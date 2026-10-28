## Why

当前APP已实现课程创建、三问学习、评价报告等核心功能，但缺少一个聚合用户学习行为和成果的"个人中心"页面。学习者需要一个集中查看学习进度、追踪能力成长、管理历史数据的入口，同时通过数据可视化（折线图、柱状图）将抽象的学习数据转化为直观的成长曲线，增强学习动机和成就感。这与产品"高效学习"的定位一脉相承——不仅要学得好，还要看得见进步。

## What Changes

- 新增**个人中心页面** (`ProfileCenterPage.ets`)：作为用户学习数据和功能入口的聚合页
- 新增**折线图组件** (`LineChart.ets`)：基于Canvas绘制周学习时长变化趋势
- 新增**柱状图组件** (`BarChart.ets`)：基于Canvas绘制各学科能力得分对比
- 实现**学习数据总览模块**：展示累计学习天数、总课程数、平均得分等关键指标卡片
- 实现**课程归档管理模块**：查看已归档课程列表，支持恢复归档课程
- 实现**资料上传历史模块**：展示知识库文件上传记录（时间、文件名、关联课程）
- 实现**设置选项模块**：API Key配置入口、深色/浅色主题切换、关于信息
- 修改**主页面导航**：添加个人中心入口（Tab或顶栏图标）
- 提升**RDB表结构**：如需为`setting`或`upload_log`新增表（或复用现有数据查询）

## Capabilities

### New Capabilities

- `profile-center`: 个人中心页面，包含学习数据总览（关键指标卡片）、课程归档管理（查看/恢复）、资料上传历史（按时间排序）、设置选项（API Key、主题切换、关于），以及Canvas数据可视化（周学习时长折线图 + 学科能力柱状图）。

### Modified Capabilities

<!-- 本次不修改现有 capability 的需求，仅读取 course-management、evaluation-report 的数据 -->

## Impact

- **新增文件**: `ProfileCenterPage.ets`、`LineChart.ets`、`BarChart.ets`、`ProfileViewModel.ets`
- **修改文件**: `Index.ets`（添加个人中心入口）、`main_pages.json`（注册新路由）
- **数据库**: 可能需要新增 `learning_log` 表记录每日学习时长，或通过 evaluation_report 的 created_at 聚合；可能需要新增 `upload_log` 表记录文件上传历史
- **资源文件**: 新增个人中心相关字符串资源、图标资源（如 tab 图标）
- **依赖**: 零第三方依赖，全部使用 HarmonyOS 原生 Canvas API + RDB 查询
