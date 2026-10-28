## 1. 基础框架搭建

- [x] 1.1 新建项目文件结构（model/ database/ engine/ viewmodel/ components/ pages/ 目录）
- [x] 1.2 实现 DatabaseHelper.ets：RDB 初始化、6张表建表脚本（course, knowledge_item, question_block, test_item, evaluation）
- [x] 1.3 实现所有 Model 类（Course, KnowledgeItem, QuestionBlock, TestItem, EvaluationReport）
- [x] 1.4 实现所有 DAO 类（CourseDao, KnowledgeDao, QuestionDao, EvaluationDao）
- [x] 1.5 配置路由表（main_pages.json 注册所有页面）+ 新建页面入口文件
- [x] 1.6 添加资源文件（字符串、颜色、深色/浅色主题 color.json）

## 2. 主页 + 课程管理

- [x] 2.1 重写 Index.ets：搜索框 + 引导语 + 课程卡片列表（空状态/有课程两种UI）
- [x] 2.2 实现 CourseCard 组件（名称、进度条、状态标签、长按菜单）
- [x] 2.3 实现 CourseViewModel（创建课程、状态机流转、多课程排序、删除、归档）
- [x] 2.4 搜索框触发课程创建：输入关键词 -> 生成课程 -> 跳转 CourseSetupPage

## 3. 知识库构建

- [x] 3.1 实现 CourseSetupPage：手动输入知识点标题+内容，知识条目列表展示
- [x] 3.2 实现知识点编辑/删除功能
- [x] 3.3 实现 AiEngine.ets 预置数据加载：HCIA-AI 三门微认证核心知识点（14条）
- [x] 3.4 实现知识库搜索和按来源筛选功能
- [x] 3.5 文件上传入口（预留，P1 实现）

## 4. 三问引擎 + 学习空间

- [x] 4.1 实现 LearningSpacePage：单页滚动布局（Scroll组件）
- [x] 4.2 第一问：AiEngine 返回5个核心心智模型预置数据，KnowledgeGraph Canvas 绘制节点+连线
- [x] 4.3 实现 KnowledgeGraph 组件：Canvas circle(节点) + line(连线) + text(标签)
- [x] 4.4 第二问：AiEngine 返回3个争议点+正反方论据预置数据，DisputeMapView 三区展示
- [x] 4.5 实现 DisputeMapView 组件：共识区/争议区/未知区布局，争议点切换，正反方对比
- [x] 4.6 第三问入口：测试题列表展示（10道题，标注布鲁姆层级）
- [x] 4.7 实现进度追踪：确认按钮 -> 更新进度（第一问33% -> 第二问66% -> 第三问100%）

## 5. 深度测试 + 评价系统

- [x] 5.1 实现 TestQuestionCard 组件：单题展示、文本输入回答、提交、AI反馈展示
- [x] 5.2 苏格拉底追问集成在 TestQuestionCard 的 AI 反馈中（答错时触发追问提示）
- [x] 5.3 实现 Evaluator.ets：三维度评分算法（按布鲁姆层级分类计算正确率）
- [x] 5.4 实现 EvaluationReportPage：得分展示 + RadarChart Canvas + 认知漏洞列表 + 复习建议
- [x] 5.5 实现 RadarChart 组件：Canvas 三角形雷达图
- [x] 5.6 问答原始记录保存和展示（question_text -> student_answer -> ai_feedback）

## 6. 集成测试 + 优化

- [ ] 6.1 端到端流程验证：创建课程 -> 输入知识 -> 三问学习 -> 评价报告（需 SDK 构建）
- [ ] 6.2 深色/浅色主题切换验证（需 SDK 构建）
- [ ] 6.3 边界情况处理：空状态、重复课程、删除确认、数据库异常容错
- [ ] 6.4 构建验证（确保无 ArkTS 编译错误、无语法违规）（需 SDK 构建）
