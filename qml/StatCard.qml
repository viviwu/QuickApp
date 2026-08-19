import QtQuick
import QtQuick.Layouts

// ======================= StatCard：可复用统计卡片 =======================
// 把 FriendDetail 里三张"标题 + 数字"卡片抽成组件。
// 教学点：组件参数化（property）+ 声明式布局，界面元素可以像积木一样复用。
Rectangle {
    id: card

    // ---- 对外属性 ----
    property string title: ""
    property string value: ""
    property color  accent: "#333333"

    Layout.fillWidth: true
    Layout.preferredHeight: 72
    radius: 8
    color: "#f5f7fa"
    border.color: "#e3e7ec"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 4

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: card.title
            font.pixelSize: 12
            color: "#888888"
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: card.value
            font.pixelSize: 18
            font.bold: true
            color: card.accent
        }
    }
}
