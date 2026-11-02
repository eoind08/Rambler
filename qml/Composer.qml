import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    signal submitted(string text)
    property int minHeight: 130
    property int maxHeight: 280
    readonly property int pad: 16
    color: Theme.entryBg
    radius: Theme.radius
    implicitHeight: Math.min(maxHeight,
        Math.max(minHeight, input.implicitHeight + toolbar.implicitHeight + 3 * pad))
    function submit() {
        const t = input.text.trim()
        if (t === "") return
        submitted(t)
        input.clear()
        input.forceActiveFocus()
    }
    function wrap(prefix, suffix) {
        const start = input.selectionStart
        const end = input.selectionEnd
        if (start === end) {
            input.insert(start, prefix + suffix)
            input.cursorPosition = start + prefix.length
        } else {
            const sel = input.selectedText
            input.remove(start, end)
            input.insert(start, prefix + sel + suffix)
            input.select(start + prefix.length, start + prefix.length + sel.length)
        }
        input.forceActiveFocus()
    }
    function link() {
        const start = input.selectionStart
        const end = input.selectionEnd
        const label = end > start ? input.selectedText : "text"
        input.remove(start, end)
        input.insert(start, "[" + label + "](url)")
        const urlStart = start + label.length + 3
        input.select(urlStart, urlStart + 3)
        input.forceActiveFocus()
    }
    function prefixLine(prefix) {
        const pos = input.cursorPosition
        const lineStart = pos === 0 ? 0 : input.text.lastIndexOf("\n", pos - 1) + 1
        input.insert(lineStart, prefix)
        input.cursorPosition = pos + prefix.length
        input.forceActiveFocus()
    }
    component ToolBtn: Item {
        id: btn
        property string label
        property bool bold: false
        property bool italic: false
        signal clicked()
        implicitWidth: 34
        implicitHeight: 32
        Rectangle {
            anchors.fill: parent
            radius: 8
            color: hover.hovered ? Theme.bookHover : "transparent"
        }
        Text {
            anchors.centerIn: parent
            text: btn.label
            color: Theme.editorText
            font.family: Theme.serif
            font.pixelSize: 16
            font.bold: btn.bold
            font.italic: btn.italic
        }
        HoverHandler { id: hover }
        TapHandler { onTapped: btn.clicked() }
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.pad
        spacing: 8
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            TextArea {
                id: input
                placeholderText: "Write something..."
                placeholderTextColor: Theme.editorText
                color: Theme.editorText
                selectionColor: Theme.sidebarBg
                font.family: Theme.serif
                font.pixelSize: 16
                wrapMode: TextArea.Wrap
                persistentSelection: true
                background: null
                padding: 0
                Keys.onPressed: (event) => {
                    const isEnter = event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                    if (isEnter && (event.modifiers & Qt.ControlModifier)) {
                        root.submit()
                        event.accepted = true
                    }
                }
            }
        }
        RowLayout {
            id: toolbar
            Layout.fillWidth: true
            spacing: 2
            ToolBtn { label: "B"; bold: true;   onClicked: root.wrap("**", "**") }
            ToolBtn { label: "I"; italic: true; onClicked: root.wrap("*", "*") }
            ToolBtn { label: "Link";            onClicked: root.link(); implicitWidth: 44 }
            ToolBtn { label: "List";            onClicked: root.prefixLine("- "); implicitWidth: 44 }
            Item { Layout.fillWidth: true }
            Rectangle {
                implicitWidth: hint.implicitWidth + 24
                implicitHeight: 28
                radius: 14
                color: Theme.bookHover
                Text {
                    id: hint
                    anchors.centerIn: parent
                    text: "Ctrl + Enter to submit"
                    color: Theme.editorText
                    font.pixelSize: 12
                }
            }
            ToolBtn { label: "Send"; implicitWidth: 48; onClicked: root.submit() }
        }
    }
}