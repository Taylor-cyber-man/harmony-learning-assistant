-- ============================================================
-- 三问高效学习机 — 数据库部署脚本
-- 数据库引擎: SQLite (HarmonyOS RDB)
-- 编码: UTF-8
-- 日期: 2026-06-10
-- 说明: 6 张业务表，全部使用 CREATE TABLE IF NOT EXISTS，
--       首次安装 APP 时由 DatabaseHelper.initDatabase() 自动执行。
--       本文件供教师离线审阅表结构及建表逻辑。
-- ============================================================

-- 1. 课程表
CREATE TABLE IF NOT EXISTS course (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT    NOT NULL,               -- 课程名称
    keywords     TEXT,                           -- 搜索关键词
    status       INTEGER DEFAULT 0,             -- 状态: 0=已创建 1=活跃中 2=已完成 3=已归档
    progress     INTEGER DEFAULT 0,             -- 学习进度 0-100
    sort_order   INTEGER DEFAULT 0,             -- 手动排序序号
    created_at   INTEGER,                       -- 创建时间 (Unix ms)
    updated_at   INTEGER                        -- 更新时间 (Unix ms)
);

-- 2. 知识点表
CREATE TABLE IF NOT EXISTS knowledge_item (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id    INTEGER,                       -- 所属课程 ID
    title        TEXT    NOT NULL,              -- 知识点标题
    content      TEXT,                          -- 详细内容
    source       INTEGER DEFAULT 0,             -- 来源: 0=手动 1=上传 2=AI搜索
    created_at   INTEGER,
    FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
);

-- 3. 三问记录表 (缓存心智模型/学术争议)
CREATE TABLE IF NOT EXISTS question_block (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id      INTEGER,                     -- 所属课程 ID
    question_type  INTEGER,                     -- 1=第一问(心智模型) 2=第二问(学术争议) 3=第三问
    title          TEXT,                        -- 标题
    ai_answer      TEXT,                        -- AI 返回的 JSON 数据
    user_reflection TEXT,                       -- 用户反思
    status         INTEGER DEFAULT 0,           -- 0=未确认 1=已确认
    created_at     INTEGER,
    FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
);

-- 4. 测试题目表
CREATE TABLE IF NOT EXISTS test_item (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id      INTEGER,                     -- 所属课程 ID
    question_text  TEXT,                        -- 题目
    bloom_level    INTEGER,                     -- 布鲁姆层级 1-6
    student_answer TEXT,                        -- 学生回答
    ai_feedback    TEXT,                        -- AI 反馈
    is_correct     INTEGER DEFAULT 0,           -- 0=未答 1=正确 2=需改进
    created_at     INTEGER,
    FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
);

-- 5. 评价报告表
CREATE TABLE IF NOT EXISTS evaluation (
    id                     INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id              INTEGER,             -- 所属课程 ID
    concept_score          INTEGER DEFAULT 0,   -- 概念理解得分
    critical_thinking_score INTEGER DEFAULT 0,  -- 批判思维得分
    practice_score         INTEGER DEFAULT 0,   -- 实践迁移得分
    report_json            TEXT,                -- 评价数据 JSON
    qa_log_json            TEXT,                -- 问答记录 JSON
    created_at             INTEGER,
    FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
);

-- 6. 文件上传日志表
CREATE TABLE IF NOT EXISTS upload_log (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id    INTEGER,                       -- 所属课程 ID
    course_name  TEXT,                          -- 课程名称 (冗余)
    file_name    TEXT    NOT NULL,              -- 文件名
    file_size    INTEGER DEFAULT 0,             -- 文件大小 (bytes)
    upload_time  INTEGER,                       -- 上传时间 (Unix ms)
    FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE SET NULL
);

-- 版本兼容: 旧版 course 表无 sort_order 列
-- ALTER TABLE course ADD COLUMN sort_order INTEGER DEFAULT 0;
