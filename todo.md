```aiexclude
能否在前面登录demo QuickApp的基础上添加东西？结合你上面提到的，比如：LoginDialog中验证用户名格式为邮箱；添加一个Label记录并提醒登录错误次数（登录错误变红色5秒钟Animation）；记录App使用时间，超过5分钟，发生自定义事件信号，MainWindow中提醒用户休息；MainWindow中展示好友列表ListView，点击查看好友详情页（多个Rectangle 使用`RowLayout`/`ColumnLayout `布局约束）。
```

先看一下之前项目目录的状态,确认我要在哪个版本上加东西(包括你后来改的文件名和 CMakeLists):在这个基础上加东西。先做几件同步的事:把 `qml/main.qml` 改成你本地实际的 `Main.qml`,并把你贴的 `CMakeLists.txt`(bundle 属性、显式 `target_link_libraries`)同步过来,再叠加新功能。

四个新功能拆成这些改动:

| 需求 | 落在哪层 | 用到的机制 |
|---|---|---|
| 邮箱格式校验 | QML(纯视图层) | JS 正则,不碰 C++ |
| 登录错误次数 + 红色闪烁5秒 | C++ 计数 + QML 动画 | `Q_PROPERTY` + `SequentialAnimation` |
| 使用时长超5分钟提醒 | 新建 C++ `UsageTracker` | `QTimer` + 自定义信号 |
| 好友列表 + 详情页 | 新建 C++ `FriendsModel` + QML `StackView` | `QAbstractListModel` + `RowLayout`/`ColumnLayout` |

先处理文件改名和 CMakeLists 同步:**第一步:`UsageTracker`(使用时长追踪 + 休息提醒)****第二步:`FriendsModel`(好友列表的 `QAbstractListModel`)****第三步:给 `AppController` 加上登录错误次数计数**现在更新对应的 `.cpp`:**第四步:重写 `LoginDialog.qml`**——加邮箱格式校验 + 错误次数 Label + 红色闪烁动画:**第五步:`FriendDetail.qml`**——用 `RowLayout`/`ColumnLayout` 摆放多个 `Rectangle`,演示 Layout 约束:**第六步:重写 `MainWindow.qml`**——`StackView` 导航 + 好友 `ListView` + 使用时长提醒:**第七步:更新 `CMakeLists.txt`**——同步你贴的版本,加上新文件:**第八步:更新 `Main.qml`**——确认它正确通过 `import QuickApp` 拿到 `AppController`(没变化,这里只是确认没有需要改的地方):`Main.qml` 本身不用大改,但加了好友列表和详情页(尤其是详情页里三个并排的统计卡片)后,原来 360×480 的窗口有点局促,我把窗口尺寸适当放大一些:现在做一遍人工的静态检查——重点看头文件/实现是否一一对应,QML 里引用的类型名/属性名是否和 C++ 端一致,因为这个容器里没有 Qt 环境,**编译错误和 QML 运行时错误我都验证不了**,只能尽量靠人工核对降低风险:全部能对上:`busy` / `loggedIn` / `currentUser` / `loginErrorCount` / `login()` / `logout()` 对应 `appcontroller.h` 里的成员;`elapsedSeconds` / `start()` / `stop()` / `reset()` 对应 `usagetracker.h`;`model.name` / `status` / `avatarColor` / `bio` 对应 `friendsmodel.cpp` 里 `roleNames()` 注册的字符串。`loginFailed`、`restReminderTriggered` 两个信号在 `Connections` 里也各自对上了。再看一眼整体目录结构和 `qmldir` 预期会出现的内容:## 重要提醒:这部分我没法帮你跑起来验证

新加了 3 个 C++ 文件、改了 2 个、新建/重写了 3 个 QML 文件,涉及 `QAbstractListModel`、`StackView`、`SequentialAnimation` 这几个我们之前 demo 完全没碰过的新 API。我做了人工交叉核对(上面贴的那两次 grep)确认了所有跨语言的属性名/方法名/信号名能对上,但**这不等于编译能过或运行时行为正确**——比如 `roleNames()` 的 QML 端用法、`StackView.view` attached property 这些细节,我没有 Qt 环境能跑一次真实编译。建议你 `cmake --build` 之后,如果报错把日志贴给我,我们照着错误定位。

## 验证路径建议(按风险从低到高)

1. 先单独确认 `Q_PROPERTY`/`Q_INVOKABLE` 那些没有语法问题——这部分风险最低,和你已经跑通的版本是同一套写法。
2. 重点关注 `friendsmodel.cpp` 的 `data()`/`roleNames()`——`QAbstractListModel` 这套我没法运行验证,如果好友列表显示空白或报 "unable to resolve" 之类的错,先看这里。
3. `UsageTracker.restThresholdSeconds` 默认 300 秒,**建议你测试时先在 QML 里临时改小**(比如在 `MainWindow.qml` 的 `Component.onCompleted` 里加一行 `UsageTracker.restThresholdSeconds = 8`),不然要等 5 分钟才能看到提醒弹窗,验证周期太长。
4. `StackView`/`Dialog` 都来自 `QtQuick.Controls`,理论上不需要额外 `find_package`,但如果运行时找不到这些类型,检查一下你的 Qt 安装是否包含 Quick Controls 2 模块。

## 几个值得讲一下的设计点

**邮箱校验为什么只在 QML 做**——格式校验(是不是长得像邮箱)是纯 UI 层的事,不需要请求 C++;但"这个邮箱到底有没有注册"依然完全是 `AppController.login()` 之后的 C++ 职责。这条边界跟我们之前聊的"QML 逻辑要薄"是一回事。

**错误次数用 `Q_PROPERTY`,但错误提醒用 `signal`**——同一个 `loginFailed` 场景里,故意用了两种不同机制:次数是持续存在的状态(适合 property),"刚刚失败了一次,去闪一下"是一次性事件(适合 signal)。这俩在 `LoginDialog.qml` 里分别绑定文本和触发动画,是个对比着看会更清楚的例子。

**休息提醒为什么单独建 `UsageTracker` 而不是塞进 `AppController`**——它跟登录状态完全无关,独立出来意味着以后随便哪个页面都能 `import QuickApp` 拿到同一个计时器单例,不需要绕道 `AppController`。

**`StackView.view.pop()`**——`FriendDetail.qml` 的返回按钮没有显式拿到 `stackView` 的引用,而是用了 attached property `StackView.view`。这跟 UIKit 里 `self.navigationController?.popViewController()` 是同一个思路:被 push 进去的页面自己知道"我在哪个导航容器里"。

如果跑起来后某个具体功能报错或者行为不对,把报错/现象贴给我,我们一个个排查。