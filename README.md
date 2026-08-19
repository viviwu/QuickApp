# QuickApp

一个基于 **Qt Quick (QML) + C++** 的微信风格教学 demo：登录 → 好友列表 → 好友详情，演示 Qt Quick UI 框架的常见用法，以及 QML 与 C++ 组合开发时的分层思路。

## 功能

- **邮箱格式校验**：登录框实时校验邮箱格式，非法时变红并禁用登录按钮
- **登录失败反馈**：记录错误次数，失败时错误信息变红并保持 5 秒（`SequentialAnimation` 闪烁）
- **使用时长 & 休息提醒**：进入主界面开始计时，每达到 5 分钟弹窗提醒休息
- **好友列表 & 详情页**：`ListView + QAbstractListModel` 展示好友，点击行 `StackView` 进入详情页

## 技术要点

- **QML 与 C++ 类型注册**：`QML_ELEMENT` / `QML_SINGLETON` 把 C++ 类注册进 `QuickApp` 模块，QML 端 `import QuickApp` 即可使用
- **双向通信**：`Q_PROPERTY`（持续状态）+ `signal`（一次性事件）+ `Q_INVOKABLE`（QML 调 C++）
- **布局与控件**：`Row/Column`、`RowLayout/ColumnLayout`、`StackView`、`ListView`、`Popup`、`Connections`、`SequentialAnimation`
- **分层边界**：QML 只做展示与交互，业务状态全在 C++ 端；C++ 不直接操作 QML 控件，通过信号反向通知

详细说明见 [intro.md](intro.md)。

## 环境要求

- CMake ≥ 3.16
- Qt ≥ 6.8（含 Quick、QuickControls2）

## 构建与运行

```bash
cmake -S . -B build
cmake --build build
./build/QuickApp.app/Contents/MacOS/QuickApp   # macOS
# 或 ./build/QuickApp                          # Linux / Windows
```

> 演示账号：任意邮箱 + 密码 `1234`。

## 目录结构

```
appcontroller.{h,cpp}    // 业务层唯一入口：登录/登出状态、错误计数
authservice.{h,cpp}      // 模拟异步登录请求
usagetracker.{h,cpp}     // 使用时长计时 + 休息提醒事件
friendsmodel.{h,cpp}     // 好友列表数据模型（QAbstractListModel）
qml/Main.qml             // 窗口 + Loader 状态切换（登录页/主界面尺寸不同）
qml/LoginDialog.qml      // 邮箱校验 + 错误闪烁
qml/MainWindow.qml       // StackView + 好友列表 + 休息提醒
qml/FriendDetail.qml     // 好友详情页（RowLayout/ColumnLayout）
```