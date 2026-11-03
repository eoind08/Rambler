import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: Theme.sidebarBg
    property var model
    property int currentIndex: -1
    property string errorText: ""
    signal bookClicked(int index)
    signal createRequested(string name)
    signal renameRequested(int index, string name)
    signal deleteRequested(int index, string name)
    property bool creating: false
    property int renameRow: -1
    readonly property bool editing: creating || renameRow >= 0
    function startCreating() {
        errorText = ""
        renameRow = -1
        nameField.text = ""
        creating = true
        Qt.callLater(nameField.forceActiveFocus)
    }
    function startRename(row, name) {
        errorText = ""
        creating = false
        renameRow = row
        nameField.text = name
        Qt.callLater(function () { nameField.forceActiveFocus(); nameField.selectAll() })
    }
    function closeEditor() {
        creating = false
        renameRow = -1
        errorText = ""
    }
    component MenuEntry: MenuItem {
        id: entry
        property color textColor: Theme.bookText
        implicitHeight: 36

        contentItem: Text {
            text: entry.text
            color: entry.textColor
            font.family: Theme.serif
            font.pixelSize: 15
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 6
            color: entry.highlighted ? Theme.bookHover : "transparent"
        }
    }
    Menu {
        id: menu
        property int row: -1
        property string bookName: ""
        width: 170
        padding: 6
        background: Rectangle {
            color: Theme.entryBg
            radius: 10
            border.width: 1
            border.color: Theme.divider
        }
        MenuEntry {
            text: "Rename"
            onTriggered: root.startRename(menu.row, menu.bookName)
        }
        MenuEntry {
            text: "Delete"
            textColor: Theme.error
            onTriggered: root.deleteRequested(menu.row, menu.bookName)
        }
    }
    Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: Theme.divider
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        anchors.rightMargin: 13
        spacing: 12
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
            PlusButton {
                onClicked: root.creating ? root.closeEditor() : root.startCreating()
            }
        }
        TextField {
            id: nameField
            visible: root.editing
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            placeholderText: root.renameRow >= 0 ? "Rename book" : "Book name"
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
            onAccepted: {
                if (root.renameRow >= 0)
                    root.renameRequested(root.renameRow, text)
                else
                    root.createRequested(text)
            }
            onTextEdited: root.errorText = ""
            Keys.onEscapePressed: root.closeEditor()
        }
        Text {
            visible: root.errorText !== ""
            Layout.fillWidth: true
            Layout.leftMargin: 8
            text: root.errorText
            color: Theme.error
            font.pixelSize: 13
            wrapMode: Text.Wrap
        }
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
                    sourceSize: Qt.size(40, 40)
                    source: "qrc:/qt/qml/Rambler/assets/book-open.svg"
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: icon.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    text: row.name
                    elide: Text.ElideRight
                    color: Theme.bookText
                    font.family: Theme.serif
                    font.pixelSize: 16
                }
                HoverHandler { id: rowHover }
                TapHandler {   
                    onTapped: root.bookClicked(row.index)
                }
                TapHandler {  
                    acceptedButtons: Qt.RightButton
                    onTapped: {
                        menu.row = row.index
                        menu.bookName = row.name
                        menu.popup()
                    }
                }
            }
        }
        Item {
            id: folder
            Layout.alignment: Qt.AlignBottom
            implicitWidth: 34
            implicitHeight: 32
            Rectangle {
                anchors.fill: parent
                radius: 8
                color: hover.hovered ? Theme.bookHover : "transparent"
            }
            Image {
                anchors.centerIn: parent
                source: "qrc:/qt/qml/Rambler/assets/folder.svg"
                width: 22
                height: 22
                sourceSize: Qt.size(44, 44)
            }
            HoverHandler {
                id: hover
            }
            TapHandler {
                onTapped: Qt.openUrlExternally("file:///" + books.rootPath)
            }
        }
    }

}