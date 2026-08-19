import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtCore
import QuickApp

// ============================================================================
// TechniquesLab.qml —— QML 技巧实验室
//
// 面向"熟 QtWidgets、刚接触 Qt Quick"的开发者。每一节 = 一个 QtWidgets 里
// 不存在的（或写法完全不同的）技术点，卡片里都有注释对照说明。
//
// 目录：
//   1) 属性绑定 vs 命令式赋值          —— QML 最核心的心法 + 最容易踩的坑
//   2) State + Transition              —— 声明式状态机（替代手动 setVisible/setGeometry）
//   3) Repeater + GridLayout           —— 声明式循环生成控件（替代 for + new）
//   4) ListModel 动态增删              —— 纯 QML 端内存数据（替代临时容器+手动刷新）
//   5) Drag & Drop                     —— 声明式拖放（替代 dragEnterEvent/dropEvent）
//   6) Timer + 属性动画                —— QML 里的 QTimer / QPropertyAnimation
//   7) MultiEffect                     —— GPU 特效（Qt 6.5+，替代 QGraphicsDropShadowEffect）
//   8) 底部用到的 Settings             —— QML 端持久化（替代 QSettings）
//
// 这个页面由 MainWindow 顶部的"QML 技巧实验室"按钮 push 进 StackView。
// ============================================================================
Item {
    id: root

    // ---- 页面级共享状态 ----
    // 第 3 节（点色块）和第 5 节（拖色块）共用同一个"当前选中色"。
    // 教学点：属性就是共享变量，任何一处改动，所有引用处自动刷新——不用手动通知。
    // 用 string 而不用 color 类型：方便与 JS 数组里的字符串比较、也方便 Settings 存取。
    property string selectedColor: "#e57373"

    // ---- 持久化：QtCore.Settings（Qt 6.5+）----
    // 等价 C++ 的 QSettings。property alias 把设置项"挂"到 root.selectedColor 上：
    // 属性一变就自动写盘，下次启动自动读回。main.cpp 里设置了 organizationName
    // 和 applicationName，Settings 才知道该写到哪个文件。
    Settings {
        property alias selectedColor: root.selectedColor
    }

    // ---- 快捷键 ----
    // QML 的 Shortcut 等价 QShortcut；页面在栈顶时，按 Esc 就能返回。
    Shortcut {
        sequence: "Esc"
        onActivated: root.StackView.view.pop()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // 顶部：返回 + 标题
        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "← 返回"
                onClicked: root.StackView.view.pop()
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "QML 技巧实验室"
                font.pixelSize: 18
                font.bold: true
            }

            Text {
                text: "（QtWidgets 开发者对照实验）"
                font.pixelSize: 12
                color: "#9ca3af"
            }
        }

        // Flickable ≈ QScrollArea：内容放进普通布局，滚动由框架接管，
        // 只需声明 contentWidth / contentHeight（可滚动范围）。
        Flickable {
            id: flick
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: labCol.implicitHeight
            ScrollBar.vertical: ScrollBar {}

            ColumnLayout {
                id: labCol
                width: flick.width
                spacing: 14

                // ==================== 1) 属性绑定 vs 命令式赋值 ====================
                SectionCard {
                    title: "1) 属性绑定 vs 命令式赋值"
                    note: "QML 里 text: slider.value 是声明式绑定：源变化 → 目标自动更新。注意：任何在 JS 里对属性执行 '=' 赋值，都会立刻抹掉这条绑定——这是从 Widgets 转过来最容易踩的坑。"

                    Slider {
                        id: demoSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: 40
                    }

                    Row {
                        spacing: 8
                        Layout.fillWidth: true

                        Text { text: "绑定："; color: "#6b7280" }
                        // 声明式绑定：demoSlider.value 一变，这里自动跟着变
                        Text { id: boundLabel; text: demoSlider.value.toFixed(0); font.bold: true }

                        Text { text: "　JS赋值："; color: "#6b7280" }
                        // 只在创建时被 JS 赋了一次值，之后再不自动更新
                        Text {
                            id: assignedLabel
                            text: demoSlider.value.toFixed(0)
                            font.bold: true
                            color: "#d97706"
                            Component.onCompleted: assignedLabel.text = demoSlider.value.toFixed(0)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                        color: "#b45309"
                        text: bindButton.broken
                            ? "boundLabel 的绑定已被 JS 破坏：现在拖滑块它不再变化。点按钮用 Qt.binding() 恢复。"
                            : "现在拖滑块：boundLabel 实时变化；assignedLabel 保持创建时的值不动。"
                    }

                    Button {
                        id: bindButton
                        Layout.fillWidth: true
                        property bool broken: false
                        text: broken ? "恢复绑定（用 Qt.binding 重新声明）" : "用 JS 给 boundLabel 赋值（演示破坏绑定）"
                        onClicked: {
                            if (broken) {
                                // Qt.binding() 是唯一能"重新建立"声明式绑定的手段。
                                // 对应 Widgets 思路：把 setter 里 connect 的信号重新连上。
                                boundLabel.text = Qt.binding(function() { return demoSlider.value.toFixed(0) })
                            } else {
                                // 命令式赋值：这一行执行后，原来的声明式绑定就没了。
                                boundLabel.text = demoSlider.value.toFixed(0)
                            }
                            broken = !broken
                        }
                    }
                }

                // ==================== 2) State + Transition ====================
                SectionCard {
                    title: "2) State + Transition：声明式状态机"
                    note: "Widgets 里切换界面状态 = 手动 setVisible / setGeometry + 自己启动动画。QML 用 states 描述'每种状态长什么样'，用 transitions 描述'状态之间怎么过渡'，中间过程交给框架。"

                    Rectangle {
                        id: stateBox
                        Layout.fillWidth: true
                        // 高度/颜色直接绑定到 state 字符串：这是最直白的写法
                        Layout.preferredHeight: stateBox.state === "expanded" ? 150 : 70
                        radius: 8
                        color: stateBox.state === "expanded" ? "#e0f2fe" : "#f1f5f9"
                        border.color: "#bae6fd"

                        // 声明两种状态。更"地道"的写法是用 PropertyChanges 把状态差异集中在一处：
                        //   State { name: "expanded"
                        //           PropertyChanges { target: stateBox; Layout.preferredHeight: 150 } }
                        // 这里直接让绑定引用 state，效果等价，代码更少。
                        states: [
                            State { name: "" },
                            State { name: "expanded" }
                        ]

                        // 状态切换时自动对指定属性做动画，而不是瞬间跳变
                        transitions: Transition {
                            NumberAnimation { properties: "Layout.preferredHeight"; duration: 300; easing.type: Easing.InOutQuad }
                            ColorAnimation { duration: 300 }
                        }

                        Column {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            Row {
                                spacing: 8

                                Button {
                                    text: stateBox.state === "expanded" ? "收起 ▲" : "展开 ▼"
                                    onClicked: stateBox.state = stateBox.state === "expanded" ? "" : "expanded"
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "在两种 state 间切换，高度/颜色动画过渡"
                                    color: "#6b7280"
                                }
                            }

                            Text {
                                visible: stateBox.state === "expanded"
                                text: "我是展开后才出现的附加内容（这类差异也能交给 PropertyChanges 统一管理）。"
                                color: "#0369a1"
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                // ==================== 3) Repeater + GridLayout ====================
                SectionCard {
                    title: "3) Repeater：声明式循环生成控件"
                    note: "Widgets 里动态生成 N 个控件要 for 循环 new 出来再手工排布、手工记指针。QML 里给 model 传一个数组，Repeater 自动克隆 delegate，位置交给 GridLayout。"

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        columns: 4
                        columnSpacing: 8
                        rowSpacing: 8

                        // model 直接给一个 JS 数组 → 8 个色块自动生成。
                        // delegate 是被克隆的"模板"，array 模式下用 modelData 取当前元素。
                        Repeater {
                            model: ["#e57373", "#64b5f6", "#81c784", "#ffb74d",
                                    "#9575cd", "#4dd0e1", "#f06292", "#a1887f"]

                            delegate: Rectangle {
                                required property string modelData
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: 8
                                color: modelData
                                border.width: 2
                                border.color: root.selectedColor === modelData ? "#111827" : "transparent"

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.selectedColor = modelData
                                }
                            }
                        }
                    }

                    Row {
                        spacing: 8
                        Layout.fillWidth: true

                        Text { text: "当前选中色："; color: "#6b7280" }

                        Rectangle {
                            width: 24
                            height: 24
                            radius: 4
                            color: root.selectedColor
                            border.color: "#d1d5db"
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        font.pixelSize: 12
                        color: "#6b7280"
                        text: "点色块会改预览色；用顶部 Settings 声明持久化后，重启 App 也记得住。"
                    }
                }

                // ==================== 4) ListModel 动态增删 ====================
                SectionCard {
                    title: "4) 纯 QML 的 ListModel：页面内临时数据"
                    note: "FriendsModel 是 C++ 的 QAbstractListModel（适合跨页面共享/持久的数据）。如果数据只在当前页面内部临时用，用 QML 内置 ListModel 更省事：append / remove 之后 UI 自动刷新，完全不用写 beginInsertRows 那一套。"

                    ListModel { id: messageModel }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        TextField {
                            id: messageInput
                            Layout.fillWidth: true
                            placeholderText: "写一条留言…"
                            onAccepted: addButton.clicked()
                        }

                        Button {
                            id: addButton
                            text: "添加"
                            onClicked: {
                                if (messageInput.text.trim().length === 0)
                                    return
                                messageModel.append({
                                    text: messageInput.text,
                                    time: new Date().toLocaleTimeString()
                                })
                                messageInput.text = ""
                            }
                        }
                    }

                    ListView {
                        id: messageList
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        clip: true
                        spacing: 6
                        model: messageModel

                        delegate: Rectangle {
                            id: msgRow
                            required property string text
                            required property string time
                            required property int index

                            width: messageList.width
                            height: 36
                            radius: 6
                            color: "#f1f5f9"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 6
                                spacing: 8

                                Text {
                                    Layout.fillWidth: true
                                    text: msgRow.text
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: msgRow.time
                                    color: "#9ca3af"
                                    font.pixelSize: 11
                                }

                                Button {
                                    implicitWidth: 24
                                    implicitHeight: 24
                                    text: "✕"
                                    onClicked: messageModel.remove(msgRow.index)
                                }
                            }
                        }
                    }
                }

                // ==================== 5) Drag & Drop ====================
                SectionCard {
                    title: "5) Drag & Drop：拖放交换数据"
                    note: "Widgets 里要重写 dragEnterEvent / dropEvent + QMimeData。QML 里给 Item 配 Drag 三件套 + 一个 DropArea 就完成，几行声明式代码。"

                    Row {
                        spacing: 12
                        Layout.fillWidth: true

                        Repeater {
                            model: ["#e57373", "#64b5f6", "#81c784", "#ffb74d"]

                            delegate: Item {
                                id: tile
                                required property string modelData

                                width: 40
                                height: 40

                                // Drag 三件套：把"我是可拖拽的 + 拖的是什么数据"挂在 Item 上
                                Drag.active: tileMouse.drag.active           // 由 MouseArea 驱动拖拽状态
                                Drag.hotSpot: Qt.point(width / 2, height / 2) // 拖拽中心对准鼠标
                                Drag.mimeData: { "text/plain": modelData }    // 类比 QMimeData

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 8
                                    color: modelData
                                }

                                MouseArea {
                                    id: tileMouse
                                    anchors.fill: parent
                                    drag.target: tile          // 让这个 MouseArea 负责移动 tile
                                    onReleased: tile.Drag.drop() // 松手时把数据交给 DropArea
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        color: "#6b7280"
                        text: "拖一个色块到下方色板（悬停时色板会高亮）："
                    }

                    // DropArea ≈ dropEvent 处理区；onEntered/onExited 类比 dragEnterEvent/dragLeaveEvent
                    DropArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56

                        property bool hovered: false

                        onEntered: hovered = true
                        onExited: hovered = false
                        onDropped: {
                            root.selectedColor = drop.getDataAsString("text/plain")
                            hovered = false
                            drop.accept()
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: parent.hovered ? "#ede9fe" : "#f1f5f9"
                            border.color: parent.hovered ? "#8b5cf6" : "#d1d5db"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "色板（当前：" + root.selectedColor + "）"
                                color: parent.hovered ? "#6d28d9" : "#6b7280"
                            }
                        }
                    }
                }

                // ==================== 6) Timer + 属性动画 ====================
                SectionCard {
                    title: "6) Timer + 属性动画"
                    note: "Timer 就是 QML 里的 QTimer；属性动画可以直接挂在属性旁（on scale / on opacity…），不用像 Widgets 那样在 C++ 里 new QPropertyAnimation 并手工管理生命周期。"

                    Timer {
                        id: countdownTimer
                        interval: 1000
                        repeat: true
                        property int remaining: 10
                        onTriggered: {
                            remaining -= 1
                            if (remaining <= 0)
                                stop()
                        }
                    }

                    Row {
                        spacing: 12
                        Layout.fillWidth: true

                        Button {
                            text: countdownTimer.remaining > 0 ? "倒计时 " + countdownTimer.remaining + "s" : "重新开始"
                            onClicked: {
                                countdownTimer.remaining = 10
                                countdownTimer.start()
                            }
                        }

                        ProgressBar {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 180
                            from: 0
                            to: 10
                            value: countdownTimer.remaining
                        }
                    }

                    Row {
                        spacing: 16
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "无限脉冲缩放："
                            color: "#6b7280"
                        }

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: "#3b82f6"

                            // "on <属性> 动画"：动画直接挂在 scale 上，running 即播放。
                            // loops: Animation.Infinite 让它永续循环（等价 Widgets 里反复重启 QPropertyAnimation）
                            SequentialAnimation on scale {
                                running: true
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.25; duration: 500; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 1.0;  duration: 500; easing.type: Easing.InOutQuad }
                            }
                        }
                    }
                }

                // ==================== 7) MultiEffect ====================
                SectionCard {
                    title: "7) MultiEffect：GPU 特效（Qt 6.5+）"
                    note: "阴影 / 模糊 / 变色一条声明搞定，底层是 shader。Widgets 里做阴影要 QGraphicsDropShadowEffect 或自己拼图，QML 里这是内置标配。"

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        Rectangle {
                            id: effectSource
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 80
                            radius: 12
                            color: "#6366f1"

                            Text {
                                anchors.centerIn: parent
                                text: "源"
                                color: "white"
                                font.bold: true
                            }
                        }

                        MultiEffect {
                            // source 指定被特效处理的元素，自身负责把特效结果画出来
                            source: effectSource
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 80
                            shadowEnabled: true
                            shadowColor: "#50000000"
                            shadowBlur: 0.6
                            shadowVerticalOffset: 6
                            // 注释里的选项也都能开：blurEnabled: true; blur: 0.1
                        }

                        Text {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: "#6b7280"
                            text: "左图是原始色块，右图是 MultiEffect 加了投影阴影后的效果。"
                        }
                    }
                }
            }
        }
    }
}
