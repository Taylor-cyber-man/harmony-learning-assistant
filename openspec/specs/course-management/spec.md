## Purpose

课程生命周期管理能力——涵盖课程创建、状态流转、卡片展示、排序、删除和归档。用户通过搜索框输入学习问题触发课程创建，每门课程经历"未创建→已创建→活跃→已完成"的状态机流转。

## Requirements

### Requirement: Search-triggered course creation
用户在主界面搜索框输入学习问题后，系统 SHALL 自动识别领域关键词并生成专属课程卡片。

#### Scenario: 输入新领域问题创建课程
- **WHEN** 用户在搜索框输入"如何掌握华为HCIA-AI认证"并提交
- **THEN** 系统生成课程"华为HCIA-AI认证"，自动跳转至课程设置页

#### Scenario: 重复课程不创建
- **WHEN** 用户输入与已有课程相同或高度相似的问题
- **THEN** 系统提示"该课程已存在"，跳转至已有课程的学习空间

### Requirement: Course lifecycle state machine
每门课程 SHALL 经历完整的状态流转：未创建 → 已创建 → 活跃中 → 已完成。

#### Scenario: 课程默认状态
- **WHEN** 课程首次创建
- **THEN** 状态为"已创建"，进度为0%，出现在主界面卡片列表中

#### Scenario: 开始学习切换活跃状态
- **WHEN** 用户点击课程卡片进入学习空间
- **THEN** 状态切换为"活跃中"，卡片高亮显示

#### Scenario: 三问全部完成切换完成状态
- **WHEN** 课程的三问全部完成
- **THEN** 状态切换为"已完成"，卡片置灰，进度更新为100%

### Requirement: Course card display
主界面 SHALL 以卡片列表形式展示已创建课程，包含课程名称、进度条、状态标识。

#### Scenario: 多课程排序展示
- **WHEN** 存在多门已创建课程
- **THEN** 按最近使用时间倒序排列，每张卡片显示名称、进度、状态

#### Scenario: 空状态展示
- **WHEN** 用户尚未创建任何课程
- **THEN** 显示搜索框和引导语，不展示课程卡片

### Requirement: Course card operations
用户 SHALL 可以通过长按课程卡片进行删除、归档操作。

#### Scenario: 删除课程
- **WHEN** 用户长按课程卡片并选择"删除"
- **THEN** 弹出确认对话框，确认后删除课程及关联的所有数据

#### Scenario: 归档已完成课程
- **WHEN** 用户长按已完成的课程卡片并选择"归档"
- **THEN** 课程从主界面隐藏，可在归档列表中查看
