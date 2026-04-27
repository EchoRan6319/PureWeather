# ☁️ 轻氧天气 (PureWeather)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Web-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.41+-02569B?logo=flutter)

一款使用 **Material You Design** 构建的现代化跨平台天气应用，支持动态主题色、多城市管理和 AI 天气助手。

## 预览

![轻氧天气应用界面](IMG_20260218_101010.jpg)

## 功能特性

- **🌤 多源天气数据** — 和风天气（实时/逐时/逐日/预警/空气质量）+ 彩云天气（分钟级降水预报）
- **🎨 Material You** — 动态取色、深色/浅色主题、AMOLED 纯黑模式、自定义主题色
- **📍 城市管理** — 多城市支持、拖拽排序、自动定位、城市搜索
- **📊 天气详情** — 当前温度、24 小时预报、7 日预报、空气质量、生活指数、天气预警
- **🤖 天气助手** — 基于 DeepSeek V4 的智能问答，支持天气分析与建议
- **🔔 定时播报** — 每日早晚天气推送，Android 16+ 支持实时更新通知
- **🔗 多平台支持** — Android、Windows、Web

## 平台支持

| 平台 | 状态 |
|------|------|
| Android | ✅ 已测试（arm64-v8a / armeabi-v7a / x86_64） |
| Windows | ✅ 已测试 |
| Web | ✅ 已测试 |
| iOS | ⚠️ 可构建，未经全面测试 |
| macOS | ⚠️ 可构建，未经全面测试 |
| Linux | ⚠️ 可构建，未经全面测试 |

---

## 快速开始

### 环境要求

- Flutter SDK >= 3.41
- Android Studio 或 VS Code

```bash
# 克隆项目
git clone https://github.com/EchoRan6319/PureWeather.git
cd PureWeather

# 获取依赖
flutter pub get
```

### 配置 API

在项目根目录创建 `.env` 文件：

```env
QWEATHER_API_KEY=你的和风天气API密钥
CAIYUN_API_KEY=你的彩云天气API密钥
AMAP_API_KEY=你的高德地图API密钥
AMAP_WEB_KEY=你的高德Web端API密钥
DEEPSEEK_API_KEY=你的DeepSeek API密钥
```

> **提示**：API 密钥也可以通过 `--dart-define` 或环境变量传入，详见 [API 配置](/lib/core/constants/api_config.dart)。

### 运行

```bash
# Android
flutter run

# Windows
flutter run -d windows

# Web
flutter run -d web
```

> 调试版使用 `applicationId` 后缀 `.debug`，可与正式版同时安装在手机上互不冲突。

---

## 构建

### Android

```bash
# 通用 APK（包含所有架构）
flutter build apk --release

# 按架构拆分（推荐正式版使用）
flutter build apk --release --split-per-abi

# 调试版 APK
flutter build apk --debug

# 安装到设备
flutter install
```

输出文件：
```
build/app/outputs/flutter-apk/
├── app-release.apk                # 通用包（所有架构）
├── app-arm64-v8a-release.apk      # 拆分包：现代设备
├── app-armeabi-v7a-release.apk    # 拆分包：老旧设备
├── app-x86_64-release.apk         # 拆分包：模拟器
└── app-debug.apk                  # 调试包（未签名）
```

> **提示**：使用 `--split-per-abi` 可大幅减小 APK 体积（arm64-v8a 约 22MB vs 通用包 56MB）。

### Windows

```bash
flutter build windows --release
```

### Web

```bash
flutter build web --release
```

### 自动版本号

使用 `build_with_version.bat` 自动从 Git 标签同步版本号：

```bash
build_with_version.bat --release --split-per-abi
```

---

## 项目结构

```
lib/
├── core/                   # 常量、主题、工具
│   ├── constants/
│   └── theme/
├── models/                 # 数据模型（freezed）
│   └── weather_models.dart
├── providers/              # Riverpod 状态管理
│   ├── weather_provider.dart
│   ├── city_provider.dart
│   ├── settings_provider.dart
│   └── theme_provider.dart
├── services/               # API 及系统服务
│   ├── qweather_service.dart         # 和风天气
│   ├── caiyun_service.dart           # 彩云天气
│   ├── location_service.dart         # 高德定位
│   ├── deepseek_service.dart         # AI 助手
│   ├── notification_service.dart
│   └── scheduled_broadcast_service.dart
├── screens/                # 页面
│   ├── weather/
│   ├── settings/
│   ├── ai_assistant/
│   └── city_management/
└── widgets/                # 可复用组件
```

### 状态管理

使用 **Riverpod** 进行状态管理，`StateNotifierProvider` 处理可变状态，`FutureProvider` 处理异步数据。

### 数据流

```
用户操作 → Riverpod Provider → Service (Dio) → 外部 API
                 ↓
         UI 通过 ref.watch() 自动更新
```

---

## 技术栈

| 类别 | 选型 |
|------|------|
| 框架 | Flutter 3.41+ |
| 状态管理 | Riverpod 2.x |
| 数据模型 | Freezed + json_serializable |
| 网络请求 | Dio |
| 通知 | flutter_local_notifications |
| 本地存储 | SharedPreferences |
| 主题 | dynamic_color（Material You） |
| AI | DeepSeek V4（OpenAI 兼容接口） |

## 绕过 ColorOS 动态取色限制

ColorOS 系统限制了第三方应用获取 Material You 动态颜色。本应用通过 **Platform Channel** 直接调用 Android 原生壁纸 API 绕过此限制：

- `MethodChannel('com.echoran.pureweather/wallpaper')`
- 不支持时自动降级到预设颜色
- 详见 [main.dart](/lib/main.dart)

---

## 开源协议

[MIT](LICENSE) © EchoRan
