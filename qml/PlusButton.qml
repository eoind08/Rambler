import QtQuick

Item {
    id: root
    property int size: 28
    signal clicked()
    implicitWidth: size
    implicitHeight: size
    Rectangle {
        anchors.fill: parent
        radius: 8
        color: hover.hovered ? Theme.bookHover : "transparent"
    }
    Text {
        anchors.centerIn: parent
        text: "+"
        color: Theme.bookText
        font.pixelSize: root.size * 0.8
    }
    HoverHandler { id: hover }
    TapHandler { onTapped: root.clicked() }
}