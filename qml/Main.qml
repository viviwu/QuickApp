import QtQuick
import QtQuick.Window
import QuickApp

Window {
    id: window

    // 不同页面使用不同的窗口尺寸：登录页小一点，主界面大一点。
    // 绑定到 AppController.loggedIn，切换页面时窗口自动缩放到对应大小。
    property int loginWidth: 360
    property int loginHeight: 320
    property int mainWidth: 640
    property int mainHeight: 480

    width: AppController.loggedIn ? mainWidth : loginWidth
    height: AppController.loggedIn ? mainHeight : loginHeight

    visible: true
    title: "QuickApp"

    // 窗口缩放做平滑动画，而不是瞬间跳变
    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

    // 整个 App 只有一个状态开关：AppController.loggedIn。
    // Loader 负责按这个开关在 LoginDialog / MainWindow 之间切换，
    // 两个页面互不知道对方存在，状态完全由 C++ 端的 AppController 驱动。
    // 注意：切换 sourceComponent 会销毁旧实例，LoginDialog 每次都是新建的，
    // 所以用户名这类"要记住"的状态由 C++ 端 AppController.lastUsername 保存，
    // LoginDialog 在 onCompleted 里读回来回填。
    Loader {
        anchors.fill: parent
        sourceComponent: AppController.loggedIn ? mainWindowComponent : loginDialogComponent
    }

    Component {
        id: loginDialogComponent
        LoginDialog {}
    }

    Component {
        id: mainWindowComponent
        MainWindow {}
    }
}
