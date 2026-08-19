import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 好友详情页。由 MainWindow 的 StackView push 进来，
// 数据通过 push 时的 initialProperties 传递（friendName / friendStatus / friendAvatarColor / friendBio）。
// 返回按钮不显式拿 stackView 引用，而是用 attached property StackView.view.pop()。
Item {
    id: root

    property string friendName: "?"
    property string friendStatus: ""
    property string friendAvatarColor: "#999999"
    property string friendBio: "这个人很懒，什么都没写。"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // 顶部：返回 + 名字
        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "← 返回"
                onClicked: root.StackView.view.pop()
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "好友详情"
                font.pixelSize: 16
                color: "#888888"
            }
        }

        // 头部：头像 + 名字/状态。
        // 复用 Avatar 组件（和列表页同一份代码），用属性定制尺寸/状态。
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Avatar {
                name: root.friendName
                bgColor: root.friendAvatarColor
                status: root.friendStatus
                size: 64
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: root.friendName
                    font.pixelSize: 22
                    font.bold: true
                }

                Text {
                    text: root.friendStatus
                    font.pixelSize: 13
                    color: "#888888"
                }
            }
        }

        // 三个并排统计卡片：复用 StatCard 组件，只传标题/数值/强调色
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            StatCard { title: "动态"; value: "12" }
            StatCard { title: "点赞"; value: "86" }
            StatCard { title: "收藏"; value: "3"; accent: "#e57373" }
        }

        // 关于我（bio）
        Text {
            Layout.fillWidth: true
            text: "关于我"
            font.pixelSize: 16
            font.bold: true
        }

        Text {
            Layout.fillWidth: true
            text: root.friendBio
            font.pixelSize: 14
            color: "#555555"
            wrapMode: Text.WordWrap
        }

        Item { Layout.fillHeight: true }
    }
}