## Fixes

1. **DB 初始化时序**: 移除 `ensureDatabaseSafe`，改为等待 `getDbStore` 的内置 2 秒重试。EntryAbility 在 `onCreate` 调用 `initDatabase`，页面打开时 DB 通常已就绪
2. **完成课程显示**: 改为 `"2/3 门"`（已完成/总数），新增 `totalCourseCount` 统计
3. **错误日志**: 关键查询失败时 log 到 hilog，方便排查
