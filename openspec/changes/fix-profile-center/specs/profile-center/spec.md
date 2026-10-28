## MODIFIED Requirements

### Requirement: Personal center navigation entry
主页 SHALL 提供进入个人中心的导航入口，使用文本图标而非 emoji 以确保跨设备兼容。

#### Scenario: 从主页进入个人中心
- **WHEN** 用户点击主页顶栏右侧的个人中心图标（圆形文本图标"我"）
- **THEN** 系统导航至 ProfileCenterPage

### Requirement: Settings options
个人中心 SHALL 提供完整的设置选项功能，包括可交互的 API Key 配置弹窗和关于弹窗。

#### Scenario: API Key 配置入口
- **WHEN** 用户点击"API Key 配置"
- **THEN** 系统弹出文本输入对话框，显示当前 apiKey（脱敏显示），用户可修改并保存

#### Scenario: 保存 API Key
- **WHEN** 用户在 API Key 弹窗中输入新的 Key 并确认
- **THEN** 系统保存新 Key 到内存配置并关闭弹窗

#### Scenario: 深色/浅色主题切换
- **WHEN** 用户点击"深色模式"开关
- **THEN** 系统切换深色/浅色主题，设置持久化

#### Scenario: 关于信息
- **WHEN** 用户点击"关于"
- **THEN** 系统弹出关于信息弹窗，展示 APP 名称、版本号、技术栈

### Requirement: Learning statistics overview cards
系统 SHALL 在个人中心顶部展示学习数据总览卡片，统计数据使用 ArkTS 兼容的去重算法（非 Set API）计算。

#### Scenario: 展示学习统计卡片
- **WHEN** 用户进入个人中心页面
- **THEN** 顶部展示3张统计卡片，数据通过 Array 手动去重、ProfileStats 类实例的属性点号访问获取
