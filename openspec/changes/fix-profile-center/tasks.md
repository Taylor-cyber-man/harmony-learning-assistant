## 1. 图标修复

- [x] 1.1 Index.ets：将 `Button('我')` 替换为 Canvas 绘制的人像图标（头部圆 + 身体弧线，白色填充，半透明圆底）
- [x] 1.2 ProfileCenterPage.ets：将 `Button('← 返回')` 替换为纯文本 `返回`

## 2. ArkTS 语法兼容性修复

- [x] 2.1 ProfileViewModel.ets：`Set<string>` 替换为 Array + 手动去重
- [x] 2.2 ProfileViewModel.ets：对象字面量 `{...} as WeekDataPoint` 替换为 `new WeekDataPoint()` + 逐字段赋值
- [x] 2.3 ProfileCenterPage.ets：`Record<string, number>` + `stats['days']` 替换为 `ProfileStats` 实例 + 点号访问

## 3. 功能完整性修复

- [x] 3.1 ProfileCenterPage.ets：实现 API Key 配置弹窗（CustomDialog + TextInput + 保存/取消）
- [x] 3.2 ProfileCenterPage.ets：实现关于信息弹窗
- [x] 3.3 ProfileCenterPage.ets：深色模式 Toggle 持久化
- [x] 3.4 LineChart.ets + BarChart.ets：onAreaChange 每次触发时强制重绘，修复异步数据加载后图表不更新的问题
- [x] 3.5 LineChart.ets：修复单数据点时的除零错误

## 4. 构建验证

- [x] 4.1 hvigorw assembleHap 构建通过
