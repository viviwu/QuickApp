import QtQuick
import QtQuick.Controls
import QuickApp

// 登录成功后展示的主界面。目前只是个占位骨架，
// 真实业务页面（列表、Tab、导航等）从这里往下搭。
Item {
    id: root

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "欢迎，" + AppController.currentUser
            font.pixelSize: 22
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            text: "退出登录"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: AppController.logout()
        }
    }
}
