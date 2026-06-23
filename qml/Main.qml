import QtQuick
import QtQuick.Window
import QuickApp

Window {
    id: window
    width: 360
    height: 480
    visible: true
    title: "QuickApp"

    // 整个 App 只有一个状态开关：AppController.loggedIn。
    // Loader 负责按这个开关在 LoginDialog / MainWindow 之间切换，
    // 两个页面互不知道对方存在，状态完全由 C++ 端的 AppController 驱动。
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
