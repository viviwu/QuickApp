import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QuickApp

// 登录成功后的主界面：
//  - 顶部：欢迎语 + 本次使用时长 + 退出登录
//  - 中间：好友列表（ListView + FriendsModel），点击行 push 进 FriendDetail
//  - 休息提醒：监听 UsageTracker.restReminderTriggered，弹提醒
Item {
    id: root

    Component.onCompleted: UsageTracker.start()
    Component.onDestruction: UsageTracker.stop()

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: homePage
    }

    Component {
        id: homePage
        Item {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // 顶部：欢迎 + 使用时长 + 退出
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "欢迎，" + AppController.currentUser
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "已用 " + UsageTracker.elapsedSeconds + "s"
                        font.pixelSize: 12
                        color: "#888888"
                    }

                    Button {
                        text: "退出登录"
                        onClicked: AppController.logout()
                    }
                }

                // 好友列表
                ListView {
                    id: friendList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8

                    model: FriendsModel {}

                    delegate: Rectangle {
                        id: row
                        required property string name
                        required property string status
                        required property string avatarColor
                        required property string bio

                        width: friendList.width
                        height: 56
                        radius: 8
                        color: "#f5f7fa"
                        border.color: "#e3e7ec"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Rectangle {
                                width: 36
                                height: 36
                                radius: 18
                                color: row.avatarColor

                                Text {
                                    anchors.centerIn: parent
                                    text: row.name.length ? row.name.charAt(0) : "?"
                                    color: "white"
                                    font.bold: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: row.name
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#222222"
                                }

                                Text {
                                    text: row.status
                                    font.pixelSize: 12
                                    color: "#888888"
                                }
                            }

                            Text {
                                text: "›"
                                font.pixelSize: 22
                                color: "#cccccc"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: stackView.push("FriendDetail.qml", {
                                friendName: row.name,
                                friendStatus: row.status,
                                friendAvatarColor: row.avatarColor,
                                friendBio: row.bio,
                            })
                        }
                    }
                }
            }
        }
    }

    // 休息提醒弹窗（用 Popup 而非 Dialog，避免 Fusion 模板对自定义 contentItem 的
    // implicitWidth 绑定环问题，布局也更好控制）
    Popup {
        id: restPopup
        modal: true
        anchors.centerIn: parent
        padding: 20

        ColumnLayout {
            width: 300
            spacing: 16

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "休息提醒"
                font.pixelSize: 18
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                text: "你已经连续使用 " + UsageTracker.elapsedSeconds + " 秒，起来活动一下吧，眼睛和脖子需要休息。"
                wrapMode: Text.WordWrap
                color: "#333333"
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                text: "知道了"
                onClicked: restPopup.close()
            }
        }
    }

    // 监听 C++ 端 UsageTracker 的自定义事件信号，弹窗提醒用户休息
    Connections {
        target: UsageTracker
        function onRestReminderTriggered() {
            restPopup.open()
        }
    }
}