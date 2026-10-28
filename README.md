# 三问高效学习机

基于 HarmonyOS NEXT 的智能学习助手，用 ArkTS + ArkUI 实现课程管理、资料整理、AI 问答、知识图谱与学习评价。

## 功能

- **课程管理**：新建课程、拖拽排序、课程资料上传与学习进度跟踪
- **AI 问答**：接入 DeepSeek 大模型，支持知识点讲解、错题分析与学习建议
- **知识图谱**：Canvas 2D 绘制知识点关系图、能力雷达图、成绩折线图与柱状图
- **在线测试**：按课程生成练习题，答题后自动评分并给出解析
- **评价报告**：汇总正确率、薄弱知识点与学习趋势，支持导出 TXT / Markdown / JSON
- **本地存储**：RDB 关系型数据库管理课程、题库、知识条目与上传记录，preferences 保存用户设置

## 技术栈

| 类别 | 技术 |
| --- | --- |
| 语言 | ArkTS |
| UI | ArkUI 声明式 UI |
| 存储 | @kit.ArkData（RDB、preferences） |
| 图表 | Canvas 2D |
| 网络 | @kit.NetworkKit（HTTP） |
| 构建 | hvigor |

## 运行

1. 使用 DevEco Studio 打开项目，等待依赖同步完成
2. 在 `entry/src/main/ets/config/AppConfig.ets` 中填入自己的 DeepSeek API Key，或运行后在「个人中心」中填写
3. 连接模拟器或真机，点击运行

> 仓库中不包含任何 API Key，请使用自己的密钥，并注意不要将密钥提交到公开仓库。

## 目录结构

```
entry/src/main/ets
├── components/     # 图表、课程卡片、知识图谱等组件
├── config/         # API 地址与模型配置
├── database/       # RDB 建表与各 DAO
├── engine/         # AI 调用与评价逻辑
├── model/          # 数据模型
├── pages/          # 首页、学习空间、评价报告、个人中心
└── viewmodel/      # 页面状态管理
```
