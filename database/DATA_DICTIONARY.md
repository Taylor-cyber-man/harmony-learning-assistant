# 三问高效学习机 — 数据字典

> HarmonyOS RDB (SQLite) · 6 张业务表 · 自包含部署

---

## ER 图

```
┌──────────┐       ┌──────────────────┐
│  course  │──1:N──│ knowledge_item   │
│          │──1:N──│ question_block   │
│          │──1:N──│ test_item        │
│          │──1:1──│ evaluation       │
│          │──1:N──│ upload_log       │
└──────────┘       └──────────────────┘
```

---

## 表 1: course (课程)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| name | TEXT NOT NULL | 课程名称 |
| keywords | TEXT | 搜索关键词 |
| status | INTEGER | 0=已创建 1=活跃中 2=已完成 3=已归档 |
| progress | INTEGER | 学习进度 0-100 |
| sort_order | INTEGER | 手动拖拽排序序号 |
| created_at | INTEGER | 创建时间 (Unix ms) |
| updated_at | INTEGER | 更新时间 (Unix ms) |

**状态机**: `已创建(0) → 活跃中(1) → 已完成(2) → 已归档(3)`

---

## 表 2: knowledge_item (知识点)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| course_id | INTEGER FK | 关联课程 |
| title | TEXT NOT NULL | 知识点标题 |
| content | TEXT | 详细内容 (含来源引用) |
| source | INTEGER | 0=手动输入 1=文件上传 2=AI搜索 |
| created_at | INTEGER | 创建时间 |

**级联删除**: 课程删除时自动删除关联知识点

---

## 表 3: question_block (三问缓存)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| course_id | INTEGER FK | 关联课程 |
| question_type | INTEGER | 1=心智模型 2=学术争议 |
| title | TEXT | 标题 |
| ai_answer | TEXT | AI 返回的原始 JSON (MentalModel[] 或 DisputePoint[]) |
| user_reflection | TEXT | 用户反思 |
| status | INTEGER | 0=未确认 1=已确认 |
| created_at | INTEGER | 创建时间 |

**用途**: 首次 AI 调用后将结果缓存到此表，下次打开直接读取本地数据，不再重复调用 API

---

## 表 4: test_item (测试题)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| course_id | INTEGER FK | 关联课程 |
| question_text | TEXT | 题目 |
| bloom_level | INTEGER | 布鲁姆认知层级 1-6 |
| student_answer | TEXT | 学生回答 |
| ai_feedback | TEXT | AI 反馈 |
| is_correct | INTEGER | 0=未答 1=正确 2=需改进 |
| created_at | INTEGER | 创建时间 |

**布鲁姆层级**: 1=记忆 2=理解 3=应用 4=分析 5=评价 6=创造

---

## 表 5: evaluation (评价报告)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| course_id | INTEGER FK | 关联课程 |
| concept_score | INTEGER | 概念理解得分 (0-100) |
| critical_thinking_score | INTEGER | 批判思维得分 (0-100) |
| practice_score | INTEGER | 实践迁移得分 (0-100) |
| report_json | TEXT | 评价数据 JSON |
| qa_log_json | TEXT | 完整问答记录 JSON |
| created_at | INTEGER | 创建时间 |

---

## 表 6: upload_log (上传日志)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| course_id | INTEGER FK | 关联课程 |
| course_name | TEXT | 课程名称 (冗余方便查询) |
| file_name | TEXT NOT NULL | 文件名 |
| file_size | INTEGER | 文件大小 (bytes) |
| upload_time | INTEGER | 上传时间 |

**级联删除**: 课程删除时 set NULL (保留日志记录)

---

## 部署说明

**自动部署**: APP 首次启动时，`EntryAbility.onCreate()` 调用 `DatabaseHelper.initDatabase(context)`，6 条 `CREATE TABLE IF NOT EXISTS` 语句顺序执行，系统自动创建 `LearningApp.db` 文件。

**手动部署**: 将 `database/init.sql` 在任意 SQLite 客户端中执行即可获得相同的表结构。

**版本升级**: `initDatabase()` 末尾执行 `ALTER TABLE course ADD COLUMN sort_order`，旧版数据库自动兼容无需重建。
