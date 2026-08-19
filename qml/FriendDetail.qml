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

        // 头部：头像 + 名字/状态，演示 RowLayout + ColumnLayout 嵌套
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Rectangle {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                radius: 32
                color: root.friendAvatarColor

                Text {
                    anchors.centerIn: parent
                    text: root.friendName.length ? root.friendName.charAt(0) : "?"
                    color: "white"
                    font.pixelSize: 28
                    font.bold: true
                }
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

        // 三个并排统计卡片：演示 RowLayout 均分约束（Layout.fillWidth + Layout.columnStretch）
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                id: statCard
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
                        text: "动态"
                        font.pixelSize: 12
                        color: "#888888"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "12"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#333333"
                    }
                }
            }

            Rectangle {
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
                        text: "点赞"
                        font.pixelSize: 12
                        color: "#888888"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "86"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#333333"
                    }
                }
            }

            Rectangle {
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
                        text: "收藏"
                        font.pixelSize: 12
                        color: "#888888"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "3"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#333333"
                    }
                }
            }
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