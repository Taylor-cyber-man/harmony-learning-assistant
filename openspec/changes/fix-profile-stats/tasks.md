## 1. 修复 ProfileViewModel 数据加载

- [x] 1.1 移除 `ensureDatabaseSafe` 调用，移除 Context 参数，改为 await `getDbStore()` 等待 DB 就绪
- [x] 1.2 新增 `totalCourseCount` 字段，统计所有非 ARCHIVED 的课程数
- [x] 1.3 加载失败时用 hilog 记录错误（不再静默吞没）

## 2. 修复 ProfileCenterPage 显示

- [x] 2.1 新增 `totalCourseCount` @State，显示为 "已完成/总门数" 格式
- [x] 2.2 移除 `loadAll(ctx)` 的 Context 传参

## 3. 构建验证

- [x] 3.1 hvigorw assembleHap 构建通过
