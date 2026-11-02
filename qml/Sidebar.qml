import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: Theme.sidebarBg

    // ---- public interface ----
    property var model
    property int currentIndex: 0
    property string errorText: ""
    signal bookClicked(int index)
    signal createRequested(string name)

    // ---- private state ----
    property bool creating: false

    onCreatingChanged: {
        if (creating) {
            errorText = ""
            nameField.clear()
            Qt.callLater(nameField.forceActiveFocus)   // field must be visible before it can take focus
        }
    }

    // a successful createBook() inserts a row: close the field then.
    // On failure no row is added, so the field stays open and the error shows.
    Connections {
        target: root.model
        function onRowsInserted() {
            root.creating = false
            root.errorText = ""
        }
    }

    // right-hand divider
    Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: Theme.divider
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        anchors.rightMargin: 13          // leaves room for the divider
        spacing: 12

        // ---- header: "Books" ......... "+" ----
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 8

            Text {
                text: "Books"
                color: Theme.entryText
                font.family: Theme.serif
                font.pixelSize: 20
                Layout.fillWidth: true
            }

            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: plusHover.hovered ? Theme.bookHover : "transparent"
                }
                Text {
                    anchors.centerIn: parent
                    text: "+"
                    color: Theme.bookText
                    font.pixelSize: 22
                }
                HoverHandler { id: plusHover }
                TapHandler { onTapped: root.creating = !root.creating }
            }
        }

        // ---- new-book name field ----
        TextField {
            id: nameField
            visible: root.creating
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            placeholderText: "Book name"
            placeholderTextColor: Theme.bookText
            color: Theme.entryText
            selectionColor: Theme.bookSelected
            selectedTextColor: Theme.entryText
            font.family: Theme.serif
            font.pixelSize: 16
            leftPadding: 14
            rightPadding: 14
            selectByMouse: true

            background: Rectangle {
                radius: 10
                color: Theme.bookHover
                border.width: 1
                border.color: nameField.activeFocus ? Theme.timeline : "transparent"
            }

            onAccepted: root.createRequested(text)      // Enter
            onTextEdited: root.errorText = ""           // typing clears a stale error
            Keys.onEscapePressed: root.creating = false
        }

        Text {
            visible: root.creating && root.errorText !== ""
            Layout.fillWidth: true
            Layout.leftMargin: 8
            text: root.errorText
            color: Theme.error
            font.pixelSize: 13
            wrapMode: Text.Wrap
        }

        // ---- the books ----
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.model
            spacing: 4
            clip: true

            delegate: Rectangle {
                id: row
                required property int index
                required property string name

                width: ListView.view.width
                height: 44
                radius: 10
                color: index === root.currentIndex ? Theme.bookSelected
                     : rowHover.hovered ? Theme.bookHover
                     : "transparent"

                Image {
                    id: icon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    width: 20
                    height: 20
                    sourceSize: Qt.size(40, 40)       // 2x for sharpness on high-DPI
                    source: "qrc:/qt/qml/Rambler/assets/book-open.svg"
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: icon.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    text: row.name
                    elide: Text.ElideRight            // long names get "..."
                    color: Theme.bookText
                    font.family: Theme.serif
                    font.pixelSize: 16
                }

                HoverHandler { id: rowHover }
                TapHandler { onTapped: root.bookClicked(row.index) }
            }
        }
    }
}