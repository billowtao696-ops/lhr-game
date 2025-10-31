# 🚀 Sky Defender - 天空守卫者打飞机游戏

一款使用 Flutter + Flame 引擎开发的竖屏射击游戏，支持 Web、Android、iOS 多平台运行。

![Flutter](https://img.shields.io/badge/Flutter-3.35.4-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)
![Flame](https://img.shields.io/badge/Flame-1.32.0-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 📱 游戏预览

### 游戏特色
- ☁️ **唯美蓝天白云背景** - 流动的云层营造真实飞行感
- ✈️ **灵活操控系统** - 键盘方向键控制，全屏自由飞行
- 💥 **自动射击系统** - 黄色子弹自动发射，每秒4发
- ⚡ **高难度挑战** - 双倍速敌机，密集弹幕攻击
- 🚀 **双重弹幕系统** - 粉红色高速火箭 + 橙色普通火箭
- 💣 **炸弹威胁** - 快速下落的炸弹，必须灵活躲避
- 🎯 **精准碰撞检测** - 优化的碰撞范围，公平的游戏体验
- 🏆 **计分系统** - 击毁敌机+2分，躲避炸弹+1分

## 🎮 游戏玩法

### 操作说明
| 按键 | 功能 |
|------|------|
| **↑** | 向上飞行 |
| **↓** | 向下飞行 |
| **←** | 向左飞行 |
| **→** | 向右飞行 |
| **组合键** | 同时按住多个方向键可斜向飞行 |

### 游戏目标
- 🎯 **消灭敌机**: 用子弹击落灰色敌机，每架+2分
- 🛡️ **躲避威胁**: 躲开炸弹和火箭，炸弹飞出屏幕+1分
- 📈 **生存挑战**: 尽可能长时间存活，获得高分

### 敌人类型
| 类型 | 外观 | 速度 | 威胁等级 | 得分 |
|------|------|------|----------|------|
| **灰色敌机** | ⬇️ 倒三角 | 200px/s | ⭐⭐⭐⭐ | +2分 |
| **黑色炸弹** | 💣 圆形+引信 | 200px/s | ⭐⭐⭐ | +1分 |
| **粉红色火箭** | 🚀 高速 | 300px/s | ⭐⭐⭐⭐⭐ | - |
| **橙色火箭** | 🔶 普通 | 150px/s | ⭐⭐⭐ | - |

### 难度特点
- ⚡ **敌机生成**: 每秒1架（高密度）
- 💥 **弹幕密度**: 每个敌机发射4枚火箭（其中2枚高速）
- 🎯 **碰撞判定**: 精准优化，距离<20像素触发
- 🚫 **炸弹特性**: 子弹无法击毁，只能躲避

## 🛠️ 技术栈

### 开发框架
- **Flutter 3.35.4** - Google跨平台UI框架
- **Dart 3.9.2** - 开发语言
- **Flame 1.32.0** - 2D游戏引擎

### 核心特性
- 🎨 **自定义Canvas渲染** - 高性能2D图形绘制
- ⚙️ **物理引擎** - 碰撞检测系统
- 🎮 **事件处理** - 键盘输入实时响应
- 🔄 **状态管理** - ValueNotifier响应式状态更新
- 📐 **动态适配** - 自适应不同屏幕尺寸

### 项目结构
```
lib/
├── main.dart                 # 主程序入口，UI界面
├── sky_defender_game.dart    # 游戏核心逻辑
│   ├── SkyDefenderGame      # 游戏主类
│   ├── PlayerPlane          # 玩家飞机组件
│   ├── EnemyPlane           # 敌机组件
│   ├── Rocket               # 火箭组件
│   ├── Bomb                 # 炸弹组件
│   ├── PlayerBullet         # 玩家子弹组件
│   └── Cloud                # 云朵背景组件
```

## 🚀 快速开始

### 环境要求
- Flutter SDK 3.35.4 或更高版本
- Dart SDK 3.9.2 或更高版本
- 支持的平台：Web、Android、iOS、Windows、macOS、Linux

### 安装步骤

1. **克隆仓库**
```bash
git clone https://github.com/billowtao696-ops/lhr-game.git
cd lhr-game
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行游戏**

**Web平台（推荐）：**
```bash
flutter run -d chrome
```

**Android平台：**
```bash
flutter run -d android
```

**构建发布版本：**
```bash
# Web
flutter build web --release

# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## 📦 依赖包

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flame: 1.32.0              # 2D游戏引擎

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## 🎯 核心算法

### 碰撞检测算法
```dart
void checkCollision(PositionComponent other) {
  if (isDead) return;
  
  final distance = position.distanceTo(other.position);
  if (distance < 20) {  // 优化后的碰撞范围
    isDead = true;
    game.gameOver();
  }
}
```

### 双速弹幕系统
```dart
class Rocket {
  final bool isHighSpeed;
  late final double speed = isHighSpeed ? 300.0 : 150.0;  // 高速2倍
}
```

### 自动射击系统
```dart
double bulletTimer = 0;
final double bulletInterval = 0.25;  // 每秒4发子弹

void update(double dt) {
  bulletTimer += dt;
  if (bulletTimer >= bulletInterval) {
    bulletTimer = 0;
    fireBullet();
  }
}
```

## 🎨 游戏设计

### 视觉设计
- **背景**: 天蓝色渐变 (#87CEEB → #E0F6FF)
- **玩家飞机**: 红色战机 (#E53935)，正三角形
- **敌机**: 灰色战机 (#607D8B)，倒三角形
- **高速火箭**: 粉红色 (#E91E63)
- **普通火箭**: 橙色 (#FF6F00)
- **炸弹**: 黑色圆形 + 红色引信
- **子弹**: 黄色椭圆 (#FFEB3B) + 光晕效果

### 游戏平衡性
- **敌机速度**: 200像素/秒（中高速）
- **玩家速度**: 250像素/秒（略快于敌机）
- **火箭速度**: 150-300像素/秒（双重威胁）
- **炸弹速度**: 200像素/秒（高速威胁）
- **子弹速度**: 400像素/秒（快速击杀）

## 📈 开发路线图

### 已完成功能 ✅
- [x] 基础游戏框架
- [x] 玩家飞机控制系统
- [x] 自动射击系统
- [x] 敌机生成和移动
- [x] 双重弹幕系统
- [x] 炸弹威胁
- [x] 碰撞检测系统
- [x] 计分系统
- [x] 游戏结束和重启
- [x] 蓝天白云背景
- [x] 全屏飞行支持

### 计划中功能 🔜
- [ ] 音效和背景音乐
- [ ] 道具系统（护盾、双倍火力等）
- [ ] Boss战
- [ ] 关卡系统
- [ ] 排行榜
- [ ] 多种飞机选择
- [ ] 成就系统
- [ ] 粒子特效
- [ ] 移动端触摸控制
- [ ] 游戏暂停功能

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 贡献步骤
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

### 开发规范
- 遵循 Dart 代码规范
- 使用 `flutter analyze` 检查代码
- 添加必要的注释和文档
- 确保测试通过

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 👨‍💻 作者

**billowtao696-ops**

- GitHub: [@billowtao696-ops](https://github.com/billowtao696-ops)
- 项目地址: [lhr-game](https://github.com/billowtao696-ops/lhr-game)

## 🙏 致谢

- [Flutter](https://flutter.dev/) - 优秀的跨平台框架
- [Flame Engine](https://flame-engine.org/) - 强大的2D游戏引擎
- 所有为本项目提供建议和帮助的开发者

## 📞 支持

如有问题或建议，请：
- 提交 [Issue](https://github.com/billowtao696-ops/lhr-game/issues)
- 参与 [Discussions](https://github.com/billowtao696-ops/lhr-game/discussions)

---

⭐ 如果这个项目对你有帮助，请给个 Star！

**享受游戏，挑战高分！** 🚀✈️🎮
