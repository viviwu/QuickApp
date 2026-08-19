# QuickApp 教学 Demo

一个基于 **Qt Quick (QML) + C++** 的微信风格登录/好友列表小应用，用来演示 Qt Quick UI 框架的常见用法，以及 QML 与 C++ 组合开发时的分层思路。

## 演示了什么功能

登录成功后进入主界面，体验完整的"登录 → 列表 → 详情"流程：

1. **邮箱格式校验**：登录框用 `RegularExpressionValidator` 校验邮箱格式，非法时文本框变红、登录按钮不可点。
2. **登录失败次数 + 红色闪烁**：每次登录失败，`AppController.loginErrorCount` 自增；错误次数 Label 和错误信息变红并保持 5 秒后恢复（`SequentialAnimation`）。
3. **使用时长 + 休息提醒**：进入主界面即开始计时（`UsageTracker` 单例），每次达到休息阈值（默认 300s，即 5 分钟）发出 `restReminderTriggered` 事件，主界面弹窗提醒用户休息。
4. **好友列表 + 详情页**：`ListView + FriendsModel（QAbstractListModel）`展示好友，点击行通过 `StackView` push 进详情页；详情页用 `RowLayout` / `ColumnLayout` 摆放头像、三张统计卡片和简介。

## 技术要点

### 1. Qt Quick 常用控件与布局

- `TextField` / `Button` / `Label` / `Popup` / `StackView` / `ListView`（`QtQuick.Controls`）
- `Row` / `Column`（锚定布局）与 `RowLayout` / `ColumnLayout`（`QtQuick.Layouts`）
- `Loader` 按状态切换页面、`Connections` 监听 C++ 信号、`Component` 延迟实例化
- `SequentialAnimation` / `ColorAnimation` / `PauseAnimation` 做闪烁提醒
- QML 单文件类型注册规则：`qt_add_qml_module` 下大写开头的文件名（如 `FriendDetail.qml`）会被当作可导入类型，供 `StackView.push()` 使用

### 2. QML 与 C++ 的组合方式

- **类型注册**：C++ 类用 `QML_ELEMENT` / `QML_SINGLETON` 宏注册进 `QuickApp` 模块，QML 端直接 `import QuickApp` 使用，无需手动 `setContextProperty`。
- **双向通信**：
  - C++ → QML：`Q_PROPERTY`（持续状态：`loggedIn`、`elapsedSeconds`、`loginErrorCount`）与 `signal`（一次性事件：`loginFailed`、`restReminderTriggered`）。
  - QML → C++：`Q_INVOKABLE` 方法（`login()`、`logout()`、`start()`）。
- **分层边界**：QML 只做展示与交互，业务状态全在 C++ 端（`AppController` 是唯一入口，`AuthService` 封装"发起登录"本身，`FriendsModel` 提供数据）。C++ 不直接操作 QML 控件，通过信号反向通知，保证 UI 层可整体替换。

### 3. 值得注意的设计细节

- **校验分层**：邮箱"格式"校验属于纯 UI 层用 JS 正则完成；"账号是否有效"则走 C++ `AuthService.login()`，两者边界清晰。
- **事件 vs 状态**：同一次登录失败场景故意同时演示两种机制——错误次数是持续状态（property，绑定文本），"刚刚失败了一次去闪一下"是一次性事件（signal，触发动画）。同一错误信息连续出现时用 signal 比 property 变化更可靠。
- **独立计时器**：休息提醒单独建 `UsageTracker` 而不是塞进 `AppController`，与登录状态解耦，任何页面都能 `import QuickApp` 拿到同一个单例。
- **返回导航**：`FriendDetail` 用 attached property `StackView.view.pop()`，页面知道自己在哪个导航容器里，等价于 UIKit 的 `navigationController?.popViewController()`。

## 构建与运行

```bash
cmake -S . -B build
cmake --build build
./build/QuickApp.app/Contents/MacOS/QuickApp
```

- 演示账号：任意邮箱 + 密码 `1234`。
- 快速验证休息提醒：把 `MainWindow.qml` 里 `Component.onCompleted` 的 `UsageTracker.restThresholdSeconds` 临时调小（如 8 秒）。

## 目录结构

```
appcontroller.{h,cpp}    // 业务层唯一入口：登录/登出状态、错误计数
authservice.{h,cpp}      // 模拟异步登录请求
usagetracker.{h,cpp}     // 使用时长计时 + 休息提醒事件
friendsmodel.{h,cpp}     // 好友列表数据模型（QAbstractListModel）
qml/Main.qml             // 窗口 + Loader 状态切换
qml/LoginDialog.qml      // 邮箱校验 + 错误闪烁
qml/MainWindow.qml       // StackView + 好友列表 + 休息提醒
qml/FriendDetail.qml     // 详情页（RowLayout/ColumnLayout）
```