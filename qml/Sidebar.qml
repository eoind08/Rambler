import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    color: Theme.sidebarBg
    property int currentIndex: 0
    property var books: ["Personal", "University", "Ideas", "Archive"]
    signal addClicked()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Text {
                text: "Books"
                color: Theme.bookText
                font.family: Theme.serif
                font.pixelSize: 16
                Layout.fillWidth: true
            }
            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                Text {
                    anchors.centerIn: parent
                    text: "+"
                    color: Theme.bookText
                    font.pixelSize: 24
                }
                TapHandler { onTapped: root.addClicked() }
            }
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.books
            spacing: 4
            clip: true
            delegate: Rectangle {
                required property int index
                required property string modelData
                width: ListView.view.width
                height: 44
                radius: 10
                color: index === root.currentIndex ? Theme.bookSelected
                     : hover.hovered ? Theme.bookHover
                     : "transparent"
                Image {
                  id: icon
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.left: parent.left
                  anchors.leftMargin: 16
                  source: "qrc:/qt/qml/Rambler/assets/book-open.svg"
                  sourceSize: Qt.size(20, 20)
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: icon.right
                    anchors.leftMargin: 12
                    text: modelData
                    color: Theme.bookText
                    font.family: Theme.serif
                    font.pixelSize: 16
                }
                HoverHandler { id: hover }
                TapHandler { onTapped: root.currentIndex = index }
            }
        }
    }
}