# QuickApp

一个基于 **Qt Quick (QML) + C++** 的教学 demo：登录 → 好友列表 → 好友详情。
面向**熟悉 QtWidgets C++、想上手 Qt Quick 这套 UI 框架**的开发者，重点讲清 Qt Quick / QuickControls2 / JS 这套 UI 层怎么用、以及它和 C++ 业务/数据层怎么组合。Qt base 和 C++ 本身不是重点。

## 从 QtWidgets 到 Qt Quick

| QtWidgets | Qt Quick (QML) |
|---|---|
| `QWidget` + `.ui` 文件 | `Window` / `Item` + `.qml` 文件 |
| `QPushButton` / `QLineEdit` / `QLabel` | `Button` / `TextField` / `Text` |
| `QHBoxLayout` / `QVBoxLayout` | `RowLayout` / `ColumnLayout`（或 `anchors`）|
| `QListView` + `QAbstractListModel` | `ListView` + `QAbstractListModel` |
| `QStackedWidget` 切换页面 | `StackView`（push/pop）|
| `QDialog` / 模态框 | `Popup` / `Dialog` |
| `QTimer` | `Timer` |
| `connect(信号, 槽)` | 属性绑定 / `Connections` / `onXxx()` |

### 关键心法（和写 Widgets 最大的不同）

- **声明式**：QML 只描述"界面长什么样"，不写"先做什么再做什么"的命令序列；布局、绑定、动画都由框架帮你维护。
- **JS 只做视图逻辑**：在 `.qml` 里用 JS 处理交互、格式校验这类纯 UI 的事，不碰业务状态。
- **业务状态放 C++**：QML 只负责读 `Q_PROPERTY`、调 `Q_INVOKABLE`。
- **C++ 不直接操作控件**：状态变了就发 `signal`，由 QML 自己响应，UI 层整体可替换。

## 本项目演示的功能

- **邮箱格式校验**：`RegularExpressionValidator` 实时校验，非法时输入框变红、登录按钮禁用
- **登录失败反馈**：错误次数自增，仅出错时红字显示、5 秒后消失（`Timer`）
- **使用时长 & 休息提醒**：`UsageTracker` 计时，每 5 分钟发 `restReminderTriggered` 事件，主界面弹 `Popup` 提醒
- **好友列表 & 详情页**：`ListView` 展示好友，点击行 `StackView` push 进详情页

## 架构：Qt Quick UI + C++ 业务/数据层

```
┌───────────────────────────── QML（薄，只管显示与交互）─────────────────────────────┐
│ Main.qml → LoginDialog / MainWindow(StackView → FriendDetail)                  │
│ 控件: Button/TextField/ListView/Popup/StackView/RowLayout…  JS: 正则校验等        │
└──────────────▲──────────────────────────────────────────────▲──────────────────┘
      import QuickApp（读 Q_PROPERTY / 调 Q_INVOKABLE / 接 signal）
┌──────────────┴─────────── C++（厚，业务与数据）────────────────┴──────────────────┐
│ AppController(QML_SINGLETON)  唯一入口，登录状态/错误计数/记住用户名                │
│ ├─ AuthService                模拟异步登录请求（信号返回结果）                    │
│ ├─ UsageTracker               使用时长 + 休息提醒信号                            │
│ └─ FriendsModel(QAbstractListModel)  好友数据（roles 暴露给 QML）                │
└──────────────────────────────────────────────────────────────────────────────────┘
```

## QML 与 C++ 通信三板斧

1. **`Q_PROPERTY` — 持续状态**：QML 里直接双向绑定。如 `loggedIn`、`loginErrorCount`、`elapsedSeconds`。只在状态**变化**时发 `*Changed` 信号，同一个值不重复触发。
2. **`signal` — 一次性事件**：QML 用 `Connections { target: ... }` 或 `onXxx()` 接。如 `loginFailed`、`restReminderTriggered`。同一原因连续发生也能每次触发，比"属性变化"可靠。
3. **`Q_INVOKABLE` — QML 调 C++ 方法**：如 `AppController.login()`、`UsageTracker.start()`。

