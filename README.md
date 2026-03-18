# 轻氧天气 (Pure Weather)

一款使用 Flutter 和 Material You Design 构建的现代化跨平台天气应用。

（100%AI生成代码，绝无手写，性能烂的一批，没见过💩的一定要试试）

（最近换用CodeX5.3进行了大量的重构，UI一致性基本已经全部解决）

## 预览

![轻氧天气应用界面](IMG_20260218_101010.jpg)

## 特性

- **多数据源天气** - 和风天气 + 彩云天气 + 高德地图
- **Material You 设计** - 动态主题色，深色/浅色主题
- **城市管理** - 多城市支持，拖拽排序，定位服务
- **天气详情** - 实时温度、小时/七日预报、空气质量、天气预警、生活指数
- **天气助手** - 基于 DeepSeek API 的智能问答

## 平台支持

- ✅ Android (arm64-v8a, armeabi-v7a, x86_64)
- ✅ Windows
- ✅ Web
- ⚠️ iOS / macOS / Linux (可构建，未经测试)

## 快速开始

### 环境准备

```bash
# 克隆项目
git clone https://github.com/EchoRan6319/PureWeather.git
cd PureWeather

# 获取依赖
flutter pub get
```

### API 配置

在项目根目录创建 `.env` 文件：

```env
QWEATHER_API_KEY=your_qweather_api_key
CAIYUN_API_KEY=your_caiyun_api_key
AMAP_API_KEY=your_amap_api_key
AMAP_WEB_KEY=your_amap_web_key
DEEPSEEK_API_KEY=your_deepseek_api_key  # 可选
```

### 运行项目

```bash
# Android
flutter run

# Windows
flutter run -d windows

# Web
flutter run -d web
```

### 正式版 / 调试版（Flavors）

#### 构建验证（已通过）

- 调试版 APK：`app-debugedition-debug.apk`
- 正式版 APK：`app-prod-debug.apk`
- 合并清单验证通过：
  - 调试版 `AndroidManifest.xml`：line 3（`package`）/ line 52（`android:label`）
  - 正式版 `AndroidManifest.xml`：line 3（`package`）/ line 52（`android:label`）
- `flutter analyze` 已通过

#### 使用方式

```bash
# 运行正式版
flutter run --flavor prod -t lib/main.dart

# 运行调试版
flutter run --flavor debugEdition -t lib/main.dart

# 打正式版包
flutter build apk --release --flavor prod -t lib/main.dart

# 打调试版包
flutter build apk --release --flavor debugEdition -t lib/main.dart
```

### 构建发布版

```bash
# Android (arm64)
flutter build apk --release --flavor prod --target-platform=android-arm64

# Android (arm32)
flutter build apk --release --flavor prod --target-platform=android-arm

# Android (x86_64，模拟器)
flutter build apk --release --flavor prod --target-platform=android-x64

# Windows
flutter build windows --release

# Web
flutter build web --release
```

## 绕过 ColorOS 动态取色限制

ColorOS 系统在默认设置下限制了第三方应用获取动态主题色，本应用通过以下方式绕过：

### 实现原理

在 `lib/main.dart` 中，直接通过原生方法获取壁纸颜色，而非使用系统提供的动态颜色 API：

```dart
// 绕过 ColorOS 限制，直接获取壁纸颜色
Future<ColorScheme> _getBypassedColorScheme() async {
  // 尝试通过原生渠道获取壁纸主色调
  final wallpaperColor = await _getWallpaperColor();
  if (wallpaperColor != null) {
    return ColorScheme.fromSeed(
      seedColor: wallpaperColor,
      brightness: brightness,
    );
  }
  // 降级使用默认颜色
  return _getDefaultColorScheme(brightness);
}
```

### 技术细节

1. **原生方法调用** - 使用 Platform Channel 直接调用 Android 原生 Wallpaper API
2. **颜色提取** - 从壁纸位图中提取主色调和强调色
3. **动态适配** - 根据提取的颜色生成 Material You 风格的 ColorScheme

## 许可证

MIT License
