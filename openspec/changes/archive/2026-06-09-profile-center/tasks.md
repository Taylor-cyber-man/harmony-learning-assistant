## 1. 数据层扩展

- [x] 1.1 在 DatabaseHelper.ets 中新增 `upload_log` 表建表脚本（id, course_id, file_name, file_size, upload_time），处理版本升级逻辑
- [x] 1.2 在 CourseDao.ets 中新增 `getArchivedCourses()` 和 `restoreCourse(id)` 方法
- [x] 1.3 新增 `UploadLogDao.ets`：insert、getByCourseId、getAll（按时间倒序）

## 2. ProfileViewModel 实现

- [x] 2.1 实现 ProfileViewModel.ets：聚合查询统计学习天数、完成课程数、平均得分
- [x] 2.2 实现周学习时长数据计算方法（从 evaluation 表按日期聚合本周记录数）
- [x] 2.3 实现学科能力数据汇总方法（从 evaluation 表读取各课程三维度得分）
- [x] 2.4 实现 archiveCourses 列表加载和恢复功能
- [x] 2.5 实现 uploadLogs 列表加载功能

## 3. Canvas 图表组件

- [x] 3.1 实现 LineChart.ets：折线图组件，支持传入7天数据点数组，X轴日期标签 + Y轴刻度 + 实心圆数据点 + path 连线
- [x] 3.2 实现 BarChart.ets：柱状图组件，支持传入多课程三维度数据，分组柱状图 + fillRect 渐变填充 + 柱顶数值标注 + 图例
- [x] 3.3 实现 Canvas 响应式宽度适配（onAreaChange），确保不同屏幕尺寸下图表比例正确

## 4. 个人中心页面

- [x] 4.1 实现 ProfileCenterPage.ets：Scroll 滚动布局，顶栏返回按钮 + "个人中心"标题
- [x] 4.2 实现学习数据总览卡片区：3张统计卡片（累计天数/完成课程/平均得分），横向排列，空状态引导文案
- [x] 4.3 集成 LineChart 和 BarChart，从 ProfileViewModel 获取数据传入
- [x] 4.4 实现课程归档管理区域：复用 CourseCard 组件（隐藏进度条，显示归档时间、恢复按钮）
- [x] 4.5 实现资料上传历史区域：列表展示文件记录（文件名、课程、时间、大小），空状态提示
- [x] 4.6 实现设置选项区域：API Key 配置弹窗、深色模式开关、关于信息弹窗

## 5. 导航与资源

- [x] 5.1 修改 Index.ets 顶栏：右侧添加个人中心图标按钮（user 或 settings 图标），点击跳转 ProfileCenterPage
- [x] 5.2 在 main_pages.json 注册 ProfileCenterPage 路由
- [x] 5.3 新增个人中心相关字符串资源（标题、卡片标签、空状态文案、设置标签）
- [x] 5.4 新增 Canvas 图表相关颜色资源（折线点色、柱状渐变色、坐标轴色）

## 6. 集成验证

- [x] 6.1 端到端流程：主页 → 个人中心 → 查看统计卡片 → 浏览图表 → 归档管理 → 上传历史 → 设置
- [x] 6.2 深色/浅色主题下图表和卡片样式验证
- [x] 6.3 边界情况：无学习数据空状态、仅1门课程柱状图、超5门课程滑动、归档列表为空、上传历史为空
- [x] 6.4 构建验证（hvigorw assembleHap）
