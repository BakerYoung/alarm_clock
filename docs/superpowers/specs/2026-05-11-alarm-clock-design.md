# 智能闹钟 App 设计文档

## 概述

一款跨平台移动闹钟应用，解决 iOS 自带闹钟的核心痛点：
1. 无法设置"仅工作日"响铃
2. 中国法定节假日和调休需要手动调整
3. 闹钟铃声选择有限

## 技术栈

| 层级 | 选型 |
|------|------|
| 框架 | Flutter (Dart) |
| 本地存储 | sqflite (SQLite) |
| 闹钟调度 | Android AlarmManager / iOS UNNotification |
| 音频播放 | audioplayers / just_audio |
| 录音 | record |
| 文件选择 | file_picker |
| 网络 | http (节假日 API) |

## 数据模型

### Alarm（闹钟）

```
Alarm {
  id: int (PK, auto)
  name: string              // 闹钟名称
  time: string              // HH:mm 格式
  rule: enum                // once | daily | weekday | custom
  customDays: List<int>     // 仅 rule=custom 时，0=周日...6=周六
  soundType: enum           // builtin | file | recording
  soundPath: string         // 铃声文件路径
  enabled: bool
  snoozeMinutes: int        // 贪睡间隔，默认 10
  createdAt: DateTime
}
```

### HolidayCache（节假日缓存）

```
HolidayCache {
  year: int (PK)
  holidays: string          // JSON: ["2026-01-01", "2026-05-01", ...]
  makeupDays: string        // JSON: ["2026-05-03", ...] 调休上班日
  updatedAt: DateTime
}
```

## 闹钟调度引擎

### 两级决策流程

```
闹钟触发时间到
  │
  ├─ 第一级：重复规则匹配
  │   检查今天是周几，是否匹配闹钟的重复规则
  │   规则 = weekday → 周一~五匹配 ✓，周六日不匹配 ✗
  │
  └─ 第二级：节假日覆盖
      查询 HolidayCache
      今天 ∈ holidays  → 不响（放假）
      今天 ∈ makeupDays → 响（调休上班）
      否则保持第一级判断
```

### 决策优先级

调休上班 > 法定放假 > 基础规则

### 节假日数据来源

- 每年初自动从国务院 API 拉取年度节假日安排
- 数据缓存到本地 SQLite，离线可用
- 设置页面提供「手动刷新」按钮
- 自动刷新策略：每月检查一次是否有更新

## 页面结构

### 底部 Tab 导航（4个Tab）

**Tab 1: 闹钟列表（主页）**
- 闹钟列表，按时间排序
- 每项显示：时间、名称、重复规则标签、启用开关
- 点击进入编辑，右上角「+」新建
- 支持滑动删除

**Tab 2: 节假日日历**
- 月视图日历，左右滑动切换月份
- 法定假日红色标记，调休上班日绿色标记
- 底部图例说明
- 显示上次同步时间

**Tab 3: 铃声管理**
- 分组列表：内置铃声、本地文件、录音
- 每项支持试听播放
- 从文件导入按钮、录制新铃声按钮
- 支持删除非内置铃声

**Tab 4: 设置**
- 节假日数据手动刷新
- 默认铃声选择
- 贪睡间隔设置
- 关于页面

### 闹钟创建/编辑页面

- 时间选择器
- 名称输入
- 重复规则选择：仅一次 / 每天 / 工作日 / 自定义周几
- 铃声选择（展开铃声列表）
- 贪睡开关

## 铃声系统

### 三种来源

1. **内置铃声**：App 打包自带 5-8 个，存放于 assets/ringtones/
2. **本地文件**：通过 file_picker 导入 mp3/m4a/wav，复制到 app 私有目录
3. **录音**：内建录音器，最长 60 秒，存储到 app 私有目录

### 录音功能

- 简单录音界面：麦克风图标 + 计时器 + 停止按钮
- 最长录制 60 秒
- 录制完成后命名保存

## 节假日 API

使用 timor.tech 公开节假日 API：
- API：`https://timor.tech/api/holiday/year/{year}`
- 响应格式：`{ code: 0, holiday: { "01-01": { holiday: true, name: "元旦" }, "05-01": { holiday: true, name: "劳动节" }, ... } }`
- 解析逻辑：`holiday: true` → 放假；`holiday: false` → 调休上班；无记录 → 普通日
- 缓存策略：请求成功写入 SQLite，失败使用本地缓存
- 降级：如果本地无缓存且 API 不可用，按基础规则响铃（工作日正常响）
- 自动更新：App 启动时检查缓存年份，如当前年份无缓存则自动拉取

## 非功能性需求

- 闹钟触发可靠性：使用系统级闹钟 API，保证 App 后台或被杀死时也能触发
- 权限：通知权限（必需）、麦克风权限（录音时请求）、文件访问权限（导入铃声时请求）
- 本地化：简体中文
- 最低版本：iOS 13+ / Android 8+
