## Context

上一轮 profile-center 实现遗留了多个 ArkTS 语法兼容性和 UI 完整性问题。本次仅为修复，不引入新架构。

## Fixes

1. **Emoji 图标替换**: `Button('👤')` / `Button('← 返回')` → HarmonyOS 系统字体对 emoji 支持差，全部替换为纯文本符号或特殊字符
2. **Set 替换**: `Set<string>` → 普通数组 + `indexOf` 手动去重（ArkTS 不支持 Set）
3. **动态索引替换**: `stats['days']` → `stats.totalLearningDays`（ArkTS 禁止 obj[key] 语法）
4. **对象字面量替换**: `{ dayLabel, ... } as WeekDataPoint` → `new WeekDataPoint(); wp.dayLabel = ...`
5. **弹窗 UI 补充**: `showApiDialog`/`showAboutDialog` 状态驱动 CustomDialog 渲染
6. **主题持久化**: Toggle 开关使用 `@StorageLink` 联动系统 colorMode