注册：C++ 类加 `QML_ELEMENT`（普通类型）或 `QML_SINGLETON`（全局单例），配合 `qt_add_qml_module`，QML 端 `import QuickApp` 直接用，**不需要** `setContextProperty`。

## 布局：anchors vs Layout

- `Row` / `Column` + `anchors`：类似手算几何 + 简单排布，适合居中小场景（`anchors.centerIn`）。
- `RowLayout` / `ColumnLayout`：等价 `QHBoxLayout` / `QVBoxLayout`，靠 `Layout.fillWidth`、`Layout.preferredWidth/Height`、`spacing` 约束，适合复杂页面（详情页三张统计卡片）。
- 布局内元素用 `Item { Layout.fillWidth: true }` 做弹性占位（类似 `addStretch()`）。

## 模型视图：ListView + QAbstractListModel

- C++ 侧 `QAbstractListModel` 里用 `roleNames()` 注册角色名（`name`/`status`/`avatarColor`/`bio`）。
- QML 侧 `ListView { model: FriendsModel {} }`，delegate 里声明 `required property string name` 即可按角色取值。
- 点击行用 `StackView.push("FriendDetail.qml", {...})` 传参；详情页返回用 attached property `StackView.view.pop()`——页面自己知道在哪个导航容器里，等价 `navigationController?.popViewController()`。

## 注意点 / 坑

1. **`Loader` 切 `sourceComponent` 会销毁旧页面**：退回登录页时输入框被清空。要跨页面保留的状态（如"记住用户名"）放 C++（`AppController.lastUsername`），页面 `Component.onCompleted` 时回填。
2. **macOS 原生样式忽略自定义控件外观**：给 `TextField` 设自定义 `background` 不生效，`main.cpp` 里 `QQuickStyle::setStyle("Fusion")`。
3. **Fusion 的 `Dialog` 自定义 `contentItem` 有 `implicitWidth` 绑定环**：需要自定义内容时改用 `Popup`。
4. **大写开头的 `.qml` 文件会被当作可导入类型**：`FriendDetail.qml` 因此能被 `StackView.push` 引用。
5. **校验分层**：格式校验（长得像不像邮箱）是纯 UI 事，用 JS 正则；账号有效性才是 C++ 服务的职责。
6. **事件 vs 状态**：错误**次数**是状态用 property，错误"刚才发生了一次要闪一下"是事件用 signal。

## 构建与运行

```bash
cmake -S . -B build
cmake --build build
./build/QuickApp.app/Contents/MacOS/QuickApp   # macOS
# 或 ./build/QuickApp                          # Linux / Windows
```

> 演示账号：任意邮箱 + 密码 `1234`。环境要求：CMake ≥ 3.16、Qt ≥ 6.8（Quick + QuickControls2）。

快速验证休息提醒：把 `MainWindow.qml` 里 `Component.onCompleted` 的 `UsageTracker.restThresholdSeconds` 临时调小（如 8 秒）。

## 目录结构

```
appcontroller.{h,cpp}    // 业务层唯一入口：登录/登出状态、错误计数、记住用户名
authservice.{h,cpp}      // 模拟异步登录请求
usagetracker.{h,cpp}     // 使用时长计时 + 休息提醒事件
friendsmodel.{h,cpp}     // 好友列表数据模型（QAbstractListModel）
qml/Main.qml             // 窗口 + Loader 状态切换（登录/主界面尺寸不同）
qml/LoginDialog.qml      // 邮箱校验 + 错误提示
qml/MainWindow.qml       // StackView + 好友列表 + 休息提醒
qml/FriendDetail.qml     // 好友详情页（RowLayout/ColumnLayout）
```