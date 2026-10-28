## Why

个人中心的三项统计卡片（累计学习天数、完成课程门数、平均得分）始终显示 0，原因是 DB 初始化时序问题和静默错误吞没。同时完成课程数应显示为「已完成门数/总门数」的比值格式而非单一数字。

## What Changes

- 修复 DB 初始化时序：ProfileViewModel 不再依赖持自己的 `ensureDatabaseSafe` 调用，改为使用 `getDbStore()` 的内在重试机制，依赖 EntryAbility 已完成的初始化
- 统计卡片 `完成课程` 显示格式改为 "2/3 门"（已完成/总数）
- 错误日志可观测化：移除静默 try/catch 吞没，在关键路径添加 hilog

## Capabilities

### Modified Capabilities

- `profile-center`: 修复统计数据显示逻辑，变更完成课程显示格式

## Impact

- 修改: `ProfileViewModel.ets`, `ProfileCenterPage.ets`
