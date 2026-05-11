# 智能闹钟

一款跨平台移动闹钟应用，解决 iOS 自带闹钟的痛点：无法设置仅工作日响铃、法定节假日和调休需手动调整、铃声选择有限。

## 功能

- **工作日闹钟**：设置仅周一至周五响铃，周末自动跳过
- **中国节假日适配**：自动获取国务院节假日安排，法定假日不响、调休上班日正常响
- **自定义铃声**：内置精选铃声 + 从手机导入本地音频文件 + 内建录音功能
- **节假日日历**：月视图展示放假/调休标记，一目了然
- **两级决策引擎**：基础规则（工作日/每天/自定义周几）→ 节假日覆盖（放假跳过/调休执行）

## 技术栈

| 层级 | 选型 |
|------|------|
| 框架 | Flutter 3.41+ (Dart) |
| 本地存储 | sqflite (SQLite) |
| 闹钟调度 | flutter_local_notifications |
| 音频播放 | audioplayers |
| 录音 | record |
| 文件选择 | file_picker |
| 节假日数据 | timor.tech API |

## 项目结构

```
lib/
├── main.dart              # 入口
├── app.dart               # Material 3 主题配置
├── models/
│   ├── alarm.dart         # 闹钟数据模型
│   └── holiday_cache.dart # 节假日缓存模型
├── engine/
│   └── alarm_engine.dart  # 两级决策引擎
├── services/
│   ├── database_service.dart  # SQLite CRUD
│   ├── holiday_service.dart   # 节假日 API + 缓存
│   ├── alarm_scheduler.dart   # 系统闹钟调度
│   ├── ringtone_service.dart  # 铃声文件管理
│   └── audio_service.dart     # 音频播放 + 录音
├── screens/
│   ├── home_screen.dart       # 主页面（4 Tab）
│   ├── alarm_edit_page.dart   # 闹钟创建/编辑
│   ├── holiday_calendar_page.dart  # 节假日日历
│   ├── ringtone_manage_page.dart   # 铃声管理
│   ├── record_page.dart       # 录音页面
│   └── settings_page.dart     # 设置
└── widgets/
    ├── alarm_card.dart        # 闹钟列表项
    ├── calendar_widget.dart   # 月历组件
    ├── day_of_week_picker.dart # 周几选择器
    └── ringtone_picker.dart   # 铃声选择器
```

## 闹钟决策逻辑

```
闹钟触发时间到
  │
  ├─ 第一级：重复规则匹配
  │   今天周几？是否匹配规则？
  │   规则 = 工作日 → 周一~五 ✓，周六日 ✗
  │
  └─ 第二级：节假日覆盖
      今天 ∈ 调休上班日 → 响
      今天 ∈ 法定假日   → 不响
      否则保持第一级判断

优先级：调休上班 > 法定放假 > 基础规则
```

## 开始开发

### 前置条件

- Flutter SDK 3.0+
- iOS: Xcode 15+ / Android: Android Studio
- macOS 26 用户注意：需要安装完整 Xcode（非仅 Command Line Tools），否则 `flutter test` 会因为 `objective_c` 包的 native build 问题而失败

### 安装

```bash
git clone git@github.com:BakerYoung/alarm_clock.git
cd alarm_clock
flutter pub get
```

### 运行

```bash
# 分析代码
flutter analyze

# 运行测试
flutter test

# 启动应用
flutter run
```

## License

MIT
