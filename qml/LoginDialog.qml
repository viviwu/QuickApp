import QtQuick
import QtQuick.Controls
import QuickApp

// LoginDialog 只负责展示和采集输入，不直接持有任何"业务状态"。
// 登录中/登录结果全部来自 AppController 的 property 和 signal。
Item {
    id: root

    Column {
        anchors.centerIn: parent
        spacing: 16
        width: 260

        Text {
            text: "登录"
            font.pixelSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        TextField {
            id: usernameField
            width: parent.width
            placeholderText: "邮箱（如 user@example.com）"
            // 登录请求进行中时禁止编辑，避免用户中途改输入造成困惑
            enabled: !AppController.busy

            validator: RegularExpressionValidator {
                regularExpression: /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/
            }

            property bool isValid: acceptableInput || text.length === 0

            color: isValid ? "black" : "red"

            // 边框提示错误
            background: Rectangle {
                border.color: usernameField.isValid ? "#cccccc" : "red"
                border.width: 1
                radius: 4
            }
        }

        TextField {
            id: passwordField
            width: parent.width
            placeholderText: "密码"
            echoMode: TextInput.Password
            enabled: !AppController.busy

            // 体验细节：在密码框按回车等价于点登录按钮
            Keys.onReturnPressed: loginButton.clicked()
        }

        // 登录错误次数：登录失败时变红并闪烁 5 秒，之后回到黑色
        Label {
            id: errorCountLabel
            anchors.horizontalCenter: parent.horizontalCenter
            text: "登录错误次数：" + AppController.loginErrorCount
            font.pixelSize: 13
            font.bold: false
            color: "black"

            SequentialAnimation {
                id: errorFlash
                // 变红 300ms -> 保持红色 5s -> 回到黑色 300ms
                ColorAnimation {
                    target: errorCountLabel
                    property: "color"
                    to: "#d32f2f"
                    duration: 300
                }
                PauseAnimation { duration: 5000 }
                ColorAnimation {
                    target: errorCountLabel
                    property: "color"
                    to: "black"
                    duration: 300
                }
            }
        }

        // 错误提示文本，登录失败时短暂显示
        Text {
            id: errorText
            width: parent.width
            color: "#d32f2f"
            wrapMode: Text.WordWrap
            visible: text.length > 0
            text: ""

            // 与错误次数同步变红闪烁，作为二次视觉提醒
            SequentialAnimation {
                id: errorTextFlash
                running: false
                ColorAnimation {
                    target: errorText
                    property: "color"
                    to: "#ff5252"
                    duration: 300
                }
                PauseAnimation { duration: 5000 }
                ColorAnimation {
                    target: errorText
                    property: "color"
                    to: "#d32f2f"
                    duration: 300
                }
            }
        }

        Button {
            id: loginButton
            width: parent.width
            text: AppController.busy ? "登录中…" : "登录"
            enabled: !AppController.busy && usernameField.isValid
                     && passwordField.text.length > 0

            onClicked: {
                errorText.text = ""
                AppController.login(usernameField.text, passwordField.text)
            }
        }
    }

    // 这是题目要求的核心行为：监听 C++ 端发出的 loginFailed 信号，
    // 在 LoginDialog 里清空密码输入框，展示原因，并触发红色闪烁动画。
    // 用 Connections 而不是直接在 AppController 里操作 QML 控件，
    // 保持"C++ 不知道 QML 长什么样"的边界。
    Connections {
        target: AppController
        function onLoginFailed(reason) {
            passwordField.text = ""
            errorText.text = reason
            errorCountLabel.color = "#d32f2f"
            if (errorFlash.running)
                errorFlash.stop()
            errorFlash.restart()
            if (errorTextFlash.running)
                errorTextFlash.stop()
            errorTextFlash.restart()
            passwordField.forceActiveFocus()
        }
    }
}