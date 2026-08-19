import QtQuick

// ======================= Avatar：可复用圆形头像组件 =======================
// 对应 QtWidgets 里"继承 QWidget 做自定义控件"。
// QML 的做法是写一个 .qml 文件（文件名即类型名，首字母大写），
// 对外暴露 property / signal，内部封装布局与细节。
// 之前 MainWindow 的好友行、FriendDetail 详情页里各写了一份几乎一样的
// 圆形头像代码，现在抽成组件，两处复用——这就是"组件化"的第一步。
Rectangle {
    id: avatar

    // ---- 对外属性（父组件通过属性定制）----
    property string name: ""            // 显示首字
    property color  bgColor: "#64b5f6"  // 背景色（注意：Rectangle 自带 color，别重名，所以叫 bgColor）
    property int    size: 36            // 直径
    property string status: "在线"       // 在线/忙碌/离开/离线 → 右下角小圆点颜色

    // ---- 对外信号（对应自定义控件信号，父组件用 onClicked 接）----
    signal clicked()

    width: size
    height: size
    radius: size / 2
    color: avatar.bgColor

    // 首字
    Text {
        anchors.centerIn: parent
        text: avatar.name.length ? avatar.name.charAt(0) : "?"
        color: "white"
        font.pixelSize: avatar.size * 0.5   // 字号随组件尺寸缩放，封装内部细节
        font.bold: true
    }

    // 在线状态小圆点：status → 颜色的映射用一条绑定表达，等价 if/else 但更声明式
    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: avatar.size * 0.3
        height: avatar.size * 0.3
        radius: width / 2
        border.color: "white"
        border.width: 1.5
        color: {
            switch (avatar.status) {
            case "忙碌": return "#f59e0b"
            case "离开": return "#64748b"
            case "离线": return "#94a3b8"
            default:     return "#22c55e"   // 在线
            }
        }
    }

    // 点击整颗头像发 clicked 信号（教学点：组件内部完成交互，把"发生了什么"对外广播）
    MouseArea {
        anchors.fill: parent
        onClicked: avatar.clicked()
    }
}
