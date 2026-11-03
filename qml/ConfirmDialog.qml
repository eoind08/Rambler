import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root
    property string title
    property string message
    property string confirmText: "Delete"
    signal confirmed()
    modal: true
    anchors.centerIn: Overlay.overlay
    width: 380
    padding: 24
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    Overlay.modal: Rectangle { color: "#99000000" }
    background: Rectangle {
        color: Theme.entryBg
        radius: Theme.radius
        border.width: 1
        border.color: Theme.divider
    }
    component DialogButton: Button {
        id: b
        property bool danger: false
        implicitHeight: 36
        implicitWidth: Math.max(80, contentItem.implicitWidth + 32)
        contentItem: Text {
            text: b.text
            color: b.danger ? Theme.error : Theme.entryText
            font.family: Theme.serif
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 8
            color: b.hovered ? Theme.bookSelected : Theme.bookHover
        }
    }
    contentItem: ColumnLayout {
        spacing: 12
        Text {
            Layout.fillWidth: true
            text: root.title
            wrapMode: Text.Wrap
            color: Theme.entryText
            font.family: Theme.serif
            font.pixelSize: 20
        }
        Text {
            Layout.fillWidth: true
            text: root.message
            wrapMode: Text.Wrap
            color: Theme.editorText
            font.family: Theme.serif
            font.pixelSize: 15
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 12
            spacing: 8
            Item { Layout.fillWidth: true }
            DialogButton { text: "Cancel"; onClicked: root.close() }
            DialogButton {
                text: root.confirmText
                danger: true
                onClicked: { root.close(); root.confirmed() }
            }
        }
    }
}