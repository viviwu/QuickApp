import QtQuick
import QtQuick.Layouts

// ============================================================================
// SectionCard —— "标题 + 说明 + 任意内容"的卡片组件，供 TechniquesLab 复用。
//
// 教学点 1：default property alias —— QML 的"默认属性"。
//   有了它，使用方可以像写普通 Item 一样直接把子元素塞进组件里：
//       SectionCard { Slider { ... } Button { ... } }
//   这些子元素自动进入 content（即下面 cardContent.data），这就是
//   Text / Row 等类型"children 直接写在里面"的原理。
//
// 教学点 2：Rectangle / Item 不会像 QWidget 那样自动包住子控件。
//   高度必须自己算（implicitHeight = 内容 + 边距）。这是 Widgets 转 QML
//   常见的困惑之一。
// ============================================================================
Rectangle {
    id: card

    Layout.fillWidth: true
    radius: 8
    color: "#f8fafc"
    border.color: "#e3e7ec"
    border.width: 1

    implicitHeight: cardContent.implicitHeight + 28

    // ---- 对外属性 ----
    default property alias content: cardContent.data
    property string title: ""
    property string note: ""

    ColumnLayout {
        id: cardContent
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Text {
            visible: card.title.length > 0
            text: card.title
            font.pixelSize: 15
            font.bold: true
            color: "#1f2937"
        }

        Text {
            visible: card.note.length > 0
            text: card.note
            font.pixelSize: 12
            color: "#6b7280"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
}