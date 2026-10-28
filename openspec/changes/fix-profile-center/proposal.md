## Why

上次实现的个人中心页面存在多个 ArkTS 兼容性问题：首页的 emoji 图标（👤）在 HarmonyOS 上无法正确渲染；ProfileViewModel 使用了 ArkTS 不支持的 `Set` API；ProfileCenterPage 使用了动态索引访问（`stats['days']`）和不规范的对象字面量。此外，API Key 配置弹窗和关于弹窗的 UI 逻辑声明了状态变量但从未渲染。这些问题导致个人中心功能不完整且存在运行时隐患，需要在归档后修复。

## What Changes

- 修复 Index.ets 个人中心入口图标：将 emoji `👤` 替换为 Canvas 绘制/文本图标
- 修复 ProfileViewModel.ets：`Set<string>` 替换为 Array 手动去重，对象字面量显式实例化
- 修复 ProfileCenterPage.ets：`Record<string, number>` 替换为 `ProfileStats` 实例 + 点号访问，实现 API Key 弹窗和关于弹窗的完整 UI
- 新增主题切换持久化支持
- 修复 `←` 返回按钮图标为纯文本

## Capabilities

### Modified Capabilities

- `profile-center`: 修复头像图标渲染、数据统计去重逻辑、设置弹窗 UI、主题持久化、语法兼容性

## Impact

- **修改文件**: `Index.ets`、`ProfileCenterPage.ets`、`ProfileViewModel.ets`
- **构建验证**: `hvigorw assembleHap`
